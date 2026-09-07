// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$audioHandlerHash() => r'ad3f934b2c6ca8ad35f6250f8d07decaf7918640';

/// See also [audioHandler].
@ProviderFor(audioHandler)
final audioHandlerProvider = Provider<DhammaAudioHandler>.internal(
  audioHandler,
  name: r'audioHandlerProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$audioHandlerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AudioHandlerRef = ProviderRef<DhammaAudioHandler>;
String _$currentMediaItemHash() => r'ca8b5f0ca04d4c113b7ff7737e5a2524f36e9e4d';

/// See also [currentMediaItem].
@ProviderFor(currentMediaItem)
final currentMediaItemProvider = AutoDisposeStreamProvider<MediaItem?>.internal(
  currentMediaItem,
  name: r'currentMediaItemProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentMediaItemHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentMediaItemRef = AutoDisposeStreamProviderRef<MediaItem?>;
String _$audioPlaybackStateHash() =>
    r'9de904a472dfb27228a0193b7e6e0a88dfaae6d5';

/// See also [audioPlaybackState].
@ProviderFor(audioPlaybackState)
final audioPlaybackStateProvider =
    AutoDisposeStreamProvider<PlaybackState>.internal(
  audioPlaybackState,
  name: r'audioPlaybackStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$audioPlaybackStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AudioPlaybackStateRef = AutoDisposeStreamProviderRef<PlaybackState>;
String _$audioPositionHash() => r'2fecfda26d878a51762b6d6f86ca27a347770bcb';

/// See also [audioPosition].
@ProviderFor(audioPosition)
final audioPositionProvider = AutoDisposeStreamProvider<Duration>.internal(
  audioPosition,
  name: r'audioPositionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$audioPositionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AudioPositionRef = AutoDisposeStreamProviderRef<Duration>;
String _$sleepTimerRemainingHash() =>
    r'934d86072ab4ebce902367cea4925b9834aac934';

/// See also [sleepTimerRemaining].
@ProviderFor(sleepTimerRemaining)
final sleepTimerRemainingProvider =
    AutoDisposeStreamProvider<Duration?>.internal(
  sleepTimerRemaining,
  name: r'sleepTimerRemainingProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sleepTimerRemainingHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SleepTimerRemainingRef = AutoDisposeStreamProviderRef<Duration?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
