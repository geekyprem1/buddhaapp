import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/generated/app_localizations.dart';
import 'app_visible_route.dart';
import 'router.dart';

/// The bottom-nav destinations, in order. Each maps to a top-level route so
/// the bar can drive navigation from anywhere in the app (not just the tab
/// shell). Profile is NOT here — it moved to the Home app-bar avatar (Wave 4);
/// its old slot is taken by Ask Buddha at the centre.
///
/// Two variants because the Ask Buddha tab is hidden when `config/bodhi_ai`
/// has `enabled: false` (BA-1.3). The route order must stay in lockstep with
/// the `destinations` list built in [_bar].
const _navRoutesWithAi = <String>[
  AppRoutes.home,
  AppRoutes.buddhistCalendar,
  AppRoutes.askBuddha,
  AppRoutes.prarthana,
  AppRoutes.videos,
];

const _navRoutesNoAi = <String>[
  AppRoutes.home,
  AppRoutes.buddhistCalendar,
  AppRoutes.prarthana,
  AppRoutes.videos,
];

/// A bottom navigation bar that persists on EVERY screen (mounted in the root
/// `MaterialApp.router` builder). It mirrors the tab shell's destinations, but
/// because it lives above the `InheritedGoRouter`, it navigates through the
/// injected [router] instance.
///
/// When the user is on a pushed detail screen (not one of the five tab roots),
/// no destination is highlighted; tapping one goes to that tab.
class PersistentBottomNav extends StatelessWidget {
  const PersistentBottomNav({
    required this.router,
    this.bodhiAiEnabled = false,
    super.key,
  });

  final GoRouter router;

  /// When true, the Ask Buddha tab is shown at the centre (index 2). Driven by
  /// `config/bodhi_ai.enabled`, threaded down from `app.dart`.
  final bool bodhiAiEnabled;

  List<String> get _navRoutes =>
      bodhiAiEnabled ? _navRoutesWithAi : _navRoutesNoAi;

  /// Height of the bar's content (excludes the system bottom inset, which
  /// [NavigationBar] applies internally). Other bottom overlays use this to sit
  /// above the bar.
  ///
  /// Material 3 defaults to 80, but a destination only needs ~52 (a 32 icon
  /// indicator + 4 label padding + a ~16 label), so the default leaves 14 of
  /// dead space above and below the icons. 62 keeps a small breathing margin
  /// while giving the rest of that space back to the page.
  static const double height = 62;

  /// Headroom in [height] for the label to grow with the system font-size
  /// setting before it would overflow the tightened bar.
  static const double _maxLabelScale = 1.3;

  /// A soft, warm tint rather than stark white, so the menu sits comfortably
  /// in the app's cream palette. Shared with the strip between the donate
  /// banner and this bar so the two read as one piece.
  static Color backgroundOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? AppColors.surfaceDark
          : AppColors.background;

  int? _currentIndex() {
    final path = visibleRoutePathOf(router);
    final index = _navRoutes.indexOf(path);
    return index < 0 ? null : index;
  }

  void _onTap(int index) {
    AppHaptics.selection();
    final target = _navRoutes[index];
    // Reset to the tab root, replacing any pushed screen so back doesn't stack.
    router.go(target);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final current = _currentIndex();
    // The bar is shorter than the Material default, so cap how far the system
    // font-size setting can grow the labels. Without this, a large system font
    // would overflow the tightened height.
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: _maxLabelScale,
      child: _bar(context, l10n, cs, current),
    );
  }

  Widget _bar(
    BuildContext context,
    AppLocalizations? l10n,
    ColorScheme cs,
    int? current,
  ) {
    return NavigationBar(
      height: height,
      // NavigationBar requires a valid selectedIndex; default to Home's slot
      // for highlighting purposes when off-tab, but the visual selection only
      // reads as "active" when the user is actually on that route.
      selectedIndex: current ?? 0,
      onDestinationSelected: _onTap,
      backgroundColor: backgroundOf(context),
      indicatorColor: current == null
          ? Colors.transparent
          : cs.primary.withValues(alpha: 0.14),
      // `tooltip: ''` on every destination is required, not cosmetic:
      // NavigationDestination defaults its tooltip to the label, and Tooltip
      // needs an Overlay ancestor. This bar is mounted in the
      // MaterialApp.router builder — above the Navigator/Overlay — so a
      // tooltip would throw "No Overlay widget found." and each destination
      // would render as an error box.
      destinations: [
        _destinationFor(
            cs, Icons.home_outlined, Icons.home, l10n?.navHome ?? 'Home'),
        _destinationFor(cs, Icons.calendar_month_outlined, Icons.calendar_month,
            l10n?.navCalendar ?? 'Calendar'),
        if (bodhiAiEnabled)
          _destinationFor(cs, Icons.self_improvement, Icons.self_improvement,
              l10n?.navAskBuddha ?? 'Ask Buddha'),
        _destinationFor(
            cs, Icons.spa_outlined, Icons.spa, l10n?.navPractice ?? 'Practice'),
        _destinationFor(cs, Icons.play_circle_outline, Icons.play_circle,
            l10n?.homeVideo ?? 'Videos'),
      ],
    );
  }

  /// `tooltip: ''` is required, not cosmetic — see the class doc: this bar is
  /// above the Overlay, so a defaulted tooltip would throw.
  NavigationDestination _destinationFor(
    ColorScheme cs,
    IconData icon,
    IconData selected,
    String label,
  ) {
    return NavigationDestination(
      icon: Icon(icon),
      selectedIcon: Icon(selected, color: cs.primary),
      label: label,
      tooltip: '',
    );
  }
}
