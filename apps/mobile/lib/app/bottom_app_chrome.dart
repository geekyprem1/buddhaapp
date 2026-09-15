import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'donate_support_banner.dart';
import 'persistent_bottom_nav.dart';
import 'router.dart';

/// Routes where the persistent bottom chrome (donate banner + navigation bar)
/// must stay hidden.
///
/// The gate screens matter for correctness, not just looks: showing a working
/// navigation bar on the force-update or maintenance screen would let the user
/// navigate straight out of the gate the router put them behind.
const _hiddenExactRoutes = <String>{
  AppRoutes.splash,
  AppRoutes.forceUpdate,
  AppRoutes.maintenance,
  AppRoutes.login,
  AppRoutes.otp,
  AppRoutes.onboardingLanguage,
  AppRoutes.onboardingPersonInfo,
  // The full-screen player is immersive and has its own controls.
  AppRoutes.player,
};

/// The donate banner plus the fixed bottom navigation bar, shown on every
/// ordinary screen.
///
/// Mounted in the root `MaterialApp.router` builder so it survives navigation,
/// which means it lives above the `InheritedGoRouter` — hence the injected
/// [router] rather than `context.push`.
class BottomAppChrome extends StatelessWidget {
  const BottomAppChrome({required this.router, super.key});

  final GoRouter router;

  /// Whether the chrome should be drawn for the router's current location.
  static bool isVisibleFor(GoRouter router) {
    try {
      final path = router.routerDelegate.currentConfiguration.uri.path;
      if (_hiddenExactRoutes.contains(path)) return false;
      if (path.startsWith('${AppRoutes.legal}/')) return false;
      return true;
    } catch (_) {
      return false;
    }
  }

  /// A hairline of breathing room between the donate banner and the navigation
  /// bar — enough to stop the maroon sitting flush against the menu, without
  /// spending screen space. The bar itself contributes a small margin above its
  /// icons, so this stays deliberately tiny.
  static const double gap = 2;

  /// Total space the chrome occupies, including the system bottom inset that
  /// the navigation bar absorbs. Bottom overlays (the mini player) use this to
  /// sit directly above the chrome.
  static double heightOf(BuildContext context) =>
      DonateSupportBanner.height +
      gap +
      PersistentBottomNav.height +
      MediaQuery.of(context).padding.bottom;

  @override
  Widget build(BuildContext context) {
    final navBackground = PersistentBottomNav.backgroundOf(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DonateSupportBanner(router: router),
        // Painted (not transparent) — there is nothing behind this Column to
        // show through, so an uncoloured gap would render as a dark band. It
        // matches the nav bar so the gap reads as part of the menu.
        SizedBox(height: gap, child: ColoredBox(color: navBackground)),
        // No SafeArea wrapper here: NavigationBar already applies the system
        // bottom inset internally (and paints behind it), so adding one would
        // double the inset and waste screen space.
        PersistentBottomNav(router: router),
      ],
    );
  }
}
