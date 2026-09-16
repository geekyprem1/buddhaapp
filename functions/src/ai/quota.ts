import { HttpsError } from "firebase-functions/v2/https";
import { FieldValue, getFirestore, Timestamp } from "firebase-admin/firestore";

/**
 * Server-authoritative daily quota for Bodhi AI.
 *
 * Counters live in `aiUsage/{uid}_{yyyy-MM-dd}`, a Function-only collection
 * (Firestore rules deny all client reads/writes). They are NOT on
 * `users/{uid}` because the owner can freely write most fields there and would
 * be able to reset their own quota. The transactional read-modify-write mirrors
 * `functions/src/auth/guardOtpAbuse.ts`.
 *
 * Minutes accrue only between a `bodhiSession('start')` and `('end')`, in
 * capped ticks, so a killed app or lost network cannot bleed the whole day.
 */

/** Max seconds credited to a single tick — bounds damage from a missed `end`. */
const IDLE_CAP_SECONDS = 30;

/** Off-topic questions per day before the gate itself is rate-limited. */
const MAX_OFFTOPIC_STRIKES = 20;

/** The day key in Asia/Kolkata, so "daily" matches the user's calendar day. */
export function todayKey(now: Date = new Date()): string {
  // en-CA gives yyyy-MM-dd; timeZone shifts it to IST regardless of server TZ.
  return new Intl.DateTimeFormat("en-CA", {
    timeZone: "Asia/Kolkata",
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  }).format(now);
}

export interface QuotaConfig {
  freeDailySeconds: number;
  paidDailySeconds: number;
  freeDailyMessages: number;
  paidDailyMessages: number;
}

export interface Remaining {
  remainingSeconds: number;
  remainingMessages: number;
}

interface UsageDoc {
  usedSeconds?: number;
  messages?: number;
  offTopicStrikes?: number;
  lastTickAt?: Timestamp;
  sessionOpen?: boolean;
  tier?: string;
}

function limitsFor(config: QuotaConfig, isPremium: boolean) {
  return {
    seconds: isPremium ? config.paidDailySeconds : config.freeDailySeconds,
    messages: isPremium ? config.paidDailyMessages : config.freeDailyMessages,
  };
}

/** True when `users/{uid}.premiumUntil` is a future Timestamp. */
export async function isPremium(uid: string): Promise<boolean> {
  const snap = await getFirestore().collection("users").doc(uid).get();
  const raw = snap.get("premiumUntil");
  return raw instanceof Timestamp && raw.toMillis() > Date.now();
}

function docRef(uid: string) {
  return getFirestore().collection("aiUsage").doc(`${uid}_${todayKey()}`);
}

function remainingFrom(
  data: UsageDoc | undefined,
  limits: { seconds: number; messages: number },
): Remaining {
  return {
    remainingSeconds: Math.max(0, limits.seconds - (data?.usedSeconds ?? 0)),
    remainingMessages: Math.max(0, limits.messages - (data?.messages ?? 0)),
  };
}

/**
 * Open / tick / close a session, accruing capped elapsed seconds on every
 * tick. Returns the remaining allowance. Throws `resource-exhausted` once the
 * day's seconds are spent.
 */
export async function accrueSession(params: {
  uid: string;
  isPremium: boolean;
  config: QuotaConfig;
  action: "start" | "heartbeat" | "end";
}): Promise<Remaining> {
  const { uid, isPremium: premium, config, action } = params;
  const limits = limitsFor(config, premium);
  const ref = docRef(uid);
  const db = getFirestore();

  return db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    const data = snap.data() as UsageDoc | undefined;
    const now = Timestamp.now();

    let usedSeconds = data?.usedSeconds ?? 0;

    // Credit elapsed time since the last tick, but only while a session was
    // already open (so 'start' itself never charges).
    if (action !== "start" && data?.sessionOpen === true && data.lastTickAt) {
      const elapsed = Math.floor(
        (now.toMillis() - data.lastTickAt.toMillis()) / 1000,
      );
      usedSeconds += Math.max(0, Math.min(elapsed, IDLE_CAP_SECONDS));
    }

    tx.set(
      ref,
      {
        uid,
        date: todayKey(),
        tier: premium ? "paid" : "free",
        usedSeconds,
        messages: data?.messages ?? 0,
        offTopicStrikes: data?.offTopicStrikes ?? 0,
        sessionOpen: action !== "end",
        lastTickAt: now,
      },
      { merge: true },
    );

    const remaining = remainingFrom({ ...data, usedSeconds }, limits);
    if (action !== "end" && remaining.remainingSeconds <= 0) {
      throw new HttpsError(
        "resource-exhausted",
        "You've used today's chat time. It resets tomorrow.",
      );
    }
    return remaining;
  });
}

export interface ChargeContext {
  remaining: Remaining;
  offTopicStrikes: number;
}

/**
 * Reserve one message before answering. Checks both the seconds budget (a
 * message costs at least [IDLE_CAP_SECONDS]) and the daily message cap, and
 * enforces the off-topic strike limit. Throws `resource-exhausted` when spent.
 *
 * Charges a whole message immediately; the topic gate decides afterwards
 * whether to also count an off-topic strike (via [recordOffTopic]).
 */
export async function reserveMessage(params: {
  uid: string;
  isPremium: boolean;
  config: QuotaConfig;
}): Promise<ChargeContext> {
  const { uid, isPremium: premium, config } = params;
  const limits = limitsFor(config, premium);
  const ref = docRef(uid);
  const db = getFirestore();

  return db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    const data = snap.data() as UsageDoc | undefined;
    const strikes = data?.offTopicStrikes ?? 0;
    const messages = data?.messages ?? 0;
    const usedSeconds = data?.usedSeconds ?? 0;

    if (strikes >= MAX_OFFTOPIC_STRIKES) {
      throw new HttpsError(
        "resource-exhausted",
        "Too many off-topic questions today. Please try again tomorrow.",
      );
    }
    if (messages >= limits.messages) {
      throw new HttpsError(
        "resource-exhausted",
        "You've reached today's message limit. It resets tomorrow.",
      );
    }
    if (usedSeconds >= limits.seconds) {
      throw new HttpsError(
        "resource-exhausted",
        "You've used today's chat time. It resets tomorrow.",
      );
    }

    tx.set(
      ref,
      {
        uid,
        date: todayKey(),
        tier: premium ? "paid" : "free",
        messages: messages + 1,
        usedSeconds,
        offTopicStrikes: strikes,
      },
      { merge: true },
    );

    return {
      remaining: remainingFrom({ ...data, messages: messages + 1 }, limits),
      offTopicStrikes: strikes,
    };
  });
}

/**
 * Called after the topic gate rejects a question. Refunds the message charged
 * by [reserveMessage] (a refusal should not cost the user), and records a
 * strike so the free classifier cannot be farmed.
 */
export async function recordOffTopic(params: {
  uid: string;
  isPremium: boolean;
  config: QuotaConfig;
}): Promise<Remaining> {
  const { uid, isPremium: premium, config } = params;
  const limits = limitsFor(config, premium);
  const ref = docRef(uid);
  const db = getFirestore();

  return db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    const data = snap.data() as UsageDoc | undefined;
    const messages = Math.max(0, (data?.messages ?? 0) - 1);
    const strikes = (data?.offTopicStrikes ?? 0) + 1;

    tx.set(
      ref,
      { messages, offTopicStrikes: strikes },
      { merge: true },
    );
    return remainingFrom({ ...data, messages }, limits);
  });
}

/**
 * Record real token usage after a successful answer, for cost reporting.
 * Best-effort: never throws (a bookkeeping failure must not fail the reply).
 */
export async function recordTokens(params: {
  uid: string;
  promptTokens: number;
  completionTokens: number;
}): Promise<void> {
  try {
    await docRef(params.uid).set(
      {
        promptTokens: FieldValue.increment(params.promptTokens),
        completionTokens: FieldValue.increment(params.completionTokens),
      },
      { merge: true },
    );
  } catch {
    // ignore
  }
}
