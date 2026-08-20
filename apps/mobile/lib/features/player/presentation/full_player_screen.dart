import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../application/audio_providers.dart';
import '../application/media_item_mapper.dart';
import 'sleep_timer_sheet.dart';

class FullPlayerScreen extends ConsumerStatefulWidget {
  const FullPlayerScreen({super.key});

  @override
  ConsumerState<FullPlayerScreen> createState() => _FullPlayerScreenState();
}

class _FullPlayerScreenState extends ConsumerState<FullPlayerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(miniPlayerSuppressedProvider.notifier).setSuppressed(true);
    });
  }

  @override
  void dispose() {
    ref.read(miniPlayerSuppressedProvider.notifier).setSuppressed(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final media = ref.watch(currentMediaItemProvider).valueOrNull;
    final playback = ref.watch(audioPlaybackStateProvider).valueOrNull;
    final position = ref.watch(audioPositionProvider).valueOrNull ?? Duration.zero;
    final sleepLeft = ref.watch(sleepTimerRemainingProvider).valueOrNull;
    final handler = ref.read(audioHandlerProvider);
    final showSleep = media != null && isMeditationMedia(media);

    if (media == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(),
        body: const Center(child: Text('Nothing is playing.')),
      );
    }

    final duration = media.duration ?? Duration.zero;
    final playing = playback?.playing ?? false;
    final buffering = playback?.processingState == AudioProcessingState.loading ||
        playback?.processingState == AudioProcessingState.buffering;
    final repeat = playback?.repeatMode ?? AudioServiceRepeatMode.none;
    final shuffle = playback?.shuffleMode == AudioServiceShuffleMode.all;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Now playing', overflow: TextOverflow.ellipsis),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final artMax = (constraints.maxHeight * 0.42).clamp(160.0, 360.0);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: artMax),
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: media.artUri == null
                              ? const ColoredBox(
                                  color: AppColors.disabled,
                                  child: Icon(Icons.music_note, size: 72),
                                )
                              : CachedNetworkImage(
                                  imageUrl: media.artUri.toString(),
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    media.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    media.artist ?? 'Anonymous',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (buffering) const LinearProgressIndicator(),
                  Slider(
                    value: _sliderValue(position, duration),
                    onChanged: duration.inMilliseconds == 0
                        ? null
                        : (v) => handler.seek(
                              Duration(
                                milliseconds:
                                    (v * duration.inMilliseconds).round(),
                              ),
                            ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_fmt(position)),
                      Text(_fmt(duration)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        tooltip: 'Previous',
                        onPressed: handler.skipToPrevious,
                        icon: const Icon(Icons.skip_previous, size: 32),
                      ),
                      IconButton(
                        tooltip: 'Back 10 seconds',
                        onPressed: handler.skipBack,
                        icon: const Icon(Icons.replay_10, size: 26),
                      ),
                      IconButton(
                        tooltip: playing ? 'Pause' : 'Play',
                        onPressed: () =>
                            playing ? handler.pause() : handler.play(),
                        icon: Icon(
                          playing
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_fill,
                          size: 64,
                          color: AppColors.primary,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Forward 10 seconds',
                        onPressed: handler.skipForward,
                        icon: const Icon(Icons.forward_10, size: 26),
                      ),
                      IconButton(
                        tooltip: 'Next',
                        onPressed: handler.skipToNext,
                        icon: const Icon(Icons.skip_next, size: 32),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        tooltip: 'Shuffle',
                        onPressed: handler.toggleShuffle,
                        icon: Icon(
                          Icons.shuffle,
                          color: shuffle
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      IconButton(
                        tooltip: 'Repeat',
                        onPressed: handler.cycleRepeat,
                        icon: Icon(
                          repeat == AudioServiceRepeatMode.one
                              ? Icons.repeat_one
                              : Icons.repeat,
                          color: repeat == AudioServiceRepeatMode.none
                              ? AppColors.textSecondary
                              : AppColors.primary,
                        ),
                      ),
                      if (showSleep) ...[
                        const SizedBox(width: AppSpacing.lg),
                        IconButton(
                          tooltip: l10n?.sleepTimerTitle ?? 'Sleep timer',
                          onPressed: () => showSleepTimerSheet(context, ref),
                          icon: Icon(
                            Icons.bedtime_outlined,
                            color: sleepLeft != null
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (showSleep && sleepLeft != null)
                    Text(
                      l10n?.sleepTimerRemaining(_fmt(sleepLeft)) ??
                          'Sleep in ${_fmt(sleepLeft)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.primary,
                          ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

double _sliderValue(Duration position, Duration duration) {
  if (duration.inMilliseconds <= 0) return 0;
  final v = position.inMilliseconds / duration.inMilliseconds;
  return v.clamp(0.0, 1.0);
}

String _fmt(Duration d) {
  final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  final h = d.inHours;
  if (h > 0) return '$h:$m:$s';
  return '$m:$s';
}
