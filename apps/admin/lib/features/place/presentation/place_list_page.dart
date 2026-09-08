import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/admin_access.dart';
import '../../../app/admin_strings.dart';
import '../../../widgets/admin_page_frame.dart';
import '../../../widgets/responsive_layout.dart';
import '../application/place_providers.dart';

class PlaceListPage extends ConsumerStatefulWidget {
  const PlaceListPage({super.key});

  @override
  ConsumerState<PlaceListPage> createState() => _PlaceListPageState();
}

class _PlaceListPageState extends ConsumerState<PlaceListPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(adminPlacesProvider);
    return AdminPageFrame(
      title: AdminStrings.places,
      actions: [
        FilledButton.icon(
          onPressed: () => context.go('${AdminRoutes.places}/new'),
          icon: const Icon(Icons.add, size: 18),
          label: const Text(AdminStrings.addNew),
        ),
      ],
      child: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorState(message: e.toString()),
        data: (items) {
          final filtered = items.where((p) {
            if (_query.isEmpty) return true;
            final q = _query.toLowerCase();
            return p.title.toLowerCase().contains(q) ||
                p.id.toLowerCase().contains(q);
          }).toList();
          return Column(
            children: [
              Padding(
                padding: AdminResponsive.pagePadding(context, top: 16, bottom: 8),
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
                          final p = filtered[i];
                          return _PlaceRow(
                            place: p,
                            onTap: () =>
                                context.go('${AdminRoutes.places}/${p.id}'),
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

class _PlaceRow extends StatelessWidget {
  const _PlaceRow({required this.place, required this.onTap});

  final BuddhistPlace place;
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
                  width: 64,
                  height: 48,
                  child: place.thumbUrl != null
                      ? Image.network(
                          place.thumbUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) =>
                              const Icon(Icons.broken_image_outlined),
                        )
                      : const Icon(Icons.place_outlined),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '${place.imageUrls.length} images · ${place.id}',
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
                place.isActive ? AdminStrings.active : AdminStrings.inactive,
                style: TextStyle(
                  color: place.isActive
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
