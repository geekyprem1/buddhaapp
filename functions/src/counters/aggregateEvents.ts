import { onSchedule } from "firebase-functions/v2/scheduler";
import { logger } from "firebase-functions/v2";
import { FieldValue, getFirestore } from "firebase-admin/firestore";
import {
  EVENT_TYPE_TO_COUNTER,
  isContentCollection,
} from "../lib/content";

const BATCH = 500;

/**
 * `aggregateEvents` (Architecture §8, T1.13, FR-9.10). Every 5 minutes: fold
 * throwaway `events/` writes into each content doc's `counters` map with a
 * single incremented write per doc, then delete the processed events. This is
 * why clients never write hot counters directly (Architecture principle #4).
 *
 * Event shape (written by the mobile app, T2.46):
 *   { collection: string, itemId: string, type: 'view'|'download'|'share'|'play', createdAt }
 */
export const aggregateEvents = onSchedule(
  {
    region: "asia-south1",
    schedule: "every 5 minutes",
    timeZone: "Asia/Kolkata",
  },
  async () => {
    const db = getFirestore();
    const snap = await db
      .collection("events")
      .orderBy("createdAt", "asc")
      .limit(BATCH)
      .get();

    if (snap.empty) return;

    // docKey -> { counterField -> increment }
    const increments = new Map<string, Map<string, number>>();
    const docRefs = new Map<string, FirebaseFirestore.DocumentReference>();

    for (const doc of snap.docs) {
      const data = doc.data();
      const collection = data.collection;
      const itemId = data.itemId;
      const counter = EVENT_TYPE_TO_COUNTER[String(data.type)];
      if (!isContentCollection(collection) || typeof itemId !== "string" || !counter) {
        // Malformed event — still deleted below so it can't poison the queue.
        continue;
      }
      const key = `${collection}/${itemId}`;
      if (!docRefs.has(key)) {
        docRefs.set(key, db.collection(collection).doc(itemId));
        increments.set(key, new Map());
      }
      const fields = increments.get(key)!;
      fields.set(counter, (fields.get(counter) ?? 0) + 1);
    }

    // Apply increments; ignore docs that were deleted since the event fired.
    await Promise.all(
      [...increments.entries()].map(async ([key, fields]) => {
        const update: Record<string, FirebaseFirestore.FieldValue> = {};
        for (const [counter, value] of fields) {
          update[`counters.${counter}`] = FieldValue.increment(value);
        }
        try {
          await docRefs.get(key)!.update(update);
        } catch (err) {
          logger.warn("Skipped counter update for missing doc", {
            key,
            error: err instanceof Error ? err.message : String(err),
          });
        }
      }),
    );

    // Delete processed events (chunked to Firestore's 500-write batch limit).
    for (let i = 0; i < snap.docs.length; i += 500) {
      const batch = db.batch();
      for (const doc of snap.docs.slice(i, i + 500)) {
        batch.delete(doc.ref);
      }
      await batch.commit();
    }

    logger.info("aggregateEvents complete", {
      events: snap.size,
      docsTouched: increments.size,
    });
  },
);
