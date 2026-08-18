import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../application/auth_controller.dart';

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
    final phone = _phoneController.text.trim();
    final error = FieldValidators.phone(phone);
    setState(() => _errorKey = error);
    if (error != null) return;

    final sent = await ref
        .read(authControllerProvider.notifier)
        .sendOtp('+91$phone');
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
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_mapAuthError(next.error))),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.xxl),
              const Icon(
                Icons.self_improvement,
                size: 56,
                color: AppColors.primary,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                l10n?.appName ?? AppConstants.appName,
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n?.tagline ?? AppConstants.tagline,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.divider),
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(12),
                      ),
                    ),
                    child: const Text('+91'),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      decoration: InputDecoration(
                        hintText: l10n?.mobileNumberHint,
                        counterText: '',
                        errorText: _errorKey == null
                            ? null
                            : _mapValidationError(_errorKey!),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.horizontal(
                            right: Radius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
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
                label: Text(
                  l10n?.loginContinueWithGoogle ?? 'Continue with Google',
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

  String _mapAuthError(Object? error) {
    // FR-2.7 — surface actionable messages for the common Firebase Auth
    // failure codes rather than a single generic string.
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-phone-number':
          return 'That phone number looks invalid.';
        case 'too-many-requests':
          return 'Too many attempts. Please try again later.';
        case 'network-request-failed':
          return 'Network error. Check your connection and retry.';
        case 'quota-exceeded':
          return 'SMS quota exceeded. Please try again later.';
        case 'app-not-authorized':
        case 'missing-client-identifier':
          return 'App verification failed. Please try again.';
        default:
          return error.message ?? 'Something went wrong. Please try again.';
      }
    }
    return 'Something went wrong. Please try again.';
  }
}
