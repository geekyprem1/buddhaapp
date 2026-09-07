import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../notifications/application/fcm_coordinator.dart';
import '../../profile/application/profile_providers.dart';
import '../../wisdom/presentation/wisdom_hero_card.dart';
import '../application/home_providers.dart';
import 'module_catalog.dart';

/// Home tab. Shows today's wisdom hero card followed by the module grid.
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
      appBar: AppBar(
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
              const SliverToBoxAdapter(child: WisdomHeroCard()),
              for (var i = 0; i < layout.sections.length; i++)
                ...moduleSectionSlivers(
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
}
