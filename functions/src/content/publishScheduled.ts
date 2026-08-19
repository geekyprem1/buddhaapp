import { onSchedule } from "firebase-functions/v2/scheduler";
import { logger } from "firebase-functions/v2";
import { FieldValue, getFirestore, Timestamp } from "firebase-admin/firestore";
import { CONTENT_COLLECTIONS } from "../lib/content";

const PAGE = 300;

/**
 * `publishScheduled` (Architecture §8, T1.12, FR-12.9). Every 15 minutes:
 *   - `draft → published` for items whose `publishAt` has passed.
 *   - `published → archived` for items whose `expireAt` has passed.
 * Status writes flow through `onContentWrite`, so each transition is audited
 * (actor `system`).
 */
export const publishScheduled = onSchedule(
  {
    region: "asia-south1",
    schedule: "every 15 minutes",
    timeZone: "Asia/Kolkata",
  },
  async () => {
    const now = Timestamp.now();
    let published = 0;
    let archived = 0;
    for (const collection of CONTENT_COLLECTIONS) {
      published += await transition(
        collection,
        "draft",
        "publishAt",
        now,
        "published",
      );
      archived += await transition(
        collection,
        "published",
        "expireAt",
        now,
        "archived",
      );
    }
    logger.info("publishScheduled complete", { published, archived });
  },
);

async function transition(
  collection: string,
  fromStatus: string,
  dateField: "publishAt" | "expireAt",
  now: Timestamp,
  toStatus: string,
): Promise<number> {
  const db = getFirestore();
  const snap = await db
    .collection(collection)
    .where("status", "==", fromStatus)
    .where(dateField, "<=", now)
    .limit(PAGE)
    .get();

  if (snap.empty) return 0;

  const batch = db.batch();
  for (const doc of snap.docs) {
    batch.update(doc.ref, {
      status: toStatus,
      updatedBy: "system",
      updatedAt: FieldValue.serverTimestamp(),
    });
  }
  await batch.commit();
  return snap.size;
}
