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
    // Re-tapping the active tab returns it to its branch's initial location.
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onTap,
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.12),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home, color: AppColors.primary),
            label: l10n?.navHome ?? 'Home',
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_month_outlined),
            selectedIcon:
                const Icon(Icons.calendar_month, color: AppColors.primary),
            label: l10n?.navCalendar ?? 'Calendar',
          ),
          NavigationDestination(
            icon: const Icon(Icons.self_improvement),
            selectedIcon:
                const Icon(Icons.self_improvement, color: AppColors.primary),
            label: l10n?.navPractice ?? 'Practice',
          ),
          NavigationDestination(
            icon: const Icon(Icons.explore_outlined),
            selectedIcon: const Icon(Icons.explore, color: AppColors.primary),
            label: l10n?.navExplore ?? 'Discover',
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person, color: AppColors.primary),
            label: l10n?.navProfile ?? 'Profile',
          ),
        ],
      ),
    );
  }
}
