import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../status/application/status_providers.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _name;
  late final TextEditingController _email;
  var _ready = false;
  var _busy = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController();
    _email = TextEditingController();
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(currentAppUserProvider).valueOrNull;
    if (user != null && !_ready) {
      _name.text = user.name;
      _email.text = user.email ?? '';
      _ready = true;
    }

    String? nameError;
    switch (FieldValidators.name(_name.text)) {
      case 'error_name_required':
        nameError = l10n?.errorNameRequired;
      case 'error_name_invalid':
        nameError = l10n?.errorNameInvalid;
    }
    String? emailError;
    if (FieldValidators.emailOptional(_email.text) == 'error_email_invalid') {
      emailError = l10n?.errorEmailInvalid;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(l10n?.profileEdit ?? 'Edit Profile')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          TextField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: l10n?.fullNameLabel ?? 'Full Name',
              errorText: _name.text.isEmpty ? null : nameError,
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: l10n?.emailLabel ?? 'Email',
              errorText: emailError,
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.xl),
          PrimaryPillButton(
            label: l10n?.profileSave ?? 'Save',
            isLoading: _busy,
            onPressed: nameError != null || emailError != null || _busy
                ? null
                : _save,
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final user = ref.read(currentAppUserProvider).valueOrNull;
    if (user == null) return;
    setState(() => _busy = true);
    try {
      await ref.read(userRepositoryProvider).updateProfile(
            user.uid,
            name: _name.text.trim(),
            email: _email.text.trim(),
          );
      await ref.read(statusDisplayNameProvider.notifier).setName(_name.text);
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
