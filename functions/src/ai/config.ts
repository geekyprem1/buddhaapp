import { getFirestore } from "firebase-admin/firestore";
import type { QuotaConfig } from "./quota";

/**
 * Server-side view of `config/bodhi_ai`, edited from the admin panel.
 * Mirrors `BodhiAiConfig` in `packages/core`. Defaults match that model, so a
 * missing doc still yields a working (but disabled) config.
 */
export interface BodhiAiConfig extends QuotaConfig {
  enabled: boolean;
  model: string;
  /** Resolved system instruction for the caller's language. */
  systemInstruction: { en: string; hi: string; mr: string };
  maxTokens: number;
  temperature: number;
}

const DEFAULTS: BodhiAiConfig = {
  enabled: false,
  model: "deepseek/deepseek-v4-flash-0731",
  systemInstruction: { en: "", hi: "", mr: "" },
  freeDailyMessages: 15,
  paidDailyMessages: 120,
  maxTokens: 700,
  temperature: 0.4,
};

function num(value: unknown, fallback: number): number {
  return typeof value === "number" && Number.isFinite(value) ? value : fallback;
}

function str(value: unknown, fallback: string): string {
  return typeof value === "string" && value.length > 0 ? value : fallback;
}

/**
 * Server-side guardrails for admin-editable numeric config (A13). The admin
 * panel is a typo away from an outsized bill or a total outage, so values
 * outside sane bounds fall back (or clamp) to defaults here — the client is
 * never trusted and the panel's own checks are only a first line.
 */
function clampInt(
  value: unknown,
  min: number,
  max: number,
  fallback: number,
): number {
  const n = num(value, fallback);
  if (n < min) return fallback;
  if (n > max) return max;
  return Math.floor(n);
}

function clampFloat(
  value: unknown,
  min: number,
  max: number,
  fallback: number,
): number {
  const n = num(value, fallback);
  if (n < min) return fallback;
  if (n > max) return max;
  return n;
}

/** Pinned `vendor/model` slugs only — no aliases, no bare words (A13). */
const MODEL_PATTERN = /^[a-z0-9][a-z0-9._-]*\/[a-z0-9][a-z0-9._:-]*$/i;

function modelSlug(value: unknown, fallback: string): string {
  if (typeof value !== "string") return fallback;
  const slug = value.trim();
  if (!MODEL_PATTERN.test(slug)) return fallback;
  // A "…-latest" alias silently re-points at new checkpoints the tone prompt
  // was never tested against — and a typo'd alias 404s every answer.
  if (slug.toLowerCase().includes("latest")) return fallback;
  return slug;
}

export async function readBodhiConfig(): Promise<BodhiAiConfig> {
  const snap = await getFirestore()
    .collection("config")
    .doc("bodhi_ai")
    .get();
  const d = snap.data() ?? {};
  const instruction = (d.systemInstruction ?? {}) as Record<string, unknown>;
  return {
    enabled: d.enabled === true,
    model: modelSlug(d.model, DEFAULTS.model),
    systemInstruction: {
      en: str(instruction.en, ""),
      hi: str(instruction.hi, ""),
      mr: str(instruction.mr, ""),
    },
    freeDailyMessages: clampInt(
      d.freeDailyMessages,
      0,
      1000,
      DEFAULTS.freeDailyMessages,
    ),
    paidDailyMessages: clampInt(
      d.paidDailyMessages,
      0,
      1000,
      DEFAULTS.paidDailyMessages,
    ),
    maxTokens: clampInt(d.maxTokens, 50, 2000, DEFAULTS.maxTokens),
    temperature: clampFloat(d.temperature, 0, 2, DEFAULTS.temperature),
  };
}

/** Resolve the admin tone instruction for a language, English-fallback. */
export function instructionFor(config: BodhiAiConfig, lang: string): string {
  const t = config.systemInstruction;
  const byLang = lang === "hi" ? t.hi : lang === "mr" ? t.mr : t.en;
  return byLang.trim().length > 0 ? byLang : t.en;
}
