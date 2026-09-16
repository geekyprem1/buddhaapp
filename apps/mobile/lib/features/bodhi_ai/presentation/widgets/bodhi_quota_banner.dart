import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';

/// Thin strip under the app bar showing today's remaining chat time.
///
/// Hidden until the first server response lands ([remainingSeconds] null), so
/// the user never sees a misleading "0:00" before a session tick arrives.
class BodhiQuotaBanner extends StatelessWidget {
  const BodhiQuotaBanner({
    required this.remainingSeconds,
    required this.l10n,
    super.key,
  });

  final int? remainingSeconds;
  final AppLocalizations? l10n;

  @override
  Widget build(BuildContext context) {
    final secs = remainingSeconds;
    if (secs == null) return const SizedBox.shrink();

    final low = secs <= 30;
    final color = low ? AppColors.error : AppColors.textSecondary;
    final label = l10n?.aiChatTimeLeft(_format(secs)) ??
        'Time left today: ${_format(secs)}';

    return Container(
      width: double.infinity,
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 6,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.timer_outlined, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  String _format(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}
