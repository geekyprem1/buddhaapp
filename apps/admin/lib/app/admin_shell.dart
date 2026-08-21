import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/application/admin_auth_controller.dart';
import '../features/auth/application/admin_session.dart';
import 'admin_access.dart';
import 'admin_strings.dart';
import '../widgets/responsive_layout.dart';

/// Collapsible left nav + top bar (AR-8.1). Collapses to icons below 1100px.
class AdminShell extends ConsumerWidget {
  const AdminShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < AdminResponsive.compactBreakpoint;
    final collapsed = width < AdminResponsive.expandedNavBreakpoint;
    final location = GoRouterState.of(context).uri.path;
    final role = ref.watch(adminRoleProvider).valueOrNull ?? '';
    final user = ref.watch(adminAuthUserProvider);
    final items = visibleFor(role);

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: compact
          ? Drawer(
              width: 248,
              child: AdminSideNav(
                destinations: items,
                currentPath: location,
                onSelect: (path) {
                  Navigator.of(context).pop();
                  context.go(path);
                },
              ),
            )
          : null,
      body: Builder(
        builder: (scaffoldContext) => Row(
          children: [
            if (!compact)
              AdminSideNav(
                destinations: items,
                currentPath: location,
                collapsed: collapsed,
                onSelect: (path) => context.go(path),
              ),
            Expanded(
              child: Column(
                children: [
                  _TopBar(
                    email: user?.email ?? '',
                    role: role,
                    compact: compact,
                    onMenu: compact
                        ? () => Scaffold.of(scaffoldContext).openDrawer()
                        : null,
                    onSignOut: () => ref
                        .read(adminAuthControllerProvider.notifier)
                        .signOut(),
                  ),
                  const Divider(height: 1),
                  Expanded(child: child),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminSideNav extends StatelessWidget {
  const AdminSideNav({
    required this.destinations,
    required this.currentPath,
    required this.onSelect,
    this.collapsed = false,
    super.key,
  });

  final List<AdminDestination> destinations;
  final String currentPath;
  final ValueChanged<String> onSelect;
  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Admin navigation',
      container: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: collapsed ? 76 : 248,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
            right: BorderSide(color: AppColors.accent, width: 2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                collapsed ? 12 : 20,
                24,
                collapsed ? 12 : 20,
                16,
              ),
              child: collapsed
                  ? const Icon(
                      Icons.self_improvement,
                      color: AppColors.primary,
                      size: 28,
                    )
                  : const _BrandMark(),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: destinations.length,
                itemBuilder: (context, index) {
                  final dest = destinations[index];
                  final selected = currentPath == dest.path ||
                      currentPath.startsWith('${dest.path}/');
                  return _NavTile(
                    label: dest.label,
                    selected: selected,
                    collapsed: collapsed,
                    icon: _iconFor(dest.path),
                    onTap: () => onSelect(dest.path),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AdminStrings.deskName.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.accent,
                letterSpacing: 2.2,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          AdminStrings.appName,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.label,
    required this.selected,
    required this.collapsed,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool collapsed;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Material(
          color: selected ? AppColors.background : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: AppSpacing.minTouchTarget,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      size: 20,
                      color: selected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                    if (!collapsed) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          label,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: selected
                                        ? AppColors.primary
                                        : AppColors.textPrimary,
                                    fontWeight: selected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.email,
    required this.role,
    required this.compact,
    required this.onSignOut,
    this.onMenu,
  });

  final String email;
  final String role;
  final bool compact;
  final VoidCallback onSignOut;
  final VoidCallback? onMenu;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      child: SizedBox(
        height: compact ? 56 : 64,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AdminResponsive.gutter(context),
          ),
          child: Row(
            children: [
              if (onMenu != null)
                IconButton(
                  tooltip: 'Open navigation',
                  onPressed: onMenu,
                  icon: const Icon(Icons.menu),
                ),
              const Spacer(),
              if (!compact && role.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.accent),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    AdminRole.label(role),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              if (!compact) ...[
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    email,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: onSignOut,
                  child: const Text(AdminStrings.signOut),
                ),
              ] else
                PopupMenuButton<String>(
                  tooltip: 'Account',
                  icon: const Icon(Icons.account_circle_outlined),
                  onSelected: (value) {
                    if (value == 'sign_out') onSignOut();
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      enabled: false,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 240),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              email,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (role.isNotEmpty)
                              Text(
                                AdminRole.label(role),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                          ],
                        ),
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'sign_out',
                      child: Text(AdminStrings.signOut),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

IconData _iconFor(String path) {
  return switch (path) {
    AdminRoutes.dashboard => Icons.dashboard_outlined,
    AdminRoutes.teachers => Icons.people_outline,
    AdminRoutes.categories => Icons.category_outlined,
    AdminRoutes.wallpapers => Icons.image_outlined,
    AdminRoutes.ringtones => Icons.notifications_outlined,
    AdminRoutes.songs => Icons.library_music_outlined,
    AdminRoutes.meditations => Icons.self_improvement,
    AdminRoutes.chantings => Icons.graphic_eq_rounded,
    AdminRoutes.statuses => Icons.photo_outlined,
    AdminRoutes.prarthanas => Icons.alarm_outlined,
    AdminRoutes.users => Icons.manage_accounts_outlined,
    AdminRoutes.notifications => Icons.campaign_outlined,
    AdminRoutes.config => Icons.settings_outlined,
    AdminRoutes.pages => Icons.article_outlined,
    AdminRoutes.audit => Icons.history,
    AdminRoutes.contact => Icons.mail_outline,
    _ => Icons.circle_outlined,
  };
}
