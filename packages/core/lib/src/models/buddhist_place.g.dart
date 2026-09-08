// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'buddhist_place.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BuddhistPlaceImpl _$$BuddhistPlaceImplFromJson(Map json) =>
    _$BuddhistPlaceImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      thumbUrl: json['thumbUrl'] as String?,
      imageUrls: (json['imageUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$$BuddhistPlaceImplToJson(_$BuddhistPlaceImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'thumbUrl': instance.thumbUrl,
      'imageUrls': instance.imageUrls,
      'sortOrder': instance.sortOrder,
      'isActive': instance.isActive,
    };
