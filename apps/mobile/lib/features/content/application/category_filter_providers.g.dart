// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_filter_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$moduleCategoryChipsHash() =>
    r'9ce9c46c05a521de42a23ea2f750fd39446ba0e3';

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

/// Active categories for one content module, resolved to chip data
/// (id + localised label) for the category filter row under the teacher
/// row on every content list screen (PRD FR-7.10, FR-10.6).
///
/// Reads the shared `categories` collection (scoped by `module`, active
/// only), so categories created in the admin panel appear in the app
/// automatically — no app release needed.
///
/// Copied from [moduleCategoryChips].
@ProviderFor(moduleCategoryChips)
const moduleCategoryChipsProvider = ModuleCategoryChipsFamily();

/// Active categories for one content module, resolved to chip data
/// (id + localised label) for the category filter row under the teacher
/// row on every content list screen (PRD FR-7.10, FR-10.6).
///
/// Reads the shared `categories` collection (scoped by `module`, active
/// only), so categories created in the admin panel appear in the app
/// automatically — no app release needed.
///
/// Copied from [moduleCategoryChips].
class ModuleCategoryChipsFamily extends Family<List<TeacherChipData>> {
  /// Active categories for one content module, resolved to chip data
  /// (id + localised label) for the category filter row under the teacher
  /// row on every content list screen (PRD FR-7.10, FR-10.6).
  ///
  /// Reads the shared `categories` collection (scoped by `module`, active
  /// only), so categories created in the admin panel appear in the app
  /// automatically — no app release needed.
  ///
  /// Copied from [moduleCategoryChips].
  const ModuleCategoryChipsFamily();

  /// Active categories for one content module, resolved to chip data
  /// (id + localised label) for the category filter row under the teacher
  /// row on every content list screen (PRD FR-7.10, FR-10.6).
  ///
  /// Reads the shared `categories` collection (scoped by `module`, active
  /// only), so categories created in the admin panel appear in the app
  /// automatically — no app release needed.
  ///
  /// Copied from [moduleCategoryChips].
  ModuleCategoryChipsProvider call(
    String module,
  ) {
    return ModuleCategoryChipsProvider(
      module,
    );
  }

  @override
  ModuleCategoryChipsProvider getProviderOverride(
    covariant ModuleCategoryChipsProvider provider,
  ) {
    return call(
      provider.module,
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
  String? get name => r'moduleCategoryChipsProvider';
}

/// Active categories for one content module, resolved to chip data
/// (id + localised label) for the category filter row under the teacher
/// row on every content list screen (PRD FR-7.10, FR-10.6).
///
/// Reads the shared `categories` collection (scoped by `module`, active
/// only), so categories created in the admin panel appear in the app
/// automatically — no app release needed.
///
/// Copied from [moduleCategoryChips].
class ModuleCategoryChipsProvider
    extends AutoDisposeProvider<List<TeacherChipData>> {
  /// Active categories for one content module, resolved to chip data
  /// (id + localised label) for the category filter row under the teacher
  /// row on every content list screen (PRD FR-7.10, FR-10.6).
  ///
  /// Reads the shared `categories` collection (scoped by `module`, active
  /// only), so categories created in the admin panel appear in the app
  /// automatically — no app release needed.
  ///
  /// Copied from [moduleCategoryChips].
  ModuleCategoryChipsProvider(
    String module,
  ) : this._internal(
          (ref) => moduleCategoryChips(
            ref as ModuleCategoryChipsRef,
            module,
          ),
          from: moduleCategoryChipsProvider,
          name: r'moduleCategoryChipsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$moduleCategoryChipsHash,
          dependencies: ModuleCategoryChipsFamily._dependencies,
          allTransitiveDependencies:
              ModuleCategoryChipsFamily._allTransitiveDependencies,
          module: module,
        );

  ModuleCategoryChipsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.module,
  }) : super.internal();

  final String module;

  @override
  Override overrideWith(
    List<TeacherChipData> Function(ModuleCategoryChipsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ModuleCategoryChipsProvider._internal(
        (ref) => create(ref as ModuleCategoryChipsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        module: module,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<List<TeacherChipData>> createElement() {
    return _ModuleCategoryChipsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ModuleCategoryChipsProvider && other.module == module;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, module.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ModuleCategoryChipsRef on AutoDisposeProviderRef<List<TeacherChipData>> {
  /// The parameter `module` of this provider.
  String get module;
}

class _ModuleCategoryChipsProviderElement
    extends AutoDisposeProviderElement<List<TeacherChipData>>
    with ModuleCategoryChipsRef {
  _ModuleCategoryChipsProviderElement(super.provider);

  @override
  String get module => (origin as ModuleCategoryChipsProvider).module;
}

String _$contentCategoryFilterHash() =>
    r'4e99b23320011ae8cd3e90b45530da9df2dbbc91';

abstract class _$ContentCategoryFilter
    extends BuildlessAutoDisposeNotifier<String?> {
  late final String module;

  String? build(
    String module,
  );
}

/// The currently-selected category in a content screen's filter row.
/// `null` = "All". Scoped per content module so switching screens doesn't
/// leak filter state between them.
///
/// Copied from [ContentCategoryFilter].
@ProviderFor(ContentCategoryFilter)
const contentCategoryFilterProvider = ContentCategoryFilterFamily();

/// The currently-selected category in a content screen's filter row.
/// `null` = "All". Scoped per content module so switching screens doesn't
/// leak filter state between them.
///
/// Copied from [ContentCategoryFilter].
class ContentCategoryFilterFamily extends Family<String?> {
  /// The currently-selected category in a content screen's filter row.
  /// `null` = "All". Scoped per content module so switching screens doesn't
  /// leak filter state between them.
  ///
  /// Copied from [ContentCategoryFilter].
  const ContentCategoryFilterFamily();

  /// The currently-selected category in a content screen's filter row.
  /// `null` = "All". Scoped per content module so switching screens doesn't
  /// leak filter state between them.
  ///
  /// Copied from [ContentCategoryFilter].
  ContentCategoryFilterProvider call(
    String module,
  ) {
    return ContentCategoryFilterProvider(
      module,
    );
  }

  @override
  ContentCategoryFilterProvider getProviderOverride(
    covariant ContentCategoryFilterProvider provider,
  ) {
    return call(
      provider.module,
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
  String? get name => r'contentCategoryFilterProvider';
}

/// The currently-selected category in a content screen's filter row.
/// `null` = "All". Scoped per content module so switching screens doesn't
/// leak filter state between them.
///
/// Copied from [ContentCategoryFilter].
class ContentCategoryFilterProvider
    extends AutoDisposeNotifierProviderImpl<ContentCategoryFilter, String?> {
  /// The currently-selected category in a content screen's filter row.
  /// `null` = "All". Scoped per content module so switching screens doesn't
  /// leak filter state between them.
  ///
  /// Copied from [ContentCategoryFilter].
  ContentCategoryFilterProvider(
    String module,
  ) : this._internal(
          () => ContentCategoryFilter()..module = module,
          from: contentCategoryFilterProvider,
          name: r'contentCategoryFilterProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$contentCategoryFilterHash,
          dependencies: ContentCategoryFilterFamily._dependencies,
          allTransitiveDependencies:
              ContentCategoryFilterFamily._allTransitiveDependencies,
          module: module,
        );

  ContentCategoryFilterProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.module,
  }) : super.internal();

  final String module;

  @override
  String? runNotifierBuild(
    covariant ContentCategoryFilter notifier,
  ) {
    return notifier.build(
      module,
    );
  }

  @override
  Override overrideWith(ContentCategoryFilter Function() create) {
    return ProviderOverride(
      origin: this,
      override: ContentCategoryFilterProvider._internal(
        () => create()..module = module,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        module: module,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<ContentCategoryFilter, String?>
      createElement() {
    return _ContentCategoryFilterProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ContentCategoryFilterProvider && other.module == module;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, module.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ContentCategoryFilterRef on AutoDisposeNotifierProviderRef<String?> {
  /// The parameter `module` of this provider.
  String get module;
}

class _ContentCategoryFilterProviderElement
    extends AutoDisposeNotifierProviderElement<ContentCategoryFilter, String?>
    with ContentCategoryFilterRef {
  _ContentCategoryFilterProviderElement(super.provider);

  @override
  String get module => (origin as ContentCategoryFilterProvider).module;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
