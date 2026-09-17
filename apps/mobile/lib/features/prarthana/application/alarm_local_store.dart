import 'dart:convert';

import 'package:core/core.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// On-device alarm mirror. Hive is the Flutter-side cache; native
/// SharedPreferences is what the boot receiver reads.
class AlarmLocalStore {
  static const boxName = 'prarthana_alarms';

  Box<String> get _box => Hive.box<String>(boxName);

  static Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox<String>(boxName);
    }
    if (!Hive.isBoxOpen('static_pages')) {
      await Hive.openBox<String>('static_pages');
    }
    if (!Hive.isBoxOpen('app_prefs')) {
      await Hive.openBox('app_prefs');
    }
    // Bodhi AI chat keeps its transcript locally (the server stores nothing).
    if (!Hive.isBoxOpen('bodhi_chat')) {
      await Hive.openBox<String>('bodhi_chat');
    }
  }

  List<Alarm> getAll() {
    // Skips bookkeeping keys (B11): the box also holds the native-sync
    // fingerprint, which is not an alarm payload.
    final alarms = <Alarm>[];
    for (final key in _box.keys) {
      if (key == _syncIdsKey) continue;
      final raw = _box.get(key);
      if (raw == null) continue;
      alarms.add(_decode(raw));
    }
    return alarms
      ..sort((a, b) {
        final h = a.timeHour.compareTo(b.timeHour);
        return h != 0 ? h : a.timeMinute.compareTo(b.timeMinute);
      });
  }

  Future<void> put(Alarm alarm) => _box.put(alarm.id, _encode(alarm));

  Future<void> delete(String id) => _box.delete(id);

  /// Fingerprint (sorted JSON id list) of the remote set last confirmed to the
  /// native scheduler, or null when never confirmed (B11 recovery).
  static const _syncIdsKey = '__native_sync_ids';

  String? getNativeSyncedIds() => _box.get(_syncIdsKey);

  Future<void> setNativeSyncedIds(Set<String> ids) {
    final sorted = ids.toList()..sort();
    return _box.put(_syncIdsKey, jsonEncode(sorted));
  }

  /// Replaces the whole mirror (B11). Stale ids go first, then one batched
  /// write — so a crash can leave stale extras or drop not-yet-written new
  /// ids, but never wipes a populated store (unlike clear-then-loop). Any
  /// partial result heals on the next visit via the sync fingerprint above.
  Future<void> replaceAll(Iterable<Alarm> alarms) async {
    final entries = <String, String>{
      for (final alarm in alarms) alarm.id: _encode(alarm),
    };
    final stale = _box.keys.where((k) => !entries.containsKey(k)).toList();
    if (stale.isNotEmpty) await _box.deleteAll(stale);
    await _box.putAll(entries);
  }

  String _encode(Alarm alarm) {
    final map = Map<String, dynamic>.from(alarm.toJson());
    map['createdAt'] = alarm.createdAt?.toIso8601String();
    return jsonEncode(map);
  }

  Alarm _decode(String raw) {
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return Alarm.fromJson(map);
  }
}
