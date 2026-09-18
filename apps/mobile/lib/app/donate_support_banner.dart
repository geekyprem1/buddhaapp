import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/generated/app_localizations.dart';
import 'app_visible_route.dart';
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

/// Compact bottom action row used away from Home. It replaces both the full
/// donation banner and the tab bar so secondary screens keep only the two
/// primary actions requested by the product.
class DaanAskBuddhaBar extends StatelessWidget {
  const DaanAskBuddhaBar({
    required this.router,
    required this.bodhiAiEnabled,
    super.key,
  });

  final GoRouter router;
  final bool bodhiAiEnabled;

  static const double height = 52;

  @override
  Widget build(BuildContext context) {
    if (!bodhiAiEnabled) {
      return ColoredBox(
        color: AppColors.primary,
        child: SafeArea(
          top: false,
          child: DonateSupportBanner(router: router),
        ),
      );
    }

    final l10n = AppLocalizations.of(context);
    final currentPath = visibleRoutePathOf(router);
    return Material(
      color: AppColors.primary,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: height,
          child: MediaQuery.withClampedTextScaling(
            maxScaleFactor: 1.2,
            child: Row(
              children: [
                Expanded(
                  child: _CompactAction(
                    icon: Icons.volunteer_activism,
                    label: l10n?.homeDana ?? 'Daan',
                    subtitle: l10n?.homeDanaSubtitle ?? 'Support this app',
                    selected: currentPath == AppRoutes.dana,
                    onTap: currentPath == AppRoutes.dana
                        ? null
                        : () => router.push(AppRoutes.dana),
                  ),
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: AppColors.surface.withValues(alpha: 0.35),
                ),
                Expanded(
                  child: _CompactAction(
                    icon: Icons.self_improvement,
                    label: l10n?.navAskBuddha ?? 'Ask Buddha',
                    subtitle: 'Powered by Bodhi AI',
                    selected: currentPath == AppRoutes.askBuddha,
                    onTap: currentPath == AppRoutes.askBuddha
                        ? null
                        : () => router.go(AppRoutes.askBuddha),
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

class _CompactAction extends StatelessWidget {
  const _CompactAction({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = AppColors.surface.withValues(alpha: selected ? 1 : 0.92);
    return InkWell(
      onTap: onTap,
      child: Ink(
        color: selected
            ? AppColors.surface.withValues(alpha: 0.12)
            : Colors.transparent,
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: foreground, size: 18),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: foreground,
                        fontSize: 13.5,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w600,
                        height: 1.15,
                      ),
                    ),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: foreground.withValues(alpha: 0.85),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
