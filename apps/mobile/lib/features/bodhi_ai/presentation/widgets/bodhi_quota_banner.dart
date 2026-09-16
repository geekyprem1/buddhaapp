import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';

/// Thin strip under the app bar showing how many messages are left today.
///
/// Hidden until the server has told us the count ([remainingMessages] null), so
/// the user never sees a misleading "0 left" before the first response arrives.
///
/// This used to show a countdown timer as well, from a daily wall-clock quota.
/// That meter was removed — it drained while the user was simply reading or
/// thinking, which made the number feel arbitrary and punished slow readers.
class BodhiQuotaBanner extends StatelessWidget {
  const BodhiQuotaBanner({
    required this.remainingMessages,
    required this.l10n,
    super.key,
  });

  final int? remainingMessages;
  final AppLocalizations? l10n;

  /// Below this, the strip turns to the error colour as a gentle heads-up that
  /// the day's allowance is nearly gone.
  static const _lowWaterMark = 3;

  @override
  Widget build(BuildContext context) {
    final left = remainingMessages;
    if (left == null) return const SizedBox.shrink();

    final low = left <= _lowWaterMark;
    final color = low ? AppColors.error : AppColors.textSecondary;
    final label = l10n?.aiChatMessagesLeft(left) ?? '$left messages left today';

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
          Icon(Icons.forum_outlined, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
