import 'package:cached_network_image/cached_network_image.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../splash/application/app_bootstrap.dart';
import '../application/audio_providers.dart';

/// Persistent bar that survives navigation (T2.35). Hidden when nothing
/// is loaded.
class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(miniPlayerSuppressedProvider)) {
      return const SizedBox.shrink();
    }
    final boot = ref.watch(appBootstrapProvider);
    final gate = boot.valueOrNull?.gate;
    if (boot.isLoading ||
        gate == AppGate.forceUpdate ||
        gate == AppGate.maintenance) {
      return const SizedBox.shrink();
    }

    final media = ref.watch(currentMediaItemProvider).valueOrNull;
    final playback = ref.watch(audioPlaybackStateProvider).valueOrNull;
    if (media == null) return const SizedBox.shrink();

    final playing = playback?.playing ?? false;
    final handler = ref.read(audioHandlerProvider);

    return Material(
      color: AppColors.surface,
      elevation: 8,
      child: InkWell(
        onTap: () => context.push(AppRoutes.player),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: media.artUri == null
                          ? const ColoredBox(color: AppColors.disabled)
                          : CachedNetworkImage(
                              imageUrl: media.artUri.toString(),
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          media.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          media.artist ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: playing ? 'Pause' : 'Play',
                    onPressed: () =>
                        playing ? handler.pause() : handler.play(),
                    icon: Icon(
                      playing ? Icons.pause_circle_filled : Icons.play_circle_fill,
                      color: AppColors.primary,
                      size: 36,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
