import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../application/category_filter_providers.dart';
import '../application/content_list_controller.dart';

/// Reusable scaffold for the four content list screens (wallpaper, ringtone,
/// song, meditation). Owns the shared chrome — app bar, the
/// `All | <categories>` filter row fed by the admin-managed `categories`
/// collection, pagination, and
/// loading/empty/error states — and delegates only the per-item rendering
/// to [itemBuilder]
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
      final categoryId = ref.read(contentCategoryFilterProvider(widget.module));
      ref
          .read(
            contentListControllerProvider(
              widget.collection,
              null,
              categoryId: categoryId,
            ).notifier,
          )
          .loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final categoryId = ref.watch(contentCategoryFilterProvider(widget.module));
    final categoryChips = ref.watch(moduleCategoryChipsProvider(widget.module));
    final asyncContent = ref.watch(
      contentListControllerProvider(
        widget.collection,
        null,
        categoryId: categoryId,
      ),
    );
    final controller = contentListControllerProvider(
      widget.collection,
      null,
      categoryId: categoryId,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [if (widget.helpAction != null) widget.helpAction!],
      ),
      body: Column(
        children: [
          if (categoryChips.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            TeacherFilterChipRow(
              teachers: categoryChips,
              selectedTeacherId: categoryId,
              onSelect: (id) => ref
                  .read(contentCategoryFilterProvider(widget.module).notifier)
                  .select(id),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: asyncContent.when(
              loading: () => _buildLoading(),
              error: (e, _) => ErrorState(
                message: l10n?.errorLoadFailed ?? 'Could not load content.',
                onRetry: () => ref.read(controller.notifier).refresh(),
              ),
              data: (paged) {
                if (paged.items.isEmpty) {
                  return EmptyState(message: widget.emptyMessage);
                }
                return RefreshIndicator(
                  onRefresh: () => ref.read(controller.notifier).refresh(),
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
