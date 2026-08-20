import 'package:core/core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('classifyAuthError', () {
    test('maps invalid phone', () {
      final failure = classifyAuthError(
        FirebaseAuthException(code: 'invalid-phone-number'),
      );
      expect(failure.kind, AuthErrorKind.invalidPhone);
      expect(failure.shouldShow, isTrue);
    });

    test('maps wrong OTP and expired session', () {
      expect(
        classifyAuthError(
          FirebaseAuthException(code: 'invalid-verification-code'),
        ).kind,
        AuthErrorKind.invalidOtp,
      );
      expect(
        classifyAuthError(
          FirebaseAuthException(code: 'session-expired'),
        ).kind,
        AuthErrorKind.sessionExpired,
      );
    });

    test('maps OTP rate-limit from the callable', () {
      expect(
        classifyAuthError(_Coded('resource-exhausted')).kind,
        AuthErrorKind.tooManyAttempts,
      );
    });

    test('maps Play Integrity / App Check failures', () {
      expect(
        classifyAuthError(
          FirebaseAuthException(code: 'app-not-authorized'),
        ).kind,
        AuthErrorKind.playIntegrity,
      );
    });

    test('maps network failures', () {
      expect(
        classifyAuthError(
          FirebaseAuthException(code: 'network-request-failed'),
        ).kind,
        AuthErrorKind.network,
      );
    });

    test('hides user-cancelled Google sign-in', () {
      final failure = classifyAuthError(_Coded('canceled'));
      expect(failure.kind, AuthErrorKind.cancelled);
      expect(failure.shouldShow, isFalse);
    });
  });
}

class _Coded {
  _Coded(this.code);
  final String code;
}
