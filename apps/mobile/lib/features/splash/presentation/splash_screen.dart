import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';

/// Branded splash (FR-1.1). The router's redirect (see app/router.dart)
/// owns navigating away from here once auth state and the user profile
/// have resolved — this screen only renders the brand while that happens.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.self_improvement, size: 72, color: AppColors.primary),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n?.appName ?? AppConstants.appName,
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n?.tagline ?? AppConstants.tagline,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.xl),
            const CircularProgressIndicator(color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
