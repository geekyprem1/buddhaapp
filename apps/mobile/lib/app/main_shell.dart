import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Persistent 5-tab shell (Home, Calendar, Practice, Videos, Profile). Each
/// tab keeps its own navigation stack and state via the
/// [StatefulNavigationShell]'s indexed stack.
///
/// The visible bottom navigation bar lives in the root app builder
/// (`PersistentBottomNav`) so it shows on every screen, not just these tab
/// branches. This shell only provides the indexed-stack body.
class MainShell extends StatelessWidget {
  const MainShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: navigationShell);
  }
}
