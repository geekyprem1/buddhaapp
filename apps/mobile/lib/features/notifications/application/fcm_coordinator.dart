import 'dart:async';
import 'dart:convert';

import 'package:core/core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/router.dart';
import 'push_deep_link.dart';

part 'fcm_coordinator.g.dart';

final rootMessengerKey = GlobalKey<ScaffoldMessengerState>();

@Riverpod(keepAlive: true)
class PendingPushRoute extends _$PendingPushRoute {
  @override
  String? build() => null;

  void offer(String route) => state = route;

  String? take() {
    final value = state;
    state = null;
    return value;
  }
}

@Riverpod(keepAlive: true)
FcmCoordinator fcmCoordinator(Ref ref) {
  final coordinator = FcmCoordinator(ref);
  unawaited(coordinator.start());
  ref.onDispose(coordinator.dispose);
  return coordinator;
}

class FcmCoordinator {
  FcmCoordinator(this._ref);

  static const _pushChannel = AndroidNotificationChannel(
    'dhamma_path_push',
    'Dhamma Path updates',
    description: 'Wisdom, practice, and Dhamma Path updates',
    importance: Importance.high,
  );

  final Ref _ref;
  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  final Set<String> _topics = {};
  StreamSubscription<String>? _tokenSub;
  StreamSubscription<RemoteMessage>? _foregroundSub;
  StreamSubscription<RemoteMessage>? _openedSub;
  var _localNotificationsReady = false;
  var _started = false;

  Future<void> start() async {
    if (_started) return;
    _started = true;

    await _initializeLocalNotifications();
    _tokenSub = _messaging.onTokenRefresh.listen(_saveToken);
    _foregroundSub = FirebaseMessaging.onMessage.listen(_onForeground);
    _openedSub = FirebaseMessaging.onMessageOpenedApp.listen(_onOpened);

    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      _handleTap(initial, fromTerminated: true);
    }

    _ref.listen<AsyncValue<AppUser?>>(currentAppUserProvider, (prev, next) {
      unawaited(_syncUser(next.valueOrNull));
    });
    await _syncUser(_ref.read(currentAppUserProvider).valueOrNull);
  }

  /// Prefs box, opened on demand (B9): startup init is best-effort and may
  /// have timed out, leaving the box closed — `Hive.box()` would then throw.
  Future<Box> _prefs() async {
    if (!Hive.isBoxOpen('app_prefs')) await Hive.openBox('app_prefs');
    return Hive.box('app_prefs');
  }

  bool get hasPromptedPermission =>
      Hive.isBoxOpen('app_prefs') &&
      Hive.box('app_prefs').get('notif_prompted') == true;

  Future<void> skipPermissionPrompt() async {
    await (await _prefs()).put('notif_prompted', true);
    await _ref.read(analyticsServiceProvider).permissionPrompt(
          type: 'notifications',
          result: 'skipped',
        );
  }

  Future<void> requestPermissionIfNeeded() async {
    final prefs = await _prefs();
    if (prefs.get('notif_prompted') == true) {
      if (await Permission.notification.isGranted) {
        await _afterPermissionGranted();
      }
      return;
    }
    final user = _ref.read(currentAppUserProvider).valueOrNull;
    if (user == null || !user.hasCompletedOnboarding) return;

    final status = await Permission.notification.status;
    if (status.isGranted) {
      await prefs.put('notif_prompted', true);
      await _afterPermissionGranted();
      return;
    }

    await _ref.read(analyticsServiceProvider).permissionPrompt(
          type: 'notifications',
          result: 'prompted',
        );
    final result = await Permission.notification.request();
    await prefs.put('notif_prompted', true);
    await _ref.read(analyticsServiceProvider).permissionPrompt(
          type: 'notifications',
          result: result.isGranted ? 'granted' : 'denied',
        );
    if (result.isGranted) {
      await _afterPermissionGranted();
    }
  }

  Future<void> _afterPermissionGranted() async {
    await _messaging.setForegroundNotificationPresentationOptions(
      // Apple can present FCM notifications natively in the foreground.
      // Android foreground messages are posted through local notifications.
      alert: true,
      badge: true,
      sound: true,
    );
    final token = await _messaging.getToken();
    if (token != null) await _saveToken(token);
    await _syncUser(_ref.read(currentAppUserProvider).valueOrNull);
  }

  Future<void> _saveToken(String token) async {
    final uid = _ref.read(authStateProvider).valueOrNull?.uid;
    if (uid == null) return;
    try {
      await _ref.read(userRepositoryProvider).addFcmToken(uid, token);
    } catch (_) {}
  }

  Future<void> _syncUser(AppUser? user) async {
    if (user == null) {
      await _alignTopics({});
      return;
    }
    final desired = FcmTopics.forUser(
      language: user.language,
      pushEnabled: user.notificationPrefs.push,
    );
    await _alignTopics(desired);
  }

  Future<void> _alignTopics(Set<String> desired) async {
    for (final topic in _topics.difference(desired)) {
      try {
        await _messaging.unsubscribeFromTopic(topic);
      } catch (_) {}
    }
    for (final topic in desired.difference(_topics)) {
      try {
        await _messaging.subscribeToTopic(topic);
      } catch (_) {}
    }
    _topics
      ..clear()
      ..addAll(desired);
  }

  void _onForeground(RemoteMessage message) {
    final user = _ref.read(currentAppUserProvider).valueOrNull;
    if (user?.notificationPrefs.push == false) return;
    unawaited(
      _ref.read(analyticsServiceProvider).notificationReceived(
            campaignId: message.data['campaignId']?.toString() ??
                message.messageId ??
                '',
          ),
    );
    if (defaultTargetPlatform == TargetPlatform.android) {
      unawaited(_showAndroidNotification(message));
    }
  }

  void _onOpened(RemoteMessage message) {
    unawaited(
      _ref.read(analyticsServiceProvider).notificationOpen(
            campaignId: message.data['campaignId']?.toString() ??
                message.messageId ??
                '',
          ),
    );
    _handleTap(message, fromTerminated: false);
  }

  void _handleTap(RemoteMessage message, {required bool fromTerminated}) {
    _handleData(message.data, fromTerminated: fromTerminated);
  }

  void _handleData(
    Map<String, dynamic> data, {
    required bool fromTerminated,
  }) {
    final target = parsePushData(data);
    if (target.externalUrl != null) {
      unawaited(
        launchUrl(target.externalUrl!, mode: LaunchMode.externalApplication),
      );
      return;
    }
    final route = target.route;
    if (route == null) return;
    final user = _ref.read(currentAppUserProvider).valueOrNull;
    if (user == null || !user.hasCompletedOnboarding || fromTerminated) {
      _ref.read(pendingPushRouteProvider.notifier).offer(route);
      return;
    }
    try {
      _ref.read(appRouterProvider).go(route);
    } catch (_) {
      _ref.read(pendingPushRouteProvider.notifier).offer(route);
    }
  }

  void dispose() {
    unawaited(_tokenSub?.cancel());
    unawaited(_foregroundSub?.cancel());
    unawaited(_openedSub?.cancel());
  }

  Future<void> _initializeLocalNotifications() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    try {
      await _localNotifications.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('ic_stat_dhamma'),
        ),
        onDidReceiveNotificationResponse: (response) {
          _openLocalNotification(response.payload, fromTerminated: false);
        },
      );
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_pushChannel);
      _localNotificationsReady = true;

      final launch =
          await _localNotifications.getNotificationAppLaunchDetails();
      if (launch?.didNotificationLaunchApp ?? false) {
        _openLocalNotification(
          launch?.notificationResponse?.payload,
          fromTerminated: true,
        );
      }
    } catch (_) {
      _localNotificationsReady = false;
    }
  }

  Future<void> _showAndroidNotification(RemoteMessage message) async {
    if (!_localNotificationsReady) return;
    final notification = message.notification;
    final title = notification?.title ?? 'Dhamma Path';
    final body = notification?.body ?? '';
    final payload = jsonEncode({
      'data': message.data,
      'messageId': message.messageId,
    });
    await _localNotifications.show(
      id: DateTime.now().millisecondsSinceEpoch.remainder(0x7fffffff),
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'dhamma_path_push',
          'Dhamma Path updates',
          channelDescription: 'Wisdom, practice, and Dhamma Path updates',
          icon: 'ic_stat_dhamma',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      payload: payload,
    );
  }

  void _openLocalNotification(
    String? payload, {
    required bool fromTerminated,
  }) {
    if (payload == null || payload.isEmpty) return;
    try {
      final decoded = jsonDecode(payload) as Map<String, dynamic>;
      final data = Map<String, dynamic>.from(decoded['data'] as Map);
      final messageId = decoded['messageId']?.toString();
      unawaited(
        _ref.read(analyticsServiceProvider).notificationOpen(
              campaignId:
                  data['campaignId']?.toString() ?? messageId ?? 'foreground',
            ),
      );
      _handleData(data, fromTerminated: fromTerminated);
    } catch (_) {
      // Ignore malformed payloads rather than opening an unrelated route.
    }
  }
}
