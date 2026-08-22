import 'package:dhamma_path/features/notifications/application/push_deep_link.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('module maps to the matching app route', () {
    expect(parsePushData({'module': 'wallpaper'}).route, '/wallpapers');
    expect(parsePushData({'module': 'prarthana'}).route, '/prarthana');
    expect(parsePushData({'module': 'chanting'}).route, '/chanting');
    expect(parsePushData({'module': 'chantings'}).route, '/chanting');
    expect(parsePushData({'module': 'vandana'}).route, '/vandana');
    expect(parsePushData({'module': 'vandanas'}).route, '/vandana');
    expect(parsePushData({'module': 'unknown'}).route, '/home');
  });

  test('explicit route wins over module', () {
    expect(
      parsePushData({'route': '/profile', 'module': 'song'}).route,
      '/profile',
    );
  });

  test('https url is treated as an external target', () {
    final target = parsePushData({'url': 'https://dhammapath.app/news'});
    expect(target.externalUrl?.host, 'dhammapath.app');
    expect(target.route, isNull);
  });

  test('topics follow the architecture naming', () {
    final topics = FcmTopics.forUser(
      language: 'hi',
      teacherIds: const ['buddha', 'ambedkar'],
      pushEnabled: true,
    );
    expect(topics,
        containsAll(['all', 'lang_hi', 'teacher_buddha', 'teacher_ambedkar']));
    expect(
      FcmTopics.forUser(
          language: 'en', teacherIds: const [], pushEnabled: false),
      isEmpty,
    );
  });
}
