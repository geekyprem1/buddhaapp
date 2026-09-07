import 'package:audio_service/audio_service.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../splash/application/app_bootstrap.dart';
import '../application/audio_providers.dart';
import '../application/dhamma_audio_handler.dart';
import '../application/player_format.dart';

/// Persistent bar over the bottom of every screen while audio is loaded
/// (T2.35). Overlay (not a Column sibling) so it always has bounded width.
class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boot = ref.watch(appBootstrapProvider);
    final gate = boot.valueOrNull?.gate;
    if (boot.isLoading ||
        gate == AppGate.forceUpdate ||
        gate == AppGate.maintenance) {
      return const SizedBox.shrink();
    }
    final handler = dhammaAudioHandlerOrNull;
    if (handler == null) return const SizedBox.shrink();

    final media = ref.watch(currentMediaItemProvider).valueOrNull;
    if (media == null) return const SizedBox.shrink();

    final router = ref.watch(appRouterProvider);

    final playing =
        ref.watch(audioPlaybackStateProvider).valueOrNull?.playing ?? false;
    final position =
        ref.watch(audioPositionProvider).valueOrNull ?? Duration.zero;
    final duration = media.duration ?? Duration.zero;
    final progress = sliderValue(position, duration);

    // Rebuild on every navigation so the bar reappears the moment the user
    // leaves the full player screen (e.g. presses back). Without listening to
    // the router, the mini player only re-evaluates its visibility when an
    // audio provider happens to tick, so it would stay hidden after going back.
    final bar = _buildBar(
      context: context,
      router: router,
      handler: handler,
      media: media,
      playing: playing,
      progress: progress,
    );
    return ListenableBuilder(
      listenable: router.routerDelegate,
      builder: (context, _) {
        if (_isFullPlayerOpen(router)) return const SizedBox.shrink();
        // On the main tabbed screens the NavigationBar sits at the bottom, so
        // lift the mini player above it. On pushed full-screen routes there's
        // no nav bar, so it stays pinned to the bottom.
        final bottom = _isOnMainTab(router) ? _kNavBarHeight : 0.0;
        return Padding(
          padding: EdgeInsets.only(bottom: bottom),
          child: bar,
        );
      },
    );
  }

  Widget _buildBar({
    required BuildContext context,
    required GoRouter router,
    required DhammaAudioHandler handler,
    required MediaItem media,
    required bool playing,
    required double progress,
  }) {
    return Material(
      color: AppColors.surface,
      elevation: 12,
      clipBehavior: Clip.hardEdge,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          width: double.infinity,
          child: Column(
            children: [
              LinearProgressIndicator(
                minHeight: 2,
                value: progress,
                backgroundColor: AppColors.disabled,
                color: AppColors.primary,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      _Art(url: media.artUri?.toString()),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => router.push(AppRoutes.player),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                media.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              Text(
                                media.artist ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // No `tooltip:` on these buttons — the mini player is
                      // rendered outside the app's Navigator/Overlay (it lives
                      // in the MaterialApp.router builder), and Tooltip requires
                      // an Overlay ancestor, which would throw "No Overlay
                      // widget found." and break the whole bar.
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: handler.skipToPrevious,
                        icon: const Icon(Icons.skip_previous),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () =>
                            playing ? handler.pause() : handler.play(),
                        icon: Icon(
                          playing
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_fill,
                          color: AppColors.primary,
                          size: 32,
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: handler.skipToNext,
                        icon: const Icon(Icons.skip_next),
                      ),
                      // Stops playback and clears the current item, which
                      // dismisses the mini player (see DhammaAudioHandler.stop).
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: handler.stop,
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Material 3 [NavigationBar] content height (excludes the system bottom
/// inset, which the mini player already accounts for via its own SafeArea).
const double _kNavBarHeight = 80;

/// The five bottom-nav tab roots. When the current location is one of these,
/// the NavigationBar is visible and the mini player must sit above it.
const _mainTabRoutes = <String>{
  AppRoutes.home,
  AppRoutes.buddhistCalendar,
  AppRoutes.prarthana,
  AppRoutes.explore,
  AppRoutes.profile,
};

bool _isOnMainTab(GoRouter router) {
  try {
    return _mainTabRoutes
        .contains(router.routerDelegate.currentConfiguration.uri.path);
  } catch (_) {
    return false;
  }
}

bool _isFullPlayerOpen(GoRouter router) {
  try {
    final config = router.routerDelegate.currentConfiguration;
    if (config.uri.path == AppRoutes.player) return true;
    for (final match in config.matches) {
      if (match is ImperativeRouteMatch &&
          match.matches.uri.path == AppRoutes.player) {
        return true;
      }
    }
  } catch (_) {}
  return false;
}

class _Art extends StatelessWidget {
  const _Art({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 40,
        height: 40,
        child: url == null || url!.isEmpty
            ? const ColoredBox(
                color: AppColors.disabled,
                child: Icon(Icons.music_note, size: 20),
              )
            : Image.network(
                url!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const ColoredBox(
                  color: AppColors.disabled,
                  child: Icon(Icons.music_note, size: 20),
                ),
              ),
      ),
    );
  }
}
