import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotificationAudience', () {
    test('accepts the documented audience shapes', () {
      expect(NotificationAudience.isValid('all'), isTrue);
      expect(NotificationAudience.isValid('language:hi'), isTrue);
      expect(NotificationAudience.isValid('teacher:buddha'), isTrue);
      expect(NotificationAudience.isValid('platform:android'), isTrue);
      expect(NotificationAudience.isValid('user:abc123'), isTrue);
    });

    test('rejects empty, unknown, or incomplete values', () {
      expect(NotificationAudience.isValid(''), isFalse);
      expect(NotificationAudience.isValid('teacher:'), isFalse);
      expect(NotificationAudience.isValid('platform:web'), isFalse);
      expect(NotificationAudience.isValid('segment:vip'), isFalse);
    });

    test('labels stay readable for the desk list', () {
      expect(NotificationAudience.label('all'), 'All users');
      expect(NotificationAudience.label('language:mr'), 'Language · mr');
      expect(NotificationAudience.label('teacher:ambedkar'), 'Teacher · ambedkar');
    });
  });
}
