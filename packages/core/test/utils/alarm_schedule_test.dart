import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const alarm = Alarm(
    id: 'a1',
    timeHour: 6,
    timeMinute: 30,
    isEveryday: true,
    repeatDays: [1, 2, 3, 4, 5, 6, 7],
  );

  test('disabled alarm has no next fire', () {
    expect(
      nextAlarmFire(alarm.copyWith(isEnabled: false), DateTime(2026, 8, 18, 5)),
      isNull,
    );
  });

  test('same morning before 6:30 fires today', () {
    final now = DateTime(2026, 8, 18, 5, 0); // Tuesday
    expect(
      nextAlarmFire(alarm, now),
      DateTime(2026, 8, 18, 6, 30),
    );
  });

  test('after the time rolls to tomorrow', () {
    final now = DateTime(2026, 8, 18, 7, 0);
    expect(
      nextAlarmFire(alarm, now),
      DateTime(2026, 8, 19, 6, 30),
    );
  });

  test('weekday filter skips today when not selected', () {
    final weekdays = alarm.copyWith(
      isEveryday: false,
      repeatDays: const [1, 2, 3, 4, 5], // Mon-Fri
    );
    final saturday = DateTime(2026, 8, 22, 5, 0); // Saturday
    expect(
      nextAlarmFire(weekdays, saturday),
      DateTime(2026, 8, 24, 6, 30), // Monday
    );
  });

  test('hour24 conversion', () {
    expect(toHour24(12, false), 0);
    expect(toHour24(12, true), 12);
    expect(toHour24(6, true), 18);
    expect(toDisplayTime(0, 5).hour12, 12);
    expect(toDisplayTime(0, 5).isPm, isFalse);
    expect(toDisplayTime(18, 0).hour12, 6);
    expect(toDisplayTime(18, 0).isPm, isTrue);
  });
}
