import * as functionsV1 from "firebase-functions/v1";
import { logger } from "firebase-functions/v2";
import { getFirestore } from "firebase-admin/firestore";
import { getStorage } from "firebase-admin/storage";
import {
  USER_LINKED_COLLECTIONS,
  USER_SUBCOLLECTIONS,
  deleteUserLinkedDocs,
  deleteUserSubcollection,
} from "../lib/userDeletion";

/**
 * `onUserDelete` (Architecture §8, T2.9). Cascade-cleans `users/{uid}`, all
 * its subcollections and user-linked records (same scope as
 * `processDeletionRequest` via lib/userDeletion, B5) and the Storage avatar
 * whenever the **Auth account** itself is deleted — whichever path that
 * happened through (self-serve Settings deletion in a future release,
 * direct Console removal, etc.).
 * This is a safety net alongside `processDeletionRequest` (T1.24), which
 * covers the reviewed admin-executed DPDP queue; this one fires unconditionally
 * so no orphaned doc/avatar survives an Auth account going away.
 */
export const onUserDelete = functionsV1
  .region("asia-south1")
  .auth.user()
  .onDelete(async (user) => {
    const db = getFirestore();
    const uid = user.uid;

    for (const sub of USER_SUBCOLLECTIONS) {
      await deleteUserSubcollection(uid, sub);
    }
    for (const collection of USER_LINKED_COLLECTIONS) {
      await deleteUserLinkedDocs(collection, uid);
    }

    await db.collection("users").doc(uid).delete();

    try {
      await getStorage().bucket().deleteFiles({ prefix: `users/${uid}/` });
    } catch (err) {
      logger.warn("onUserDelete: no storage files to remove", {
        uid,
        error: err instanceof Error ? err.message : String(err),
      });
    }
  });
