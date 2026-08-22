import 'package:core/core.dart';
import 'package:dhamma_path/platform/alarm_service.dart';
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
}
