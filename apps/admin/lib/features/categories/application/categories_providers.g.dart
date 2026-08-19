// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'categories_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$adminCategoriesHash() => r'e720950c72fc71ae24a71b3afe276ea73fdc3ec4';

/// See also [adminCategories].
@ProviderFor(adminCategories)
final adminCategoriesProvider =
    AutoDisposeStreamProvider<List<Category>>.internal(
  adminCategories,
  name: r'adminCategoriesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$adminCategoriesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdminCategoriesRef = AutoDisposeStreamProviderRef<List<Category>>;
String _$adminCategoryHash() => r'ed92e54d408191f5af55414accf1f724fce5d9e8';

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

/// See also [adminCategory].
@ProviderFor(adminCategory)
const adminCategoryProvider = AdminCategoryFamily();

/// See also [adminCategory].
class AdminCategoryFamily extends Family<AsyncValue<Category?>> {
  /// See also [adminCategory].
  const AdminCategoryFamily();

  /// See also [adminCategory].
  AdminCategoryProvider call(
    String id,
  ) {
    return AdminCategoryProvider(
      id,
    );
  }

  @override
  AdminCategoryProvider getProviderOverride(
    covariant AdminCategoryProvider provider,
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
  String? get name => r'adminCategoryProvider';
}

/// See also [adminCategory].
class AdminCategoryProvider extends AutoDisposeFutureProvider<Category?> {
  /// See also [adminCategory].
  AdminCategoryProvider(
    String id,
  ) : this._internal(
          (ref) => adminCategory(
            ref as AdminCategoryRef,
            id,
          ),
          from: adminCategoryProvider,
          name: r'adminCategoryProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$adminCategoryHash,
          dependencies: AdminCategoryFamily._dependencies,
          allTransitiveDependencies:
              AdminCategoryFamily._allTransitiveDependencies,
          id: id,
        );

  AdminCategoryProvider._internal(
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
    FutureOr<Category?> Function(AdminCategoryRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AdminCategoryProvider._internal(
        (ref) => create(ref as AdminCategoryRef),
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
  AutoDisposeFutureProviderElement<Category?> createElement() {
    return _AdminCategoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AdminCategoryProvider && other.id == id;
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
mixin AdminCategoryRef on AutoDisposeFutureProviderRef<Category?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _AdminCategoryProviderElement
    extends AutoDisposeFutureProviderElement<Category?> with AdminCategoryRef {
  _AdminCategoryProviderElement(super.provider);

  @override
  String get id => (origin as AdminCategoryProvider).id;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
