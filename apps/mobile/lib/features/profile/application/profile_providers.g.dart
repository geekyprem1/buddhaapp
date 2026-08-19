// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$contactRepositoryHash() => r'97a1fe443c3035343f23774e933277eff7c9ae8f';

/// See also [contactRepository].
@ProviderFor(contactRepository)
final contactRepositoryProvider = Provider<ContactRepository>.internal(
  contactRepository,
  name: r'contactRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$contactRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ContactRepositoryRef = ProviderRef<ContactRepository>;
String _$packageInfoHash() => r'f1c17d5174896e536210506ee5ade32f9766a6b9';

/// See also [packageInfo].
@ProviderFor(packageInfo)
final packageInfoProvider = AutoDisposeFutureProvider<PackageInfo>.internal(
  packageInfo,
  name: r'packageInfoProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$packageInfoHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PackageInfoRef = AutoDisposeFutureProviderRef<PackageInfo>;
String _$staticPageHash() => r'611cb96e7c9aa25fed2bda0bda696ecce3900ce7';

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

/// See also [staticPage].
@ProviderFor(staticPage)
const staticPageProvider = StaticPageFamily();

/// See also [staticPage].
class StaticPageFamily extends Family<AsyncValue<StaticPage?>> {
  /// See also [staticPage].
  const StaticPageFamily();

  /// See also [staticPage].
  StaticPageProvider call(
    String slug,
  ) {
    return StaticPageProvider(
      slug,
    );
  }

  @override
  StaticPageProvider getProviderOverride(
    covariant StaticPageProvider provider,
  ) {
    return call(
      provider.slug,
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
  String? get name => r'staticPageProvider';
}

/// See also [staticPage].
class StaticPageProvider extends AutoDisposeFutureProvider<StaticPage?> {
  /// See also [staticPage].
  StaticPageProvider(
    String slug,
  ) : this._internal(
          (ref) => staticPage(
            ref as StaticPageRef,
            slug,
          ),
          from: staticPageProvider,
          name: r'staticPageProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$staticPageHash,
          dependencies: StaticPageFamily._dependencies,
          allTransitiveDependencies:
              StaticPageFamily._allTransitiveDependencies,
          slug: slug,
        );

  StaticPageProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.slug,
  }) : super.internal();

  final String slug;

  @override
  Override overrideWith(
    FutureOr<StaticPage?> Function(StaticPageRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: StaticPageProvider._internal(
        (ref) => create(ref as StaticPageRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        slug: slug,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<StaticPage?> createElement() {
    return _StaticPageProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StaticPageProvider && other.slug == slug;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, slug.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin StaticPageRef on AutoDisposeFutureProviderRef<StaticPage?> {
  /// The parameter `slug` of this provider.
  String get slug;
}

class _StaticPageProviderElement
    extends AutoDisposeFutureProviderElement<StaticPage?> with StaticPageRef {
  _StaticPageProviderElement(super.provider);

  @override
  String get slug => (origin as StaticPageProvider).slug;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
