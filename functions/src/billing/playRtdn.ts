import { onMessagePublished } from "firebase-functions/v2/pubsub";
import { getFirestore, Timestamp } from "firebase-admin/firestore";
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
 */
export const playRtdn = onMessagePublished(
  { region: "asia-south1", topic: "play-subscriptions" },
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
    // Find the user who owns this purchase token.
    const snap = await db
      .collection("users")
      .where("premiumToken", "==", token)
      .limit(1)
      .get();
    if (snap.empty) return;
    const userRef = snap.docs[0].ref;

    let status;
    try {
      status = await fetchSubscriptionStatus(token);
    } catch {
      return; // transient; Play will retry via Pub/Sub redelivery
    }

    await userRef.set(
      {
        premiumUntil:
          status.premiumUntil > 0
            ? Timestamp.fromMillis(status.premiumUntil)
            : null,
        premiumToken: status.active ? token : null,
        premiumState: status.state,
        premiumUpdatedAt: Timestamp.now(),
      },
      { merge: true },
    );
  },
);
