import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'feature_coming_soon_screen.dart';

/// Shared rendering for the module catalogue (the 2-column grid of feature
/// tiles). Used by both the Home tab (below the wisdom hero) and the Discover
/// tab, so the tile look, labels and routing stay in one place.

/// Builds the slivers for a single [HomeSection] — either a wide row card or a
/// 2-column grid of compact tiles.
List<Widget> moduleSectionSlivers(
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
    last ? AppSpacing.lg : AppSpacing.sm,
  );
  if (section.wide) {
    final id = section.ids.first;
    return [
      SliverPadding(
        padding: padding,
        sliver: SliverToBoxAdapter(
          child: ModuleWideTile(
            icon: moduleIcon(id),
            label: moduleLabel(l10n, id),
            subtitle: moduleSubtitle(l10n, id),
            onTap: () => openModule(context, l10n, id),
          ),
        ),
      ),
    ];
  }
  return [
    SliverPadding(
      padding: padding,
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppSpacing.sm,
          mainAxisSpacing: AppSpacing.sm,
          mainAxisExtent: 80,
        ),
        delegate: SliverChildListDelegate([
          for (final id in section.ids)
            ModuleTile(
              icon: moduleIcon(id),
              label: moduleLabel(l10n, id),
              subtitle: moduleSubtitle(l10n, id),
              onTap: () => openModule(context, l10n, id),
            ),
        ]),
      ),
    ),
  ];
}

/// Opens a module: coming-soon modules show the placeholder screen, everything
/// else pushes its route.
void openModule(BuildContext context, AppLocalizations? l10n, String id) {
  if (HomeModuleIds.isComingSoon(id)) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => FeatureComingSoonScreen(title: moduleLabel(l10n, id)),
      ),
    );
    return;
  }
  context.push(moduleRoute(id));
}

IconData moduleIcon(String id) => switch (id) {
      HomeModuleIds.wallpaper => Icons.image_outlined,
      HomeModuleIds.meditation => Icons.self_improvement,
      HomeModuleIds.ringtone => Icons.music_note_outlined,
      HomeModuleIds.song => Icons.library_music_outlined,
      HomeModuleIds.vandana => Icons.spa_outlined,
      HomeModuleIds.video => Icons.play_circle_outline,
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

String moduleLabel(AppLocalizations? l10n, String id) => switch (id) {
      HomeModuleIds.wallpaper => l10n?.homeWallpaper ?? 'Wallpapers',
      HomeModuleIds.meditation => l10n?.homeMeditation ?? 'Meditation',
      HomeModuleIds.ringtone => l10n?.homeRingtone ?? 'Ringtone',
      HomeModuleIds.song => l10n?.homeSong ?? 'Song',
      HomeModuleIds.vandana => l10n?.homeVandana ?? 'Vandana',
      HomeModuleIds.video => l10n?.homeVideo ?? 'Videos',
      HomeModuleIds.prarthana => l10n?.homeDailyPrarthana ?? 'Daily Prarthana',
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

String? moduleSubtitle(AppLocalizations? l10n, String id) => switch (id) {
      HomeModuleIds.wallpaper => l10n?.homeWallpaperSubtitle ?? 'HD wallpapers',
      HomeModuleIds.meditation =>
        l10n?.homeMeditationSubtitle ?? 'Timer & guide',
      HomeModuleIds.video => l10n?.homeVideoSubtitle ?? 'Watch & learn',
      HomeModuleIds.buddhistCalendar =>
        l10n?.homeBuddhistCalendarSubtitle ?? 'Uposatha • Festivals',
      HomeModuleIds.dailyPaliWord =>
        l10n?.homeDailyPaliWordSubtitle ?? 'Learn one word daily',
      HomeModuleIds.chanting =>
        l10n?.homeChantingSubtitle ?? 'Audio collection',
      HomeModuleIds.tipitaka => l10n?.homeTipitakaSubtitle ?? 'Read scriptures',
      HomeModuleIds.dana => l10n?.homeDanaSubtitle ?? 'Support Dhamma',
      HomeModuleIds.buddhistPlaces =>
        l10n?.homeBuddhistPlacesSubtitle ?? 'Sacred sites',
      _ => null,
    };

String moduleRoute(String id) => switch (id) {
      HomeModuleIds.wallpaper => AppRoutes.wallpapers,
      HomeModuleIds.meditation => AppRoutes.meditations,
      HomeModuleIds.ringtone => AppRoutes.ringtones,
      HomeModuleIds.song => AppRoutes.songs,
      HomeModuleIds.vandana => AppRoutes.vandanas,
      HomeModuleIds.video => AppRoutes.videos,
      HomeModuleIds.chanting => AppRoutes.chantings,
      HomeModuleIds.buddhistCalendar => AppRoutes.buddhistCalendar,
      HomeModuleIds.prarthana => AppRoutes.prarthana,
      HomeModuleIds.status => AppRoutes.statuses,
      _ => AppRoutes.home,
    };

/// Compact feature tile used in the 2-column grid.
class ModuleTile extends StatelessWidget {
  const ModuleTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
    super.key,
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
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withValues(alpha: 0.14),
                      AppColors.accent.withValues(alpha: 0.14),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.button),
                ),
                child: Icon(icon, size: 22, color: AppColors.primary),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            height: 1.1,
                          ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.1,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: AppColors.textSecondary.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Full-width row card used for the wide modules (Daily Prarthana, Status).
class ModuleWideTile extends StatelessWidget {
  const ModuleWideTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
    super.key,
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
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Icon(icon, size: 32, color: AppColors.primary),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: AppSpacing.xs),
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
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
