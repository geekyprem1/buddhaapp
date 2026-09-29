import 'package:core/core.dart';
import 'package:dhamma_path/platform/alarm_service.dart';
import 'package:dhamma_path/features/prarthana/application/alarm_local_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('alarmToChannel matches the Kotlin plugin contract', () {
    final alarm = Alarm(
      id: 'pr_1',
      timeHour: 6,
      timeMinute: 30,
      repeatDays: const [1, 2, 3],
      isEveryday: false,
      prarthanaId: 'song_1',
      prarthanaLocalPath: '/tmp/pr.mp3',
      isEnabled: true,
      label: 'Daily Prarthana',
      snoozeMinutes: 10,
    );

    expect(alarmToChannel(alarm), {
      'id': 'pr_1',
      'timeHour': 6,
      'timeMinute': 30,
      'repeatDays': [1, 2, 3],
      'isEveryday': false,
      'prarthanaId': 'song_1',
      'prarthanaLocalPath': '/tmp/pr.mp3',
      'isEnabled': true,
      'label': 'Daily Prarthana',
      'snoozeMinutes': 10,
    });
  });

  test('computeFingerprint changes when time, days, or enabled status change', () {
    final a1 = const Alarm(
      id: 'pr_1',
      timeHour: 6,
      timeMinute: 0,
      isEnabled: true,
    );
    final a2 = const Alarm(
      id: 'pr_1',
      timeHour: 7,
      timeMinute: 0,
      isEnabled: true,
    );
    final a3 = const Alarm(
      id: 'pr_1',
      timeHour: 6,
      timeMinute: 0,
      isEnabled: false,
    );

    final fp1 = AlarmLocalStore.computeFingerprint([a1]);
    final fp2 = AlarmLocalStore.computeFingerprint([a2]);
    final fp3 = AlarmLocalStore.computeFingerprint([a3]);

    expect(fp1, isNot(equals(fp2)));
    expect(fp1, isNot(equals(fp3)));
  });

  test('computeFingerprint is deterministic regardless of alarm order', () {
    final a1 = const Alarm(id: 'a', timeHour: 6, timeMinute: 0);
    final a2 = const Alarm(id: 'b', timeHour: 7, timeMinute: 0);

    final fpA = AlarmLocalStore.computeFingerprint([a1, a2]);
    final fpB = AlarmLocalStore.computeFingerprint([a2, a1]);

    expect(fpA, equals(fpB));
  });
}
