import '../models/alarm.dart';

/// Next [DateTime] the alarm should fire after [now], or null if disabled.
///
/// Weekdays are ISO (1 = Monday … 7 = Sunday), matching [Alarm.repeatDays].
/// Everyday / empty [repeatDays] means every day. Used by Dart tests and
/// the scheduler; Kotlin mirrors this in `AlarmScheduler.kt`.
DateTime? nextAlarmFire(Alarm alarm, DateTime now) {
  if (!alarm.isEnabled) return null;
  final days = alarm.isEveryday || alarm.repeatDays.isEmpty
      ? const [1, 2, 3, 4, 5, 6, 7]
      : alarm.repeatDays;
  final today = DateTime(now.year, now.month, now.day);
  for (var i = 0; i <= 7; i++) {
    final day = today.add(Duration(days: i));
    final fire = DateTime(
      day.year,
      day.month,
      day.day,
      alarm.timeHour,
      alarm.timeMinute,
    );
    if (fire.isAfter(now) && days.contains(fire.weekday)) {
      return fire;
    }
  }
  return null;
}

/// 12-hour clock parts for the wheel picker.
({int hour12, int minute, bool isPm}) toDisplayTime(int hour24, int minute) {
  final isPm = hour24 >= 12;
  final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
  return (hour12: hour12, minute: minute, isPm: isPm);
}

int toHour24(int hour12, bool isPm) {
  if (isPm) return hour12 == 12 ? 12 : hour12 + 12;
  return hour12 == 12 ? 0 : hour12;
}
