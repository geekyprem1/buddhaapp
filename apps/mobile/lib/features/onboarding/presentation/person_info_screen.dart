import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../application/onboarding_controller.dart';

/// Person Information (PRD FR-4.1–4.4): Full Name, Mobile (prefilled +
/// read-only if phone auth), Email (optional, prefilled if Google auth).
class PersonInfoScreen extends ConsumerStatefulWidget {
  const PersonInfoScreen({super.key});

  @override
  ConsumerState<PersonInfoScreen> createState() => _PersonInfoScreenState();
}

class _PersonInfoScreenState extends ConsumerState<PersonInfoScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  String? _nameError;
  String? _emailError;
  bool _phoneReadOnly = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authServiceProvider).currentUser;
    if (user != null) {
      if (user.phoneNumber != null) {
        _phoneController.text = user.phoneNumber!.replaceFirst('+91', '');
        _phoneReadOnly = true;
      }
      if (user.email != null) _emailController.text = user.email!;
      if (user.displayName != null) _nameController.text = user.displayName!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  bool get _isValid {
    return FieldValidators.name(_nameController.text) == null &&
        FieldValidators.phone(_phoneController.text) == null &&
        FieldValidators.emailOptional(_emailController.text) == null;
  }

  Future<void> _continue() async {
    final nameErr = FieldValidators.name(_nameController.text);
    final emailErr = FieldValidators.emailOptional(_emailController.text);
    setState(() {
      _nameError = nameErr;
      _emailError = emailErr;
    });
    if (nameErr != null || emailErr != null) return;

    await ref
        .read(onboardingControllerProvider.notifier)
        .submitPersonInfo(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          email: _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(onboardingControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n?.personInfoScreenTitle ?? 'Person Information'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n?.fullNameLabel ?? 'Full Name'),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(errorText: _mapNameError()),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(l10n?.mobileNumberLabel ?? 'Mobile Number'),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                controller: _phoneController,
                readOnly: _phoneReadOnly,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: InputDecoration(
                  hintText: l10n?.mobileNumberHint,
                  counterText: '',
                  filled: _phoneReadOnly,
                  fillColor: _phoneReadOnly ? AppColors.disabled : null,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(l10n?.emailLabel ?? 'Email'),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(errorText: _mapEmailError()),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: AppSpacing.xl),
              PrimaryPillButton(
                label: l10n?.continueButton ?? 'Continue',
                isLoading: state.isLoading,
                onPressed: _isValid ? _continue : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _mapNameError() {
    if (_nameError == null) return null;
    final l10n = AppLocalizations.of(context);
    return _nameError == 'error_name_required'
        ? (l10n?.errorNameRequired ?? 'Please enter your name')
        : (l10n?.errorNameInvalid ?? 'Please enter a valid name');
  }

  String? _mapEmailError() {
    if (_emailError == null) return null;
    final l10n = AppLocalizations.of(context);
    return l10n?.errorEmailInvalid ?? 'Please enter a valid email address';
  }
}
