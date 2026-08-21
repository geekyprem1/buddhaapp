import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';

class FeatureComingSoonScreen extends StatelessWidget {
  const FeatureComingSoonScreen({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.construction_rounded,
                size: 64,
                color: AppColors.primary,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                l10n?.profileComingSoon ?? 'Coming soon',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n?.featureComingSoonBody ??
                    'We are preparing this feature for you.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
