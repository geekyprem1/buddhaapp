import 'package:freezed_annotation/freezed_annotation.dart';

import '../utils/timestamp_converter.dart';
import 'localised_text.dart';

part 'app_config.freezed.dart';
part 'app_config.g.dart';

/// `config/app_config` — remote-controlled flags and copy
/// (Architecture §6.2, PRD AR-7.1). Feature flags start `false` so Phase 2
/// work can ship dark and be enabled without a release.
@freezed
class AppConfig with _$AppConfig {
  const factory AppConfig({
    @Default('1.0.0') String minSupportedVersion,
    @Default('1.0.0') String latestVersion,
    @Default(false) bool forceUpdate,
    @Default(false) bool maintenanceMode,
    @Default(LocalisedText()) LocalisedText maintenanceMessage,
    @Default(<LanguageOption>[]) List<LanguageOption> languages,

    /// Phase 2 (PRD D5).
    @Default(false) bool adsEnabled,

    /// Phase 2 (PRD D4).
    @Default(false) bool idCardEnabled,

    /// Phase 2 (PRD D3).
    @Default(false) bool liveWallpaperEnabled,
    @TimestampConverter() DateTime? updatedAt,
  }) = _AppConfig;

  factory AppConfig.fromJson(Map<String, dynamic> json) =>
      _$AppConfigFromJson(json);
}

@freezed
class LanguageOption with _$LanguageOption {
  const factory LanguageOption({
    required String code,
    required String name,
    required String native,
  }) = _LanguageOption;

  factory LanguageOption.fromJson(Map<String, dynamic> json) =>
      _$LanguageOptionFromJson(json);
}
