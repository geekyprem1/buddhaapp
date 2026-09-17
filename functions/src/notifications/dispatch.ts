import {
  getMessaging,
  type MulticastMessage,
  type TokenMessage,
  type TopicMessage,
} from "firebase-admin/messaging";
import {
  FieldValue,
  getFirestore,
  Timestamp,
  type DocumentReference,
  type QueryDocumentSnapshot,
} from "firebase-admin/firestore";
import { parseAudience, pushDataFromDeepLink } from "./audience";

export const PUSH_CHANNEL_ID = "dhamma_path_push";
const TOKEN_CHUNK = 500;
const DUE_BATCH = 20;

export interface CampaignContent {
  title: string;
  body: string;
  imageUrl?: string | null;
  deepLink?: string | null;
  audience: string;
}

export interface DispatchResult {
  deliveredCount: number;
  messageId?: string;
  target: string;
}

function basePayload(content: CampaignContent, campaignId: string) {
  const imageUrl = content.imageUrl?.trim() || undefined;
  return {
    notification: {
      title: content.title,
      body: content.body,
      ...(imageUrl ? { imageUrl } : {}),
    },
    data: pushDataFromDeepLink(content.deepLink, campaignId),
    android: {
      priority: "high" as const,
      notification: {
        channelId: PUSH_CHANNEL_ID,
        ...(imageUrl ? { imageUrl } : {}),
      },
    },
  };
}

function collectTokens(raw: unknown): string[] {
  if (!Array.isArray(raw)) return [];
  const tokens: string[] = [];
  for (const item of raw) {
    if (typeof item === "string" && item.trim()) {
      tokens.push(item.trim());
    }
  }
  return tokens;
}

/** A device token with its owning user, so dead tokens can be pruned (B7). */
interface OwnedToken {
  token: string;
  uid: string;
}

function ownedTokens(uid: string, raw: unknown): OwnedToken[] {
  return collectTokens(raw).map((token) => ({ token, uid }));
}

async function tokensForUser(uid: string): Promise<OwnedToken[]> {
  const snap = await getFirestore().collection("users").doc(uid).get();
  if (!snap.exists) {
    throw new Error(`User ${uid} was not found.`);
  }
  return ownedTokens(uid, snap.data()?.fcmTokens);
}

async function tokensForPlatform(platform: string): Promise<OwnedToken[]> {
  // Full cursor pagination (B8): the old limit(2000) + 5000-token cutoff
  // silently dropped everyone past the cap while the campaign was still
  // marked sent. Requires the (platform, __name__) composite index shipped
  // in firebase/firestore.indexes.json.
  const db = getFirestore();
  const tokens: OwnedToken[] = [];
  let cursor: QueryDocumentSnapshot | null = null;
  for (;;) {
    let query = db
      .collection("users")
      .where("platform", "==", platform)
      .orderBy("__name__")
      .limit(2000);
    if (cursor) query = query.startAfter(cursor);
    const snap = await query.get();
    if (snap.empty) break;
    for (const doc of snap.docs) {
      tokens.push(...ownedTokens(doc.id, doc.data().fcmTokens));
    }
    cursor = snap.docs[snap.docs.length - 1];
    if (snap.size < 2000) break;
  }
  return tokens;
}

/** FCM codes meaning "this token will never work again" (B7). */
function isDeadToken(error: unknown): boolean {
  const code = (error as { code?: unknown } | undefined)?.code;
  return (
    code === "messaging/registration-token-not-registered" ||
    code === "messaging/invalid-registration-token"
  );
}

/** Best-effort removal of dead tokens from their owners (B7). Never throws. */
async function pruneTokens(dead: OwnedToken[]): Promise<void> {
  const byUser = new Map<string, string[]>();
  for (const { token, uid } of dead) {
    const list = byUser.get(uid) ?? [];
    list.push(token);
    byUser.set(uid, list);
  }
  await Promise.all(
    [...byUser.entries()].map(async ([uid, uidTokens]) => {
      try {
        await getFirestore()
          .collection("users")
          .doc(uid)
          .update({ fcmTokens: FieldValue.arrayRemove(...uidTokens) });
      } catch {
        // Owner deleted mid-campaign — nothing left to prune.
      }
    }),
  );
}

async function sendToTokens(
  tokens: OwnedToken[],
  content: CampaignContent,
  campaignId: string,
): Promise<DispatchResult> {
  if (tokens.length === 0) {
    return { deliveredCount: 0, target: "tokens" };
  }
  const messaging = getMessaging();
  const base = basePayload(content, campaignId);
  let delivered = 0;
  let lastError: string | undefined;
  for (let i = 0; i < tokens.length; i += TOKEN_CHUNK) {
    const chunk = tokens.slice(i, i + TOKEN_CHUNK);
    const message: MulticastMessage = {
      ...base,
      tokens: chunk.map((t) => t.token),
    };
    const result = await messaging.sendEachForMulticast(message);
    delivered += result.successCount;
    // Prune dead tokens so the list heals instead of rotting (B7); only
    // retryable errors count toward the campaign failure message.
    const dead: OwnedToken[] = [];
    result.responses.forEach((r, idx) => {
      if (!r.success) {
        if (isDeadToken(r.error)) {
          dead.push(chunk[idx]);
        } else if (lastError === undefined) {
          lastError = r.error?.message;
        }
      }
    });
    if (dead.length > 0) await pruneTokens(dead);
  }
  if (delivered === 0) {
    throw new Error(lastError ?? "FCM rejected every device token.");
  }
  return { deliveredCount: delivered, target: `${delivered} tokens` };
}

export async function sendToAudience(
  content: CampaignContent,
  campaignId: string,
): Promise<DispatchResult> {
  const target = parseAudience(content.audience);
  if (target.kind === "topic") {
    const message: TopicMessage = {
      ...basePayload(content, campaignId),
      topic: target.topic,
    };
    const messageId = await getMessaging().send(message);
    return {
      deliveredCount: 0,
      messageId,
      target: `topic ${target.topic}`,
    };
  }
  if (target.kind === "user") {
    const tokens = await tokensForUser(target.uid);
    if (tokens.length === 0) {
      throw new Error("That user has no registered device tokens.");
    }
    return sendToTokens(tokens, content, campaignId);
  }
  const tokens = await tokensForPlatform(target.platform);
  return sendToTokens(tokens, content, campaignId);
}

export async function sendTestToToken(
  token: string,
  content: CampaignContent,
  campaignId: string,
): Promise<string> {
  const message: TokenMessage = {
    ...basePayload(content, campaignId),
    token,
  };
  return getMessaging().send(message);
}

export async function writeCampaign(
  ref: DocumentReference,
  content: CampaignContent,
  fields: Record<string, unknown>,
): Promise<void> {
  await ref.set(
    {
      title: content.title,
      body: content.body,
      imageUrl: content.imageUrl ?? null,
      deepLink: content.deepLink ?? null,
      audience: content.audience,
      deliveredCount: 0,
      openedCount: 0,
      ...fields,
    },
    { merge: true },
  );
}

export async function markSent(
  ref: DocumentReference,
  result: DispatchResult,
): Promise<void> {
  await ref.set(
    {
      status: "sent",
      sentAt: FieldValue.serverTimestamp(),
      deliveredCount: result.deliveredCount,
      messageId: result.messageId ?? null,
      target: result.target,
      error: null,
    },
    { merge: true },
  );
}

export async function markFailed(
  ref: DocumentReference,
  error: string,
): Promise<void> {
  await ref.set(
    {
      status: "failed",
      error,
    },
    { merge: true },
  );
}

export async function dispatchDueCampaigns(): Promise<number> {
  const db = getFirestore();
  const due = await db
    .collection("notifications")
    .where("status", "==", "scheduled")
    .where("scheduledAt", "<=", Timestamp.now())
    .limit(DUE_BATCH)
    .get();

  let sent = 0;
  for (const doc of due.docs) {
    const claimed = await db.runTransaction(async (tx) => {
      const snap = await tx.get(doc.ref);
      if (snap.data()?.status !== "scheduled") return false;
      tx.update(doc.ref, { status: "sending" });
      return true;
    });
    if (!claimed) continue;

    const data = doc.data();
    const content: CampaignContent = {
      title: String(data.title ?? ""),
      body: String(data.body ?? ""),
      imageUrl: typeof data.imageUrl === "string" ? data.imageUrl : null,
      deepLink: typeof data.deepLink === "string" ? data.deepLink : null,
      audience: String(data.audience ?? "all"),
    };
    try {
      const result = await sendToAudience(content, doc.id);
      await markSent(doc.ref, result);
      sent += 1;
    } catch (err) {
      await markFailed(
        doc.ref,
        err instanceof Error ? err.message : "Send failed.",
      );
    }
  }
  return sent;
}
