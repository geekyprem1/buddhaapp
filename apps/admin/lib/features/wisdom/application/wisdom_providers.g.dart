// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wisdom_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$adminWisdomsHash() => r'0a78cf1698b0d887f4b2da35a4bbf5d38bc8e238';

/// See also [adminWisdoms].
@ProviderFor(adminWisdoms)
final adminWisdomsProvider = AutoDisposeStreamProvider<List<Wisdom>>.internal(
  adminWisdoms,
  name: r'adminWisdomsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$adminWisdomsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdminWisdomsRef = AutoDisposeStreamProviderRef<List<Wisdom>>;
String _$adminWisdomHash() => r'c5758c44bfb5517d9012640440bed38a4cf2b9ce';

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

/// See also [adminWisdom].
@ProviderFor(adminWisdom)
const adminWisdomProvider = AdminWisdomFamily();

/// See also [adminWisdom].
class AdminWisdomFamily extends Family<AsyncValue<Wisdom?>> {
  /// See also [adminWisdom].
  const AdminWisdomFamily();

  /// See also [adminWisdom].
  AdminWisdomProvider call(
    String id,
  ) {
    return AdminWisdomProvider(
      id,
    );
  }

  @override
  AdminWisdomProvider getProviderOverride(
    covariant AdminWisdomProvider provider,
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
  String? get name => r'adminWisdomProvider';
}

/// See also [adminWisdom].
class AdminWisdomProvider extends AutoDisposeFutureProvider<Wisdom?> {
  /// See also [adminWisdom].
  AdminWisdomProvider(
    String id,
  ) : this._internal(
          (ref) => adminWisdom(
            ref as AdminWisdomRef,
            id,
          ),
          from: adminWisdomProvider,
          name: r'adminWisdomProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$adminWisdomHash,
          dependencies: AdminWisdomFamily._dependencies,
          allTransitiveDependencies:
              AdminWisdomFamily._allTransitiveDependencies,
          id: id,
        );

  AdminWisdomProvider._internal(
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
    FutureOr<Wisdom?> Function(AdminWisdomRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AdminWisdomProvider._internal(
        (ref) => create(ref as AdminWisdomRef),
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
    return _AdminWisdomProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AdminWisdomProvider && other.id == id;
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
mixin AdminWisdomRef on AutoDisposeFutureProviderRef<Wisdom?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _AdminWisdomProviderElement
    extends AutoDisposeFutureProviderElement<Wisdom?> with AdminWisdomRef {
  _AdminWisdomProviderElement(super.provider);

  @override
  String get id => (origin as AdminWisdomProvider).id;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
