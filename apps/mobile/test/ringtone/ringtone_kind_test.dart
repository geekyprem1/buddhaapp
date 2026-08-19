import 'package:dhamma_path/platform/ringtone_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('channel values match the Kotlin plugin contract', () {
    expect(RingtoneKind.ringtone.channelValue, 'ringtone');
    expect(RingtoneKind.alarm.channelValue, 'alarm');
    expect(RingtoneKind.notification.channelValue, 'notification');
  });
}
