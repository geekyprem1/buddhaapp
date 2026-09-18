import { HttpsError, onCall } from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import { instructionFor, readBodhiConfig } from "./config";
import { OPENROUTER_API_KEY, chatCompletion } from "./openRouter";
import {
  REFUSAL_SENTINEL,
  buildMessages,
  refusalMessage,
  sanitiseHistory,
} from "./prompt";
import {
  isPremium,
  recordOffTopic,
  recordTokens,
  refundMessage,
  reserveMessage,
} from "./quota";

interface BodhiChatRequest {
  message?: unknown;
  history?: unknown;
  lang?: unknown;
}

const SUPPORTED_LANGS = new Set(["en", "hi", "mr"]);
const MAX_QUESTION_CHARS = 2000;
const DEFAULT_REPLY_MAX_TOKENS = 200;
const DEFAULT_REPLY_MAX_WORDS = 80;

/** True only when the user explicitly asks for a longer explanation. */
function requestsDetailedAnswer(question: string): boolean {
  return /\b(?:in[ -]?depth|detailed?|detail mein|deep(?:ly)?|long answer|full explanation|vistar|vistaar|sawistar|savistar|tapsheelwar|tafseel)\b|(?:विस्तार|विस्तृत|गहराई|सविस्तर|तपशीलवार)/iu
    .test(question);
}

/** Keep ordinary replies short without cutting them in the middle of a sentence. */
function shortenOrdinaryReply(content: string): string {
  const words = content.trim().split(/\s+/u);
  if (words.length <= DEFAULT_REPLY_MAX_WORDS) return content.trim();

  const prefix = words.slice(0, DEFAULT_REPLY_MAX_WORDS).join(" ");
  // Greedy match deliberately selects the last complete sentence that fits.
  const complete = prefix.match(/^[\s\S]*[.!?।](?=\s|$)/u)?.[0].trim();
  if (complete && complete.split(/\s+/u).length >= 15) return complete;

  // A provider may omit sentence punctuation. In that rare case, cap the
  // words cleanly instead of leaking an arbitrarily long reply.
  return `${prefix.replace(/[,:;\-–—]+$/u, "")}…`;
}

/**
 * The Bodhi AI chat proxy (see `.kiro/specs/bodhi-ai-chat/design.md`).
 *
 * Pipeline: auth → config gate → tier → reserve message/quota → topic gate →
 * answer → record tokens. The OpenRouter key never leaves this function; the
 * client only ever sends a question and renders the reply.
 *
 * App Check enforcement is temporarily relaxed (mirroring `guardOtpAbuse`):
 * current internal-testing builds cannot attach a Play Integrity token, so an
 * enforced App Check rejected every chat call with `unauthenticated` and the
 * user saw no reply at all. Auth is still verified below, and the per-uid
 * daily quota still meters spend; re-enable enforcement once a build that
 * passes Play Integrity is adopted.
 *
 * Streams the reply when the client accepts it (`response.sendChunk` is a safe
 * no-op otherwise), and always returns the final result map.
 */
export const bodhiChat = onCall(
  {
    region: "asia-south1",
    secrets: [OPENROUTER_API_KEY],
  },
  async (request, response) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Sign in required.");
    }
    const uid = request.auth.uid;

    const data = (request.data ?? {}) as BodhiChatRequest;
    const question = typeof data.message === "string"
      ? data.message.trim().slice(0, MAX_QUESTION_CHARS)
      : "";
    if (question.length === 0) {
      throw new HttpsError("invalid-argument", "Message is empty.");
    }
    const lang = typeof data.lang === "string" && SUPPORTED_LANGS.has(data.lang)
      ? data.lang
      : "en";

    const config = await readBodhiConfig();
    if (!config.enabled) {
      throw new HttpsError("failed-precondition", "Bodhi AI is turned off.");
    }

    const premium = await isPremium(uid);

    // Reserve one message up front (checks seconds, message cap, strike cap).
    // Refunded below if the question turns out to be off-topic.
    const charge = await reserveMessage({ uid, isPremium: premium, config });

    // Scope is enforced by the answering call itself, via the hardcoded
    // preamble in `buildMessages` — an off-topic question comes back as
    // REFUSAL_SENTINEL and is handled below.
    //
    // There used to be a cheap classifier pre-pass here. It was removed: the
    // model is a reasoning model, so a small-budget classifier call spends its
    // tokens on chain-of-thought and returns empty content, which made the
    // gate's fail-closed path refuse *every* question — including plainly
    // Buddhist ones. Disabling reasoning fixed the classifier in isolation but
    // the pre-pass was never load-bearing: the preamble already refuses
    // off-topic requests on its own (verified against prod). Dropping it also
    // halves the per-message cost and latency.
    const messages = buildMessages({
      lang,
      adminInstruction: instructionFor(config, lang),
      history: sanitiseHistory(data.history),
      question,
    });

    // Answer. A provider failure — or an empty reply — refunds the reserved
    // message (A3/N5): the user must not pay quota for an answer they never
    // got. The original error is rethrown so the client shows "try again"
    // instead of a paywall.
    let result;
    try {
      const detailedAnswer = requestsDetailedAnswer(question);
      const outputTokenBudget = detailedAnswer
        ? config.maxTokens
        : Math.min(config.maxTokens, DEFAULT_REPLY_MAX_TOKENS);
      result = await chatCompletion({
        model: config.model,
        messages,
        maxTokens: outputTokenBudget,
        temperature: config.temperature,
        // Bodhi Chat favours quick, concise guidance over a hidden reasoning
        // pass. This also leaves the full completion budget for visible text.
        disableReasoning: true,
      });
      if (!detailedAnswer) {
        result = {
          ...result,
          content: shortenOrdinaryReply(result.content),
        };
      }
      if (result.content.length === 0) {
        throw new HttpsError("unavailable", "The AI returned an empty reply.");
      }
    } catch (err) {
      await refundMessage({ uid, isPremium: premium, config, day: charge.day });
      // The refund is silent to the user, so without this line a persistent
      // answering failure looks like "the app just doesn't reply".
      logger.error("bodhiChat: answering failed, message refunded", {
        code: err instanceof HttpsError ? err.code : undefined,
        message: err instanceof Error ? err.message : String(err),
        model: config.model,
        lang,
      });
      if (err instanceof HttpsError) throw err;
      throw new HttpsError("unavailable", "Could not reach the AI.");
    }

    // Off-topic detection (A5). The scope preamble makes the model reply with
    // just the sentinel; never show it raw and never charge a message for it.
    // Refund the reserved message and record a strike — with the classifier
    // pre-pass gone this is the only off-topic signal, so the strike counter
    // (and the lockout it feeds in `reserveMessage`) has to be driven here,
    // otherwise the refusal path could be farmed for free.
    if (result.content.includes(REFUSAL_SENTINEL)) {
      const remaining = await recordOffTopic({
        uid,
        isPremium: premium,
        config,
        day: charge.day,
      });
      const reply = refusalMessage(lang);
      if (request.acceptsStreaming && response) {
        response.sendChunk(reply);
      }
      return {
        reply,
        onTopic: false,
        remainingMessages: remaining.remainingMessages,
      };
    }

    // The answering call is non-streamed upstream; emit it as one chunk so the
    // client's streaming path still receives text before the final result.
    if (request.acceptsStreaming && response && result.content.length > 0) {
      response.sendChunk(result.content);
    }

    await recordTokens({
      uid,
      promptTokens: result.usage.promptTokens,
      completionTokens: result.usage.completionTokens,
      day: charge.day,
    });

    return {
      reply: result.content,
      onTopic: true,
      remainingMessages: charge.remaining.remainingMessages,
    };
  },
);
