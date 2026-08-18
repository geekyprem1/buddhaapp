// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_type_metas.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WallpaperMetaImpl _$$WallpaperMetaImplFromJson(Map json) =>
    _$WallpaperMetaImpl(
      kind: json['kind'] as String? ?? 'static',
      width: (json['width'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toInt(),
      orientation: json['orientation'] as String? ?? 'portrait',
    );

Map<String, dynamic> _$$WallpaperMetaImplToJson(_$WallpaperMetaImpl instance) =>
    <String, dynamic>{
      'kind': instance.kind,
      'width': instance.width,
      'height': instance.height,
      'orientation': instance.orientation,
    };

_$AudioMetaImpl _$$AudioMetaImplFromJson(Map json) => _$AudioMetaImpl(
      durationSec: (json['durationSec'] as num?)?.toInt(),
      waveformUrl: json['waveformUrl'] as String?,
      seriesId: json['seriesId'] as String?,
      partNumber: (json['partNumber'] as num?)?.toInt(),
      level: json['level'] as String?,
    );

Map<String, dynamic> _$$AudioMetaImplToJson(_$AudioMetaImpl instance) =>
    <String, dynamic>{
      'durationSec': instance.durationSec,
      'waveformUrl': instance.waveformUrl,
      'seriesId': instance.seriesId,
      'partNumber': instance.partNumber,
      'level': instance.level,
    };

_$LayoutRectImpl _$$LayoutRectImplFromJson(Map json) => _$LayoutRectImpl(
      x: (json['x'] as num?)?.toDouble() ?? 0,
      y: (json['y'] as num?)?.toDouble() ?? 0,
      w: (json['w'] as num?)?.toDouble() ?? 0,
      h: (json['h'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$$LayoutRectImplToJson(_$LayoutRectImpl instance) =>
    <String, dynamic>{
      'x': instance.x,
      'y': instance.y,
      'w': instance.w,
      'h': instance.h,
    };

_$StatusTextStyleImpl _$$StatusTextStyleImplFromJson(Map json) =>
    _$StatusTextStyleImpl(
      x: (json['x'] as num?)?.toDouble() ?? 0,
      y: (json['y'] as num?)?.toDouble() ?? 0,
      w: (json['w'] as num?)?.toDouble() ?? 0.6,
      align: json['align'] as String? ?? 'left',
      font: json['font'] as String? ?? 'Poppins',
      size: (json['size'] as num?)?.toDouble() ?? 0.045,
      color: json['color'] as String? ?? '#1F1F1F',
      weight: (json['weight'] as num?)?.toInt() ?? 700,
    );

Map<String, dynamic> _$$StatusTextStyleImplToJson(
        _$StatusTextStyleImpl instance) =>
    <String, dynamic>{
      'x': instance.x,
      'y': instance.y,
      'w': instance.w,
      'align': instance.align,
      'font': instance.font,
      'size': instance.size,
      'color': instance.color,
      'weight': instance.weight,
    };

_$StatusMetaImpl _$$StatusMetaImplFromJson(Map json) => _$StatusMetaImpl(
      photoFrame: json['photoFrame'] == null
          ? const LayoutRect(x: 0.62, y: 0.70, w: 0.22, h: 0.22)
          : LayoutRect.fromJson(
              Map<String, dynamic>.from(json['photoFrame'] as Map)),
      nameText: json['nameText'] == null
          ? const StatusTextStyle()
          : StatusTextStyle.fromJson(
              Map<String, dynamic>.from(json['nameText'] as Map)),
      watermark: json['watermark'] as bool? ?? true,
      festivalDate: const TimestampConverter().fromJson(json['festivalDate']),
    );

Map<String, dynamic> _$$StatusMetaImplToJson(_$StatusMetaImpl instance) =>
    <String, dynamic>{
      'photoFrame': instance.photoFrame.toJson(),
      'nameText': instance.nameText.toJson(),
      'watermark': instance.watermark,
      'festivalDate': const TimestampConverter().toJson(instance.festivalDate),
    };
