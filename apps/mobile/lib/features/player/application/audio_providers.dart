import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'dhamma_audio_handler.dart';

part 'audio_providers.g.dart';

@Riverpod(keepAlive: true)
DhammaAudioHandler audioHandler(Ref ref) => dhammaAudioHandler;

@riverpod
Stream<MediaItem?> currentMediaItem(Ref ref) {
  return ref.watch(audioHandlerProvider).mediaItem;
}

@riverpod
Stream<PlaybackState> audioPlaybackState(Ref ref) {
  return ref.watch(audioHandlerProvider).playbackState;
}

@riverpod
Stream<Duration> audioPosition(Ref ref) {
  return ref.watch(audioHandlerProvider).positionStream;
}

@riverpod
Stream<Duration?> sleepTimerRemaining(Ref ref) {
  return ref.watch(audioHandlerProvider).sleepTimer.remainingStream;
}

@Riverpod(keepAlive: true)
class MiniPlayerSuppressed extends _$MiniPlayerSuppressed {
  @override
  bool build() => false;

  void setSuppressed(bool value) => state = value;
}
