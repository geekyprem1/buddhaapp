import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';

class ContactScreen extends ConsumerStatefulWidget {
  const ContactScreen({super.key});

  @override
  ConsumerState<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends ConsumerState<ContactScreen> {
  final _subject = TextEditingController();
  final _message = TextEditingController();
  var _busy = false;

  @override
  void dispose() {
    _subject.dispose();
    _message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n?.profileContactUs ?? 'Contact Us'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          TextField(
            controller: _subject,
            decoration: InputDecoration(
              labelText: l10n?.contactSubject ?? 'Subject',
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _message,
            minLines: 5,
            maxLines: 8,
            decoration: InputDecoration(
              labelText: l10n?.contactMessage ?? 'Message',
              alignLabelWithHint: true,
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.xl),
          PrimaryPillButton(
            label: l10n?.contactSend ?? 'Send',
            isLoading: _busy,
            onPressed: _subject.text.trim().isEmpty ||
                    _message.text.trim().isEmpty ||
                    _busy
                ? null
                : _send,
          ),
        ],
      ),
    );
  }

  Future<void> _send() async {
    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    if (uid == null) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      await ref.read(contactRepositoryProvider).submit(
            uid: uid,
            subject: _subject.text,
            message: _message.text,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n?.contactSent ?? 'Message sent.')),
      );
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n?.contactFailed ?? 'Could not send the message.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
