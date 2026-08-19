import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../application/audio_providers.dart';
import '../application/sleep_timer.dart';

Future<void> showSleepTimerSheet(BuildContext context, WidgetRef ref) {
  final l10n = AppLocalizations.of(context);
  final handler = ref.read(audioHandlerProvider);
  final chosen = handler.sleepTimer.chosen;

  return AppBottomSheet.show<void>(
    context: context,
    title: l10n?.sleepTimerTitle ?? 'Sleep timer',
    child: Column(
      children: [
        ListTile(
          leading: Icon(
            Icons.timer_off_outlined,
            color: chosen == null ? AppColors.primary : AppColors.textSecondary,
          ),
          title: Text(l10n?.sleepTimerOff ?? 'Off'),
          selected: chosen == null,
          onTap: () {
            handler.setSleepTimer(null);
            Navigator.of(context).pop();
          },
        ),
        for (final minutes in SleepTimerPresets.minutes)
          ListTile(
            leading: Icon(
              Icons.bedtime_outlined,
              color: chosen?.inMinutes == minutes
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),
            title: Text(
              l10n?.sleepTimerMinutes(minutes) ?? '$minutes min',
            ),
            selected: chosen?.inMinutes == minutes,
            onTap: () {
              handler.setSleepTimer(Duration(minutes: minutes));
              Navigator.of(context).pop();
            },
          ),
      ],
    ),
  );
}
