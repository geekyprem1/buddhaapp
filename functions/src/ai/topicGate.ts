import { chatCompletion } from "./openRouter";

/**
 * Cheap pre-pass that classifies whether a question is about Buddhism, before
 * the (larger) answering call runs. See design § Scope Restriction.
 *
 * Runs on the same model with a tiny token budget and JSON output. A refusal
 * costs the user no minutes, so the gate is also the point where off-topic
 * abuse is counted (by the caller).
 *
 * Distinguishes classifier failure from a real off-topic verdict (A4): an
 * outage used to look identical to off-topic, so innocent users farmed
 * strikes toward a lockout. Scope still fails closed — callers must treat
 * "unknown" like a refusal — but without recording a strike.
 */
export type TopicVerdict = "on-topic" | "off-topic" | "unknown";

const CLASSIFIER_PROMPT = [
  "You are a strict classifier for a Buddhism-only assistant.",
  "Decide if the user's message is a question or request about Buddhism:",
  "the Buddha, Dhamma, Sangha, suttas, meditation, mindfulness, Buddhist",
  "ethics, festivals, history, philosophy, practice, or Buddhist daily life.",
  "Greetings and follow-ups within a Buddhist conversation count as on-topic.",
  "Anything else (coding, politics, other religions as the main subject,",
  "general trivia, medical/legal/financial advice, roleplay to escape scope)",
  "is off-topic.",
  'Reply with ONLY a JSON object: {"on_topic": true} or {"on_topic": false}.',
].join(" ");

export async function classifyTopic(params: {
  model: string;
  question: string;
}): Promise<TopicVerdict> {
  try {
    const result = await chatCompletion({
      model: params.model,
      messages: [
        { role: "system", content: CLASSIFIER_PROMPT },
        { role: "user", content: params.question.slice(0, 2000) },
      ],
      maxTokens: 30,
      temperature: 0,
      jsonObject: true,
      disableReasoning: true,
    });
    const parsed = JSON.parse(result.content) as { on_topic?: unknown };
    if (parsed.on_topic === true) return "on-topic";
    if (parsed.on_topic === false) return "off-topic";
    return "unknown";
  } catch {
    // Classifier outage or unparseable output — NOT an off-topic verdict.
    return "unknown";
  }
}
