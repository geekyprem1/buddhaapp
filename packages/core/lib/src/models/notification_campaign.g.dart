// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_campaign.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NotificationCampaignImpl _$$NotificationCampaignImplFromJson(Map json) =>
    _$NotificationCampaignImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      imageUrl: json['imageUrl'] as String?,
      deepLink: json['deepLink'] as String?,
      audience: json['audience'] as String? ?? 'all',
      status: json['status'] as String? ?? 'draft',
      scheduledAt: const TimestampConverter().fromJson(json['scheduledAt']),
      sentAt: const TimestampConverter().fromJson(json['sentAt']),
      deliveredCount: (json['deliveredCount'] as num?)?.toInt() ?? 0,
      openedCount: (json['openedCount'] as num?)?.toInt() ?? 0,
      createdBy: json['createdBy'] as String?,
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
    );

Map<String, dynamic> _$$NotificationCampaignImplToJson(
        _$NotificationCampaignImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'body': instance.body,
      'imageUrl': instance.imageUrl,
      'deepLink': instance.deepLink,
      'audience': instance.audience,
      'status': instance.status,
      'scheduledAt': const TimestampConverter().toJson(instance.scheduledAt),
      'sentAt': const TimestampConverter().toJson(instance.sentAt),
      'deliveredCount': instance.deliveredCount,
      'openedCount': instance.openedCount,
      'createdBy': instance.createdBy,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
    };
