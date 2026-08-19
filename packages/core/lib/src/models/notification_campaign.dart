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

/// Values of [NotificationCampaign.status].
abstract class NotificationCampaignStatus {
  NotificationCampaignStatus._();

  static const draft = 'draft';
  static const scheduled = 'scheduled';
  static const sending = 'sending';
  static const sent = 'sent';
  static const failed = 'failed';
}

/// Values of [NotificationCampaign.audience].
/// `all` | `teacher:{id}` | `language:{code}` | `platform:{android|ios}` | `user:{uid}`.
abstract class NotificationAudience {
  NotificationAudience._();

  static const all = 'all';

  static String teacher(String id) => 'teacher:$id';
  static String language(String code) => 'language:$code';
  static String platform(String name) => 'platform:$name';
  static String user(String uid) => 'user:$uid';

  static bool isValid(String raw) {
    final value = raw.trim();
    if (value == all) return true;
    final colon = value.indexOf(':');
    if (colon <= 0 || colon == value.length - 1) return false;
    final kind = value.substring(0, colon);
    final id = value.substring(colon + 1).trim();
    if (id.isEmpty) return false;
    return switch (kind) {
      'teacher' || 'language' || 'user' => true,
      'platform' => id == 'android' || id == 'ios',
      _ => false,
    };
  }

  static String label(String raw) {
    final value = raw.trim();
    if (value.isEmpty || value == all) return 'All users';
    final colon = value.indexOf(':');
    if (colon <= 0) return value;
    final kind = value.substring(0, colon);
    final id = value.substring(colon + 1);
    return switch (kind) {
      'teacher' => 'Teacher · $id',
      'language' => 'Language · $id',
      'platform' => 'Platform · $id',
      'user' => 'User · $id',
      _ => value,
    };
  }
}
