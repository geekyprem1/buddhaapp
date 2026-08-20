import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../widgets/brand_header.dart';
import '../application/auth_controller.dart';
import '../application/auth_error_messages.dart';

/// Login screen (PRD FR-2.1) — logo, tagline, phone input, OTP + Google
/// sign-in. No skip/guest affordance exists here by design (PRD D2).
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  String? _errorKey;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _continueWithOtp() async {
    final phone = FieldValidators.normalizeIndianMobile(
      _phoneController.text,
    );
    final error = FieldValidators.phone(phone);
    setState(() => _errorKey = error);
    if (error != null) return;

    final sent =
        await ref.read(authControllerProvider.notifier).sendOtp('+91$phone');
    if (!mounted) return;
    if (sent) {
      context.push(AppRoutes.otp, extra: '+91$phone');
    }
  }

  Future<void> _continueWithGoogle() async {
    await ref.read(authControllerProvider.notifier).signInWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    ref.listen(authControllerProvider, (previous, next) {
      if (!next.hasError) return;
      final failure = classifyAuthError(next.error!);
      if (!failure.shouldShow) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authErrorMessage(l10n, failure))),
      );
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.xl),
              const BrandHeader(compact: true),
              const SizedBox(height: AppSpacing.xl),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.telephoneNumberNational],
                inputFormatters: const [_IndianMobileFormatter()],
                onChanged: (_) {
                  if (_errorKey != null) {
                    setState(() => _errorKey = null);
                  }
                },
                onSubmitted: (_) => _continueWithOtp(),
                decoration: InputDecoration(
                  hintText: l10n?.mobileNumberHint,
                  counterText: '',
                  errorMaxLines: 2,
                  errorText: _errorKey == null
                      ? null
                      : _mapValidationError(_errorKey!),
                  prefixIcon: Align(
                    alignment: Alignment.center,
                    child: Text(
                      '+91',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 56,
                    maxWidth: 56,
                    minHeight: 48,
                    maxHeight: 48,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              PrimaryPillButton(
                label: l10n?.loginContinueWithOtp ?? 'Continue with OTP',
                isLoading: isLoading,
                onPressed: _continueWithOtp,
              ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: isLoading ? null : _continueWithGoogle,
                icon: const Icon(Icons.g_mobiledata),
                label: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    l10n?.loginContinueWithGoogle ?? 'Continue with Google',
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(
                    AppSpacing.minTouchTarget,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    l10n?.loginLegalPrefix ??
                        'By continuing you agree to the ',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  InkWell(
                    onTap: () => context.push(
                      '${AppRoutes.legal}/${StaticPageSlugs.terms}',
                    ),
                    child: Text(
                      l10n?.profileTermsConditions ?? 'Terms',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    l10n?.loginLegalAnd ?? ' and ',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  InkWell(
                    onTap: () => context.push(
                      '${AppRoutes.legal}/${StaticPageSlugs.privacy}',
                    ),
                    child: Text(
                      l10n?.profilePrivacyPolicy ?? 'Privacy Policy',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _mapValidationError(String key) {
    final l10n = AppLocalizations.of(context);
    switch (key) {
      case 'error_phone_required':
        return l10n?.errorPhoneRequired ?? 'Please enter your mobile number';
      case 'error_phone_invalid':
        return l10n?.errorPhoneInvalid ?? 'Please enter a valid number';
      default:
        return key;
    }
  }
}

/// Keeps the login field as 10 local digits even if the user pastes
/// `+91`, spaces, or a leading `0`.
class _IndianMobileFormatter extends TextInputFormatter {
  const _IndianMobileFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = FieldValidators.normalizeIndianMobile(newValue.text);
    return TextEditingValue(
      text: digits,
      selection: TextSelection.collapsed(offset: digits.length),
    );
  }
}
