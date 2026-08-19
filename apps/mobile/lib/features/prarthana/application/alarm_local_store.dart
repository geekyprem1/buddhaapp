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
  }

  List<Alarm> getAll() {
    return _box.values.map(_decode).toList()
      ..sort((a, b) {
        final h = a.timeHour.compareTo(b.timeHour);
        return h != 0 ? h : a.timeMinute.compareTo(b.timeMinute);
      });
  }

  Future<void> put(Alarm alarm) => _box.put(alarm.id, _encode(alarm));

  Future<void> delete(String id) => _box.delete(id);

  Future<void> replaceAll(Iterable<Alarm> alarms) async {
    await _box.clear();
    for (final alarm in alarms) {
      await _box.put(alarm.id, _encode(alarm));
    }
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
