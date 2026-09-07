import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/admin_access.dart';
import '../../../app/admin_strings.dart';
import '../../../widgets/admin_page_frame.dart';
import '../../../widgets/responsive_layout.dart';
import '../application/video_providers.dart';

class VideoListPage extends ConsumerStatefulWidget {
  const VideoListPage({super.key});

  @override
  ConsumerState<VideoListPage> createState() => _VideoListPageState();
}

class _VideoListPageState extends ConsumerState<VideoListPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(adminVideosProvider);
    return AdminPageFrame(
      title: AdminStrings.videos,
      actions: [
        FilledButton.icon(
          onPressed: () => context.go('${AdminRoutes.videos}/new'),
          icon: const Icon(Icons.add, size: 18),
          label: const Text(AdminStrings.addNew),
        ),
      ],
      child: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorState(message: e.toString()),
        data: (items) {
          final filtered = items.where((v) {
            if (_query.isEmpty) return true;
            final q = _query.toLowerCase();
            return v.title.en.toLowerCase().contains(q) ||
                v.title.hi.contains(_query) ||
                v.title.mr.contains(_query) ||
                v.id.toLowerCase().contains(q);
          }).toList();
          return Column(
            children: [
              Padding(
                padding: AdminResponsive.pagePadding(
                  context,
                  top: 16,
                  bottom: 8,
                ),
                child: TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: AdminStrings.search,
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? const EmptyState(message: AdminStrings.emptyList)
                    : ListView.separated(
                        padding: AdminResponsive.pagePadding(
                          context,
                          top: 8,
                          bottom: 32,
                        ),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final v = filtered[i];
                          return _VideoRow(
                            video: v,
                            onTap: () =>
                                context.go('${AdminRoutes.videos}/${v.id}'),
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

class _VideoRow extends StatelessWidget {
  const _VideoRow({required this.video, required this.onTap});

  final Video video;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 80,
                  height: 48,
                  child: Image.network(
                    video.thumbnailUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) => const Icon(
                      Icons.broken_image_outlined,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.title.resolve('en'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      video.id,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                video.isActive ? AdminStrings.active : AdminStrings.inactive,
                style: TextStyle(
                  color: video.isActive
                      ? AppColors.success
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
