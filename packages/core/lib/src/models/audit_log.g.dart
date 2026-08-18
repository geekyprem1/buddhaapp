// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audit_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AuditLogImpl _$$AuditLogImplFromJson(Map json) => _$AuditLogImpl(
      id: json['id'] as String,
      actorUid: json['actorUid'] as String,
      actorEmail: json['actorEmail'] as String?,
      action: json['action'] as String,
      entityType: json['entityType'] as String,
      entityId: json['entityId'] as String,
      before: (json['before'] as Map?)?.map(
        (k, e) => MapEntry(k as String, e),
      ),
      after: (json['after'] as Map?)?.map(
        (k, e) => MapEntry(k as String, e),
      ),
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
    );

Map<String, dynamic> _$$AuditLogImplToJson(_$AuditLogImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'actorUid': instance.actorUid,
      'actorEmail': instance.actorEmail,
      'action': instance.action,
      'entityType': instance.entityType,
      'entityId': instance.entityId,
      'before': instance.before,
      'after': instance.after,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
    };
