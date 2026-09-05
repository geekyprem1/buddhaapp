// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wisdom.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WisdomImpl _$$WisdomImplFromJson(Map json) => _$WisdomImpl(
      id: json['id'] as String,
      title: LocalisedText.fromJson(
          Map<String, dynamic>.from(json['title'] as Map)),
      body: LocalisedText.fromJson(
          Map<String, dynamic>.from(json['body'] as Map)),
      imageUrl: json['imageUrl'] as String?,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$$WisdomImplToJson(_$WisdomImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title.toJson(),
      'body': instance.body.toJson(),
      'imageUrl': instance.imageUrl,
      'sortOrder': instance.sortOrder,
      'isActive': instance.isActive,
    };
