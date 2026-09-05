// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wisdom_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$todayWisdomHash() => r'e1d6429e3171dfd31fff4990a00f118af76d0ebd';

/// Today's card for the home hero. `null` while loading or when the admin
/// hasn't published any card yet (the hero hides itself).
///
/// Copied from [todayWisdom].
@ProviderFor(todayWisdom)
final todayWisdomProvider = AutoDisposeProvider<Wisdom?>.internal(
  todayWisdom,
  name: r'todayWisdomProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$todayWisdomHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TodayWisdomRef = AutoDisposeProviderRef<Wisdom?>;
String _$wisdomByIdHash() => r'172dded5ed1e7ff2ff8b3dab2495ac406eb19bfb';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// One card by id, for the detail screen.
///
/// Copied from [wisdomById].
@ProviderFor(wisdomById)
const wisdomByIdProvider = WisdomByIdFamily();

/// One card by id, for the detail screen.
///
/// Copied from [wisdomById].
class WisdomByIdFamily extends Family<AsyncValue<Wisdom?>> {
  /// One card by id, for the detail screen.
  ///
  /// Copied from [wisdomById].
  const WisdomByIdFamily();

  /// One card by id, for the detail screen.
  ///
  /// Copied from [wisdomById].
  WisdomByIdProvider call(
    String id,
  ) {
    return WisdomByIdProvider(
      id,
    );
  }

  @override
  WisdomByIdProvider getProviderOverride(
    covariant WisdomByIdProvider provider,
  ) {
    return call(
      provider.id,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'wisdomByIdProvider';
}

/// One card by id, for the detail screen.
///
/// Copied from [wisdomById].
class WisdomByIdProvider extends AutoDisposeFutureProvider<Wisdom?> {
  /// One card by id, for the detail screen.
  ///
  /// Copied from [wisdomById].
  WisdomByIdProvider(
    String id,
  ) : this._internal(
          (ref) => wisdomById(
            ref as WisdomByIdRef,
            id,
          ),
          from: wisdomByIdProvider,
          name: r'wisdomByIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$wisdomByIdHash,
          dependencies: WisdomByIdFamily._dependencies,
          allTransitiveDependencies:
              WisdomByIdFamily._allTransitiveDependencies,
          id: id,
        );

  WisdomByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(
    FutureOr<Wisdom?> Function(WisdomByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: WisdomByIdProvider._internal(
        (ref) => create(ref as WisdomByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Wisdom?> createElement() {
    return _WisdomByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WisdomByIdProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin WisdomByIdRef on AutoDisposeFutureProviderRef<Wisdom?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _WisdomByIdProviderElement
    extends AutoDisposeFutureProviderElement<Wisdom?> with WisdomByIdRef {
  _WisdomByIdProviderElement(super.provider);

  @override
  String get id => (origin as WisdomByIdProvider).id;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
