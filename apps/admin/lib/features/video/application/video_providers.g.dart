// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$adminVideosHash() => r'baf02f7a0539defcd2e8cd6db4bb7fc915971823';

/// See also [adminVideos].
@ProviderFor(adminVideos)
final adminVideosProvider = AutoDisposeStreamProvider<List<Video>>.internal(
  adminVideos,
  name: r'adminVideosProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$adminVideosHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdminVideosRef = AutoDisposeStreamProviderRef<List<Video>>;
String _$adminVideoHash() => r'7e021f85f9816f052086b70ad8fadf781ecb64a7';

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

/// See also [adminVideo].
@ProviderFor(adminVideo)
const adminVideoProvider = AdminVideoFamily();

/// See also [adminVideo].
class AdminVideoFamily extends Family<AsyncValue<Video?>> {
  /// See also [adminVideo].
  const AdminVideoFamily();

  /// See also [adminVideo].
  AdminVideoProvider call(
    String id,
  ) {
    return AdminVideoProvider(
      id,
    );
  }

  @override
  AdminVideoProvider getProviderOverride(
    covariant AdminVideoProvider provider,
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
  String? get name => r'adminVideoProvider';
}

/// See also [adminVideo].
class AdminVideoProvider extends AutoDisposeFutureProvider<Video?> {
  /// See also [adminVideo].
  AdminVideoProvider(
    String id,
  ) : this._internal(
          (ref) => adminVideo(
            ref as AdminVideoRef,
            id,
          ),
          from: adminVideoProvider,
          name: r'adminVideoProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$adminVideoHash,
          dependencies: AdminVideoFamily._dependencies,
          allTransitiveDependencies:
              AdminVideoFamily._allTransitiveDependencies,
          id: id,
        );

  AdminVideoProvider._internal(
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
    FutureOr<Video?> Function(AdminVideoRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AdminVideoProvider._internal(
        (ref) => create(ref as AdminVideoRef),
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
  AutoDisposeFutureProviderElement<Video?> createElement() {
    return _AdminVideoProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AdminVideoProvider && other.id == id;
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
mixin AdminVideoRef on AutoDisposeFutureProviderRef<Video?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _AdminVideoProviderElement
    extends AutoDisposeFutureProviderElement<Video?> with AdminVideoRef {
  _AdminVideoProviderElement(super.provider);

  @override
  String get id => (origin as AdminVideoProvider).id;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
