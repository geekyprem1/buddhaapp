import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:core/core.dart';
import 'package:just_audio/just_audio.dart';

import 'media_item_mapper.dart';
import 'sleep_timer.dart';

/// Single [AudioHandler] for ringtone previews, songs and meditations
/// (Architecture §9.5). A second play request always stops the first.
class DhammaAudioHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  DhammaAudioHandler() {
    _player.playbackEventStream.listen(_broadcastState);
    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        _onComplete();
      }
    });
  }

  final AudioPlayer _player = AudioPlayer();
  final EventsRepository _events = EventsRepository();
  var _retrying = false;

  late final SleepTimer sleepTimer = SleepTimer(
    onElapsed: () {
      unawaited(pause());
    },
  );

  Stream<Duration> get positionStream => _player.positionStream;

  void setSleepTimer(Duration? duration) {
    if (duration == null || duration <= Duration.zero) {
      sleepTimer.cancel();
    } else {
      sleepTimer.start(duration);
    }
  }

  Future<void> playContent(
    ContentItem item, {
    List<ContentItem>? queue,
    String language = 'en',
  }) async {
    final playable = (queue ?? [item])
        .where((e) => e.mediaUrl != null && e.mediaUrl!.isNotEmpty)
        .toList();
    if (playable.isEmpty) return;

    final mediaItems = [
      for (final e in playable) mediaItemFromContent(e, language: language),
    ];
    this.queue.add(mediaItems);

    var index = playable.indexWhere((e) => e.id == item.id);
    if (index < 0) index = 0;
    await _loadIndex(index);
    await play();
  }

  Future<void> _loadIndex(int index) async {
    final items = queue.value;
    if (index < 0 || index >= items.length) return;
    final item = items[index];
    mediaItem.add(item);
    final url = mediaUrlOf(item);
    if (url == null || url.isEmpty) return;
    try {
      await _player.setUrl(url);
      _retrying = false;
    } catch (_) {
      if (_retrying) rethrow;
      _retrying = true;
      await Future<void>.delayed(const Duration(seconds: 1));
      await _player.setUrl(url);
      _retrying = false;
    }
  }

  Future<void> _onComplete() async {
    // FR-9.10 — count a *completed* play. Fire-and-forget into `events/`;
    // `aggregateEvents` folds it into the content doc's `counters.plays`.
    _recordPlay(mediaItem.value);

    if (_player.loopMode == LoopMode.one) {
      await _player.seek(Duration.zero);
      await _player.play();
      return;
    }
    final items = queue.value;
    final current = mediaItem.value;
    if (current == null || items.isEmpty) return;
    final index = items.indexWhere((e) => e.id == current.id);
    if (index >= 0 && index < items.length - 1) {
      await skipToNext();
    } else if (_player.loopMode == LoopMode.all && items.isNotEmpty) {
      await _loadIndex(0);
      await play();
    } else {
      await stop();
    }
  }

  void _recordPlay(MediaItem? item) {
    if (item == null) return;
    final type = contentTypeOf(item);
    final collection = type == null ? null : ContentCollections.forType(type);
    if (collection == null) return;
    // Ringtone previews aren't "plays" in the FR-9.10 sense — skip them.
    if (type == ContentType.ringtone) return;
    unawaited(
      _events
          .record(
            collection: collection,
            itemId: item.id,
            type: ContentEventType.play,
          )
          .catchError((_) {}),
    );
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    sleepTimer.cancel();
    await _player.stop();
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() async {
    final items = queue.value;
    final current = mediaItem.value;
    if (current == null) return;
    final index = items.indexWhere((e) => e.id == current.id);
    if (index < 0 || index >= items.length - 1) return;
    final wasPlaying = _player.playing;
    await _loadIndex(index + 1);
    if (wasPlaying) await play();
  }

  @override
  Future<void> skipToPrevious() async {
    if (_player.position > const Duration(seconds: 3)) {
      await seek(Duration.zero);
      return;
    }
    final items = queue.value;
    final current = mediaItem.value;
    if (current == null) return;
    final index = items.indexWhere((e) => e.id == current.id);
    if (index <= 0) {
      await seek(Duration.zero);
      return;
    }
    final wasPlaying = _player.playing;
    await _loadIndex(index - 1);
    if (wasPlaying) await play();
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    final wasPlaying = _player.playing;
    await _loadIndex(index);
    if (wasPlaying) await play();
  }

  Future<void> skipForward() =>
      seek(_player.position + const Duration(seconds: 10));

  Future<void> skipBack() {
    final next = _player.position - const Duration(seconds: 10);
    return seek(next.isNegative ? Duration.zero : next);
  }

  Future<void> cycleRepeat() async {
    final next = switch (_player.loopMode) {
      LoopMode.off => LoopMode.all,
      LoopMode.all => LoopMode.one,
      LoopMode.one => LoopMode.off,
    };
    await _player.setLoopMode(next);
    _broadcastState(_player.playbackEvent);
  }

  Future<void> toggleShuffle() async {
    await _player.setShuffleModeEnabled(!_player.shuffleModeEnabled);
    _broadcastState(_player.playbackEvent);
  }

  void _broadcastState(PlaybackEvent event) {
    final playing = _player.playing;
    playbackState.add(
      PlaybackState(
        controls: [
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
          MediaControl.stop,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player.processingState]!,
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: () {
          final current = mediaItem.value;
          if (current == null) return null;
          final i = queue.value.indexWhere((e) => e.id == current.id);
          return i < 0 ? null : i;
        }(),
        repeatMode: switch (_player.loopMode) {
          LoopMode.off => AudioServiceRepeatMode.none,
          LoopMode.one => AudioServiceRepeatMode.one,
          LoopMode.all => AudioServiceRepeatMode.all,
        },
        shuffleMode: _player.shuffleModeEnabled
            ? AudioServiceShuffleMode.all
            : AudioServiceShuffleMode.none,
      ),
    );
  }
}

DhammaAudioHandler? _handler;

Future<DhammaAudioHandler> initAudioHandler() async {
  _handler = await AudioService.init(
    builder: DhammaAudioHandler.new,
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'app.dhammapath.audio',
      androidNotificationChannelName: 'Dhamma Path',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );
  return _handler!;
}

DhammaAudioHandler get dhammaAudioHandler {
  final handler = _handler;
  if (handler == null) {
    throw StateError(
      'Audio handler was not initialised. Call initAudioHandler() from main().',
    );
  }
  return handler;
}
