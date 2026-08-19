import { HttpsError, onCall } from "firebase-functions/v2/https";
import { FieldValue, getFirestore, Timestamp } from "firebase-admin/firestore";

const WINDOW_MS = 15 * 60 * 1000; // 15 minutes
const MAX_REQUESTS = 5; // per phone number per window
const E164 = /^\+[1-9]\d{6,14}$/;

interface GuardOtpAbuseRequest {
  phoneNumber?: string;
}

/**
 * `guardOtpAbuse` (Architecture §8, T2.11, FR-2.9). Called by the mobile
 * client immediately before `startPhoneVerification` — Firebase Phone Auth
 * has no server-side hook of its own to rate-limit, so the app asks this
 * callable for permission first and only proceeds if it doesn't throw.
 *
 * Deliberately **not** `request.auth`-gated (there is no signed-in user yet
 * at this point in the flow); App Check is the intended defence per
 * Architecture §7, enforced once T0.6 lands. The per-number counter lives in
 * `otpGuards/{phoneKey}`, a Function-only collection (Firestore rules deny
 * all client reads/writes), so a client can't reset its own counter.
 */
export const guardOtpAbuse = onCall(
  { region: "asia-south1" },
  async (request) => {
    const data = (request.data ?? {}) as GuardOtpAbuseRequest;
    const phoneNumber = data.phoneNumber?.trim();
    if (!phoneNumber || !E164.test(phoneNumber)) {
      throw new HttpsError(
        "invalid-argument",
        "phoneNumber must be E.164, e.g. +919625460555.",
      );
    }

    const db = getFirestore();
    const key = phoneNumber.replace(/[^0-9+]/g, "");
    const ref = db.collection("otpGuards").doc(key);
    const now = Date.now();

    await db.runTransaction(async (tx) => {
      const snap = await tx.get(ref);
      const guard = snap.data();
      const windowStart = (guard?.windowStart as Timestamp | undefined)?.toMillis();
      const count = (guard?.count as number | undefined) ?? 0;

      if (windowStart != null && now - windowStart < WINDOW_MS) {
        if (count >= MAX_REQUESTS) {
          const retryAfterSec = Math.ceil(
            (windowStart + WINDOW_MS - now) / 1000,
          );
          throw new HttpsError(
            "resource-exhausted",
            `Too many OTP requests for this number. Try again in ${retryAfterSec}s.`,
          );
        }
        tx.set(ref, { count: count + 1 }, { merge: true });
      } else {
        tx.set(ref, {
          count: 1,
          windowStart: FieldValue.serverTimestamp(),
        });
      }
    });

    return { allowed: true };
  },
);
