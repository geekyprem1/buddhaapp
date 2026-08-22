import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../notifications/application/fcm_coordinator.dart';
import '../../profile/application/profile_providers.dart';
import '../application/home_providers.dart';
import 'feature_coming_soon_screen.dart';

/// Home screen skeleton (PRD FR-6.x). Module grid, status feed and share
/// actions land here in the next milestone — this confirms the onboarding
/// → home hand-off works end-to-end.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _maybeAskNotifications();
      if (!mounted) return;
      final route = ref.read(pendingPushRouteProvider.notifier).take();
      if (route != null) context.go(route);
    });
  }

  Future<void> _maybeAskNotifications() async {
    final fcm = ref.read(fcmCoordinatorProvider);
    if (!fcm.hasPromptedPermission) {
      final l10n = AppLocalizations.of(context);
      final allow = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n?.notifPermissionTitle ?? 'Stay in the loop'),
          content: Text(
            l10n?.notifPermissionBody ??
                'Allow notifications for Daily Prarthana reminders and Dhamma updates.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l10n?.ringtonePermissionNotNow ?? 'Not now'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(l10n?.notifPermissionAllow ?? 'Allow'),
            ),
          ],
        ),
      );
      if (allow == true) {
        await fcm.requestPermissionIfNeeded();
      } else {
        await fcm.skipPermissionPrompt();
      }
    } else {
      await fcm.requestPermissionIfNeeded();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final userValue = ref.watch(currentAppUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          tooltip: l10n?.profileTitle ?? 'Profile',
          onPressed: () => context.push(AppRoutes.profile),
          icon: const Icon(Icons.person_outline),
        ),
        title: Text(
          l10n?.appName ?? AppConstants.appName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            tooltip: l10n?.homeShareApp ?? 'Share App',
            onPressed: shareApp,
            icon: const Icon(Icons.share, color: AppColors.whatsappGreen),
          ),
        ],
      ),
      body: userValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => ErrorState(message: 'Could not load your profile.'),
        data: (_) {
          final layout =
              ref.watch(homeLayoutProvider).valueOrNull ?? HomeLayout.defaults;
          return CustomScrollView(
            slivers: [
              for (var i = 0; i < layout.sections.length; i++)
                ..._sectionSlivers(
                  context,
                  l10n,
                  layout.sections[i],
                  first: i == 0,
                  last: i == layout.sections.length - 1,
                ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _sectionSlivers(
    BuildContext context,
    AppLocalizations? l10n,
    HomeSection section, {
    required bool first,
    required bool last,
  }) {
    final padding = EdgeInsets.fromLTRB(
      AppSpacing.lg,
      first ? AppSpacing.lg : 0,
      AppSpacing.lg,
      last ? AppSpacing.lg : AppSpacing.md,
    );
    if (section.wide) {
      final id = section.ids.first;
      return [
        SliverPadding(
          padding: padding,
          sliver: SliverToBoxAdapter(child: _wideTile(context, l10n, id)),
        ),
      ];
    }
    return [
      SliverPadding(
        padding: padding,
        sliver: SliverGrid.count(
          crossAxisCount: 2,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
          childAspectRatio: 1.5,
          children: [
            for (final id in section.ids) _gridTile(context, l10n, id),
          ],
        ),
      ),
    ];
  }

  Widget _gridTile(BuildContext context, AppLocalizations? l10n, String id) {
    return _ModuleTile(
      icon: _iconFor(id),
      label: _labelFor(l10n, id),
      subtitle: _subtitleFor(l10n, id),
      onTap: () => _openModule(context, l10n, id),
    );
  }

  Widget _wideTile(BuildContext context, AppLocalizations? l10n, String id) {
    final subtitle = _subtitleFor(l10n, id);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: () => _openModule(context, l10n, id),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Icon(_iconFor(id), size: 32, color: AppColors.primary),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _labelFor(l10n, id),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  void _openModule(
    BuildContext context,
    AppLocalizations? l10n,
    String id,
  ) {
    if (HomeModuleIds.isComingSoon(id)) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => FeatureComingSoonScreen(title: _labelFor(l10n, id)),
        ),
      );
      return;
    }
    context.push(_routeFor(id));
  }

  IconData _iconFor(String id) => switch (id) {
        HomeModuleIds.wallpaper => Icons.image_outlined,
        HomeModuleIds.meditation => Icons.self_improvement,
        HomeModuleIds.ringtone => Icons.music_note_outlined,
        HomeModuleIds.song => Icons.library_music_outlined,
        HomeModuleIds.vandana => Icons.spa_outlined,
        HomeModuleIds.prarthana => Icons.notifications_active_outlined,
        HomeModuleIds.status => Icons.auto_awesome,
        HomeModuleIds.buddhistCalendar => Icons.calendar_month_outlined,
        HomeModuleIds.dailyPaliWord => Icons.menu_book_outlined,
        HomeModuleIds.chanting => Icons.graphic_eq_rounded,
        HomeModuleIds.tipitaka => Icons.auto_stories_outlined,
        HomeModuleIds.dana => Icons.favorite_outline_rounded,
        HomeModuleIds.buddhistPlaces => Icons.map_outlined,
        _ => Icons.apps_outlined,
      };

  String _labelFor(AppLocalizations? l10n, String id) => switch (id) {
        HomeModuleIds.wallpaper => l10n?.homeWallpaper ?? 'Wallpapers',
        HomeModuleIds.meditation => l10n?.homeMeditation ?? 'Meditation',
        HomeModuleIds.ringtone => l10n?.homeRingtone ?? 'Ringtone',
        HomeModuleIds.song => l10n?.homeSong ?? 'Song',
        HomeModuleIds.vandana => l10n?.homeVandana ?? 'Vandana',
        HomeModuleIds.prarthana =>
          l10n?.homeDailyPrarthana ?? 'Daily Prarthana',
        HomeModuleIds.status => l10n?.homeTrendingStatus ?? 'Trending Status',
        HomeModuleIds.buddhistCalendar =>
          l10n?.homeBuddhistCalendar ?? 'Buddhist Calendar',
        HomeModuleIds.dailyPaliWord =>
          l10n?.homeDailyPaliWord ?? 'Daily Pali Word',
        HomeModuleIds.chanting => l10n?.homeChanting ?? 'Chanting',
        HomeModuleIds.tipitaka => l10n?.homeTipitaka ?? 'Tipitaka',
        HomeModuleIds.dana => l10n?.homeDana ?? 'Dana',
        HomeModuleIds.buddhistPlaces =>
          l10n?.homeBuddhistPlaces ?? 'Buddhist Places',
        _ => HomeModuleIds.label(id),
      };

  String? _subtitleFor(AppLocalizations? l10n, String id) => switch (id) {
        HomeModuleIds.wallpaper =>
          l10n?.homeWallpaperSubtitle ?? 'HD wallpapers',
        HomeModuleIds.meditation =>
          l10n?.homeMeditationSubtitle ?? 'Timer & guide',
        HomeModuleIds.buddhistCalendar =>
          l10n?.homeBuddhistCalendarSubtitle ?? 'Uposatha • Festivals',
        HomeModuleIds.dailyPaliWord =>
          l10n?.homeDailyPaliWordSubtitle ?? 'Learn one word daily',
        HomeModuleIds.chanting =>
          l10n?.homeChantingSubtitle ?? 'Audio collection',
        HomeModuleIds.tipitaka =>
          l10n?.homeTipitakaSubtitle ?? 'Read scriptures',
        HomeModuleIds.dana => l10n?.homeDanaSubtitle ?? 'Support Dhamma',
        HomeModuleIds.buddhistPlaces =>
          l10n?.homeBuddhistPlacesSubtitle ?? 'Sacred sites',
        _ => null,
      };

  String _routeFor(String id) => switch (id) {
        HomeModuleIds.wallpaper => AppRoutes.wallpapers,
        HomeModuleIds.meditation => AppRoutes.meditations,
        HomeModuleIds.ringtone => AppRoutes.ringtones,
        HomeModuleIds.song => AppRoutes.songs,
        HomeModuleIds.vandana => AppRoutes.vandanas,
        HomeModuleIds.chanting => AppRoutes.chantings,
        HomeModuleIds.buddhistCalendar => AppRoutes.buddhistCalendar,
        HomeModuleIds.prarthana => AppRoutes.prarthana,
        HomeModuleIds.status => AppRoutes.statuses,
        _ => AppRoutes.home,
      };
}

class _ModuleTile extends StatelessWidget {
  const _ModuleTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.button),
                ),
                child: Icon(icon, size: 26, color: AppColors.primary),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
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
