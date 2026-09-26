import { HttpsError, onCall } from "firebase-functions/v2/https";
import { getFirestore, Timestamp } from "firebase-admin/firestore";
import { writeAuditLog } from "../lib/audit";
import { isSuperAdmin } from "./roles";

/** State written on a manual admin grant/revoke, distinct from Play states. */
const ADMIN_GRANT_STATE = "admin_grant";
const ADMIN_REVOKE_STATE = "admin_revoke";

const MAX_GRANT_DAYS = 3650; // 10 years — a sane upper bound.

interface GrantPremiumRequest {
  uid?: string;
  /** How long premium should last from now, in whole days. */
  days?: number;
}

interface RevokePremiumRequest {
  uid?: string;
}

/**
 * Manually grant premium ("Pro") to a user without a Play purchase
 * (Architecture §8, monetization). Super-admin only, audit-logged.
 *
 * Entitlement lives at `users/{uid}.premiumUntil` — the app treats
 * `premiumUntil > now` as premium. We deliberately DO NOT write
 * `premiumToken`: the Play RTDN handler (`playRtdn.ts`) only overwrites a
 * user whose stored token matches the Play event, so leaving the token null
 * keeps this manual grant safe from any subscription-lifecycle event. It
 * also means a manual grant never blocks a real future purchase — that flows
 * through `verifyPurchase` and sets its own token.
 */
export const grantPremium = onCall(
  { region: "asia-south1" },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Sign in required.");
    }
    if (!isSuperAdmin(request.auth.token.role)) {
      throw new HttpsError(
        "permission-denied",
        "Only a Super Admin can grant premium.",
      );
    }

    const data = (request.data ?? {}) as GrantPremiumRequest;
    const uid = (data.uid ?? "").trim();
    const days = Number(data.days);

    if (!uid) {
      throw new HttpsError("invalid-argument", "Provide a user uid.");
    }
    if (!Number.isFinite(days) || days <= 0 || days > MAX_GRANT_DAYS) {
      throw new HttpsError(
        "invalid-argument",
        `days must be a number between 1 and ${MAX_GRANT_DAYS}.`,
      );
    }

    const db = getFirestore();
    const userRef = db.collection("users").doc(uid);

    const previousUntil = await db.runTransaction(async (tx) => {
      const snap = await tx.get(userRef);
      if (!snap.exists) {
        throw new HttpsError("not-found", "No user with that uid.");
      }
      const prev = snap.data()?.premiumUntil ?? null;
      const until = Timestamp.fromMillis(
        Date.now() + days * 24 * 60 * 60 * 1000,
      );
      tx.set(
        userRef,
        {
          premiumUntil: until,
          // Leave premiumToken alone/null so RTDN can't clobber a manual
          // grant; mark the source so it's distinguishable in Firestore.
          premiumState: ADMIN_GRANT_STATE,
          premiumUpdatedAt: Timestamp.now(),
        },
        { merge: true },
      );
      return prev as Timestamp | null;
    });

    const premiumUntilMillis = Date.now() + days * 24 * 60 * 60 * 1000;

    await writeAuditLog({
      actorUid: request.auth.uid,
      actorEmail: request.auth.token.email ?? null,
      action: "grant_premium",
      entityType: "users",
      entityId: uid,
      before: {
        premiumUntil: previousUntil ? previousUntil.toMillis() : null,
      },
      after: { premiumUntil: premiumUntilMillis, days },
    });

    return { uid, premiumUntil: premiumUntilMillis, days };
  },
);

/**
 * Revoke premium from a user (super-admin only, audit-logged). Clears
 * `premiumUntil` so the app treats the account as free immediately. If the
 * user later makes a real Play purchase, `verifyPurchase` re-grants it.
 */
export const revokePremium = onCall(
  { region: "asia-south1" },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Sign in required.");
    }
    if (!isSuperAdmin(request.auth.token.role)) {
      throw new HttpsError(
        "permission-denied",
        "Only a Super Admin can revoke premium.",
      );
    }

    const data = (request.data ?? {}) as RevokePremiumRequest;
    const uid = (data.uid ?? "").trim();
    if (!uid) {
      throw new HttpsError("invalid-argument", "Provide a user uid.");
    }

    const db = getFirestore();
    const userRef = db.collection("users").doc(uid);

    const previousUntil = await db.runTransaction(async (tx) => {
      const snap = await tx.get(userRef);
      if (!snap.exists) {
        throw new HttpsError("not-found", "No user with that uid.");
      }
      const prev = snap.data()?.premiumUntil ?? null;
      tx.set(
        userRef,
        {
          premiumUntil: null,
          premiumToken: null,
          premiumState: ADMIN_REVOKE_STATE,
          premiumUpdatedAt: Timestamp.now(),
        },
        { merge: true },
      );
      return prev as Timestamp | null;
    });

    await writeAuditLog({
      actorUid: request.auth.uid,
      actorEmail: request.auth.token.email ?? null,
      action: "revoke_premium",
      entityType: "users",
      entityId: uid,
      before: {
        premiumUntil: previousUntil ? previousUntil.toMillis() : null,
      },
      after: { premiumUntil: null },
    });

    return { uid };
  },
);
