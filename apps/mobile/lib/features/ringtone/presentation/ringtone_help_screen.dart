import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../application/ringtone_providers.dart';

/// WRITE_SETTINGS how-to (T2.41 / FR-8.1).
class RingtoneHelpScreen extends ConsumerWidget {
  const RingtoneHelpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final steps = [
      l10n?.ringtoneHelpStep1 ??
          'Tap Set on a ringtone, then pick Ringtone, Alarm or Notification.',
      l10n?.ringtoneHelpStep2 ?? 'If asked, tap Open settings.',
      l10n?.ringtoneHelpStep3 ?? 'Turn on the switch for Dhamma Path.',
      l10n?.ringtoneHelpStep4 ??
          'Return here — we finish setting the sound automatically.',
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n?.ringtoneHelpTitle ?? 'How to set a ringtone'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(
            l10n?.ringtoneHelpIntro ??
                'Android asks for a one-time “modify system settings” '
                    'permission. The app cannot set the sound without it.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.lg),
          for (var i = 0; i < steps.length; i++) ...[
            _StepRow(index: i + 1, text: steps[i]),
            const SizedBox(height: AppSpacing.md),
          ],
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: () =>
                ref.read(ringtoneServiceProvider).openWriteSettings(),
            icon: const Icon(Icons.settings_outlined),
            label: Text(
              l10n?.ringtoneHelpOpenSettings ?? 'Open system settings',
            ),
          ),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.index, required this.text});

  final int index;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          child: Text('$index'),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
          ),
        ),
      ],
    );
  }
}
