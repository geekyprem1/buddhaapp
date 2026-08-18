// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppUserImpl _$$AppUserImplFromJson(Map json) => _$AppUserImpl(
      uid: json['uid'] as String,
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      photoUrl: json['photoUrl'] as String?,
      language: json['language'] as String? ?? 'en',
      selectedTeachers: (json['selectedTeachers'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      authMethod: json['authMethod'] as String? ?? 'phone',
      onboardingStep: json['onboardingStep'] as String? ?? 'language',
      fcmTokens: (json['fcmTokens'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      notificationPrefs: json['notificationPrefs'] == null
          ? const NotificationPrefs()
          : NotificationPrefs.fromJson(
              Map<String, dynamic>.from(json['notificationPrefs'] as Map)),
      isBlocked: json['isBlocked'] as bool? ?? false,
      platform: json['platform'] as String? ?? 'android',
      appVersion: json['appVersion'] as String?,
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      lastActiveAt: const TimestampConverter().fromJson(json['lastActiveAt']),
    );

Map<String, dynamic> _$$AppUserImplToJson(_$AppUserImpl instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'name': instance.name,
      'phone': instance.phone,
      'email': instance.email,
      'photoUrl': instance.photoUrl,
      'language': instance.language,
      'selectedTeachers': instance.selectedTeachers,
      'authMethod': instance.authMethod,
      'onboardingStep': instance.onboardingStep,
      'fcmTokens': instance.fcmTokens,
      'notificationPrefs': instance.notificationPrefs.toJson(),
      'isBlocked': instance.isBlocked,
      'platform': instance.platform,
      'appVersion': instance.appVersion,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'lastActiveAt': const TimestampConverter().toJson(instance.lastActiveAt),
    };

_$NotificationPrefsImpl _$$NotificationPrefsImplFromJson(Map json) =>
    _$NotificationPrefsImpl(
      push: json['push'] as bool? ?? true,
      prarthana: json['prarthana'] as bool? ?? true,
    );

Map<String, dynamic> _$$NotificationPrefsImplToJson(
        _$NotificationPrefsImpl instance) =>
    <String, dynamic>{
      'push': instance.push,
      'prarthana': instance.prarthana,
    };
