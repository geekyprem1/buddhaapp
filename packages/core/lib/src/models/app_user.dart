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

    /// Server-verified premium entitlement. The app is premium ("Pro") while
    /// `premiumUntil > now`. Written by `verifyPurchase`/`playRtdn` for real
    /// Play subscriptions, or by the admin `grantPremium` callable for manual
    /// grants. Never trust a local flag — this timestamp is the source of
    /// truth (see BodhiAiConfigX.messagesFor).
    @TimestampConverter() DateTime? premiumUntil,

    /// Origin of the current entitlement, e.g. a Play subscription state or
    /// `admin_grant` / `admin_revoke` for manual admin actions.
    String? premiumState,
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

  /// Premium ("Pro") while the server-verified entitlement is still in the
  /// future. Mirrors the app's own `premiumUntil > now` rule.
  bool get isPremium =>
      premiumUntil != null && premiumUntil!.isAfter(DateTime.now());
}
