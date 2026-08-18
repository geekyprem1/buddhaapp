import 'package:freezed_annotation/freezed_annotation.dart';

import '../utils/timestamp_converter.dart';

part 'app_user.freezed.dart';
part 'app_user.g.dart';

/// `users/{uid}` — see Architecture §6.2.
@freezed
class AppUser with _$AppUser {
  const factory AppUser({
    required String uid,
    @Default('') String name,
    String? phone,
    String? email,
    String? photoUrl,
    @Default('en') String language,
    @Default(<String>[]) List<String> selectedTeachers,

    /// `phone` | `google`
    @Default('phone') String authMethod,

    /// `language` | `person_info` | `teacher` | `complete`
    @Default('language') String onboardingStep,
    @Default(<String>[]) List<String> fcmTokens,
    @Default(NotificationPrefs()) NotificationPrefs notificationPrefs,
    @Default(false) bool isBlocked,
    @Default('android') String platform,
    String? appVersion,
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? lastActiveAt,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) =>
      _$AppUserFromJson(json);
}

@freezed
class NotificationPrefs with _$NotificationPrefs {
  const factory NotificationPrefs({
    @Default(true) bool push,
    @Default(true) bool prarthana,
  }) = _NotificationPrefs;

  factory NotificationPrefs.fromJson(Map<String, dynamic> json) =>
      _$NotificationPrefsFromJson(json);
}

extension AppUserX on AppUser {
  bool get hasCompletedOnboarding => onboardingStep == 'complete';
}
