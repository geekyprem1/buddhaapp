import { onSchedule } from "firebase-functions/v2/scheduler";
import { logger } from "firebase-functions/v2";
import { getFirestore, Timestamp } from "firebase-admin/firestore";
import { getStorage } from "firebase-admin/storage";
import { CONTENT_COLLECTIONS } from "../lib/content";

const THIRTY_DAYS_MS = 30 * 24 * 60 * 60 * 1000;
const SAFE_AGE_MS = 24 * 60 * 60 * 1000; // never touch objects younger than 24h
const PAGE = 200;

/**
 * `cleanupOrphans` (Architecture §8, T1.14, AR-3.7). Runs daily:
 *   1. Hard-delete content soft-deleted more than 30 days ago, plus its
 *      Storage folder.
 *   2. Delete Storage objects under content prefixes whose owning document no
 *      longer exists — guarded to skip anything created in the last 24h so an
 *      in-progress upload is never removed.
 * Both steps are intentionally conservative: they only ever touch the six
 * content prefixes, never user data (`users/**`).
 */
export const cleanupOrphans = onSchedule(
  {
    region: "asia-south1",
    schedule: "every 24 hours",
    timeZone: "Asia/Kolkata",
  },
  async () => {
    const purged = await purgeSoftDeletes();
    const orphans = await purgeOrphanObjects();
    logger.info("cleanupOrphans complete", { purged, orphans });
  },
);

async function purgeSoftDeletes(): Promise<number> {
  const db = getFirestore();
  const cutoff = Timestamp.fromMillis(Date.now() - THIRTY_DAYS_MS);
  let count = 0;
  for (const collection of CONTENT_COLLECTIONS) {
    const snap = await db
      .collection(collection)
      .where("deletedAt", "<=", cutoff)
      .limit(PAGE)
      .get();
    for (const doc of snap.docs) {
      await deleteStorageFolder(`${collection}/${doc.id}/`);
      await doc.ref.delete();
      count += 1;
    }
  }
  return count;
}

async function purgeOrphanObjects(): Promise<number> {
  const db = getFirestore();
  const bucket = getStorage().bucket();
  const now = Date.now();
  let count = 0;

  for (const collection of CONTENT_COLLECTIONS) {
    const [files] = await bucket.getFiles({ prefix: `${collection}/` });
    // Group object age by the itemId segment of the path.
    const itemIds = new Set<string>();
    for (const file of files) {
      const parts = file.name.split("/");
      if (parts.length >= 2 && parts[1]) itemIds.add(parts[1]);
    }

    for (const itemId of itemIds) {
      const docSnap = await db.collection(collection).doc(itemId).get();
      if (docSnap.exists) continue;

      const itemFiles = files.filter(
        (f) => f.name.startsWith(`${collection}/${itemId}/`),
      );
      // Only delete when every object in the folder is older than the safety
      // window — protects a fresh upload whose doc has not been written yet.
      const allSafe = itemFiles.every((f) => {
        const created = Date.parse(f.metadata.timeCreated ?? "");
        return Number.isFinite(created) && now - created > SAFE_AGE_MS;
      });
      if (!allSafe) continue;

      await Promise.all(itemFiles.map((f) => f.delete().catch(() => undefined)));
      count += itemFiles.length;
    }
  }
  return count;
}

async function deleteStorageFolder(prefix: string): Promise<void> {
  try {
    await getStorage().bucket().deleteFiles({ prefix, force: true });
  } catch (err) {
    logger.warn("Failed to delete storage folder", {
      prefix,
      error: err instanceof Error ? err.message : String(err),
    });
  }
}
