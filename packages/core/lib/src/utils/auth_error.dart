import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Classified auth failure for FR-2.7 / T2.10.
///
/// [l10nKey] matches ARB keys in the mobile app (`authErrorInvalidPhone`,
/// …). The UI maps the key to a localised string; this file stays
/// Flutter-widget-free so it is unit-testable in `packages/core`.
class AuthFailure {
  const AuthFailure(this.kind, this.l10nKey, {this.code});

  final AuthErrorKind kind;
  final String l10nKey;
  final String? code;

  /// User-cancelled Google / reCAPTCHA flows must not show a snackbar.
  bool get shouldShow => kind != AuthErrorKind.cancelled;
}

enum AuthErrorKind {
  cancelled,
  invalidPhone,
  invalidOtp,
  sessionExpired,
  tooManyAttempts,
  network,
  playIntegrity,
  userDisabled,
  unknown,
}

/// Maps Firebase Auth / Functions / Google Sign-In errors onto [AuthFailure].
AuthFailure classifyAuthError(Object error) {
  if (error is FirebaseFunctionsException) {
    switch (error.code) {
      case 'resource-exhausted':
        return const AuthFailure(
          AuthErrorKind.tooManyAttempts,
          'authErrorTooManyAttempts',
        );
      case 'unavailable':
      case 'deadline-exceeded':
        return const AuthFailure(AuthErrorKind.network, 'authErrorNetwork');
      case 'unauthenticated':
      case 'failed-precondition':
        return const AuthFailure(
          AuthErrorKind.playIntegrity,
          'authErrorPlayIntegrity',
        );
      default:
        return AuthFailure(
          AuthErrorKind.unknown,
          'authErrorGeneric',
          code: error.code,
        );
    }
  }

  if (error is FirebaseAuthException) {
    return _fromAuthCode(error.code);
  }

  final code = _dynamicCode(error);
  if (code != null) return _fromAuthCode(code);

  final text = error.toString();
  if (text.contains('SocketException') ||
      text.contains('Failed host lookup') ||
      text.contains('Network is unreachable') ||
      text.contains('ClientException')) {
    return const AuthFailure(AuthErrorKind.network, 'authErrorNetwork');
  }

  return const AuthFailure(AuthErrorKind.unknown, 'authErrorGeneric');
}

AuthFailure _fromAuthCode(String code) {
  switch (code) {
    case 'canceled':
    case 'cancelled':
    case 'web-context-cancelled':
      return const AuthFailure(AuthErrorKind.cancelled, 'authErrorGeneric');
    case 'invalid-phone-number':
      return const AuthFailure(
        AuthErrorKind.invalidPhone,
        'authErrorInvalidPhone',
      );
    case 'invalid-verification-code':
    case 'invalid-verification-id':
      return const AuthFailure(AuthErrorKind.invalidOtp, 'authErrorInvalidOtp');
    case 'session-expired':
      return const AuthFailure(
        AuthErrorKind.sessionExpired,
        'authErrorSessionExpired',
      );
    case 'too-many-requests':
    case 'quota-exceeded':
    case 'resource-exhausted':
      return const AuthFailure(
        AuthErrorKind.tooManyAttempts,
        'authErrorTooManyAttempts',
      );
    case 'network-request-failed':
      return const AuthFailure(AuthErrorKind.network, 'authErrorNetwork');
    case 'app-not-authorized':
    case 'missing-client-identifier':
    case 'missing-app-credential':
    case 'invalid-app-credential':
    case 'captcha-check-failed':
    case 'play-integrity-check-failed':
    case 'app-check-token-error':
    case 'clientConfigurationError':
    case 'providerConfigurationError':
    case '10':
    case 'sign_in_failed':
    case 'DEVELOPER_ERROR':
      return AuthFailure(
        AuthErrorKind.playIntegrity,
        'authErrorPlayIntegrity',
        code: code,
      );
    case 'user-disabled':
      return const AuthFailure(
        AuthErrorKind.userDisabled,
        'authErrorUserDisabled',
      );
    default:
      return AuthFailure(
        AuthErrorKind.unknown,
        'authErrorGeneric',
        code: code,
      );
  }
}

/// Google Sign-In 7 exposes `code` as an enum; Firebase as a string.
String? _dynamicCode(Object error) {
  try {
    final dynamic value = error;
    final code = value.code;
    if (code is String) return code;
    if (code is Enum) return code.name;
  } catch (_) {}
  return null;
}
