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
  freeDailySeconds: 210,
  paidDailySeconds: 1800,
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

export async function readBodhiConfig(): Promise<BodhiAiConfig> {
  const snap = await getFirestore()
    .collection("config")
    .doc("bodhi_ai")
    .get();
  const d = snap.data() ?? {};
  const instruction = (d.systemInstruction ?? {}) as Record<string, unknown>;
  return {
    enabled: d.enabled === true,
    model: str(d.model, DEFAULTS.model),
    systemInstruction: {
      en: str(instruction.en, ""),
      hi: str(instruction.hi, ""),
      mr: str(instruction.mr, ""),
    },
    freeDailySeconds: num(d.freeDailySeconds, DEFAULTS.freeDailySeconds),
    paidDailySeconds: num(d.paidDailySeconds, DEFAULTS.paidDailySeconds),
    freeDailyMessages: num(d.freeDailyMessages, DEFAULTS.freeDailyMessages),
    paidDailyMessages: num(d.paidDailyMessages, DEFAULTS.paidDailyMessages),
    maxTokens: num(d.maxTokens, DEFAULTS.maxTokens),
    temperature: num(d.temperature, DEFAULTS.temperature),
  };
}

/** Resolve the admin tone instruction for a language, English-fallback. */
export function instructionFor(config: BodhiAiConfig, lang: string): string {
  const t = config.systemInstruction;
  const byLang = lang === "hi" ? t.hi : lang === "mr" ? t.mr : t.en;
  return byLang.trim().length > 0 ? byLang : t.en;
}
