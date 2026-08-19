import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/admin_strings.dart';
import '../application/admin_auth_controller.dart';
import '../application/admin_session.dart';

/// Email/password only (AR-1.1). No phone, no Google, no sign-up.
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({this.idleExpired = false, super.key});

  final bool idleExpired;

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _email = TextEditingController(text: 'admin@dhammapath.app');
  final _password = TextEditingController();
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final emailErr = FieldValidators.emailRequired(_email.text);
    final passErr = FieldValidators.passwordRequired(_password.text);
    setState(() {
      _emailError = _mapField(emailErr);
      _passwordError = _mapField(passErr);
    });
    if (emailErr != null || passErr != null) return;

    await ref
        .read(adminAuthControllerProvider.notifier)
        .signIn(email: _email.text, password: _password.text);
  }

  String? _mapField(String? key) {
    return switch (key) {
      'error_email_required' => AdminStrings.emailRequired,
      'error_email_invalid' => AdminStrings.emailInvalid,
      'error_password_required' => AdminStrings.passwordRequired,
      _ => null,
    };
  }

  String _mapError(Object error) {
    if (error is AdminAccessDenied) return error.message;
    if (error is FirebaseException) {
      return switch (error.code) {
        'invalid-credential' ||
        'wrong-password' ||
        'user-not-found' ||
        'INVALID_LOGIN_CREDENTIALS' ||
        'invalid-login-credentials' => AdminStrings.badCredentials,
        'too-many-requests' => AdminStrings.tooManyAttempts,
        'network-request-failed' => AdminStrings.networkError,
        'user-disabled' => AdminStrings.accountInactive,
        'unauthorized-domain' =>
          'This site is not authorised for admin sign-in.',
        _ => '${AdminStrings.genericError} (${error.code})',
      };
    }
    return '${AdminStrings.genericError} $error';
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(adminAuthControllerProvider);
    final isLoading = auth.isLoading;
    final idleExpired =
        widget.idleExpired || ref.watch(idleSignOutProvider);

    ref.listen(adminAuthControllerProvider, (previous, next) {
      if (next.hasError && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_mapError(next.error!))),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(4),
                border: const Border(
                  left: BorderSide(color: AppColors.accent, width: 4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.textPrimary.withValues(alpha: 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(32, 36, 32, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      AdminStrings.loginEyebrow.toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        letterSpacing: 2.4,
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AdminStrings.appName,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AdminStrings.loginTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AdminStrings.loginBody,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (idleExpired) ...[
                      const SizedBox(height: 16),
                      const _Banner(text: AdminStrings.sessionExpired),
                    ],
                    if (auth.hasError) ...[
                      const SizedBox(height: 16),
                      _Banner(text: _mapError(auth.error!)),
                    ],
                    const SizedBox(height: 28),
                    TextField(
                      controller: _email,
                      enabled: !isLoading,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.username],
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: AdminStrings.emailLabel,
                        errorText: _emailError,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _password,
                      enabled: !isLoading,
                      obscureText: true,
                      autofillHints: const [AutofillHints.password],
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _submit(),
                      decoration: InputDecoration(
                        labelText: AdminStrings.passwordLabel,
                        errorText: _passwordError,
                      ),
                    ),
                    const SizedBox(height: 28),
                    PrimaryPillButton(
                      label: AdminStrings.signIn,
                      isLoading: isLoading,
                      onPressed: isLoading ? null : _submit,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
      ),
    );
  }
}
