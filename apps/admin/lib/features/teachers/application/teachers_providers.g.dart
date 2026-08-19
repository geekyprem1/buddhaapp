// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teachers_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$adminTeachersHash() => r'573f55bb7862039e5c45d16119d012b15d8edb1f';

/// See also [adminTeachers].
@ProviderFor(adminTeachers)
final adminTeachersProvider = AutoDisposeStreamProvider<List<Teacher>>.internal(
  adminTeachers,
  name: r'adminTeachersProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$adminTeachersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdminTeachersRef = AutoDisposeStreamProviderRef<List<Teacher>>;
String _$adminTeacherHash() => r'c93276ecd75453ca79f52e3d3a494e7d11696b42';

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

/// See also [adminTeacher].
@ProviderFor(adminTeacher)
const adminTeacherProvider = AdminTeacherFamily();

/// See also [adminTeacher].
class AdminTeacherFamily extends Family<AsyncValue<Teacher?>> {
  /// See also [adminTeacher].
  const AdminTeacherFamily();

  /// See also [adminTeacher].
  AdminTeacherProvider call(
    String id,
  ) {
    return AdminTeacherProvider(
      id,
    );
  }

  @override
  AdminTeacherProvider getProviderOverride(
    covariant AdminTeacherProvider provider,
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
  String? get name => r'adminTeacherProvider';
}

/// See also [adminTeacher].
class AdminTeacherProvider extends AutoDisposeFutureProvider<Teacher?> {
  /// See also [adminTeacher].
  AdminTeacherProvider(
    String id,
  ) : this._internal(
          (ref) => adminTeacher(
            ref as AdminTeacherRef,
            id,
          ),
          from: adminTeacherProvider,
          name: r'adminTeacherProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$adminTeacherHash,
          dependencies: AdminTeacherFamily._dependencies,
          allTransitiveDependencies:
              AdminTeacherFamily._allTransitiveDependencies,
          id: id,
        );

  AdminTeacherProvider._internal(
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
    FutureOr<Teacher?> Function(AdminTeacherRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AdminTeacherProvider._internal(
        (ref) => create(ref as AdminTeacherRef),
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
  AutoDisposeFutureProviderElement<Teacher?> createElement() {
    return _AdminTeacherProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AdminTeacherProvider && other.id == id;
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
mixin AdminTeacherRef on AutoDisposeFutureProviderRef<Teacher?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _AdminTeacherProviderElement
    extends AutoDisposeFutureProviderElement<Teacher?> with AdminTeacherRef {
  _AdminTeacherProviderElement(super.provider);

  @override
  String get id => (origin as AdminTeacherProvider).id;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
