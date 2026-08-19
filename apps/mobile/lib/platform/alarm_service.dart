import 'package:core/core.dart';
import 'package:flutter/services.dart';

/// Dart face of `AlarmPlugin.kt` (Architecture §9.3).
class AlarmService {
  AlarmService({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel('app.dhammapath/alarm');

  final MethodChannel _channel;

  Future<bool> canScheduleExact() async {
    return await _channel.invokeMethod<bool>('canScheduleExact') ?? true;
  }

  Future<void> openExactAlarmSettings() {
    return _channel.invokeMethod<void>('openExactAlarmSettings');
  }

  Future<bool> isIgnoringBatteryOptimizations() async {
    return await _channel.invokeMethod<bool>('isIgnoringBatteryOptimizations') ??
        true;
  }

  Future<void> openBatterySettings() {
    return _channel.invokeMethod<void>('openBatterySettings');
  }

  Future<void> syncAlarms(List<Alarm> alarms) {
    return _channel.invokeMethod<void>('syncAlarms', {
      'alarms': [for (final a in alarms) alarmToChannel(a)],
    });
  }

  Future<void> cancel(String id) {
    return _channel.invokeMethod<void>('cancelAlarm', {'id': id});
  }

  Future<void> scheduleTest({required String id, int seconds = 60}) {
    return _channel.invokeMethod<void>('scheduleTest', {
      'id': id,
      'seconds': seconds,
    });
  }

  Future<void> stopRinging() {
    return _channel.invokeMethod<void>('stopRinging');
  }
}

Map<String, dynamic> alarmToChannel(Alarm alarm) => {
      'id': alarm.id,
      'timeHour': alarm.timeHour,
      'timeMinute': alarm.timeMinute,
      'repeatDays': alarm.repeatDays,
      'isEveryday': alarm.isEveryday,
      'prarthanaId': alarm.prarthanaId,
      'prarthanaLocalPath': alarm.prarthanaLocalPath,
      'isEnabled': alarm.isEnabled,
      'label': alarm.label,
      'snoozeMinutes': alarm.snoozeMinutes,
    };
