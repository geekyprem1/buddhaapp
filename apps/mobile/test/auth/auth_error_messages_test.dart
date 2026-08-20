import 'package:core/core.dart';
import 'package:dhamma_path/features/auth/application/auth_error_messages.dart';
import 'package:dhamma_path/l10n/generated/app_localizations_en.dart';
import 'package:dhamma_path/l10n/generated/app_localizations_hi.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('English messages cover every auth kind', () {
    final l10n = AppLocalizationsEn();
    expect(
      authErrorMessage(
        l10n,
        const AuthFailure(AuthErrorKind.invalidOtp, 'authErrorInvalidOtp'),
      ),
      l10n.authErrorInvalidOtp,
    );
    expect(
      authErrorMessage(
        l10n,
        const AuthFailure(
          AuthErrorKind.playIntegrity,
          'authErrorPlayIntegrity',
        ),
      ),
      l10n.authErrorPlayIntegrity,
    );
  });

  test('Hindi messages are not the English fallback', () {
    final hi = AppLocalizationsHi();
    final en = AppLocalizationsEn();
    expect(
      authErrorMessage(
        hi,
        const AuthFailure(
          AuthErrorKind.tooManyAttempts,
          'authErrorTooManyAttempts',
        ),
      ),
      isNot(en.authErrorTooManyAttempts),
    );
  });
}
