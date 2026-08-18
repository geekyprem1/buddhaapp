// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CategoryImpl _$$CategoryImplFromJson(Map json) => _$CategoryImpl(
      id: json['id'] as String,
      module: json['module'] as String,
      name: LocalisedText.fromJson(
          Map<String, dynamic>.from(json['name'] as Map)),
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$$CategoryImplToJson(_$CategoryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'module': instance.module,
      'name': instance.name.toJson(),
      'sortOrder': instance.sortOrder,
      'isActive': instance.isActive,
    };
