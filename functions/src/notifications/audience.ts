/**
 * Audience strings stored on `notifications/{id}.audience`.
 * Must stay aligned with mobile `FcmTopics` (`all`, `lang_{code}`, `teacher_{id}`).
 */

export type AudienceTarget =
  | { kind: "topic"; topic: string; label: string }
  | { kind: "user"; uid: string; label: string }
  | { kind: "platform"; platform: "android" | "ios"; label: string };

const TOPIC_SAFE = /[^a-zA-Z0-9_-]/g;

export function topicSafe(raw: string): string {
  const cleaned = raw.replace(TOPIC_SAFE, "_");
  return cleaned.length === 0 ? "unknown" : cleaned;
}

export function parseAudience(raw: unknown): AudienceTarget {
  if (typeof raw !== "string" || raw.trim().length === 0 || raw === "all") {
    return { kind: "topic", topic: "all", label: "all users" };
  }
  const value = raw.trim();
  const colon = value.indexOf(":");
  if (colon <= 0 || colon === value.length - 1) {
    throw new Error(
      "audience must be all, teacher:{id}, language:{code}, platform:{android|ios}, or user:{uid}.",
    );
  }
  const kind = value.slice(0, colon);
  const id = value.slice(colon + 1).trim();
  if (!id) {
    throw new Error("audience value is empty.");
  }
  switch (kind) {
    case "teacher":
      return {
        kind: "topic",
        topic: `teacher_${topicSafe(id)}`,
        label: `teacher ${id}`,
      };
    case "language":
      return {
        kind: "topic",
        topic: `lang_${topicSafe(id)}`,
        label: `language ${id}`,
      };
    case "platform":
      if (id !== "android" && id !== "ios") {
        throw new Error("platform must be android or ios.");
      }
      return { kind: "platform", platform: id, label: `platform ${id}` };
    case "user":
      return { kind: "user", uid: id, label: `user ${id}` };
    default:
      throw new Error(
        "audience must be all, teacher:{id}, language:{code}, platform:{android|ios}, or user:{uid}.",
      );
  }
}

export function pushDataFromDeepLink(
  deepLink: string | null | undefined,
  campaignId: string,
): Record<string, string> {
  const data: Record<string, string> = { campaignId };
  const trimmed = (deepLink ?? "").trim();
  if (!trimmed) return data;
  if (/^https?:\/\//i.test(trimmed)) {
    data.url = trimmed;
  } else if (trimmed.startsWith("/")) {
    data.route = trimmed;
  } else {
    data.module = trimmed.toLowerCase();
  }
  return data;
}
