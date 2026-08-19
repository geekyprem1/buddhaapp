// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ringtone_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$ringtoneServiceHash() => r'4adde23bdfbde22c60170f153fe29150d173cc4d';

/// See also [ringtoneService].
@ProviderFor(ringtoneService)
final ringtoneServiceProvider = Provider<RingtoneService>.internal(
  ringtoneService,
  name: r'ringtoneServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$ringtoneServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RingtoneServiceRef = ProviderRef<RingtoneService>;
String _$pendingRingtoneHash() => r'7cc6bd2cb83af2a81462cc2e5d4afa4c5925ab72';

/// Survives the WRITE_SETTINGS activity so we can finish the set on resume.
///
/// Copied from [PendingRingtone].
@ProviderFor(PendingRingtone)
final pendingRingtoneProvider =
    NotifierProvider<PendingRingtone, PendingRingtoneSet?>.internal(
  PendingRingtone.new,
  name: r'pendingRingtoneProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$pendingRingtoneHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PendingRingtone = Notifier<PendingRingtoneSet?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
