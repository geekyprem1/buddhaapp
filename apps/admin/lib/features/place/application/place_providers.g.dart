// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'place_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$adminPlacesHash() => r'edebf2f848c6ca1709619cefd0b1e1b9839fce42';

/// See also [adminPlaces].
@ProviderFor(adminPlaces)
final adminPlacesProvider =
    AutoDisposeStreamProvider<List<BuddhistPlace>>.internal(
  adminPlaces,
  name: r'adminPlacesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$adminPlacesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdminPlacesRef = AutoDisposeStreamProviderRef<List<BuddhistPlace>>;
String _$adminPlaceHash() => r'18ed0abc7326c417a019c92ff2f944e7f7bc6925';

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

/// See also [adminPlace].
@ProviderFor(adminPlace)
const adminPlaceProvider = AdminPlaceFamily();

/// See also [adminPlace].
class AdminPlaceFamily extends Family<AsyncValue<BuddhistPlace?>> {
  /// See also [adminPlace].
  const AdminPlaceFamily();

  /// See also [adminPlace].
  AdminPlaceProvider call(
    String id,
  ) {
    return AdminPlaceProvider(
      id,
    );
  }

  @override
  AdminPlaceProvider getProviderOverride(
    covariant AdminPlaceProvider provider,
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
  String? get name => r'adminPlaceProvider';
}

/// See also [adminPlace].
class AdminPlaceProvider extends AutoDisposeFutureProvider<BuddhistPlace?> {
  /// See also [adminPlace].
  AdminPlaceProvider(
    String id,
  ) : this._internal(
          (ref) => adminPlace(
            ref as AdminPlaceRef,
            id,
          ),
          from: adminPlaceProvider,
          name: r'adminPlaceProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$adminPlaceHash,
          dependencies: AdminPlaceFamily._dependencies,
          allTransitiveDependencies:
              AdminPlaceFamily._allTransitiveDependencies,
          id: id,
        );

  AdminPlaceProvider._internal(
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
    FutureOr<BuddhistPlace?> Function(AdminPlaceRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AdminPlaceProvider._internal(
        (ref) => create(ref as AdminPlaceRef),
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
  AutoDisposeFutureProviderElement<BuddhistPlace?> createElement() {
    return _AdminPlaceProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AdminPlaceProvider && other.id == id;
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
mixin AdminPlaceRef on AutoDisposeFutureProviderRef<BuddhistPlace?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _AdminPlaceProviderElement
    extends AutoDisposeFutureProviderElement<BuddhistPlace?>
    with AdminPlaceRef {
  _AdminPlaceProviderElement(super.provider);

  @override
  String get id => (origin as AdminPlaceProvider).id;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
