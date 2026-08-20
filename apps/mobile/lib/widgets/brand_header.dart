import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';

/// Shared splash / login brand lockup — centered logo, compact title, tagline.
class BrandHeader extends StatelessWidget {
  const BrandHeader({this.compact = false, super.key});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final logoSize = compact ? 72.0 : 96.0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.asset(
              'assets/branding/logo.png',
              width: logoSize,
              height: logoSize,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            ),
          ),
          SizedBox(height: compact ? AppSpacing.md : AppSpacing.lg),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              l10n?.appName ?? AppConstants.appName,
              textAlign: TextAlign.center,
              maxLines: 1,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: compact ? 26 : 28,
                    height: 1.15,
                    letterSpacing: 0.2,
                  ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n?.tagline ?? AppConstants.tagline,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  letterSpacing: 0.4,
                ),
          ),
        ],
      ),
    );
  }
}
