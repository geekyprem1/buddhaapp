import { HttpsError, onCall } from "firebase-functions/v2/https";
import { FieldValue, getFirestore } from "firebase-admin/firestore";
import { getStorage } from "firebase-admin/storage";
import { getAuth } from "firebase-admin/auth";
import { writeAuditLog } from "../lib/audit";
import { isSuperAdmin } from "./roles";

interface ProcessDeletionRequestData {
  uid?: string;
}

/**
 * `processDeletionRequest` (Architecture §8, T1.24, AR-5.5, FR-2.8).
 *
 * DPDP/GDPR-style deletion is admin-executed rather than an automatic
 * trigger on `deletionRequests` create: AR-5.5 asks for a queue an admin
 * *reviews and executes* deletion from, and an unattended trigger that wipes
 * a user's data the instant they request it would be a silent, unreviewable
 * destructive action. Super Admin only; writes a proof record on the
 * request doc and an audit log entry (who, when, what was removed).
 *
 * Deletes: `users/{uid}` doc, its `alarms` subcollection, the Storage avatar,
 * and the Firebase Auth account. Content the user personalised on-device
 * (status photos) never left the device (FR-12.10), so there's nothing
 * server-side to remove for that.
 */
export const processDeletionRequest = onCall(
  { region: "asia-south1" },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Sign in required.");
    }
    if (!isSuperAdmin(request.auth.token.role)) {
      throw new HttpsError(
        "permission-denied",
        "Only a Super Admin can execute a deletion request.",
      );
    }

    const data = (request.data ?? {}) as ProcessDeletionRequestData;
    const uid = data.uid?.trim();
    if (!uid) {
      throw new HttpsError("invalid-argument", "uid is required.");
    }

    const db = getFirestore();
    const reqRef = db.collection("deletionRequests").doc(uid);
    const reqSnap = await reqRef.get();
    if (!reqSnap.exists) {
      throw new HttpsError("not-found", "No deletion request for this uid.");
    }
    if (reqSnap.data()?.status === "completed") {
      throw new HttpsError(
        "failed-precondition",
        "This request has already been processed.",
      );
    }

    const removed: string[] = [];

    // Alarms subcollection.
    const alarms = await db.collection(`users/${uid}/alarms`).get();
    if (!alarms.empty) {
      const batch = db.batch();
      for (const doc of alarms.docs) batch.delete(doc.ref);
      await batch.commit();
      removed.push(`${alarms.size} alarm(s)`);
    }

    // Storage avatar.
    try {
      await getStorage().bucket().deleteFiles({ prefix: `users/${uid}/` });
      removed.push("storage files");
    } catch {
      // No files is not an error.
    }

    // User doc.
    const userRef = db.collection("users").doc(uid);
    const userSnap = await userRef.get();
    if (userSnap.exists) {
      await userRef.delete();
      removed.push("user document");
    }

    // Auth account — best-effort; the user may have already deleted it
    // themselves via Settings, or it may not exist in this environment.
    try {
      await getAuth().deleteUser(uid);
      removed.push("auth account");
    } catch {
      // Already gone.
    }

    await reqRef.set(
      {
        status: "completed",
        processedAt: FieldValue.serverTimestamp(),
        processedBy: request.auth.uid,
        removed,
      },
      { merge: true },
    );

    await writeAuditLog({
      actorUid: request.auth.uid,
      actorEmail: request.auth.token.email ?? null,
      action: "process_deletion_request",
      entityType: "deletionRequests",
      entityId: uid,
      after: { removed },
    });

    return { uid, removed };
  },
);
