import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/generated/app_localizations.dart';

/// Report an AI reply as offensive/harmful.
///
/// Required by Google Play's generative-AI policy: users must be able to flag
/// AI output in-app. Reuses the existing `contactMessages` collection (and its
/// admin inbox) rather than adding a new store — the reported text goes in as
/// a tagged message, which satisfies the `uid == request.auth.uid` rule.
Future<void> showBodhiReportSheet(
  BuildContext context, {
  required WidgetRef ref,
  required String reportedText,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _ReportSheet(ref: ref, reportedText: reportedText),
  );
}

class _ReportSheet extends StatefulWidget {
  const _ReportSheet({required this.ref, required this.reportedText});

  final WidgetRef ref;
  final String reportedText;

  @override
  State<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<_ReportSheet> {
  final _note = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    setState(() => _sending = true);

    // Keep the reported reply short enough to stay well within a doc field,
    // and tag the subject so the admin inbox can filter AI reports.
    final excerpt = widget.reportedText.trim();
    final clipped =
        excerpt.length > 1500 ? '${excerpt.substring(0, 1500)}…' : excerpt;
    final body = [
      if (_note.text.trim().isNotEmpty) 'Reason: ${_note.text.trim()}',
      'Reported reply:',
      clipped,
    ].join('\n');

    final l10n = AppLocalizations.of(context);
    try {
      await widget.ref.read(contactRepositoryProvider).submit(
            uid: uid,
            subject: 'ai_report',
            message: body,
          );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n?.aiChatReportThanks ?? 'Thanks for reporting.'),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _sending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n?.aiChatError ?? 'Could not send. Try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final insets = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg + insets,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n?.aiChatReportTitle ?? 'Report this reply',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n?.aiChatReportSubtitle ??
                'Tell us what was wrong (optional). Our team will review it.',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _note,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: l10n?.aiChatReportHint ?? 'What was wrong?',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          PrimaryPillButton(
            label: l10n?.aiChatReportSend ?? 'Send report',
            isLoading: _sending,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
