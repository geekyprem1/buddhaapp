// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teacher.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TeacherImpl _$$TeacherImplFromJson(Map json) => _$TeacherImpl(
      id: json['id'] as String,
      name: LocalisedText.fromJson(
          Map<String, dynamic>.from(json['name'] as Map)),
      portraitUrl: json['portraitUrl'] as String?,
      thumbUrl: json['thumbUrl'] as String?,
      bio: json['bio'] == null
          ? null
          : LocalisedText.fromJson(
              Map<String, dynamic>.from(json['bio'] as Map)),
      signatureUrl: json['signatureUrl'] as String?,
      idCardPrefix: json['idCardPrefix'] as String?,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$$TeacherImplToJson(_$TeacherImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name.toJson(),
      'portraitUrl': instance.portraitUrl,
      'thumbUrl': instance.thumbUrl,
      'bio': instance.bio?.toJson(),
      'signatureUrl': instance.signatureUrl,
      'idCardPrefix': instance.idCardPrefix,
      'sortOrder': instance.sortOrder,
      'isActive': instance.isActive,
    };
