import 'package:core/core.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isRetryableError', () {
    test('retries transient Firebase codes', () {
      expect(
        isRetryableError(
          FirebaseException(plugin: 'cloud_firestore', code: 'unavailable'),
        ),
        isTrue,
      );
      expect(
        isRetryableError(
          FirebaseException(
            plugin: 'cloud_firestore',
            code: 'deadline-exceeded',
          ),
        ),
        isTrue,
      );
    });

    test('does not retry permission or not-found', () {
      expect(
        isRetryableError(
          FirebaseException(
            plugin: 'cloud_firestore',
            code: 'permission-denied',
          ),
        ),
        isFalse,
      );
      expect(
        isRetryableError(
          FirebaseException(plugin: 'cloud_firestore', code: 'not-found'),
        ),
        isFalse,
      );
    });

    test('retries socket-style messages', () {
      expect(isRetryableError(Exception('SocketException: failed')), isTrue);
    });
  });

  group('retryWithBackoff', () {
    test('returns on first success', () async {
      var calls = 0;
      final value = await retryWithBackoff(() async {
        calls++;
        return 7;
      });
      expect(value, 7);
      expect(calls, 1);
    });

    test('retries unavailable then succeeds', () async {
      var calls = 0;
      final value = await retryWithBackoff(
        () async {
          calls++;
          if (calls < 3) {
            throw FirebaseException(
              plugin: 'cloud_firestore',
              code: 'unavailable',
            );
          }
          return 'ok';
        },
        initialDelay: Duration.zero,
      );
      expect(value, 'ok');
      expect(calls, 3);
    });

    test('does not retry permission-denied', () async {
      var calls = 0;
      await expectLater(
        () => retryWithBackoff(
          () async {
            calls++;
            throw FirebaseException(
              plugin: 'cloud_firestore',
              code: 'permission-denied',
            );
          },
          initialDelay: Duration.zero,
        ),
        throwsA(isA<FirebaseException>()),
      );
      expect(calls, 1);
    });
  });
}
