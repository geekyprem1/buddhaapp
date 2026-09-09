// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_banner_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$adminHomeBannersHash() => r'c3fa99d79d1896a3b06c211ff17ac22c1fe83f45';

/// See also [adminHomeBanners].
@ProviderFor(adminHomeBanners)
final adminHomeBannersProvider =
    AutoDisposeStreamProvider<List<HomeBanner>>.internal(
  adminHomeBanners,
  name: r'adminHomeBannersProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$adminHomeBannersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdminHomeBannersRef = AutoDisposeStreamProviderRef<List<HomeBanner>>;
String _$adminHomeBannerHash() => r'07efe0b228a4f46f8fd626a4f1565f281d9c5142';

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

/// See also [adminHomeBanner].
@ProviderFor(adminHomeBanner)
const adminHomeBannerProvider = AdminHomeBannerFamily();

/// See also [adminHomeBanner].
class AdminHomeBannerFamily extends Family<AsyncValue<HomeBanner?>> {
  /// See also [adminHomeBanner].
  const AdminHomeBannerFamily();

  /// See also [adminHomeBanner].
  AdminHomeBannerProvider call(
    String id,
  ) {
    return AdminHomeBannerProvider(
      id,
    );
  }

  @override
  AdminHomeBannerProvider getProviderOverride(
    covariant AdminHomeBannerProvider provider,
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
  String? get name => r'adminHomeBannerProvider';
}

/// See also [adminHomeBanner].
class AdminHomeBannerProvider extends AutoDisposeFutureProvider<HomeBanner?> {
  /// See also [adminHomeBanner].
  AdminHomeBannerProvider(
    String id,
  ) : this._internal(
          (ref) => adminHomeBanner(
            ref as AdminHomeBannerRef,
            id,
          ),
          from: adminHomeBannerProvider,
          name: r'adminHomeBannerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$adminHomeBannerHash,
          dependencies: AdminHomeBannerFamily._dependencies,
          allTransitiveDependencies:
              AdminHomeBannerFamily._allTransitiveDependencies,
          id: id,
        );

  AdminHomeBannerProvider._internal(
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
    FutureOr<HomeBanner?> Function(AdminHomeBannerRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AdminHomeBannerProvider._internal(
        (ref) => create(ref as AdminHomeBannerRef),
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
  AutoDisposeFutureProviderElement<HomeBanner?> createElement() {
    return _AdminHomeBannerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AdminHomeBannerProvider && other.id == id;
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
mixin AdminHomeBannerRef on AutoDisposeFutureProviderRef<HomeBanner?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _AdminHomeBannerProviderElement
    extends AutoDisposeFutureProviderElement<HomeBanner?>
    with AdminHomeBannerRef {
  _AdminHomeBannerProviderElement(super.provider);

  @override
  String get id => (origin as AdminHomeBannerProvider).id;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
