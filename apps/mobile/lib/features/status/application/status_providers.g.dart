// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'status_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$statusCompositorHash() => r'80ffcf39d95e631fa47c1f9335bc29fb6a65916c';

/// See also [statusCompositor].
@ProviderFor(statusCompositor)
final statusCompositorProvider = Provider<StatusCompositor>.internal(
  statusCompositor,
  name: r'statusCompositorProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$statusCompositorHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StatusCompositorRef = ProviderRef<StatusCompositor>;
String _$statusExportHash() => r'164249c00e241193f4d0b84f5956680649db0b8f';

/// See also [statusExport].
@ProviderFor(statusExport)
final statusExportProvider = Provider<StatusExport>.internal(
  statusExport,
  name: r'statusExportProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$statusExportHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StatusExportRef = ProviderRef<StatusExport>;
String _$statusAvatarHash() => r'15cf4ee33bdfd2b26193d8fe1dde061154db1a0f';

/// See also [StatusAvatar].
@ProviderFor(StatusAvatar)
final statusAvatarProvider = NotifierProvider<StatusAvatar, File?>.internal(
  StatusAvatar.new,
  name: r'statusAvatarProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$statusAvatarHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$StatusAvatar = Notifier<File?>;
String _$statusDisplayNameHash() => r'd07f769f1b6c690bbf818168e379b3a6f7bb5ab2';

/// See also [StatusDisplayName].
@ProviderFor(StatusDisplayName)
final statusDisplayNameProvider =
    NotifierProvider<StatusDisplayName, String>.internal(
  StatusDisplayName.new,
  name: r'statusDisplayNameProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$statusDisplayNameHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$StatusDisplayName = Notifier<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
