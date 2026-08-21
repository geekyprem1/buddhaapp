import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/admin_strings.dart';
import '../../../widgets/admin_page_frame.dart';
import '../../../widgets/confirm_dialog.dart';
import '../../../widgets/responsive_layout.dart';
import '../application/content_providers.dart';
import '../application/content_type_config.dart';

class ContentListPage extends ConsumerStatefulWidget {
  const ContentListPage({required this.config, super.key});

  final ContentTypeConfig config;

  @override
  ConsumerState<ContentListPage> createState() => _ContentListPageState();
}

class _ContentListPageState extends ConsumerState<ContentListPage> {
  String? _status;
  String _query = '';

  ContentTypeConfig get config => widget.config;

  Future<void> _setStatus(ContentItem item, String status) async {
    await ref
        .read(contentRepositoryProvider(config.collection))
        .setStatus(item.id, status);
    ref.invalidate(adminContentListProvider(config.collection));
  }

  Future<void> _archive(ContentItem item) async {
    final ok = await ConfirmDialog.show(
      context,
      title: AdminStrings.confirmArchiveTitle,
      body: AdminStrings.confirmArchiveBody,
      confirmLabel: AdminStrings.archive,
    );
    if (!ok) return;
    await ref
        .read(contentRepositoryProvider(config.collection))
        .softDelete(item.id);
    ref.invalidate(adminContentListProvider(config.collection));
  }

  Future<void> _restore(ContentItem item) async {
    await ref
        .read(contentRepositoryProvider(config.collection))
        .restore(item.id);
    ref.invalidate(adminContentListProvider(config.collection));
  }

  Future<void> _clone(ContentItem item) async {
    await ref.read(contentRepositoryProvider(config.collection)).clone(item);
    ref.invalidate(adminContentListProvider(config.collection));
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text(AdminStrings.cloned)));
    }
  }

  Future<void> _reorder(
    List<ContentItem> rows,
    int oldIndex,
    int newIndex,
  ) async {
    final reordered = [...rows];
    final moved = reordered.removeAt(oldIndex);
    reordered.insert(newIndex, moved);
    await ref
        .read(contentRepositoryProvider(config.collection))
        .reorder(reordered.map((e) => e.id).toList());
    ref.invalidate(adminContentListProvider(config.collection));
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(adminContentListProvider(config.collection));
    return AdminPageFrame(
      title: config.label,
      actions: [
        OutlinedButton.icon(
          onPressed: () => context.go('${config.route}/bulk'),
          icon: const Icon(Icons.cloud_upload_outlined, size: 18),
          label: const Text(AdminStrings.bulkUpload),
        ),
        const SizedBox(width: 8),
        FilledButton.icon(
          onPressed: () => context.go('${config.route}/new'),
          icon: const Icon(Icons.add, size: 18),
          label: const Text(AdminStrings.addNew),
        ),
      ],
      child: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorState(message: e.toString()),
        data: (items) {
          final rows = items.where((item) {
            if (_status != null && item.status != _status) return false;
            if (_query.isEmpty) return true;
            final q = _query.toLowerCase();
            return item.title.resolve('en').toLowerCase().contains(q) ||
                item.id.toLowerCase().contains(q);
          }).toList();
          // Drag-reorder only makes sense over the full, unfiltered list —
          // otherwise "row 2" doesn't map to a stable sortOrder position.
          final reorderable = _status == null && _query.isEmpty;
          return Column(
            children: [
              Padding(
                padding: AdminResponsive.pagePadding(
                  context,
                  top: 16,
                  bottom: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: AdminStrings.search,
                      ),
                      onChanged: (v) => setState(() => _query = v),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final status in [
                          null,
                          ContentStatus.draft,
                          ContentStatus.published,
                          ContentStatus.unpublished,
                          ContentStatus.archived,
                        ])
                          FilterChip(
                            label: Text(status ?? 'All'),
                            selected: _status == status,
                            onSelected: (_) => setState(() => _status = status),
                          ),
                      ],
                    ),
                    if (reorderable && rows.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        AdminStrings.reorderHint,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              Expanded(
                child: rows.isEmpty
                    ? const EmptyState(message: AdminStrings.emptyList)
                    : reorderable
                        ? ReorderableListView.builder(
                            padding: AdminResponsive.pagePadding(
                              context,
                              top: 8,
                              bottom: 32,
                            ),
                            itemCount: rows.length,
                            onReorderItem: (oldIndex, newIndex) =>
                                _reorder(rows, oldIndex, newIndex),
                            itemBuilder: (context, i) {
                              final item = rows[i];
                              return Padding(
                                key: ValueKey(item.id),
                                padding: const EdgeInsets.only(bottom: 8),
                                child: _ContentRow(
                                  item: item,
                                  media: config.media,
                                  onOpen: () =>
                                      context.go('${config.route}/${item.id}'),
                                  onPublish: () =>
                                      _setStatus(item, ContentStatus.published),
                                  onUnpublish: () => _setStatus(
                                    item,
                                    ContentStatus.unpublished,
                                  ),
                                  onArchive: () => _archive(item),
                                  onRestore: () => _restore(item),
                                  onClone: () => _clone(item),
                                ),
                              );
                            },
                          )
                        : ListView.separated(
                            padding: AdminResponsive.pagePadding(
                              context,
                              top: 8,
                              bottom: 32,
                            ),
                            itemCount: rows.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, i) {
                              final item = rows[i];
                              return _ContentRow(
                                item: item,
                                media: config.media,
                                onOpen: () =>
                                    context.go('${config.route}/${item.id}'),
                                onPublish: () =>
                                    _setStatus(item, ContentStatus.published),
                                onUnpublish: () =>
                                    _setStatus(item, ContentStatus.unpublished),
                                onArchive: () => _archive(item),
                                onRestore: () => _restore(item),
                                onClone: () => _clone(item),
                              );
                            },
                          ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ContentRow extends StatelessWidget {
  const _ContentRow({
    required this.item,
    required this.media,
    required this.onOpen,
    required this.onPublish,
    required this.onUnpublish,
    required this.onArchive,
    required this.onRestore,
    required this.onClone,
  });

  final ContentItem item;
  final ContentMediaKind media;
  final VoidCallback onOpen;
  final VoidCallback onPublish;
  final VoidCallback onUnpublish;
  final VoidCallback onArchive;
  final VoidCallback onRestore;
  final VoidCallback onClone;

  @override
  Widget build(BuildContext context) {
    final thumbUrl = item.thumbUrl;
    final previewUrl = media == ContentMediaKind.image
        ? (thumbUrl != null && thumbUrl.isNotEmpty ? thumbUrl : item.mediaUrl)
        : (thumbUrl != null && thumbUrl.isNotEmpty && thumbUrl != item.mediaUrl
            ? thumbUrl
            : null);

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: ListTile(
        onTap: onOpen,
        leading: previewUrl == null || previewUrl.isEmpty
            ? Icon(
                media == ContentMediaKind.audio
                    ? Icons.audiotrack_outlined
                    : Icons.image_outlined,
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(
                  previewUrl,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.broken_image_outlined),
                ),
              ),
        title: Text(
          item.title.resolve('en'),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${item.status} · ${item.id}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'publish':
                onPublish();
              case 'unpublish':
                onUnpublish();
              case 'archive':
                onArchive();
              case 'restore':
                onRestore();
              case 'clone':
                onClone();
            }
          },
          itemBuilder: (context) => [
            if (item.status != ContentStatus.published)
              const PopupMenuItem(
                value: 'publish',
                child: Text(AdminStrings.publish),
              ),
            if (item.status == ContentStatus.published)
              const PopupMenuItem(
                value: 'unpublish',
                child: Text(AdminStrings.unpublish),
              ),
            const PopupMenuItem(
              value: 'clone',
              child: Text(AdminStrings.clone),
            ),
            if (item.status != ContentStatus.archived)
              const PopupMenuItem(
                value: 'archive',
                child: Text(AdminStrings.archive),
              ),
            if (item.status == ContentStatus.archived)
              const PopupMenuItem(
                value: 'restore',
                child: Text(AdminStrings.restore),
              ),
          ],
        ),
      ),
    );
  }
}
