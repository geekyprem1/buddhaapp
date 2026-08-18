import 'package:freezed_annotation/freezed_annotation.dart';

import '../utils/timestamp_converter.dart';

part 'notification_campaign.freezed.dart';
part 'notification_campaign.g.dart';

/// `notifications/{campaignId}` — composed in the admin panel, sent by the
/// `sendNotification` / `sendScheduledNotification` Cloud Functions
/// (PRD AR-6.x).
@freezed
class NotificationCampaign with _$NotificationCampaign {
  const factory NotificationCampaign({
    required String id,
    required String title,
    required String body,
    String? imageUrl,

    /// Deep-link target, e.g. `dhammapath://wallpaper/wp_001`.
    String? deepLink,

    /// One of: `all`, `teacher:{teacherId}`, `language:{code}`,
    /// `platform:{android|ios}`, `user:{uid}`.
    @Default('all') String audience,

    /// draft | scheduled | sent | failed
    @Default('draft') String status,
    @TimestampConverter() DateTime? scheduledAt,
    @TimestampConverter() DateTime? sentAt,
    @Default(0) int deliveredCount,
    @Default(0) int openedCount,
    String? createdBy,
    @TimestampConverter() DateTime? createdAt,
  }) = _NotificationCampaign;

  factory NotificationCampaign.fromJson(Map<String, dynamic> json) =>
      _$NotificationCampaignFromJson(json);
}
