// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VideoImpl _$$VideoImplFromJson(Map json) => _$VideoImpl(
      id: json['id'] as String,
      title: LocalisedText.fromJson(
          Map<String, dynamic>.from(json['title'] as Map)),
      youtubeUrl: json['youtubeUrl'] as String,
      videoId: json['videoId'] as String,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$$VideoImplToJson(_$VideoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title.toJson(),
      'youtubeUrl': instance.youtubeUrl,
      'videoId': instance.videoId,
      'sortOrder': instance.sortOrder,
      'isActive': instance.isActive,
    };
