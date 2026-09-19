import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_visible_route.dart';
import 'donate_support_banner.dart';
import 'persistent_bottom_nav.dart';
import 'router.dart';

/// Routes where the persistent bottom chrome (navigation bar) must stay
/// hidden.
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

/// Home gets the tab navigation. Every other ordinary screen gets one compact
/// Daan / Ask Buddha action row.
///
/// Mounted in the root `MaterialApp.router` builder so it survives navigation,
/// which means it lives above the `InheritedGoRouter` — hence the injected
/// [router] rather than `context.push`.
class BottomAppChrome extends StatelessWidget {
  const BottomAppChrome({
    required this.router,
    this.bodhiAiEnabled = false,
    super.key,
  });

  final GoRouter router;

  /// Forwarded to [PersistentBottomNav] to show/hide the Ask Buddha tab.
  final bool bodhiAiEnabled;

  /// Whether the chrome should be drawn for the route the user is looking at.
  ///
  /// Uses [visibleRoutePathOf] because `RouteMatchList.uri` ignores pushed
  /// pages — without it a `push('/wallpapers')` on top of Home would read as
  /// Home and show the full tab bar on the wrong screen.
  static bool isVisibleFor(GoRouter router) {
    final path = visibleRoutePathOf(router);
    if (_hiddenExactRoutes.contains(path)) return false;
    if (path.startsWith('${AppRoutes.legal}/')) return false;
    return true;
  }

  static bool isHomeFor(GoRouter router) =>
      visibleRoutePathOf(router) == AppRoutes.home;

  /// Total space the chrome occupies, including the system bottom inset that
  /// the navigation bar absorbs. Bottom overlays (the mini player) use this to
  /// sit directly above the chrome.
  static double heightOf(BuildContext context, GoRouter router) =>
      (isHomeFor(router)
          ? PersistentBottomNav.height
          : DaanAskBuddhaBar.height) +
      MediaQuery.of(context).padding.bottom;

  @override
  Widget build(BuildContext context) {
    if (!isHomeFor(router)) {
      return DaanAskBuddhaBar(
        router: router,
        bodhiAiEnabled: bodhiAiEnabled,
      );
    }

    // Home shows just the tab navigation now — the donation banner was
    // removed from the home screen. No SafeArea wrapper here: NavigationBar
    // already applies the system bottom inset internally.
    return PersistentBottomNav(
      router: router,
      bodhiAiEnabled: bodhiAiEnabled,
    );
  }
}
