import { HttpsError, onCall } from "firebase-functions/v2/https";
import { logger } from "firebase-functions/v2";
import { FieldValue, getFirestore, Timestamp } from "firebase-admin/firestore";

const WINDOW_MS = 15 * 60 * 1000; // 15 minutes
const MAX_REQUESTS = 5; // per phone number per window
const MAX_REQUESTS_PER_IP = 30; // per caller IP per window (B2)
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
 * at this point in the flow); App Check attests the app instead (per
 * Architecture §7), so scripts can't call this endpoint directly. A per-IP
 * throttle (B2) sits in front of the per-number counter so one caller can't
 * cheaply burn many victims' windows. Both counters live in Function-only
 * collections (Firestore rules deny all client reads/writes), so a client
 * can't reset its own counter. Invalid numbers are rejected before any
 * counter is touched.
 *
 * Residual (B2, stated honestly): no counting scheme can stop ONE attested
 * device from spending its 5 calls on a single victim's number — any
 * threshold ≥5 permits it, and a lower one would block legitimate retries.
 * Cap hits are therefore logged with caller context for admin review, and a
 * real closure needs an interaction proof (e.g. reCAPTCHA Enterprise score
 * verification) as a separate change.
 */

/** Best-effort caller IP for per-IP throttling (B2). Null when unavailable. */
function clientIp(request: { rawRequest?: unknown }): string | null {
  const raw = request.rawRequest as
    | { ip?: unknown; headers?: unknown }
    | undefined;
  if (typeof raw?.ip === "string" && raw.ip.length > 0) return raw.ip;
  const headers = raw?.headers as Record<string, unknown> | undefined;
  const fwd = headers?.["x-forwarded-for"];
  const first = Array.isArray(fwd) ? fwd[0] : fwd;
  if (typeof first === "string" && first.length > 0) {
    return first.split(",")[0].trim();
  }
  return null;
}

/** Firestore-safe doc id for an IP (strips `/`, caps length). */
function ipKey(ip: string): string {
  const clean = ip.replace(/[^a-zA-Z0-9.:-]/g, "_").slice(0, 64);
  return clean.length > 0 ? clean : "unknown";
}

export const guardOtpAbuse = onCall(
  { region: "asia-south1", enforceAppCheck: true },
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

    // Per-IP throttle first (B2): a single script must not be able to walk
    // through many victims' numbers. Counted only for well-formed requests.
    const ip = clientIp(request);
    if (ip) {
      const ipRef = db.collection("otpGuardsByIp").doc(ipKey(ip));
      await db.runTransaction(async (tx) => {
        const snap = await tx.get(ipRef);
        const guard = snap.data();
        const windowStart = (
          guard?.windowStart as Timestamp | undefined
        )?.toMillis();
        const count = (guard?.count as number | undefined) ?? 0;

        if (windowStart != null && now - windowStart < WINDOW_MS) {
          if (count >= MAX_REQUESTS_PER_IP) {
            const retryAfterSec = Math.ceil(
              (windowStart + WINDOW_MS - now) / 1000,
            );
            // Abuse signal for admin review (B2): who is spraying numbers.
            logger.warn("guardOtpAbuse: IP throttle hit", {
              ip: ipKey(ip),
              number: key,
            });
            throw new HttpsError(
              "resource-exhausted",
              `Too many OTP requests from this device. Try again in ${retryAfterSec}s.`,
            );
          }
          tx.set(ipRef, { count: count + 1 }, { merge: true });
        } else {
          tx.set(ipRef, {
            count: 1,
            windowStart: FieldValue.serverTimestamp(),
          });
        }
      });
    }

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
          // Abuse signal for admin review (B2): a capped number with a
          // caller IP attached distinguishes victim-retry noise from a
          // single device burning someone else's window.
          logger.warn("guardOtpAbuse: number throttle hit", {
            number: key,
            ip: ip ? ipKey(ip) : null,
          });
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
