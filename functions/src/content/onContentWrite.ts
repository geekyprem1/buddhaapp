import {
  onDocumentWritten,
  type FirestoreEvent,
  type Change,
  type DocumentSnapshot,
} from "firebase-functions/v2/firestore";
import { logger } from "firebase-functions/v2";
import { writeAuditLog } from "../lib/audit";
import { CONTENT_COLLECTIONS } from "../lib/content";

/**
 * Fields that change from Function-driven writes (media derivatives, counter
 * aggregation, timestamps). An update touching only these is machine noise and
 * is not audited.
 */
const IGNORED_FIELDS = new Set([
  "updatedAt",
  "counters",
  "mediaUrl",
  "thumbUrl",
  "storagePath",
  "mediaProcessedAt",
  "wallpaper",
  "audio",
]);

/** Keep audit diffs small: skip large / machine-owned fields in the snapshot. */
const DIFF_SKIP = new Set(["counters", "mediaProcessedAt"]);

type WriteEvent = FirestoreEvent<
  Change<DocumentSnapshot> | undefined,
  { itemId: string }
>;

function actorOf(data: FirebaseFirestore.DocumentData | undefined): {
  uid: string;
  email: string | null;
} {
  const uid =
    (typeof data?.updatedBy === "string" && data.updatedBy) ||
    (typeof data?.createdBy === "string" && data.createdBy) ||
    "system";
  const email =
    typeof data?.updatedByEmail === "string" ? data.updatedByEmail : null;
  return { uid, email };
}

function changedKeys(
  before: FirebaseFirestore.DocumentData,
  after: FirebaseFirestore.DocumentData,
): string[] {
  const keys = new Set([...Object.keys(before), ...Object.keys(after)]);
  const changed: string[] = [];
  for (const key of keys) {
    if (JSON.stringify(before[key]) !== JSON.stringify(after[key])) {
      changed.push(key);
    }
  }
  return changed;
}

function pick(
  data: FirebaseFirestore.DocumentData,
  keys: string[],
): Record<string, unknown> {
  const out: Record<string, unknown> = {};
  for (const key of keys) {
    if (DIFF_SKIP.has(key)) continue;
    out[key] = data[key] ?? null;
  }
  return out;
}

async function handleWrite(
  collection: string,
  event: WriteEvent,
): Promise<void> {
  const change = event.data;
  if (!change) return;
  const beforeSnap = change.before;
  const afterSnap = change.after;
  const itemId = event.params.itemId;

  // Create
  if (!beforeSnap.exists && afterSnap.exists) {
    const after = afterSnap.data() ?? {};
    const actor = actorOf(after);
    await writeAuditLog({
      actorUid: actor.uid,
      actorEmail: actor.email,
      action: "create",
      entityType: collection,
      entityId: itemId,
      after: pick(after, Object.keys(after)),
    });
    validate(collection, itemId, after);
    return;
  }

  // Delete
  if (beforeSnap.exists && !afterSnap.exists) {
    const before = beforeSnap.data() ?? {};
    const actor = actorOf(before);
    await writeAuditLog({
      actorUid: actor.uid,
      actorEmail: actor.email,
      action: "delete",
      entityType: collection,
      entityId: itemId,
      before: pick(before, Object.keys(before)),
    });
    return;
  }

  // Update
  const before = beforeSnap.data() ?? {};
  const after = afterSnap.data() ?? {};
  const changed = changedKeys(before, after);
  if (changed.length === 0) return;
  if (changed.every((key) => IGNORED_FIELDS.has(key))) return;

  const actor = actorOf(after);
  await writeAuditLog({
    actorUid: actor.uid,
    actorEmail: actor.email,
    action: "update",
    entityType: collection,
    entityId: itemId,
    before: pick(before, changed),
    after: pick(after, changed),
  });
  validate(collection, itemId, after);
}

/** Light required-field validation (T1.11); logged, never mutates the doc. */
function validate(
  collection: string,
  itemId: string,
  data: FirebaseFirestore.DocumentData,
): void {
  if (data.status !== "published") return;
  const missing: string[] = [];
  const title = data.title as Record<string, unknown> | undefined;
  const hasTitle =
    title && Object.values(title).some((v) => typeof v === "string" && v.trim());
  if (!hasTitle) missing.push("title");
  if (!data.source) missing.push("source");
  if (!data.mediaUrl) missing.push("mediaUrl");
  if (missing.length > 0) {
    logger.warn("Published content is missing required fields", {
      collection,
      itemId,
      missing,
    });
  }
}

function makeTrigger(collection: string) {
  return onDocumentWritten(
    { region: "asia-south1", document: `${collection}/{itemId}` },
    (event) => handleWrite(collection, event as WriteEvent),
  );
}

// One export per collection so each gets its own Firestore trigger.
export const onWallpaperWrite = makeTrigger("wallpapers");
export const onRingtoneWrite = makeTrigger("ringtones");
export const onSongWrite = makeTrigger("songs");
export const onVandanaWrite = makeTrigger("vandanas");
export const onMeditationWrite = makeTrigger("meditations");
export const onChantingWrite = makeTrigger("chantings");
export const onStatusWrite = makeTrigger("statuses");
export const onPrarthanaWrite = makeTrigger("prarthanas");

// Compile-time guard: every content collection has a trigger above.
void CONTENT_COLLECTIONS;
