import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../../../app/router.dart';
import '../../../l10n/generated/app_localizations.dart';
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

  VideoPlayerController? _bgVideo;
  bool _bgReady = false;

  @override
  void initState() {
    super.initState();
    final c = VideoPlayerController.asset('assets/video/login_bg.mp4');
    _bgVideo = c;
    c.initialize().then((_) {
      if (!mounted) return;
      c
        ..setVolume(0)
        ..setLooping(true)
        ..play();
      setState(() => _bgReady = true);
    }).catchError((_) {
      // Fall back to the plain background if the video can't load.
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _bgVideo?.dispose();
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

    final video = _bgVideo;
    return Scaffold(
      // Keep the video fixed when the keyboard opens; the sheet handles the
      // inset itself (see _buildSheet) so only it lifts above the keyboard.
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background video, shown as-is (no scrim) so it stays bright.
          // Falls back to the theme background while initialising / on error.
          if (_bgReady && video != null)
            FittedBox(
              fit: BoxFit.cover,
              clipBehavior: Clip.hardEdge,
              child: SizedBox(
                width: video.value.size.width,
                height: video.value.size.height,
                child: VideoPlayer(video),
              ),
            ),
          // The login form lives in a cream sheet pinned to the bottom. The
          // brand logo/name already live inside the video, so we don't draw
          // our own BrandHeader here (that caused a double-logo overlap).
          //
          // `Align.bottomCenter` (instead of a Column with a Spacer) keeps the
          // video fixed when the keyboard opens — only the sheet lifts above
          // the keyboard, the artwork behind it never jumps.
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildSheet(context, l10n, isLoading),
          ),
        ],
      ),
    );
  }

  /// The cream "sheet" that rises from the bottom and holds the whole form.
  Widget _buildSheet(
    BuildContext context,
    AppLocalizations? l10n,
    bool isLoading,
  ) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 24,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            // Lift the sheet above the keyboard when it's open.
            AppSpacing.md + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                icon: const Icon(
                  Icons.g_mobiledata,
                  color: AppColors.primary,
                ),
                label: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    l10n?.loginContinueWithGoogle ?? 'Continue with Google',
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: BorderSide(
                    color: AppColors.textSecondary.withValues(alpha: 0.4),
                  ),
                  minimumSize: const Size.fromHeight(
                    AppSpacing.minTouchTarget,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
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
                        fontWeight: FontWeight.w700,
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
                        fontWeight: FontWeight.w700,
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
