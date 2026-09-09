import 'dart:async';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../content/application/content_list_controller.dart';
import '../../content/presentation/audio_list_tile.dart';
import '../../player/application/audio_providers.dart';
import '../../premium/application/premium_guard.dart';

/// Guided meditation timer inside Daily Practice: pick a meditation track,
/// set a duration, tap Start — the audio plays and a countdown runs; when it
/// ends, playback stops. Uses the shared audio handler + an independent
/// [SleepTimer] so it never fights the mini-player's own sleep timer.
class MeditationTimerScreen extends ConsumerStatefulWidget {
  const MeditationTimerScreen({super.key});

  @override
  ConsumerState<MeditationTimerScreen> createState() =>
      _MeditationTimerScreenState();
}

class _MeditationTimerScreenState extends ConsumerState<MeditationTimerScreen> {
  static const _presets = [5, 10, 15, 20, 30, 45, 60];

  ContentItem? _track;
  int _minutes = 10;

  Timer? _ticker;
  DateTime? _endsAt;
  bool _running = false;

  /// Dedicated player for the end-of-session bell (independent of the shared
  /// audio handler, which we stop when the timer finishes).
  final AudioPlayer _bell = AudioPlayer();

  @override
  void dispose() {
    _ticker?.cancel();
    _bell.dispose();
    super.dispose();
  }

  Future<void> _playBell() async {
    try {
      await _bell.setAsset('assets/audio/bell.mp3');
      await _bell.play();
    } catch (_) {
      // Bell is a nicety — never let it break the finish flow.
    }
  }

  Duration get _remaining {
    final ends = _endsAt;
    if (ends == null) return Duration(minutes: _minutes);
    final left = ends.difference(DateTime.now());
    return left.isNegative ? Duration.zero : left;
  }

  Future<void> _pickTrack() async {
    AppHaptics.tap();
    final item = await showMeditationTrackPicker(context);
    if (item == null || !mounted) return;
    setState(() => _track = item);
  }

  Future<void> _start() async {
    // Starting a guided meditation is premium.
    if (!ensurePremium(ref, context)) return;
    final l10n = AppLocalizations.of(context);
    final track = _track;
    if (track == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n?.meditationTimerNeedTrack ?? 'Choose a meditation first.',
          ),
        ),
      );
      return;
    }
    if (track.mediaUrl == null || track.mediaUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n?.errorLoadFailed ?? 'This track has no audio.'),
        ),
      );
      return;
    }

    AppHaptics.impact();
    final language = Localizations.localeOf(context).languageCode;
    final handler = ref.read(audioHandlerProvider);

    // Start the countdown IMMEDIATELY — do not wait for the audio to finish
    // loading over the network. Otherwise the timer only appears to start once
    // playback (and a rebuild) kicks in.
    _endsAt = DateTime.now().add(Duration(minutes: _minutes));
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_remaining <= Duration.zero) {
        _finish();
      } else {
        setState(() {}); // re-read _remaining from the clock each tick
      }
    });
    setState(() => _running = true);

    // Fire-and-forget playback; the countdown is independent of load time.
    unawaited(() async {
      await handler.playContent(track, queue: [track], language: language);
      await handler.seek(Duration.zero);
    }());
  }

  Future<void> _finish() async {
    _ticker?.cancel();
    _ticker = null;
    _endsAt = null;
    await ref.read(audioHandlerProvider).stop();
    // Play the gentle bell AFTER the meditation audio stops.
    unawaited(_playBell());
    AppHaptics.success();
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _running = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n?.meditationTimerDone ?? 'Meditation complete. 🙏'),
      ),
    );
  }

  Future<void> _stop() async {
    AppHaptics.tap();
    _ticker?.cancel();
    _ticker = null;
    _endsAt = null;
    await ref.read(audioHandlerProvider).stop();
    if (!mounted) return;
    setState(() => _running = false);
  }

  String _fmt(Duration d) {
    final m = d.inMinutes;
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final language = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.meditationTimerTitle ?? 'Start Meditation'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // ── Countdown dial ──
          Center(
            child: Container(
              width: 220,
              height: 220,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.12),
                    AppColors.accent.withValues(alpha: 0.12),
                  ],
                ),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _fmt(_remaining),
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                  ),
                  Text(
                    _running
                        ? (l10n?.meditationTimerRunning ?? 'Meditating…')
                        : (l10n?.meditationTimerReady ?? 'Ready'),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // ── Track picker ──
          Text(
            l10n?.meditationTimerTrack ?? 'Meditation',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              leading: const Icon(
                Icons.self_improvement,
                color: AppColors.primary,
              ),
              title: Text(
                _track?.title.resolve(language) ??
                    (l10n?.meditationTimerNoTrack ?? 'No meditation selected'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const Icon(Icons.chevron_right),
              enabled: !_running,
              onTap: _running ? null : _pickTrack,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Duration presets ──
          Text(
            l10n?.meditationTimerDuration ?? 'Duration',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final m in _presets)
                ChoiceChip(
                  label: Text(l10n?.meditationTimerMinutes(m) ?? '$m min'),
                  selected: _minutes == m,
                  onSelected: _running
                      ? null
                      : (_) {
                          AppHaptics.tap();
                          setState(() => _minutes = m);
                        },
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // ── Start / Stop ──
          if (_running)
            PrimaryPillButton(
              label: l10n?.meditationTimerStop ?? 'Stop',
              icon: Icons.stop,
              onPressed: _stop,
            )
          else
            PrimaryPillButton(
              label: l10n?.meditationTimerStart ?? 'Start',
              icon: Icons.play_arrow,
              onPressed: _start,
            ),
        ],
      ),
    );
  }
}

/// Bottom-sheet picker over the meditations collection. Returns the chosen
/// [ContentItem] (its `mediaUrl` feeds the audio handler).
Future<ContentItem?> showMeditationTrackPicker(BuildContext context) {
  return AppBottomSheet.show<ContentItem>(
    context: context,
    title: AppLocalizations.of(context)?.meditationTimerTrack ?? 'Meditation',
    child: const SizedBox(
      height: 360,
      child: _MeditationPickerList(),
    ),
  );
}

class _MeditationPickerList extends ConsumerWidget {
  const _MeditationPickerList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(
      contentListControllerProvider(FirestoreCollections.meditations, null),
    );
    final l10n = AppLocalizations.of(context);
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => Center(
        child: Text(l10n?.errorLoadFailed ?? 'Could not load meditations.'),
      ),
      data: (page) {
        if (page.items.isEmpty) {
          return Center(
            child: Text(l10n?.meditationTimerNoTrack ?? 'No meditations yet.'),
          );
        }
        final language = Localizations.localeOf(context).languageCode;
        return ListView.separated(
          itemCount: page.items.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, i) {
            final item = page.items[i];
            return AudioListTile(
              item: item,
              language: language,
              onTap: () => Navigator.of(context).pop(item),
            );
          },
        );
      },
    );
  }
}
