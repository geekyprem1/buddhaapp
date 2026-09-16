import { HttpsError, onCall } from "firebase-functions/v2/https";
import { readBodhiConfig } from "./config";
import { accrueSession, isPremium } from "./quota";

interface BodhiSessionRequest {
  action?: unknown;
}

/**
 * Drives minute accrual for Bodhi AI. The client calls this on `start` when
 * the chat screen becomes active, every ~20 s as a `heartbeat` while it stays
 * open and foregrounded, and `end` on leaving. Time is credited server-side in
 * capped ticks (see `quota.ts`), so a modified or backgrounded client cannot
 * inflate — or, past a missed `end`, bleed — the daily allowance.
 *
 * No model call and no OpenRouter key here, so App Check enforcement is not
 * strictly required for cost, but we enforce it anyway for consistency with
 * `bodhiChat`: a client that can chat can also tick.
 */
export const bodhiSession = onCall(
  { region: "asia-south1", enforceAppCheck: true },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Sign in required.");
    }
    const uid = request.auth.uid;

    const data = (request.data ?? {}) as BodhiSessionRequest;
    const action = data.action;
    if (action !== "start" && action !== "heartbeat" && action !== "end") {
      throw new HttpsError(
        "invalid-argument",
        "action must be start, heartbeat, or end.",
      );
    }

    const config = await readBodhiConfig();
    if (!config.enabled) {
      throw new HttpsError("failed-precondition", "Bodhi AI is turned off.");
    }

    const premium = await isPremium(uid);
    const remaining = await accrueSession({
      uid,
      isPremium: premium,
      config,
      action,
    });

    return {
      remainingSeconds: remaining.remainingSeconds,
      remainingMessages: remaining.remainingMessages,
    };
  },
);
