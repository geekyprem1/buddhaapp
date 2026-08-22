import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../application/prarthana_providers.dart';

class PrarthanaHelpScreen extends ConsumerWidget {
  const PrarthanaHelpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final steps = [
      l10n?.prarthanaHelpStep1 ??
          'Pick a time, the days it should repeat, and a prarthana song.',
      l10n?.prarthanaHelpStep2 ??
          'Allow notifications and exact alarms if Android asks.',
      l10n?.prarthanaHelpStep3 ??
          'If a phone still misses the alarm, open App info and set Battery to Unrestricted. This is optional and only needed on some devices.',
      l10n?.prarthanaHelpStep4 ??
          'When it rings, use Stop or Snooze on the notification. It works with the app closed.',
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n?.prarthanaHelpTitle ?? 'How Daily Prarthana works'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(
            l10n?.prarthanaHelpIntro ??
                'The alarm is stored on this phone and plays even offline, after reboot, and if the app is closed.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.lg),
          for (var i = 0; i < steps.length; i++) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  child: Text('${i + 1}'),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      steps[i],
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: () =>
                ref.read(alarmServiceProvider).openExactAlarmSettings(),
            icon: const Icon(Icons.alarm),
            label: Text(
              l10n?.prarthanaHelpExact ?? 'Open exact-alarm settings',
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: () =>
                ref.read(alarmServiceProvider).openBatterySettings(),
            icon: const Icon(Icons.battery_saver_outlined),
            label: Text(
              l10n?.prarthanaHelpBattery ?? 'Open app battery settings',
            ),
          ),
        ],
      ),
    );
  }
}
