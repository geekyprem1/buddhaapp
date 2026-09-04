// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zoom_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sharedPreferencesHash() => r'1d918febfb0fbc49ea16643d1c4a79dfd24e50ca';

/// Injected in `main` with a real [SharedPreferences] instance.
///
/// Copied from [sharedPreferences].
@ProviderFor(sharedPreferences)
final sharedPreferencesProvider = Provider<SharedPreferences>.internal(
  sharedPreferences,
  name: r'sharedPreferencesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sharedPreferencesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SharedPreferencesRef = ProviderRef<SharedPreferences>;
String _$zoomControllerHash() => r'e4c18c5f8e1fba518bac0b3f5333a6df217c0801';

/// See also [ZoomController].
@ProviderFor(ZoomController)
final zoomControllerProvider =
    NotifierProvider<ZoomController, double>.internal(
  ZoomController.new,
  name: r'zoomControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$zoomControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ZoomController = Notifier<double>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
