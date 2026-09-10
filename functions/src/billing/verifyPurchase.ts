import { HttpsError, onCall } from "firebase-functions/v2/https";
import { getFirestore, Timestamp } from "firebase-admin/firestore";
import {
  PREMIUM_PRODUCT_ID,
  acknowledgeSubscription,
  fetchSubscriptionStatus,
} from "./androidPublisher";

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
    await db.collection("users").doc(uid).set(
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

    return {
      active: status.active,
      premiumUntil: status.premiumUntil,
      state: status.state,
    };
  },
);
