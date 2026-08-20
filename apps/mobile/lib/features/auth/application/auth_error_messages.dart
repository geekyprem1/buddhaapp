import 'package:core/core.dart';

import '../../../l10n/generated/app_localizations.dart';

/// Resolves a classified [AuthFailure] to a localised user-facing string.
String authErrorMessage(AppLocalizations? l10n, AuthFailure failure) {
  switch (failure.kind) {
    case AuthErrorKind.invalidPhone:
      return l10n?.authErrorInvalidPhone ?? 'That phone number looks invalid.';
    case AuthErrorKind.invalidOtp:
      return l10n?.authErrorInvalidOtp ?? 'Invalid code. Please try again.';
    case AuthErrorKind.sessionExpired:
      return l10n?.authErrorSessionExpired ??
          'That code expired. Request a new one.';
    case AuthErrorKind.tooManyAttempts:
      return l10n?.authErrorTooManyAttempts ??
          'Too many attempts. Please try again later.';
    case AuthErrorKind.network:
      return l10n?.authErrorNetwork ??
          'Network error. Check your connection and retry.';
    case AuthErrorKind.playIntegrity:
      return l10n?.authErrorPlayIntegrity ??
          'App verification failed. Please try again.';
    case AuthErrorKind.userDisabled:
      return l10n?.authErrorUserDisabled ?? 'This account has been disabled.';
    case AuthErrorKind.cancelled:
    case AuthErrorKind.unknown:
      return l10n?.authErrorGeneric ??
          'Something went wrong. Please try again.';
  }
}
