import { HttpsError, onCall } from "firebase-functions/v2/https";
import { getFirestore, Timestamp } from "firebase-admin/firestore";
import {
  PREMIUM_PRODUCT_ID,
  acknowledgeSubscription,
  fetchSubscriptionStatus,
} from "./androidPublisher";
import {
  PURCHASE_TOKENS_COLLECTION,
  purchaseTokenDocId,
} from "./purchaseTokens";

interface VerifyPurchaseRequest {
  productId?: string;
  purchaseToken?: string;
}

/**
 * Verifies a Play subscription purchase server-side and writes the
 * authoritative entitlement onto the caller's user doc.
 *
 * The app calls this after a purchase (and can call it any time to refresh).
 * Entitlement lives at `users/{uid}.premiumUntil` (a Timestamp) — the app
 * treats `premiumUntil > now` as premium. `premiumToken` is stored so the
 * Real-time Developer Notifications handler can map a token back to the user
 * when Play reports a cancel/expire/refund.
 *
 * Token ownership (N7): one purchase token grants exactly one app account.
 * The claim is recorded atomically in `purchaseTokens` (Function-only
 * collection) in the same transaction as the entitlement write — first
 * account wins, a different account gets an explicit error instead of silent
 * double-premium. Re-verify by the same account stays allowed. The canonical
 * record uses a deterministic doc ID so concurrent claims contend on one
 * document; pre-ownership auto-ID records and legacy `users.premiumToken`
 * grants are also honored, so old grants can't be re-claimed by a stranger.
 */
export const verifyPurchase = onCall(
  { region: "asia-south1" },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Sign in required.");
    }
    const data = (request.data ?? {}) as VerifyPurchaseRequest;
    const productId = (data.productId ?? "").trim();
    const purchaseToken = (data.purchaseToken ?? "").trim();

    if (productId !== PREMIUM_PRODUCT_ID) {
      throw new HttpsError("invalid-argument", "Unknown product.");
    }
    if (!purchaseToken) {
      throw new HttpsError("invalid-argument", "Missing purchase token.");
    }

    let status;
    try {
      status = await fetchSubscriptionStatus(purchaseToken);
    } catch (err) {
      throw new HttpsError(
        "internal",
        `Could not verify with Google Play: ${(err as Error).message}`,
      );
    }

    if (status.active) {
      await acknowledgeSubscription(purchaseToken);
    }

    const uid = request.auth.uid;
    const db = getFirestore();
    // Ownership claim + entitlement write in one transaction (N7). The
    // canonical record's deterministic ID makes concurrent claims contend on
    // a single document, so exactly one racer can win; legacy layers are
    // checked too, so a stranger can't reclaim an old grant either.
    await db.runTransaction(async (tx) => {
      const alreadyLinked = () =>
        new HttpsError(
          "permission-denied",
          "This purchase is already linked to another account.",
        );
      const ownerRef = db
        .collection(PURCHASE_TOKENS_COLLECTION)
        .doc(purchaseTokenDocId(purchaseToken));
      const ownerSnap = await tx.get(ownerRef);
      if (ownerSnap.exists && ownerSnap.data()?.uid !== uid) {
        throw alreadyLinked();
      }
      const legacyRecord = await tx.get(
        db
          .collection(PURCHASE_TOKENS_COLLECTION)
          .where("token", "==", purchaseToken)
          .limit(1),
      );
      const legacyOwner = legacyRecord.docs[0];
      if (legacyOwner && legacyOwner.data().uid !== uid) {
        throw alreadyLinked();
      }
      const legacyGrant = await tx.get(
        db
          .collection("users")
          .where("premiumToken", "==", purchaseToken)
          .limit(1),
      );
      const granted = legacyGrant.docs[0];
      if (granted && granted.id !== uid) {
        throw alreadyLinked();
      }
      tx.set(
        ownerRef,
        { token: purchaseToken, uid, updatedAt: Timestamp.now() },
        { merge: true },
      );
      tx.set(
        db.collection("users").doc(uid),
        {
          premiumUntil:
            status.premiumUntil > 0
              ? Timestamp.fromMillis(status.premiumUntil)
              : null,
          premiumToken: status.active ? purchaseToken : null,
          premiumState: status.state,
          premiumUpdatedAt: Timestamp.now(),
        },
        { merge: true },
      );
    });

    return {
      active: status.active,
      premiumUntil: status.premiumUntil,
      state: status.state,
    };
  },
);
