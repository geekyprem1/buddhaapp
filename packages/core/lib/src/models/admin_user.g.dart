// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AdminUserImpl _$$AdminUserImplFromJson(Map json) => _$AdminUserImpl(
      uid: json['uid'] as String,
      email: json['email'] as String,
      name: json['name'] as String? ?? '',
      role: json['role'] as String,
      isActive: json['isActive'] as bool? ?? true,
      createdBy: json['createdBy'] as String?,
      lastLoginAt: const TimestampConverter().fromJson(json['lastLoginAt']),
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
    );

Map<String, dynamic> _$$AdminUserImplToJson(_$AdminUserImpl instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'email': instance.email,
      'name': instance.name,
      'role': instance.role,
      'isActive': instance.isActive,
      'createdBy': instance.createdBy,
      'lastLoginAt': const TimestampConverter().toJson(instance.lastLoginAt),
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
    };
