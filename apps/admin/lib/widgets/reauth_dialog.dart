import 'package:core/core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/admin_strings.dart';
import '../features/auth/application/admin_auth_controller.dart';

/// Forced password re-entry for destructive actions (AR-1.4).
class ReauthDialog extends ConsumerStatefulWidget {
  const ReauthDialog({super.key});

  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const ReauthDialog(),
    );
    return result ?? false;
  }

  @override
  ConsumerState<ReauthDialog> createState() => _ReauthDialogState();
}

class _ReauthDialogState extends ConsumerState<ReauthDialog> {
  final _password = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    if (FieldValidators.passwordRequired(_password.text) != null) {
      setState(() => _error = AdminStrings.passwordRequired);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(adminAuthControllerProvider.notifier)
          .reauthenticate(_password.text);
      if (mounted) Navigator.of(context).pop(true);
    } on FirebaseAuthException {
      setState(() {
        _busy = false;
        _error = AdminStrings.badCredentials;
      });
    } catch (_) {
      setState(() {
        _busy = false;
        _error = AdminStrings.genericError;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(AdminStrings.reauthTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(AdminStrings.reauthBody),
          const SizedBox(height: 16),
          TextField(
            controller: _password,
            obscureText: true,
            autofocus: true,
            enabled: !_busy,
            onSubmitted: (_) => _confirm(),
            decoration: InputDecoration(
              labelText: AdminStrings.passwordLabel,
              errorText: _error,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(false),
          child: const Text(AdminStrings.cancel),
        ),
        FilledButton(
          onPressed: _busy ? null : _confirm,
          child: _busy
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text(AdminStrings.reauthConfirm),
        ),
      ],
    );
  }
}
