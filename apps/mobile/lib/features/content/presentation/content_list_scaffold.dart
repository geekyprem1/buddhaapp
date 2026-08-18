import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/content_list_controller.dart';
import '../application/teacher_filter_providers.dart';

/// Reusable scaffold for the four content list screens (wallpaper, ringtone,
/// song, meditation). Owns the shared chrome — app bar, the
/// `All | <teachers> | ⊕` filter row, pagination, and loading/empty/error
/// states — and delegates only the per-item rendering to [itemBuilder]
/// (Architecture §5.1; DRY per the generic content module principle §11).
class ContentListScaffold extends ConsumerStatefulWidget {
  const ContentListScaffold({
    required this.module,
    required this.collection,
    required this.title,
    required this.itemBuilder,
    this.gridColumns,
    this.emptyMessage = 'Nothing here yet.',
    this.helpAction,
    super.key,
  });

  /// Module key for filter-state scoping (e.g. 'wallpaper').
  final String module;

  /// Firestore collection name (e.g. `FirestoreCollections.wallpapers`).
  final String collection;
  final String title;

  /// Builds one item. Given the item and its index in the flat list.
  final Widget Function(BuildContext context, ContentItem item, int index)
      itemBuilder;

  /// If set, items render in a grid with this many columns; otherwise a
  /// single-column list.
  final int? gridColumns;
  final String emptyMessage;

  /// Optional trailing app-bar action (e.g. the "▶ Help" button on ringtone
  /// and prarthana screens).
  final Widget? helpAction;

  @override
  ConsumerState<ContentListScaffold> createState() =>
      _ContentListScaffoldState();
}

class _ContentListScaffoldState extends ConsumerState<ContentListScaffold> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 400) {
      final teacherId = ref.read(contentTeacherFilterProvider(widget.module));
      ref
          .read(
            contentListControllerProvider(widget.collection, teacherId)
                .notifier,
          )
          .loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final teacherId = ref.watch(contentTeacherFilterProvider(widget.module));
    final chips = ref.watch(selectedTeacherChipsProvider);
    final asyncContent = ref.watch(
      contentListControllerProvider(widget.collection, teacherId),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.title),
        actions: [if (widget.helpAction != null) widget.helpAction!],
      ),
      body: Column(
        children: [
          const SizedBox(height: AppSpacing.sm),
          TeacherFilterChipRow(
            teachers: chips,
            selectedTeacherId: teacherId,
            onSelect: (id) => ref
                .read(contentTeacherFilterProvider(widget.module).notifier)
                .select(id),
            onAddTeacher: () {
              // ⊕ teacher picker sheet — wired in a later task (FR-5.7).
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: asyncContent.when(
              loading: () => _buildLoading(),
              error: (e, _) => ErrorState(
                message: 'Could not load content.',
                onRetry: () => ref
                    .read(
                      contentListControllerProvider(
                        widget.collection,
                        teacherId,
                      ).notifier,
                    )
                    .refresh(),
              ),
              data: (paged) {
                if (paged.items.isEmpty) {
                  return EmptyState(message: widget.emptyMessage);
                }
                return RefreshIndicator(
                  onRefresh: () => ref
                      .read(
                        contentListControllerProvider(
                          widget.collection,
                          teacherId,
                        ).notifier,
                      )
                      .refresh(),
                  child: widget.gridColumns != null
                      ? _buildGrid(paged)
                      : _buildList(paged),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildList(PagedContent paged) {
    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: paged.items.length + (paged.isLoadingMore ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        if (index >= paged.items.length) {
          return const Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return widget.itemBuilder(context, paged.items[index], index);
      },
    );
  }

  Widget _buildGrid(PagedContent paged) {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppSpacing.md),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.gridColumns!,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.7,
      ),
      itemCount: paged.items.length,
      itemBuilder: (context, index) =>
          widget.itemBuilder(context, paged.items[index], index),
    );
  }
}
