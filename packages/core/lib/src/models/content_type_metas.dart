import 'package:freezed_annotation/freezed_annotation.dart';

import '../utils/timestamp_converter.dart';

part 'content_type_metas.freezed.dart';
part 'content_type_metas.g.dart';

/// Type-specific metadata for wallpapers. `kind` is reserved for Phase 2
/// (`static` | `live`) per PRD D3 — MVP only ever produces `static`.
@freezed
class WallpaperMeta with _$WallpaperMeta {
  const factory WallpaperMeta({
    @Default('static') String kind,
    int? width,
    int? height,
    @Default('portrait') String orientation,
  }) = _WallpaperMeta;

  factory WallpaperMeta.fromJson(Map<String, dynamic> json) =>
      _$WallpaperMetaFromJson(json);
}

/// Type-specific metadata shared by ringtones, songs and meditations.
@freezed
class AudioMeta with _$AudioMeta {
  const factory AudioMeta({
    int? durationSec,
    String? waveformUrl,

    /// Groups multi-part meditation series (e.g. "AnaPana Meditation").
    String? seriesId,
    int? partNumber,

    /// `beginner` | `intermediate` — meditation only.
    String? level,
  }) = _AudioMeta;

  factory AudioMeta.fromJson(Map<String, dynamic> json) =>
      _$AudioMetaFromJson(json);
}

/// A normalised (0-1) rectangle used to position the photo frame or the
/// name text on a status image. Multiplying by the rendered box size gives
/// the same composition on any screen resolution (Architecture §9.4).
@freezed
class LayoutRect with _$LayoutRect {
  const factory LayoutRect({
    @Default(0) double x,
    @Default(0) double y,
    @Default(0) double w,
    @Default(0) double h,
  }) = _LayoutRect;

  factory LayoutRect.fromJson(Map<String, dynamic> json) =>
      _$LayoutRectFromJson(json);
}

@freezed
class StatusTextStyle with _$StatusTextStyle {
  const factory StatusTextStyle({
    @Default(0) double x,
    @Default(0) double y,
    @Default(0.6) double w,
    @Default('left') String align,
    @Default('Poppins') String font,

    /// Font size as a fraction of the rendered image height.
    @Default(0.045) double size,
    @Default('#1F1F1F') String color,
    @Default(700) int weight,
  }) = _StatusTextStyle;

  factory StatusTextStyle.fromJson(Map<String, dynamic> json) =>
      _$StatusTextStyleFromJson(json);
}

/// Type-specific metadata for Trending Status images.
@freezed
class StatusMeta with _$StatusMeta {
  const factory StatusMeta({
    @Default(LayoutRect(x: 0.62, y: 0.70, w: 0.22, h: 0.22))
    LayoutRect photoFrame,
    @Default(StatusTextStyle()) StatusTextStyle nameText,
    @Default(true) bool watermark,
    @TimestampConverter() DateTime? festivalDate,
  }) = _StatusMeta;

  factory StatusMeta.fromJson(Map<String, dynamic> json) =>
      _$StatusMetaFromJson(json);
}
