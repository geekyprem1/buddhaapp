import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'content_list_controller.g.dart';

/// Immutable state for a paginated content list (Architecture §5.1, §10).
class PagedContent {
  const PagedContent({
    required this.items,
    required this.hasMore,
    this.lastDoc,
    this.isLoadingMore = false,
  });

  final List<ContentItem> items;
  final bool hasMore;
  final DocumentSnapshot<Map<String, dynamic>>? lastDoc;
  final bool isLoadingMore;

  PagedContent copyWith({
    List<ContentItem>? items,
    bool? hasMore,
    DocumentSnapshot<Map<String, dynamic>>? lastDoc,
    bool? isLoadingMore,
  }) {
    return PagedContent(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      lastDoc: lastDoc ?? this.lastDoc,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

/// Generic paginated list controller, one instance per
/// (collection, teacherId) pair (FR-6.6). `teacherId == null` means "All".
///
/// `build()` loads the first page as an `AsyncValue`; [loadMore] appends
/// subsequent pages using the cursor from the previous query. The same
/// controller backs every content list screen (wallpaper/ringtone/song/
/// meditation) — they differ only in how each item is rendered.
@riverpod
class ContentListController extends _$ContentListController {
  static const _pageSize = AppConstants.defaultPageSize;

  ContentRepository get _repo =>
      ref.read(contentRepositoryProvider(collection));

  @override
  Future<PagedContent> build(String collection, String? teacherId) async {
    return _fetchPage();
  }

  Future<PagedContent> _fetchPage({
    DocumentSnapshot<Map<String, dynamic>>? startAfter,
  }) async {
    final snap = await _repo.fetchPublishedPageRaw(
      teacherId: teacherId,
      pageSize: _pageSize,
      startAfter: startAfter,
    );
    final items = snap.docs
        .map((d) => ContentItem.fromJson({...d.data(), 'id': d.id}))
        .toList();
    return PagedContent(
      items: items,
      hasMore: snap.docs.length == _pageSize,
      lastDoc: snap.docs.isNotEmpty ? snap.docs.last : startAfter,
    );
  }

  /// Fetches the next page and appends it. No-op while a fetch is in
  /// progress, at the end of the list, or before the first page resolves.
  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null ||
        !current.hasMore ||
        current.isLoadingMore ||
        current.lastDoc == null) {
      return;
    }

    state = AsyncData(current.copyWith(isLoadingMore: true));
    try {
      final next = await _fetchPage(startAfter: current.lastDoc);
      state = AsyncData(
        current.copyWith(
          items: [...current.items, ...next.items],
          hasMore: next.hasMore,
          lastDoc: next.lastDoc,
          isLoadingMore: false,
        ),
      );
    } catch (_) {
      // Keep the already-loaded items; just stop the spinner. A transient
      // load-more failure shouldn't blow away the whole list.
      state = AsyncData(current.copyWith(isLoadingMore: false));
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchPage);
  }
}
