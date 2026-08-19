// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$adminNotificationCampaignsHash() =>
    r'c1a2b3c4d5e6f708192a3b4c5d6e7f8091a2b3c4';

/// See also [adminNotificationCampaigns].
@ProviderFor(adminNotificationCampaigns)
final adminNotificationCampaignsProvider =
    AutoDisposeStreamProvider<List<NotificationCampaign>>.internal(
  adminNotificationCampaigns,
  name: r'adminNotificationCampaignsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$adminNotificationCampaignsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdminNotificationCampaignsRef
    = AutoDisposeStreamProviderRef<List<NotificationCampaign>>;
String _$adminNotificationCampaignHash() =>
    r'd2b3c4d5e6f708192a3b4c5d6e7f8091a2b3c4d5';

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

/// See also [adminNotificationCampaign].
@ProviderFor(adminNotificationCampaign)
const adminNotificationCampaignProvider = AdminNotificationCampaignFamily();

/// See also [adminNotificationCampaign].
class AdminNotificationCampaignFamily
    extends Family<AsyncValue<NotificationCampaign?>> {
  /// See also [adminNotificationCampaign].
  const AdminNotificationCampaignFamily();

  /// See also [adminNotificationCampaign].
  AdminNotificationCampaignProvider call(
    String id,
  ) {
    return AdminNotificationCampaignProvider(
      id,
    );
  }

  @override
  AdminNotificationCampaignProvider getProviderOverride(
    covariant AdminNotificationCampaignProvider provider,
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
  String? get name => r'adminNotificationCampaignProvider';
}

/// See also [adminNotificationCampaign].
class AdminNotificationCampaignProvider
    extends AutoDisposeFutureProvider<NotificationCampaign?> {
  /// See also [adminNotificationCampaign].
  AdminNotificationCampaignProvider(
    String id,
  ) : this._internal(
          (ref) => adminNotificationCampaign(
            ref as AdminNotificationCampaignRef,
            id,
          ),
          from: adminNotificationCampaignProvider,
          name: r'adminNotificationCampaignProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$adminNotificationCampaignHash,
          dependencies: AdminNotificationCampaignFamily._dependencies,
          allTransitiveDependencies:
              AdminNotificationCampaignFamily._allTransitiveDependencies,
          id: id,
        );

  AdminNotificationCampaignProvider._internal(
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
    FutureOr<NotificationCampaign?> Function(
      AdminNotificationCampaignRef provider,
    ) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AdminNotificationCampaignProvider._internal(
        (ref) => create(ref as AdminNotificationCampaignRef),
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
  AutoDisposeFutureProviderElement<NotificationCampaign?> createElement() {
    return _AdminNotificationCampaignProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AdminNotificationCampaignProvider && other.id == id;
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
mixin AdminNotificationCampaignRef
    on AutoDisposeFutureProviderRef<NotificationCampaign?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _AdminNotificationCampaignProviderElement
    extends AutoDisposeFutureProviderElement<NotificationCampaign?>
    with AdminNotificationCampaignRef {
  _AdminNotificationCampaignProviderElement(super.provider);

  @override
  String get id => (origin as AdminNotificationCampaignProvider).id;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
