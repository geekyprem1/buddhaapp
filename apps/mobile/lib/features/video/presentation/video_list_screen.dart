import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../premium/application/premium_guard.dart';

/// Videos screen — a scrollable list of admin-curated YouTube videos, each
/// shown as a thumbnail card. Tapping opens the in-app player.
class VideoListScreen extends ConsumerWidget {
  const VideoListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(activeVideosProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n?.homeVideo ?? 'Videos',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => ErrorState(
          message: l10n?.errorLoadFailed ?? 'Could not load content.',
          onRetry: () => ref.invalidate(activeVideosProvider),
        ),
        data: (videos) {
          if (videos.isEmpty) {
            return EmptyState(
              message: l10n?.videosEmpty ?? 'No videos yet.',
            );
          }
          final language = Localizations.localeOf(context).languageCode;
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: videos.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, i) {
              final v = videos[i];
              return _VideoCard(
                title: v.title.resolve(language),
                thumbnailUrl: v.thumbnailUrl,
                onTap: () {
                  if (!ensurePremium(ref, context)) return;
                  AppHaptics.impact();
                  context.push(AppRoutes.videoPlayer, extra: v);
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _VideoCard extends StatelessWidget {
  const _VideoCard({
    required this.title,
    required this.thumbnailUrl,
    required this.onTap,
  });

  final String title;
  final String thumbnailUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: thumbnailUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => const ColoredBox(
                      color: AppColors.disabled,
                    ),
                    errorWidget: (_, __, ___) => const ColoredBox(
                      color: AppColors.disabled,
                      child: Icon(Icons.broken_image_outlined),
                    ),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.center,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black26],
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
