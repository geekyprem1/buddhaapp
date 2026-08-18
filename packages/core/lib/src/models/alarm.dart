import 'package:freezed_annotation/freezed_annotation.dart';

import '../utils/timestamp_converter.dart';

part 'alarm.freezed.dart';
part 'alarm.g.dart';

/// `users/{uid}/alarms/{alarmId}` — Daily Prarthana alarm (PRD FR-11.x).
///
/// Mirrored into Hive on-device; Hive is authoritative at fire time
/// (Architecture §9.3) because the alarm must fire fully offline.
@freezed
class Alarm with _$Alarm {
  const factory Alarm({
    required String id,
    @Default(6) int timeHour,
    @Default(0) int timeMinute,

    /// ISO weekday numbers (1 = Monday .. 7 = Sunday). Empty = one-shot.
    @Default(<int>[]) List<int> repeatDays,
    @Default(true) bool isEveryday,
    String? prarthanaId,

    /// Path to the pre-downloaded audio file — required before the alarm
    /// can be considered "set" (PRD FR-11.8).
    String? prarthanaLocalPath,
    @Default(true) bool isEnabled,
    @Default('Daily Prarthana') String label,
    @Default(10) int snoozeMinutes,
    @TimestampConverter() DateTime? createdAt,
  }) = _Alarm;

  factory Alarm.fromJson(Map<String, dynamic> json) => _$AlarmFromJson(json);
}
