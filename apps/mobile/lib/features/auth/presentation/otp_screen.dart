import 'dart:async';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../application/auth_controller.dart';
import '../application/auth_error_messages.dart';

/// OTP verification screen (PRD FR-2.2) — 6-digit code entry, 60s resend
/// timer, change-number link.
class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({required this.phoneNumber, super.key});

  final String phoneNumber;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _codeController = TextEditingController();
  Timer? _resendTimer;
  int _secondsRemaining = 60;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    _secondsRemaining = 60;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        timer.cancel();
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  Future<void> _verify() async {
    final code = _codeController.text.trim();
    if (code.length != 6) return;
    await ref.read(authControllerProvider.notifier).verifyOtp(code);
  }

  Future<void> _resend() async {
    await ref.read(authControllerProvider.notifier).sendOtp(widget.phoneNumber);
    if (mounted) _startResendTimer();
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
      appBar: AppBar(title: Text(l10n?.otpScreenTitle ?? 'Verify OTP')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n?.otpEnterCode(widget.phoneNumber) ??
                    'Enter the code sent to ${widget.phoneNumber}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 28, letterSpacing: 12),
                decoration: const InputDecoration(counterText: ''),
                onChanged: (value) {
                  if (value.length == 6) _verify();
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              PrimaryPillButton(
                label: l10n?.otpVerify ?? 'Verify',
                isLoading: isLoading,
                onPressed: _verify,
              ),
              const SizedBox(height: AppSpacing.md),
              Center(
                child: _secondsRemaining > 0
                    ? Text(
                        l10n?.otpResendIn(_secondsRemaining) ??
                            'Resend code in ${_secondsRemaining}s',
                      )
                    : TextButton(
                        onPressed: _resend,
                        child: Text(l10n?.otpResend ?? 'Resend code'),
                      ),
              ),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n?.otpChangeNumber ?? 'Change number'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
