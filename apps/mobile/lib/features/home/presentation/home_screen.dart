import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Home screen skeleton (PRD FR-6.x). Module grid, status feed and share
/// actions land here in the next milestone — this confirms the onboarding
/// → home hand-off works end-to-end.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final userValue = ref.watch(currentAppUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const Icon(Icons.person_outline),
        title: Text(l10n?.appName ?? AppConstants.appName),
        actions: [
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.share, color: AppColors.whatsappGreen),
            label: Text(l10n?.homeShareApp ?? 'Share App'),
          ),
        ],
      ),
      body: userValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => ErrorState(message: 'Could not load your profile.'),
        data: (user) => Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            children: [
              _ModuleTile(
                icon: Icons.image_outlined,
                label: l10n?.homeWallpaper ?? 'Wallpaper',
                onTap: () => context.push(AppRoutes.wallpapers),
              ),
              _ModuleTile(
                icon: Icons.self_improvement,
                label: l10n?.homeMeditation ?? 'Meditation',
                onTap: () => context.push(AppRoutes.meditations),
              ),
              _ModuleTile(
                icon: Icons.music_note_outlined,
                label: l10n?.homeRingtone ?? 'Ringtone',
                onTap: () => context.push(AppRoutes.ringtones),
              ),
              _ModuleTile(
                icon: Icons.library_music_outlined,
                label: l10n?.homeSong ?? 'Song',
                onTap: () => context.push(AppRoutes.songs),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModuleTile extends StatelessWidget {
  const _ModuleTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: AppColors.primary),
            const SizedBox(height: AppSpacing.sm),
            Text(label),
          ],
        ),
      ),
    );
  }
}
