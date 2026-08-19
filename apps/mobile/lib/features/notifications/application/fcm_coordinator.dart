import 'dart:async';

import 'package:core/core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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

  final Ref _ref;
  final _messaging = FirebaseMessaging.instance;
  final Set<String> _topics = {};
  StreamSubscription<String>? _tokenSub;
  StreamSubscription<RemoteMessage>? _foregroundSub;
  StreamSubscription<RemoteMessage>? _openedSub;
  var _started = false;

  Future<void> start() async {
    if (_started) return;
    _started = true;

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

  bool get hasPromptedPermission =>
      Hive.box('app_prefs').get('notif_prompted') == true;

  Future<void> skipPermissionPrompt() async {
    await Hive.box('app_prefs').put('notif_prompted', true);
    await _ref.read(analyticsServiceProvider).permissionPrompt(
          type: 'notifications',
          result: 'skipped',
        );
  }

  Future<void> requestPermissionIfNeeded() async {
    final prefs = Hive.box('app_prefs');
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
      teacherIds: user.selectedTeachers,
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
            campaignId: message.data['campaignId']?.toString() ?? message.messageId ?? '',
          ),
    );
    final title = message.notification?.title ?? 'Dhamma Path';
    final body = message.notification?.body ?? '';
    rootMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(body.isEmpty ? title : '$title — $body'),
        action: SnackBarAction(
          label: 'Open',
          onPressed: () => _handleTap(message, fromTerminated: false),
        ),
      ),
    );
  }

  void _onOpened(RemoteMessage message) {
    unawaited(
      _ref.read(analyticsServiceProvider).notificationOpen(
            campaignId: message.data['campaignId']?.toString() ?? message.messageId ?? '',
          ),
    );
    _handleTap(message, fromTerminated: false);
  }

  void _handleTap(RemoteMessage message, {required bool fromTerminated}) {
    final target = parsePushData(message.data);
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
}
