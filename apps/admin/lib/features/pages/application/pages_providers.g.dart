// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pages_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$adminStaticPagesHash() => r'e5f60718293a4b5c6d7e8f9012a3b4c5d6e7f809';

/// See also [adminStaticPages].
@ProviderFor(adminStaticPages)
final adminStaticPagesProvider =
    AutoDisposeStreamProvider<List<StaticPage>>.internal(
  adminStaticPages,
  name: r'adminStaticPagesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$adminStaticPagesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdminStaticPagesRef = AutoDisposeStreamProviderRef<List<StaticPage>>;
String _$adminStaticPageHash() => r'f60718293a4b5c6d7e8f9012a3b4c5d6e7f8091a';

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

/// See also [adminStaticPage].
@ProviderFor(adminStaticPage)
const adminStaticPageProvider = AdminStaticPageFamily();

/// See also [adminStaticPage].
class AdminStaticPageFamily extends Family<AsyncValue<StaticPage?>> {
  /// See also [adminStaticPage].
  const AdminStaticPageFamily();

  /// See also [adminStaticPage].
  AdminStaticPageProvider call(
    String slug,
  ) {
    return AdminStaticPageProvider(
      slug,
    );
  }

  @override
  AdminStaticPageProvider getProviderOverride(
    covariant AdminStaticPageProvider provider,
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
  String? get name => r'adminStaticPageProvider';
}

/// See also [adminStaticPage].
class AdminStaticPageProvider extends AutoDisposeFutureProvider<StaticPage?> {
  /// See also [adminStaticPage].
  AdminStaticPageProvider(
    String slug,
  ) : this._internal(
          (ref) => adminStaticPage(
            ref as AdminStaticPageRef,
            slug,
          ),
          from: adminStaticPageProvider,
          name: r'adminStaticPageProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$adminStaticPageHash,
          dependencies: AdminStaticPageFamily._dependencies,
          allTransitiveDependencies:
              AdminStaticPageFamily._allTransitiveDependencies,
          slug: slug,
        );

  AdminStaticPageProvider._internal(
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
    FutureOr<StaticPage?> Function(AdminStaticPageRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AdminStaticPageProvider._internal(
        (ref) => create(ref as AdminStaticPageRef),
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
    return _AdminStaticPageProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AdminStaticPageProvider && other.slug == slug;
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
mixin AdminStaticPageRef on AutoDisposeFutureProviderRef<StaticPage?> {
  /// The parameter `slug` of this provider.
  String get slug;
}

class _AdminStaticPageProviderElement
    extends AutoDisposeFutureProviderElement<StaticPage?>
    with AdminStaticPageRef {
  _AdminStaticPageProviderElement(super.provider);

  @override
  String get slug => (origin as AdminStaticPageProvider).slug;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
