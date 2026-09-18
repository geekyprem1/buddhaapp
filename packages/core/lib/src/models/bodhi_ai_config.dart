import 'package:freezed_annotation/freezed_annotation.dart';

import '../utils/timestamp_converter.dart';
import 'localised_text.dart';

part 'bodhi_ai_config.freezed.dart';
part 'bodhi_ai_config.g.dart';

/// `config/bodhi_ai` — admin-controlled settings for the Bodhi AI chat
/// ("Ask Buddha"). See `.kiro/specs/bodhi-ai-chat/design.md`.
///
/// Read by the mobile app (to show quota and hide the tab when disabled) and
/// by the `bodhiChat` Cloud Function (which is the only thing that may act on
/// [model], [maxTokens] and the quota fields — the client is never trusted
/// with those).
///
/// [enabled] defaults to `false` so the feature ships dark and is switched on
/// from the admin panel without a release, matching `AppConfig.adsEnabled` and
/// friends.
@freezed
class BodhiAiConfig with _$BodhiAiConfig {
  const factory BodhiAiConfig({
    @Default(false) bool enabled,

    /// OpenRouter model slug.
    ///
    /// Deliberately a pinned, dated checkpoint. Do **not** set this to a
    /// `~vendor/model-latest` alias — an alias silently re-points to a new
    /// checkpoint, so a tuned [systemInstruction] would one day run against a
    /// model it was never tested on.
    @Default('deepseek/deepseek-v4-flash-0731') String model,

    /// Tone and style guidance, per locale.
    ///
    /// This does **not** carry the Buddhism-only restriction. That rule is
    /// hardcoded in the Function and prepended to whatever is stored here, so
    /// an admin cannot remove it from this field. Empty means "use the
    /// Function's built-in default tone".
    @Default(LocalisedText()) LocalisedText systemInstruction,

    /// The daily allowance, and the only meter.
    ///
    /// There was briefly a second, wall-clock meter here (`freeDailySeconds` /
    /// `paidDailySeconds`) that drained while the chat screen was open. It was
    /// removed: time is a poor proxy for cost and a hostile unit for the user,
    /// since it burned while they read a reply or thought about the next
    /// question. Messages map to what is actually spent upstream.
    @Default(15) int freeDailyMessages,
    @Default(120) int paidDailyMessages,

    /// Per-reply output ceiling, so one "write me an essay" prompt cannot
    /// produce an outsized bill.
    @Default(300) int maxTokens,

    /// Lower is more factual. Doctrinal answers should not be inventive.
    @Default(0.4) double temperature,
    @TimestampConverter() DateTime? updatedAt,
  }) = _BodhiAiConfig;

  factory BodhiAiConfig.fromJson(Map<String, dynamic> json) =>
      _$BodhiAiConfigFromJson(json);
}

extension BodhiAiConfigX on BodhiAiConfig {
  /// Daily message cap for the caller's tier. [isPremium] comes from the
  /// server-verified `users/{uid}.premiumUntil`, never from a local flag.
  int messagesFor({required bool isPremium}) =>
      isPremium ? paidDailyMessages : freeDailyMessages;
}
