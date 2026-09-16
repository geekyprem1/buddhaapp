import { HttpsError } from "firebase-functions/v2/https";
import { FieldValue, getFirestore, Timestamp } from "firebase-admin/firestore";

/**
 * Server-authoritative daily quota for Bodhi AI, metered in MESSAGES.
 *
 * Counters live in `aiUsage/{uid}_{yyyy-MM-dd}`, a Function-only collection
 * (Firestore rules deny all client reads/writes). They are NOT on
 * `users/{uid}` because the owner can freely write most fields there and would
 * be able to reset their own quota. The transactional read-modify-write mirrors
 * `functions/src/auth/guardOtpAbuse.ts`.
 *
 * There used to be a second meter here: a daily *time* budget that accrued
 * while the chat screen was open, ticked by a client heartbeat. It was removed.
 * Wall-clock time is a poor proxy for cost and a hostile unit for the user —
 * it burned while they read a long answer or thought about their next question,
 * and any missed "session end" leaked the capped tail of a tick. Messages map
 * directly to what is actually spent upstream, and are trivial for the user to
 * reason about ("12 of 15 left today").
 */

/** Off-topic questions per day before the refusal path is rate-limited. */
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
  freeDailyMessages: number;
  paidDailyMessages: number;
}

export interface Remaining {
  remainingMessages: number;
}

interface UsageDoc {
  messages?: number;
  offTopicStrikes?: number;
  /** Last reservation time — kept for support/debugging, not for metering. */
  lastAnswerAt?: Timestamp;
  tier?: string;
}

function limitsFor(config: QuotaConfig, isPremium: boolean) {
  return {
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
  return docRefFor(uid, todayKey());
}

/** Usage doc for an explicit day (N6): refunds must hit the day that was charged. */
function docRefFor(uid: string, day: string) {
  return getFirestore().collection("aiUsage").doc(`${uid}_${day}`);
}

function remainingFrom(
  data: UsageDoc | undefined,
  limits: { messages: number },
): Remaining {
  return {
    remainingMessages: Math.max(0, limits.messages - (data?.messages ?? 0)),
  };
}

/**
 * Read today's remaining allowance without charging anything.
 *
 * Used by the `bodhiQuota` callable so the chat screen can show the count as
 * soon as it opens, instead of leaving the user guessing until their first
 * reply lands.
 */
export async function readRemaining(params: {
  uid: string;
  isPremium: boolean;
  config: QuotaConfig;
}): Promise<Remaining> {
  const { uid, isPremium: premium, config } = params;
  const snap = await docRef(uid).get();
  return remainingFrom(
    snap.data() as UsageDoc | undefined,
    limitsFor(config, premium),
  );
}

export interface ChargeContext {
  remaining: Remaining;
  offTopicStrikes: number;
  /** Day key of the usage doc that was charged (N6) — pass back to refunds. */
  day: string;
}

/**
 * Reserve one message before answering, enforcing the daily message cap and
 * the off-topic strike limit. Throws `resource-exhausted` when spent.
 *
 * Charges a whole message immediately; the answering call decides afterwards
 * whether the question was off-topic and refunds via [recordOffTopic].
 */
export async function reserveMessage(params: {
  uid: string;
  isPremium: boolean;
  config: QuotaConfig;
}): Promise<ChargeContext> {
  const { uid, isPremium: premium, config } = params;
  const limits = limitsFor(config, premium);
  // Pin the reservation to one day doc (N6): a slow answer crossing midnight
  // must refund the day that was actually charged.
  const day = todayKey();
  const ref = docRefFor(uid, day);
  const db = getFirestore();

  return db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    const data = snap.data() as UsageDoc | undefined;
    const now = Timestamp.now();
    const strikes = data?.offTopicStrikes ?? 0;
    const messages = data?.messages ?? 0;

    if (strikes >= MAX_OFFTOPIC_STRIKES) {
      throw new HttpsError(
        "resource-exhausted",
        "Too many off-topic questions today. Please try again tomorrow.",
        { reason: "off-topic-limit" },
      );
    }
    if (messages >= limits.messages) {
      throw new HttpsError(
        "resource-exhausted",
        "You've reached today's message limit. It resets tomorrow.",
        { reason: "message-limit" },
      );
    }

    tx.set(
      ref,
      {
        uid,
        date: day,
        tier: premium ? "paid" : "free",
        messages: messages + 1,
        offTopicStrikes: strikes,
        lastAnswerAt: now,
      },
      { merge: true },
    );

    return {
      remaining: remainingFrom({ ...data, messages: messages + 1 }, limits),
      offTopicStrikes: strikes,
      day,
    };
  });
}

/**
 * Called when the answering model declines an off-topic question. Refunds the
 * message charged by [reserveMessage] (a refusal should not cost the user), and
 * records a strike so the refusal path cannot be farmed.
 */
export async function recordOffTopic(params: {
  uid: string;
  isPremium: boolean;
  config: QuotaConfig;
  /** Day charged by the matching [reserveMessage] (N6); defaults to today. */
  day?: string;
}): Promise<Remaining> {
  const { uid, isPremium: premium, config } = params;
  const limits = limitsFor(config, premium);
  const ref = params.day ? docRefFor(uid, params.day) : docRef(uid);
  const db = getFirestore();

  return db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    const data = snap.data() as UsageDoc | undefined;
    const messages = Math.max(0, (data?.messages ?? 0) - 1);
    const strikes = (data?.offTopicStrikes ?? 0) + 1;

    tx.set(ref, { messages, offTopicStrikes: strikes }, { merge: true });
    return remainingFrom({ ...data, messages }, limits);
  });
}

/**
 * Refund a message reserved by [reserveMessage] when answering failed or came
 * back empty (A3/N5). No strike — the user did nothing wrong.
 */
export async function refundMessage(params: {
  uid: string;
  isPremium: boolean;
  config: QuotaConfig;
  /** Day charged by the matching [reserveMessage] (N6); defaults to today. */
  day?: string;
}): Promise<Remaining> {
  const { uid, isPremium: premium, config } = params;
  const limits = limitsFor(config, premium);
  const ref = params.day ? docRefFor(uid, params.day) : docRef(uid);
  const db = getFirestore();

  return db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    const data = snap.data() as UsageDoc | undefined;
    const messages = Math.max(0, (data?.messages ?? 0) - 1);

    tx.set(ref, { messages }, { merge: true });
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
  /** Day charged by the matching [reserveMessage] (N6); defaults to today. */
  day?: string;
}): Promise<void> {
  try {
    const ref = params.day
      ? docRefFor(params.uid, params.day)
      : docRef(params.uid);
    await ref.set(
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
