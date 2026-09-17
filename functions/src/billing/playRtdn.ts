import { HttpsError } from "firebase-functions/v2/https";
import { onMessagePublished } from "firebase-functions/v2/pubsub";
import { getFirestore, Timestamp } from "firebase-admin/firestore";
import { findTokenOwnerUid } from "./purchaseTokens";
import { fetchSubscriptionStatus } from "./androidPublisher";

/**
 * Real-time Developer Notifications (RTDN) handler.
 *
 * Play publishes to a Pub/Sub topic on every subscription event (renew,
 * cancel, expire, revoke, grace period, …). We re-fetch the authoritative
 * status by token and update the owning user's `premiumUntil`, so a
 * cancellation/expiry/refund removes access without the app doing anything.
 *
 * Topic name must match the one configured in Play Console → Monetization
 * setup → Real-time developer notifications. Set here to `play-subscriptions`.
 *
 * `retry: true` with failure propagation (N8): a transient Play lookup
 * failure used to return normally — acknowledging the message and silently
 * dropping a renewal/revocation. Now it throws so Pub/Sub redelivers. The
 * handler is idempotent (re-fetch authoritative status, overwrite the same
 * fields), so redelivery is safe. Poison messages (missing/bad payload,
 * unknown token) still return normally and are never retried.
 */
export const playRtdn = onMessagePublished(
  { region: "asia-south1", topic: "play-subscriptions", retry: true },
  async (event) => {
    const raw = event.data.message.data;
    if (!raw) return;

    let payload: {
      subscriptionNotification?: { purchaseToken?: string };
      testNotification?: unknown;
    };
    try {
      payload = JSON.parse(Buffer.from(raw, "base64").toString("utf8"));
    } catch {
      return;
    }

    // Play sends a testNotification when you press "Send test message".
    const token = payload.subscriptionNotification?.purchaseToken;
    if (!token) return;

    const db = getFirestore();
    // Find the user who owns this purchase token: canonical + pre-ownership
    // records first (N7), then the legacy `users.premiumToken` field for
    // tokens granted before records existed.
    const ownerUid = await findTokenOwnerUid(token);
    const legacySnap = ownerUid
      ? null
      : await db
          .collection("users")
          .where("premiumToken", "==", token)
          .limit(1)
          .get();
    const userRef = ownerUid
      ? db.collection("users").doc(ownerUid)
      : legacySnap && !legacySnap.empty
        ? legacySnap.docs[0].ref
        : null;
    if (!userRef) return;

    let status;
    try {
      status = await fetchSubscriptionStatus(token);
    } catch (err) {
      // Transient lookup failure: throw so the message is redelivered (N8).
      // Never swallow here — a normal return would ack and lose the update.
      throw new HttpsError(
        "unavailable",
        `Could not verify with Google Play: ${(err as Error).message}`,
      );
    }

    // Existence + current-token + write in one transaction (B5): a
    // `set({merge:true})` after a non-transactional exists-check could
    // recreate an erased user if deletion landed in between. `update`
    // cannot create a missing doc; the transaction re-reads so a concurrent
    // erase is visible. Ownership records are deleted with the account, so
    // a later legitimate restore re-claims via `verifyPurchase`.
    await db.runTransaction(async (tx) => {
      const userSnap = await tx.get(userRef);
      if (!userSnap.exists) return;
      // Stale-event guard: if the user has since moved to a different
      // purchase token, this event belongs to a superseded subscription
      // and must not clobber the current entitlement.
      const currentToken = userSnap.data()?.premiumToken as
        | string
        | null
        | undefined;
      if (currentToken != null && currentToken !== token) return;
      tx.update(userRef, {
        premiumUntil:
          status.premiumUntil > 0
            ? Timestamp.fromMillis(status.premiumUntil)
            : null,
        premiumToken: status.active ? token : null,
        premiumState: status.state,
        premiumUpdatedAt: Timestamp.now(),
      });
    });
  },
);
