// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'core_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authServiceHash() => r'21d842d4dceafa3d239c0196a0f2b890d37c0b71';

/// See also [authService].
@ProviderFor(authService)
final authServiceProvider = Provider<AuthService>.internal(
  authService,
  name: r'authServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$authServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthServiceRef = ProviderRef<AuthService>;
String _$userRepositoryHash() => r'6f33c0662d4bd5e514fd4f4f99ff0bcb31cd094d';

/// See also [userRepository].
@ProviderFor(userRepository)
final userRepositoryProvider = Provider<UserRepository>.internal(
  userRepository,
  name: r'userRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserRepositoryRef = ProviderRef<UserRepository>;
String _$teacherRepositoryHash() => r'748e973d6521fcc0f398251605dcb27d0f2d36db';

/// See also [teacherRepository].
@ProviderFor(teacherRepository)
final teacherRepositoryProvider = Provider<TeacherRepository>.internal(
  teacherRepository,
  name: r'teacherRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$teacherRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TeacherRepositoryRef = ProviderRef<TeacherRepository>;
String _$contentRepositoryHash() => r'30861485e0e2f75b5da412d11c67db173881854d';

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

/// One [ContentRepository] instance per collection name, cached for the
/// lifetime of the app (Architecture §11 generic content module).
///
/// Copied from [contentRepository].
@ProviderFor(contentRepository)
const contentRepositoryProvider = ContentRepositoryFamily();

/// One [ContentRepository] instance per collection name, cached for the
/// lifetime of the app (Architecture §11 generic content module).
///
/// Copied from [contentRepository].
class ContentRepositoryFamily extends Family<ContentRepository> {
  /// One [ContentRepository] instance per collection name, cached for the
  /// lifetime of the app (Architecture §11 generic content module).
  ///
  /// Copied from [contentRepository].
  const ContentRepositoryFamily();

  /// One [ContentRepository] instance per collection name, cached for the
  /// lifetime of the app (Architecture §11 generic content module).
  ///
  /// Copied from [contentRepository].
  ContentRepositoryProvider call(
    String collectionName,
  ) {
    return ContentRepositoryProvider(
      collectionName,
    );
  }

  @override
  ContentRepositoryProvider getProviderOverride(
    covariant ContentRepositoryProvider provider,
  ) {
    return call(
      provider.collectionName,
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
  String? get name => r'contentRepositoryProvider';
}

/// One [ContentRepository] instance per collection name, cached for the
/// lifetime of the app (Architecture §11 generic content module).
///
/// Copied from [contentRepository].
class ContentRepositoryProvider extends Provider<ContentRepository> {
  /// One [ContentRepository] instance per collection name, cached for the
  /// lifetime of the app (Architecture §11 generic content module).
  ///
  /// Copied from [contentRepository].
  ContentRepositoryProvider(
    String collectionName,
  ) : this._internal(
          (ref) => contentRepository(
            ref as ContentRepositoryRef,
            collectionName,
          ),
          from: contentRepositoryProvider,
          name: r'contentRepositoryProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$contentRepositoryHash,
          dependencies: ContentRepositoryFamily._dependencies,
          allTransitiveDependencies:
              ContentRepositoryFamily._allTransitiveDependencies,
          collectionName: collectionName,
        );

  ContentRepositoryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.collectionName,
  }) : super.internal();

  final String collectionName;

  @override
  Override overrideWith(
    ContentRepository Function(ContentRepositoryRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ContentRepositoryProvider._internal(
        (ref) => create(ref as ContentRepositoryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        collectionName: collectionName,
      ),
    );
  }

  @override
  ProviderElement<ContentRepository> createElement() {
    return _ContentRepositoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ContentRepositoryProvider &&
        other.collectionName == collectionName;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, collectionName.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ContentRepositoryRef on ProviderRef<ContentRepository> {
  /// The parameter `collectionName` of this provider.
  String get collectionName;
}

class _ContentRepositoryProviderElement
    extends ProviderElement<ContentRepository> with ContentRepositoryRef {
  _ContentRepositoryProviderElement(super.provider);

  @override
  String get collectionName =>
      (origin as ContentRepositoryProvider).collectionName;
}

String _$authStateHash() => r'f65ef85fe894b530eeed3e3daeaa177f0a63e94c';

/// See also [authState].
@ProviderFor(authState)
final authStateProvider = AutoDisposeStreamProvider<User?>.internal(
  authState,
  name: r'authStateProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$authStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthStateRef = AutoDisposeStreamProviderRef<User?>;
String _$currentAppUserHash() => r'218edeb594ca8e9391473a670af0c1a1a7839cd2';

/// The signed-in user's Firestore profile, kept live via a snapshot
/// listener. `null` while signed out or before the document exists.
///
/// Copied from [currentAppUser].
@ProviderFor(currentAppUser)
final currentAppUserProvider = AutoDisposeStreamProvider<AppUser?>.internal(
  currentAppUser,
  name: r'currentAppUserProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentAppUserHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentAppUserRef = AutoDisposeStreamProviderRef<AppUser?>;
String _$activeTeachersHash() => r'526874e4e6a4b60b7819600aa92625cab4c2716c';

/// Active teachers for onboarding / filter chips (FR-5.3).
///
/// Copied from [activeTeachers].
@ProviderFor(activeTeachers)
final activeTeachersProvider =
    AutoDisposeStreamProvider<List<Teacher>>.internal(
  activeTeachers,
  name: r'activeTeachersProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeTeachersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveTeachersRef = AutoDisposeStreamProviderRef<List<Teacher>>;
String _$firestoreHash() => r'864285def6284159b44f9598dcde96347e0c1dce';

/// Direct Firestore instance, exposed for edge cases (e.g. cursor-based
/// pagination controllers that need to hold a raw `DocumentSnapshot`).
///
/// Copied from [firestore].
@ProviderFor(firestore)
final firestoreProvider = Provider<FirebaseFirestore>.internal(
  firestore,
  name: r'firestoreProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$firestoreHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FirestoreRef = ProviderRef<FirebaseFirestore>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
