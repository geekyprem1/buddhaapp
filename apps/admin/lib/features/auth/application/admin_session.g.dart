// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_session.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$adminRoleHash() => r'db9b878a5a2588c6ad93a148dce65c8abc501b51';

/// Latest ID-token role for the signed-in user, or `null` if they have no
/// admin claim. Force-refreshed so a just-granted claim is visible.
///
/// Copied from [adminRole].
@ProviderFor(adminRole)
final adminRoleProvider = FutureProvider<String?>.internal(
  adminRole,
  name: r'adminRoleProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$adminRoleHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdminRoleRef = FutureProviderRef<String?>;
String _$adminAuthUserHash() => r'98b36af13908a52294529f43eae6387138c929ab';

/// See also [adminAuthUser].
@ProviderFor(adminAuthUser)
final adminAuthUserProvider = AutoDisposeProvider<User?>.internal(
  adminAuthUser,
  name: r'adminAuthUserProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$adminAuthUserHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdminAuthUserRef = AutoDisposeProviderRef<User?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
