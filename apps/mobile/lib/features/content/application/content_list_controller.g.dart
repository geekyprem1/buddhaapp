// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$contentListControllerHash() =>
    r'449dd38d9e7144c8bd3280ed2f14c61b4b1b7ec7';

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

abstract class _$ContentListController
    extends BuildlessAutoDisposeAsyncNotifier<PagedContent> {
  late final String collection;
  late final String? teacherId;

  FutureOr<PagedContent> build(
    String collection,
    String? teacherId,
  );
}

/// Generic paginated list controller, one instance per
/// (collection, teacherId) pair (FR-6.6). `teacherId == null` means "All".
///
/// `build()` loads the first page as an `AsyncValue`; [loadMore] appends
/// subsequent pages using the cursor from the previous query. The same
/// controller backs every content list screen (wallpaper/ringtone/song/
/// meditation) — they differ only in how each item is rendered.
///
/// Copied from [ContentListController].
@ProviderFor(ContentListController)
const contentListControllerProvider = ContentListControllerFamily();

/// Generic paginated list controller, one instance per
/// (collection, teacherId) pair (FR-6.6). `teacherId == null` means "All".
///
/// `build()` loads the first page as an `AsyncValue`; [loadMore] appends
/// subsequent pages using the cursor from the previous query. The same
/// controller backs every content list screen (wallpaper/ringtone/song/
/// meditation) — they differ only in how each item is rendered.
///
/// Copied from [ContentListController].
class ContentListControllerFamily extends Family<AsyncValue<PagedContent>> {
  /// Generic paginated list controller, one instance per
  /// (collection, teacherId) pair (FR-6.6). `teacherId == null` means "All".
  ///
  /// `build()` loads the first page as an `AsyncValue`; [loadMore] appends
  /// subsequent pages using the cursor from the previous query. The same
  /// controller backs every content list screen (wallpaper/ringtone/song/
  /// meditation) — they differ only in how each item is rendered.
  ///
  /// Copied from [ContentListController].
  const ContentListControllerFamily();

  /// Generic paginated list controller, one instance per
  /// (collection, teacherId) pair (FR-6.6). `teacherId == null` means "All".
  ///
  /// `build()` loads the first page as an `AsyncValue`; [loadMore] appends
  /// subsequent pages using the cursor from the previous query. The same
  /// controller backs every content list screen (wallpaper/ringtone/song/
  /// meditation) — they differ only in how each item is rendered.
  ///
  /// Copied from [ContentListController].
  ContentListControllerProvider call(
    String collection,
    String? teacherId,
  ) {
    return ContentListControllerProvider(
      collection,
      teacherId,
    );
  }

  @override
  ContentListControllerProvider getProviderOverride(
    covariant ContentListControllerProvider provider,
  ) {
    return call(
      provider.collection,
      provider.teacherId,
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
  String? get name => r'contentListControllerProvider';
}

/// Generic paginated list controller, one instance per
/// (collection, teacherId) pair (FR-6.6). `teacherId == null` means "All".
///
/// `build()` loads the first page as an `AsyncValue`; [loadMore] appends
/// subsequent pages using the cursor from the previous query. The same
/// controller backs every content list screen (wallpaper/ringtone/song/
/// meditation) — they differ only in how each item is rendered.
///
/// Copied from [ContentListController].
class ContentListControllerProvider
    extends AutoDisposeAsyncNotifierProviderImpl<ContentListController,
        PagedContent> {
  /// Generic paginated list controller, one instance per
  /// (collection, teacherId) pair (FR-6.6). `teacherId == null` means "All".
  ///
  /// `build()` loads the first page as an `AsyncValue`; [loadMore] appends
  /// subsequent pages using the cursor from the previous query. The same
  /// controller backs every content list screen (wallpaper/ringtone/song/
  /// meditation) — they differ only in how each item is rendered.
  ///
  /// Copied from [ContentListController].
  ContentListControllerProvider(
    String collection,
    String? teacherId,
  ) : this._internal(
          () => ContentListController()
            ..collection = collection
            ..teacherId = teacherId,
          from: contentListControllerProvider,
          name: r'contentListControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$contentListControllerHash,
          dependencies: ContentListControllerFamily._dependencies,
          allTransitiveDependencies:
              ContentListControllerFamily._allTransitiveDependencies,
          collection: collection,
          teacherId: teacherId,
        );

  ContentListControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.collection,
    required this.teacherId,
  }) : super.internal();

  final String collection;
  final String? teacherId;

  @override
  FutureOr<PagedContent> runNotifierBuild(
    covariant ContentListController notifier,
  ) {
    return notifier.build(
      collection,
      teacherId,
    );
  }

  @override
  Override overrideWith(ContentListController Function() create) {
    return ProviderOverride(
      origin: this,
      override: ContentListControllerProvider._internal(
        () => create()
          ..collection = collection
          ..teacherId = teacherId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        collection: collection,
        teacherId: teacherId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<ContentListController, PagedContent>
      createElement() {
    return _ContentListControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ContentListControllerProvider &&
        other.collection == collection &&
        other.teacherId == teacherId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, collection.hashCode);
    hash = _SystemHash.combine(hash, teacherId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ContentListControllerRef
    on AutoDisposeAsyncNotifierProviderRef<PagedContent> {
  /// The parameter `collection` of this provider.
  String get collection;

  /// The parameter `teacherId` of this provider.
  String? get teacherId;
}

class _ContentListControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<ContentListController,
        PagedContent> with ContentListControllerRef {
  _ContentListControllerProviderElement(super.provider);

  @override
  String get collection => (origin as ContentListControllerProvider).collection;
  @override
  String? get teacherId => (origin as ContentListControllerProvider).teacherId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
