import { HttpsError, onCall } from "firebase-functions/v2/https";
import { getAuth } from "firebase-admin/auth";
import { getFirestore, FieldValue } from "firebase-admin/firestore";
import { writeAuditLog } from "../lib/audit";
import { isAdminRole, isSuperAdmin, type AdminRole } from "./roles";

interface SetAdminRoleRequest {
  uid?: string;
  email?: string;
  /** Pass `null` to revoke. */
  role: AdminRole | null;
  name?: string;
}

/**
 * Grant or revoke an admin custom claim and keep `adminUsers/{uid}` in
 * lockstep (Architecture §8, AR-1.2). Super-admin callers only.
 */
export const setAdminRole = onCall(
  { region: "asia-south1" },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Sign in required.");
    }
    if (!isSuperAdmin(request.auth.token.role)) {
      throw new HttpsError(
        "permission-denied",
        "Only a Super Admin can change admin roles.",
      );
    }

    const data = (request.data ?? {}) as SetAdminRoleRequest;
    const nextRole = data.role;
    if (nextRole !== null && !isAdminRole(nextRole)) {
      throw new HttpsError(
        "invalid-argument",
        "role must be super_admin, content_manager, moderator, or null.",
      );
    }
    if (!data.uid && !data.email) {
      throw new HttpsError("invalid-argument", "Provide uid or email.");
    }

    const auth = getAuth();
    const target = data.uid
      ? await auth.getUser(data.uid)
      : await auth.getUserByEmail(data.email!);

    if (target.uid === request.auth.uid && nextRole !== "super_admin") {
      throw new HttpsError(
        "failed-precondition",
        "You cannot revoke or demote your own Super Admin role.",
      );
    }

    const previousRole =
      typeof target.customClaims?.role === "string"
        ? target.customClaims.role
        : null;

    await auth.setCustomUserClaims(
      target.uid,
      nextRole ? { role: nextRole } : {},
    );

    const db = getFirestore();
    const adminRef = db.collection("adminUsers").doc(target.uid);
    const existing = await adminRef.get();
    const email = target.email ?? data.email ?? "";

    if (nextRole) {
      await adminRef.set(
        {
          email,
          name: data.name ?? target.displayName ?? existing.data()?.name ?? "",
          role: nextRole,
          isActive: true,
          createdBy: existing.exists
            ? existing.data()?.createdBy ?? request.auth.uid
            : request.auth.uid,
          createdAt: existing.exists
            ? existing.data()?.createdAt
            : FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
    } else if (existing.exists) {
      await adminRef.set(
        { isActive: false, role: previousRole ?? "moderator" },
        { merge: true },
      );
    }

    await writeAuditLog({
      actorUid: request.auth.uid,
      actorEmail: request.auth.token.email ?? null,
      action: nextRole ? "set_role" : "revoke_role",
      entityType: "adminUsers",
      entityId: target.uid,
      before: { role: previousRole },
      after: { role: nextRole, email },
    });

    return { uid: target.uid, email, role: nextRole };
  },
);
