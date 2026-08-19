import 'dart:io';

import 'package:core/core.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../platform/alarm_service.dart';
import 'alarm_local_store.dart';

part 'prarthana_providers.g.dart';

@Riverpod(keepAlive: true)
AlarmRepository alarmRepository(Ref ref) => AlarmRepository();

@Riverpod(keepAlive: true)
AlarmLocalStore alarmLocalStore(Ref ref) => AlarmLocalStore();

@Riverpod(keepAlive: true)
AlarmService alarmService(Ref ref) => AlarmService();

@riverpod
Stream<List<Alarm>> userAlarms(Ref ref) {
  final uid = ref.watch(authStateProvider).valueOrNull?.uid;
  if (uid == null) return Stream.value(const []);
  return ref.watch(alarmRepositoryProvider).watch(uid);
}

class PrarthanaActions {
  PrarthanaActions(this._ref);

  final Ref _ref;

  Future<Alarm> save({
    required Alarm alarm,
    required String audioUrl,
  }) async {
    if (alarm.prarthanaId == null || alarm.prarthanaId!.isEmpty) {
      throw StateError('Pick a prarthana first.');
    }
    await _ensureNotificationPermission();
    final path = await _download(alarm.prarthanaId!, audioUrl);
    final stored = alarm.copyWith(
      prarthanaLocalPath: path,
      createdAt: alarm.createdAt ?? DateTime.now(),
    );
    await _persist(stored);
    await _syncNative();
    await _afterSchedulePermissions();
    final uid = _uid;
    if (uid != null) {
      await _ref.read(analyticsServiceProvider).prarthanaSet(
            time:
                '${stored.timeHour.toString().padLeft(2, '0')}:${stored.timeMinute.toString().padLeft(2, '0')}',
            days: stored.isEveryday
                ? 'everyday'
                : stored.repeatDays.join(','),
            songId: stored.prarthanaId ?? '',
          );
    }
    return stored;
  }

  Future<void> toggle(Alarm alarm, bool enabled) async {
    final next = alarm.copyWith(isEnabled: enabled);
    await _persist(next);
    await _syncNative();
  }

  Future<void> delete(Alarm alarm) async {
    final uid = _uid;
    if (uid != null) {
      await _ref.read(alarmRepositoryProvider).delete(uid, alarm.id);
    }
    await _ref.read(alarmLocalStoreProvider).delete(alarm.id);
    await _ref.read(alarmServiceProvider).cancel(alarm.id);
    await _syncNative();
  }

  Future<void> testIn60s(Alarm alarm) async {
    if (alarm.prarthanaLocalPath == null) {
      throw StateError('Download the prarthana before testing.');
    }
    await _ref.read(alarmServiceProvider).syncAlarms(
          _ref.read(alarmLocalStoreProvider).getAll(),
        );
    await _ref.read(alarmServiceProvider).scheduleTest(id: alarm.id);
  }

  Future<void> _persist(Alarm alarm) async {
    await _ref.read(alarmLocalStoreProvider).put(alarm);
    final uid = _uid;
    if (uid != null) {
      await _ref.read(alarmRepositoryProvider).upsert(uid, alarm);
    }
  }

  Future<void> _syncNative() {
    return _ref.read(alarmServiceProvider).syncAlarms(
          _ref.read(alarmLocalStoreProvider).getAll(),
        );
  }

  Future<String> _download(String prarthanaId, String url) async {
    final file = await DefaultCacheManager().getSingleFile(url);
    if (!await file.exists() || await file.length() < 64) {
      throw StateError('Could not download the prarthana.');
    }
    final dir = await getApplicationDocumentsDirectory();
    final dest = File('${dir.path}/prarthanas/$prarthanaId.mp3');
    await dest.parent.create(recursive: true);
    await file.copy(dest.path);
    return dest.path;
  }

  Future<void> _ensureNotificationPermission() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  Future<void> _afterSchedulePermissions() async {
    final service = _ref.read(alarmServiceProvider);
    if (!await service.canScheduleExact()) {
      await service.openExactAlarmSettings();
    }
  }

  String? get _uid =>
      _ref.read(authStateProvider).valueOrNull?.uid;
}

@Riverpod(keepAlive: true)
PrarthanaActions prarthanaActions(Ref ref) => PrarthanaActions(ref);
