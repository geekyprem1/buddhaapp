// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teacher_filter_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$selectedTeacherChipsHash() =>
    r'1e79a82ae0fdf7d4fcb72ccdcd20c22c0165c1c4';

/// The user's selected teachers, resolved to chip data (id + localised
/// label) for the `All | <teachers> | ⊕` filter row shared by every content
/// list screen (Architecture §5.1, FR-5.7).
///
/// Cross-references the user's `selectedTeachers` ids against the live
/// `teachers` collection so labels stay correct and inactive teachers drop
/// out automatically.
///
/// Copied from [selectedTeacherChips].
@ProviderFor(selectedTeacherChips)
final selectedTeacherChipsProvider =
    AutoDisposeProvider<List<TeacherChipData>>.internal(
  selectedTeacherChips,
  name: r'selectedTeacherChipsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedTeacherChipsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SelectedTeacherChipsRef = AutoDisposeProviderRef<List<TeacherChipData>>;
String _$contentTeacherFilterHash() =>
    r'ec38f0f9d7ac0b257a46282daa3fcd8388f1ebb8';

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

abstract class _$ContentTeacherFilter
    extends BuildlessAutoDisposeNotifier<String?> {
  late final String module;

  String? build(
    String module,
  );
}

/// The currently-selected teacher in a content screen's filter row.
/// `null` = "All". Scoped per content module so switching screens doesn't
/// leak filter state between them.
///
/// Copied from [ContentTeacherFilter].
@ProviderFor(ContentTeacherFilter)
const contentTeacherFilterProvider = ContentTeacherFilterFamily();

/// The currently-selected teacher in a content screen's filter row.
/// `null` = "All". Scoped per content module so switching screens doesn't
/// leak filter state between them.
///
/// Copied from [ContentTeacherFilter].
class ContentTeacherFilterFamily extends Family<String?> {
  /// The currently-selected teacher in a content screen's filter row.
  /// `null` = "All". Scoped per content module so switching screens doesn't
  /// leak filter state between them.
  ///
  /// Copied from [ContentTeacherFilter].
  const ContentTeacherFilterFamily();

  /// The currently-selected teacher in a content screen's filter row.
  /// `null` = "All". Scoped per content module so switching screens doesn't
  /// leak filter state between them.
  ///
  /// Copied from [ContentTeacherFilter].
  ContentTeacherFilterProvider call(
    String module,
  ) {
    return ContentTeacherFilterProvider(
      module,
    );
  }

  @override
  ContentTeacherFilterProvider getProviderOverride(
    covariant ContentTeacherFilterProvider provider,
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
  String? get name => r'contentTeacherFilterProvider';
}

/// The currently-selected teacher in a content screen's filter row.
/// `null` = "All". Scoped per content module so switching screens doesn't
/// leak filter state between them.
///
/// Copied from [ContentTeacherFilter].
class ContentTeacherFilterProvider
    extends AutoDisposeNotifierProviderImpl<ContentTeacherFilter, String?> {
  /// The currently-selected teacher in a content screen's filter row.
  /// `null` = "All". Scoped per content module so switching screens doesn't
  /// leak filter state between them.
  ///
  /// Copied from [ContentTeacherFilter].
  ContentTeacherFilterProvider(
    String module,
  ) : this._internal(
          () => ContentTeacherFilter()..module = module,
          from: contentTeacherFilterProvider,
          name: r'contentTeacherFilterProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$contentTeacherFilterHash,
          dependencies: ContentTeacherFilterFamily._dependencies,
          allTransitiveDependencies:
              ContentTeacherFilterFamily._allTransitiveDependencies,
          module: module,
        );

  ContentTeacherFilterProvider._internal(
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
    covariant ContentTeacherFilter notifier,
  ) {
    return notifier.build(
      module,
    );
  }

  @override
  Override overrideWith(ContentTeacherFilter Function() create) {
    return ProviderOverride(
      origin: this,
      override: ContentTeacherFilterProvider._internal(
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
  AutoDisposeNotifierProviderElement<ContentTeacherFilter, String?>
      createElement() {
    return _ContentTeacherFilterProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ContentTeacherFilterProvider && other.module == module;
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
mixin ContentTeacherFilterRef on AutoDisposeNotifierProviderRef<String?> {
  /// The parameter `module` of this provider.
  String get module;
}

class _ContentTeacherFilterProviderElement
    extends AutoDisposeNotifierProviderElement<ContentTeacherFilter, String?>
    with ContentTeacherFilterRef {
  _ContentTeacherFilterProviderElement(super.provider);

  @override
  String get module => (origin as ContentTeacherFilterProvider).module;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
