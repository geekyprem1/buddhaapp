import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/generated/app_localizations.dart';
import 'router.dart';

/// A persistent, full-width "Donate & Support" banner that sits just above the
/// bottom navigation bar on every screen (replaces the old floating heart
/// bubble). Tapping it opens the Daan (donation) page.
///
/// It is mounted in the root `MaterialApp.router` builder, above the
/// `InheritedGoRouter`, so navigation goes through the injected [router]
/// instance rather than `context.push`.
class DonateSupportBanner extends StatelessWidget {
  const DonateSupportBanner({required this.router, super.key});

  final GoRouter router;

  /// Height of the banner. Deliberately compact so it costs as little vertical
  /// screen space as possible. Bottom overlays (e.g. the mini player) use this
  /// to sit above the banner.
  static const double height = 52;

  /// Space reserved at each end for the icon and the chevron. The centred text
  /// is inset by this much on both sides so it stays optically centred in the
  /// banner without ever colliding with them.
  static const double _endInset = 56;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = l10n?.homeDana == null || l10n?.homeDana == 'Daan'
        ? 'Donate & Support'
        : l10n!.homeDana;
    final subtitle = l10n?.homeDanaSubtitle ?? 'Help us keep Dhamma alive';

    return Material(
      color: AppColors.primary,
      child: InkWell(
        onTap: () => router.push(AppRoutes.dana),
        splashColor: AppColors.surface.withValues(alpha: 0.12),
        highlightColor: AppColors.surface.withValues(alpha: 0.06),
        // No SafeArea here: the bottom navigation bar sits directly below this
        // banner and absorbs the system bottom inset itself.
        child: SizedBox(
          height: height,
          // The banner is deliberately short to save screen space, so cap how
          // far the system font-size setting can stretch its two lines. Some
          // scaling is still honoured; unbounded scaling would overflow the
          // fixed height.
          child: MediaQuery.withClampedTextScaling(
            maxScaleFactor: 1.2,
            // A Stack (rather than a Row) so the text is centred against the
            // full banner width instead of the space left over beside the
            // icon and chevron.
            child: Stack(
              children: [
                Positioned(
                  left: AppSpacing.md,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surface,
                      ),
                      child: const Icon(
                        Icons.volunteer_activism,
                        color: AppColors.primary,
                        size: 19,
                      ),
                    ),
                  ),
                ),
                // Compact, tight line heights so both lines fit the reduced
                // banner height without overflowing.
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: _endInset),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.surface,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            height: 1.15,
                          ),
                        ),
                        Text(
                          subtitle,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.surface.withValues(alpha: 0.9),
                            fontSize: 11,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Positioned(
                  right: AppSpacing.md,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.surface,
                      size: 24,
                    ),
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
