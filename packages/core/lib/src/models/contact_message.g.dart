// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ContactMessageImpl _$$ContactMessageImplFromJson(Map json) =>
    _$ContactMessageImpl(
      id: json['id'] as String,
      uid: json['uid'] as String,
      subject: json['subject'] as String,
      message: json['message'] as String,
      screenshotUrl: json['screenshotUrl'] as String?,
      status: json['status'] as String? ?? 'open',
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      resolvedAt: const TimestampConverter().fromJson(json['resolvedAt']),
      resolvedBy: json['resolvedBy'] as String?,
    );

Map<String, dynamic> _$$ContactMessageImplToJson(
        _$ContactMessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'uid': instance.uid,
      'subject': instance.subject,
      'message': instance.message,
      'screenshotUrl': instance.screenshotUrl,
      'status': instance.status,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'resolvedAt': const TimestampConverter().toJson(instance.resolvedAt),
      'resolvedBy': instance.resolvedBy,
    };
