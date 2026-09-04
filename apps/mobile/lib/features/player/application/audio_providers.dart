import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'dhamma_audio_handler.dart';

part 'audio_providers.g.dart';

@Riverpod(keepAlive: true)
DhammaAudioHandler audioHandler(Ref ref) => dhammaAudioHandler;

@riverpod
Stream<MediaItem?> currentMediaItem(Ref ref) {
  final handler = dhammaAudioHandlerOrNull;
  if (handler == null) return const Stream<MediaItem?>.empty();
  return handler.mediaItem;
}

@riverpod
Stream<PlaybackState> audioPlaybackState(Ref ref) {
  final handler = dhammaAudioHandlerOrNull;
  if (handler == null) return const Stream<PlaybackState>.empty();
  return handler.playbackState;
}

@riverpod
Stream<Duration> audioPosition(Ref ref) {
  final handler = dhammaAudioHandlerOrNull;
  if (handler == null) return const Stream<Duration>.empty();
  return handler.positionStream;
}

@riverpod
Stream<Duration?> sleepTimerRemaining(Ref ref) {
  final handler = dhammaAudioHandlerOrNull;
  if (handler == null) return const Stream<Duration?>.empty();
  return handler.sleepTimer.remainingStream;
}
