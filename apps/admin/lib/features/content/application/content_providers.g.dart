// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$adminContentListHash() => r'634cacbedb3fbbb5fa89cf6d339ea31fb7667dcd';

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

/// See also [adminContentList].
@ProviderFor(adminContentList)
const adminContentListProvider = AdminContentListFamily();

/// See also [adminContentList].
class AdminContentListFamily extends Family<AsyncValue<List<ContentItem>>> {
  /// See also [adminContentList].
  const AdminContentListFamily();

  /// See also [adminContentList].
  AdminContentListProvider call(
    String collection,
  ) {
    return AdminContentListProvider(
      collection,
    );
  }

  @override
  AdminContentListProvider getProviderOverride(
    covariant AdminContentListProvider provider,
  ) {
    return call(
      provider.collection,
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
  String? get name => r'adminContentListProvider';
}

/// See also [adminContentList].
class AdminContentListProvider
    extends AutoDisposeFutureProvider<List<ContentItem>> {
  /// See also [adminContentList].
  AdminContentListProvider(
    String collection,
  ) : this._internal(
          (ref) => adminContentList(
            ref as AdminContentListRef,
            collection,
          ),
          from: adminContentListProvider,
          name: r'adminContentListProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$adminContentListHash,
          dependencies: AdminContentListFamily._dependencies,
          allTransitiveDependencies:
              AdminContentListFamily._allTransitiveDependencies,
          collection: collection,
        );

  AdminContentListProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.collection,
  }) : super.internal();

  final String collection;

  @override
  Override overrideWith(
    FutureOr<List<ContentItem>> Function(AdminContentListRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AdminContentListProvider._internal(
        (ref) => create(ref as AdminContentListRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        collection: collection,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<ContentItem>> createElement() {
    return _AdminContentListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AdminContentListProvider && other.collection == collection;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, collection.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AdminContentListRef on AutoDisposeFutureProviderRef<List<ContentItem>> {
  /// The parameter `collection` of this provider.
  String get collection;
}

class _AdminContentListProviderElement
    extends AutoDisposeFutureProviderElement<List<ContentItem>>
    with AdminContentListRef {
  _AdminContentListProviderElement(super.provider);

  @override
  String get collection => (origin as AdminContentListProvider).collection;
}

String _$adminContentItemHash() => r'1d48faa5f07950d46dcc56973ca8c154f595eff5';

/// See also [adminContentItem].
@ProviderFor(adminContentItem)
const adminContentItemProvider = AdminContentItemFamily();

/// See also [adminContentItem].
class AdminContentItemFamily extends Family<AsyncValue<ContentItem?>> {
  /// See also [adminContentItem].
  const AdminContentItemFamily();

  /// See also [adminContentItem].
  AdminContentItemProvider call(
    (String, String) key,
  ) {
    return AdminContentItemProvider(
      key,
    );
  }

  @override
  AdminContentItemProvider getProviderOverride(
    covariant AdminContentItemProvider provider,
  ) {
    return call(
      provider.key,
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
  String? get name => r'adminContentItemProvider';
}

/// See also [adminContentItem].
class AdminContentItemProvider extends AutoDisposeFutureProvider<ContentItem?> {
  /// See also [adminContentItem].
  AdminContentItemProvider(
    (String, String) key,
  ) : this._internal(
          (ref) => adminContentItem(
            ref as AdminContentItemRef,
            key,
          ),
          from: adminContentItemProvider,
          name: r'adminContentItemProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$adminContentItemHash,
          dependencies: AdminContentItemFamily._dependencies,
          allTransitiveDependencies:
              AdminContentItemFamily._allTransitiveDependencies,
          key: key,
        );

  AdminContentItemProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.key,
  }) : super.internal();

  final (String, String) key;

  @override
  Override overrideWith(
    FutureOr<ContentItem?> Function(AdminContentItemRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AdminContentItemProvider._internal(
        (ref) => create(ref as AdminContentItemRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        key: key,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<ContentItem?> createElement() {
    return _AdminContentItemProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AdminContentItemProvider && other.key == key;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, key.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AdminContentItemRef on AutoDisposeFutureProviderRef<ContentItem?> {
  /// The parameter `key` of this provider.
  (String, String) get key;
}

class _AdminContentItemProviderElement
    extends AutoDisposeFutureProviderElement<ContentItem?>
    with AdminContentItemRef {
  _AdminContentItemProviderElement(super.provider);

  @override
  (String, String) get key => (origin as AdminContentItemProvider).key;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
