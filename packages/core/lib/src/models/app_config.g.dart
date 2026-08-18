// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppConfigImpl _$$AppConfigImplFromJson(Map json) => _$AppConfigImpl(
      minSupportedVersion: json['minSupportedVersion'] as String? ?? '1.0.0',
      latestVersion: json['latestVersion'] as String? ?? '1.0.0',
      forceUpdate: json['forceUpdate'] as bool? ?? false,
      maintenanceMode: json['maintenanceMode'] as bool? ?? false,
      maintenanceMessage: json['maintenanceMessage'] == null
          ? const LocalisedText()
          : LocalisedText.fromJson(
              Map<String, dynamic>.from(json['maintenanceMessage'] as Map)),
      languages: (json['languages'] as List<dynamic>?)
              ?.map((e) =>
                  LanguageOption.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const <LanguageOption>[],
      adsEnabled: json['adsEnabled'] as bool? ?? false,
      idCardEnabled: json['idCardEnabled'] as bool? ?? false,
      liveWallpaperEnabled: json['liveWallpaperEnabled'] as bool? ?? false,
      updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
    );

Map<String, dynamic> _$$AppConfigImplToJson(_$AppConfigImpl instance) =>
    <String, dynamic>{
      'minSupportedVersion': instance.minSupportedVersion,
      'latestVersion': instance.latestVersion,
      'forceUpdate': instance.forceUpdate,
      'maintenanceMode': instance.maintenanceMode,
      'maintenanceMessage': instance.maintenanceMessage.toJson(),
      'languages': instance.languages.map((e) => e.toJson()).toList(),
      'adsEnabled': instance.adsEnabled,
      'idCardEnabled': instance.idCardEnabled,
      'liveWallpaperEnabled': instance.liveWallpaperEnabled,
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
    };

_$LanguageOptionImpl _$$LanguageOptionImplFromJson(Map json) =>
    _$LanguageOptionImpl(
      code: json['code'] as String,
      name: json['name'] as String,
      native: json['native'] as String,
    );

Map<String, dynamic> _$$LanguageOptionImplToJson(
        _$LanguageOptionImpl instance) =>
    <String, dynamic>{
      'code': instance.code,
      'name': instance.name,
      'native': instance.native,
    };
