import { HttpsError } from "firebase-functions/v2/https";
import { defineSecret } from "firebase-functions/params";
import * as logger from "firebase-functions/logger";
import type { ChatMessage } from "./prompt";

/**
 * The one real secret in this backend. Set out of band, never committed:
 *   firebase functions:secrets:set OPENROUTER_API_KEY --project <proj>
 * Attach to a function via `secrets: [OPENROUTER_API_KEY]`.
 */
export const OPENROUTER_API_KEY = defineSecret("OPENROUTER_API_KEY");

const ENDPOINT = "https://openrouter.ai/api/v1/chat/completions";
const REQUEST_TIMEOUT_MS = 45_000;

/**
 * Attribution headers OpenRouter uses for its dashboard rankings.
 *
 * ASCII ONLY. HTTP header values are byte strings (ISO-8859-1), so any
 * character above U+00FF makes `fetch` throw a `TypeError` before the request
 * is even sent. This title previously used an em dash, which failed *every*
 * call — silently, because the throw was translated into a generic
 * "could not reach the AI" and the reserved message was refunded. Keep
 * [asciiHeader] between these constants and the request so a stray typographic
 * character can never take the feature down again.
 */
const REFERER = "https://dhammapath.app";
const TITLE = "Dhamma Path - Bodhi AI";

/**
 * Strips anything a header value cannot legally carry: characters outside
 * Latin-1, plus CR/LF (which would be a header-injection vector).
 */
function asciiHeader(value: string): string {
  return value
    .replace(/[\r\n]/g, " ")
    .replace(/[^\x20-\x7E]/g, "-")
    .trim();
}

export interface ChatUsage {
  promptTokens: number;
  completionTokens: number;
}

export interface ChatResult {
  content: string;
  usage: ChatUsage;
}

interface OpenRouterChoice {
  message?: { content?: string };
}

interface OpenRouterResponse {
  choices?: OpenRouterChoice[];
  usage?: { prompt_tokens?: number; completion_tokens?: number };
}

interface ChatCompletionParams {
  model: string;
  messages: ChatMessage[];
  maxTokens: number;
  temperature: number;
  /** When set, asks for a strict JSON object back (used by the topic gate). */
  jsonObject?: boolean;
  /**
   * Turn off the model's chain-of-thought. DeepSeek V4 is a reasoning model:
   * left on, it spends its token budget "thinking" before writing any
   * `content`. For the topic gate (a 1-token JSON answer with a tiny budget)
   * that means `content` comes back empty with `finish_reason: "length"`, so
   * JSON.parse fails and the gate wrongly fails closed. Disabling reasoning
   * makes every token go to the answer. Leave it on for the main reply, where
   * the larger budget benefits from the reasoning pass.
   */
  disableReasoning?: boolean;
}

/**
 * One non-streamed chat completion.
 *
 * Errors are normalised to `HttpsError` so callers can rethrow directly.
 * The OpenRouter key is read from Secret Manager at call time — the function
 * that uses this must declare `secrets: [OPENROUTER_API_KEY]`.
 */
export async function chatCompletion(
  params: ChatCompletionParams,
): Promise<ChatResult> {
  const key = OPENROUTER_API_KEY.value();
  if (!key) {
    logger.error("openRouter: OPENROUTER_API_KEY resolved empty");
    throw new HttpsError("failed-precondition", "AI is not configured.");
  }

  const body: Record<string, unknown> = {
    model: params.model,
    messages: params.messages,
    max_tokens: params.maxTokens,
    temperature: params.temperature,
    stream: false,
  };
  if (params.jsonObject) {
    body.response_format = { type: "json_object" };
  }
  if (params.disableReasoning) {
    body.reasoning = { enabled: false };
  }

  // The abort timer spans the whole upstream read — headers AND body (N4).
  // The fetch signal also aborts an in-progress body read, so a stalled JSON
  // payload can no longer outlive the advertised timeout.
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), REQUEST_TIMEOUT_MS);

  let response: Response;
  try {
    response = await fetch(ENDPOINT, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${key}`,
        "Content-Type": "application/json",
        "HTTP-Referer": asciiHeader(REFERER),
        "X-Title": asciiHeader(TITLE),
      },
      body: JSON.stringify(body),
      signal: controller.signal,
    });
  } catch (err) {
    clearTimeout(timer);
    const aborted = err instanceof Error && err.name === "AbortError";
    // Logged, not just translated: without this, a network/egress failure is
    // indistinguishable from a model refusal by the time it reaches the user.
    logger.error("openRouter: request failed before a response arrived", {
      aborted,
      name: err instanceof Error ? err.name : typeof err,
      message: err instanceof Error ? err.message : String(err),
      cause:
        err instanceof Error && err.cause instanceof Error
          ? err.cause.message
          : undefined,
    });
    throw new HttpsError(
      aborted ? "deadline-exceeded" : "unavailable",
      aborted ? "The AI took too long to respond." : "Could not reach the AI.",
    );
  }

  try {
    if (!response.ok) {
      // 402 = out of credit, 429 = rate limited upstream — surface as retryable
      // where sensible, but never leak the provider body to the client.
      // The 429 reason tag (A9) keeps the client from mistaking an upstream
      // rate limit for the user's own quota and opening the paywall for it.
      //
      // The body is logged (truncated) because the status code on its own
      // almost never says why the provider rejected the call.
      const errorBody = await response.text().catch(() => "");
      logger.error("openRouter: provider returned an error status", {
        status: response.status,
        model: params.model,
        body: errorBody.slice(0, 500),
      });
      if (response.status === 429) {
        throw new HttpsError(
          "resource-exhausted",
          `AI request failed (${response.status}).`,
          { reason: "upstream-rate-limit" },
        );
      }
      throw new HttpsError(
        "internal",
        `AI request failed (${response.status}).`,
      );
    }

    const data = (await response.json()) as OpenRouterResponse;
    const content = data.choices?.[0]?.message?.content?.trim() ?? "";
    if (content.length === 0) {
      // Most likely a reasoning model that spent the whole token budget
      // "thinking" and never got to write an answer.
      logger.warn("openRouter: provider returned empty content", {
        model: params.model,
        maxTokens: params.maxTokens,
        completionTokens: data.usage?.completion_tokens,
      });
    }
    return {
      content,
      usage: {
        promptTokens: data.usage?.prompt_tokens ?? 0,
        completionTokens: data.usage?.completion_tokens ?? 0,
      },
    };
  } catch (err) {
    if (err instanceof HttpsError) throw err;
    const aborted = err instanceof Error && err.name === "AbortError";
    logger.error("openRouter: failed while reading the response", {
      aborted,
      name: err instanceof Error ? err.name : typeof err,
      message: err instanceof Error ? err.message : String(err),
    });
    throw new HttpsError(
      aborted ? "deadline-exceeded" : "internal",
      aborted
        ? "The AI took too long to respond."
        : "AI returned an unreadable response.",
    );
  } finally {
    clearTimeout(timer);
  }
}
