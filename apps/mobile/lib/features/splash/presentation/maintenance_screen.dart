import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../application/app_bootstrap.dart';

/// Full-screen maintenance wall (FR-1.4, T2.4). Retry re-fetches config.
class MaintenanceScreen extends ConsumerWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final boot = ref.watch(appBootstrapProvider).valueOrNull;
    final language =
        ref.watch(currentAppUserProvider).valueOrNull?.language ??
        Localizations.localeOf(context).languageCode;
    final message = boot?.config.maintenanceMessage.resolve(language) ?? '';
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: AppSpacing.xl),
                        const Icon(
                          Icons.cloud_off_outlined,
                          size: 72,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          l10n?.maintenanceTitle ?? 'We will be back shortly',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          message.isEmpty
                              ? (l10n?.maintenanceFallback ??
                                    'Dhamma Path is under maintenance. Please try again later.')
                              : message,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () =>
                                ref.invalidate(appBootstrapProvider),
                            child: Text(l10n?.retryButton ?? 'Retry'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
