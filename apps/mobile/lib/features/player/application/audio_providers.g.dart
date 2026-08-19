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
String _$currentMediaItemHash() => r'1df8b06622fdc696a1d56695ce68a66d2cf788a6';

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
    r'e8ee5586244e59aa7e05a208c76b88cef1eae4ee';

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
String _$audioPositionHash() => r'7202aee0082f42f3c7ec7387166395370d043aca';

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
    r'd8b72d1a9a479a304253c58fc319c6834809e68c';

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
String _$miniPlayerSuppressedHash() =>
    r'ea10daa849adbd317e505eaba07e806f27a9e217';

/// See also [MiniPlayerSuppressed].
@ProviderFor(MiniPlayerSuppressed)
final miniPlayerSuppressedProvider =
    NotifierProvider<MiniPlayerSuppressed, bool>.internal(
  MiniPlayerSuppressed.new,
  name: r'miniPlayerSuppressedProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$miniPlayerSuppressedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$MiniPlayerSuppressed = Notifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
