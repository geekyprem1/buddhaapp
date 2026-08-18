import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/auth_controller.dart';

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
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    ref.listen(authControllerProvider, (previous, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid code. Please try again.')),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Verify OTP')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
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
                label: 'Verify',
                isLoading: isLoading,
                onPressed: _verify,
              ),
              const SizedBox(height: AppSpacing.md),
              Center(
                child: _secondsRemaining > 0
                    ? Text('Resend code in ${_secondsRemaining}s')
                    : TextButton(
                        onPressed: _resend,
                        child: const Text('Resend code'),
                      ),
              ),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Change number'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
