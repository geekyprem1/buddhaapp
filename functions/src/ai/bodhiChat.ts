import { HttpsError, onCall } from "firebase-functions/v2/https";
import { instructionFor, readBodhiConfig } from "./config";
import { OPENROUTER_API_KEY, chatCompletion } from "./openRouter";
import { buildMessages, refusalMessage, sanitiseHistory } from "./prompt";
import {
  isPremium,
  recordOffTopic,
  recordTokens,
  reserveMessage,
} from "./quota";
import { isOnTopic } from "./topicGate";

interface BodhiChatRequest {
  message?: unknown;
  history?: unknown;
  lang?: unknown;
}

const SUPPORTED_LANGS = new Set(["en", "hi", "mr"]);
const MAX_QUESTION_CHARS = 2000;

/**
 * The Bodhi AI chat proxy (see `.kiro/specs/bodhi-ai-chat/design.md`).
 *
 * Pipeline: auth → App Check → config gate → tier → reserve message/quota →
 * topic gate → answer → record tokens. The OpenRouter key never leaves this
 * function; the client only ever sends a question and renders the reply.
 *
 * `enforceAppCheck` is true because this endpoint spends money per call — an
 * unauthenticated script hitting it would be a direct billing attack. It is
 * the first function in this codebase to enforce App Check; the other six
 * callables are unaffected (enforcement is per-function).
 *
 * Streams the reply when the client accepts it (`response.sendChunk` is a safe
 * no-op otherwise), and always returns the final result map.
 */
export const bodhiChat = onCall(
  {
    region: "asia-south1",
    secrets: [OPENROUTER_API_KEY],
    enforceAppCheck: true,
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

    // Topic gate. Fails closed (off-topic) on any classifier error.
    const onTopic = await isOnTopic({ model: config.model, question });
    if (!onTopic) {
      const remaining = await recordOffTopic({
        uid,
        isPremium: premium,
        config,
      });
      const reply = refusalMessage(lang);
      // Stream the refusal too, so the client renders it the same way.
      if (request.acceptsStreaming && response) {
        response.sendChunk(reply);
      }
      return {
        reply,
        onTopic: false,
        remainingSeconds: remaining.remainingSeconds,
        remainingMessages: remaining.remainingMessages,
      };
    }

    // Answer.
    const messages = buildMessages({
      lang,
      adminInstruction: instructionFor(config, lang),
      history: sanitiseHistory(data.history),
      question,
    });

    const result = await chatCompletion({
      model: config.model,
      messages,
      maxTokens: config.maxTokens,
      temperature: config.temperature,
    });

    // The answering call is non-streamed upstream; emit it as one chunk so the
    // client's streaming path still receives text before the final result.
    if (request.acceptsStreaming && response && result.content.length > 0) {
      response.sendChunk(result.content);
    }

    await recordTokens({
      uid,
      promptTokens: result.usage.promptTokens,
      completionTokens: result.usage.completionTokens,
    });

    return {
      reply: result.content,
      onTopic: true,
      remainingSeconds: charge.remaining.remainingSeconds,
      remainingMessages: charge.remaining.remainingMessages,
    };
  },
);
