import { getFirestore } from "firebase-admin/firestore";

/**
 * Shared account-erasure helpers (B5), used by both `processDeletionRequest`
 * (reviewed admin queue) and `onUserDelete` (Auth-trigger safety net) so the
 * two paths can never drift apart again.
 *
 * Firestore never deletes subcollections with their parent doc, and several
 * user-linked records live outside `users/{uid}` entirely — every one of
 * them must be enumerated explicitly or it orphans on deletion.
 */

/** Per-user subcollections under `users/{uid}` that must go with the account. */
export const USER_SUBCOLLECTIONS = ["alarms", "favourites", "progress"];

/**
 * Top-level collections holding docs with a `uid` field that must go with
 * the account. `events/` is intentionally absent: engagement events carry no
 * owner linkage. `deletionRequests/{uid}` and audit logs are kept as the
 * compliance proof record.
 *
 * `purchaseTokens` ownership records are erased too (B5): erasure releases
 * the token, so a later legitimate restore can re-claim it. (A stranger
 * reusing a still-active token of an erased account is indistinguishable
 * from the purchaser restoring — Play exposes no app-user binding — and an
 * expired token grants nothing anyway.)
 */
export const USER_LINKED_COLLECTIONS = [
  "aiUsage",
  "contactMessages",
  "purchaseTokens",
];

/** Delete all docs in `users/{uid}/{sub}`. Returns the deleted count. */
export async function deleteUserSubcollection(
  uid: string,
  sub: string,
): Promise<number> {
  const db = getFirestore();
  const snap = await db.collection(`users/${uid}/${sub}`).get();
  if (snap.empty) return 0;
  // Chunked to Firestore's 500-write batch limit.
  for (let i = 0; i < snap.docs.length; i += 500) {
    const batch = db.batch();
    for (const doc of snap.docs.slice(i, i + 500)) batch.delete(doc.ref);
    await batch.commit();
  }
  return snap.size;
}

/** Delete every doc in `collection` with `uid == uid`. Returns the count. */
export async function deleteUserLinkedDocs(
  collection: string,
  uid: string,
): Promise<number> {
  const db = getFirestore();
  let total = 0;
  for (;;) {
    const snap = await db
      .collection(collection)
      .where("uid", "==", uid)
      .limit(500)
      .get();
    if (snap.empty) break;
    const batch = db.batch();
    for (const doc of snap.docs) batch.delete(doc.ref);
    await batch.commit();
    total += snap.size;
    if (snap.size < 500) break;
  }
  return total;
}
