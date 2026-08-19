import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../profile/application/profile_providers.dart';
import '../application/app_bootstrap.dart';

/// Blocking update wall (FR-1.3, T2.4). No skip, no back.
class ForceUpdateScreen extends ConsumerWidget {
  const ForceUpdateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final boot = ref.watch(appBootstrapProvider).valueOrNull;
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              children: [
                const Spacer(),
                const Icon(
                  Icons.system_update_alt,
                  size: 72,
                  color: AppColors.primary,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  l10n?.forceUpdateTitle ?? 'Update required',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  l10n?.forceUpdateBody ??
                      'A newer version of Dhamma Path is required to continue.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (boot != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    '${boot.installedVersion} → ${boot.config.minSupportedVersion}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: openPlayStore,
                    child: Text(l10n?.forceUpdateButton ?? 'Update'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
