import { HttpsError, onCall } from "firebase-functions/v2/https";
import { readBodhiConfig } from "./config";
import { isPremium, readRemaining } from "./quota";

/**
 * Reports today's remaining Bodhi AI allowance. Read-only: it charges nothing.
 *
 * The chat screen calls this once when it opens so the message counter is
 * populated immediately, rather than staying blank until the first reply.
 *
 * This replaces the old `bodhiSession` callable, which existed to accrue a
 * wall-clock time quota via a client heartbeat. That meter was removed (see
 * `quota.ts`) — the quota is now purely per-message, which needs no session
 * tracking, so there is nothing to start, tick, or end.
 *
 * No model call and no OpenRouter key here, so there is nothing to protect.
 * App Check was relaxed together with `bodhiChat`: current internal-testing
 * builds cannot attach a Play Integrity token, and an enforced check made the
 * chat screen's quota counter fail silently. Re-enable both together once a
 * build that passes Play Integrity is adopted.
 */
export const bodhiQuota = onCall(
  { region: "asia-south1" },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Sign in required.");
    }
    const uid = request.auth.uid;

    const config = await readBodhiConfig();
    if (!config.enabled) {
      throw new HttpsError("failed-precondition", "Bodhi AI is turned off.");
    }

    const premium = await isPremium(uid);
    const remaining = await readRemaining({ uid, isPremium: premium, config });

    return { remainingMessages: remaining.remainingMessages };
  },
);
