import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/generated/app_localizations.dart';

/// Persistent 5-tab bottom navigation shell (Home, Calendar, Practice,
/// Discover, Profile). Each tab keeps its own navigation stack and state via
/// the [StatefulNavigationShell]'s indexed stack.
class MainShell extends StatelessWidget {
  const MainShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  void _onTap(int index) {
    AppHaptics.selection();
    // Re-tapping the active tab returns it to its branch's initial location.
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onTap,
        backgroundColor: cs.surface,
        indicatorColor: cs.primary.withValues(alpha: 0.14),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: cs.primary),
            label: l10n?.navHome ?? 'Home',
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month, color: cs.primary),
            label: l10n?.navCalendar ?? 'Calendar',
          ),
          NavigationDestination(
            icon: const Icon(Icons.self_improvement),
            selectedIcon: Icon(Icons.self_improvement, color: cs.primary),
            label: l10n?.navPractice ?? 'Practice',
          ),
          NavigationDestination(
            icon: const Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore, color: cs.primary),
            label: l10n?.navExplore ?? 'Discover',
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: cs.primary),
            label: l10n?.navProfile ?? 'Profile',
          ),
        ],
      ),
    );
  }
}
