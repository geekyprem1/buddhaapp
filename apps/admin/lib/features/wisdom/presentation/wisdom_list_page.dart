import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/admin_access.dart';
import '../../../app/admin_strings.dart';
import '../../../widgets/admin_page_frame.dart';
import '../../../widgets/responsive_layout.dart';
import '../application/wisdom_providers.dart';

class WisdomListPage extends ConsumerStatefulWidget {
  const WisdomListPage({super.key});

  @override
  ConsumerState<WisdomListPage> createState() => _WisdomListPageState();
}

class _WisdomListPageState extends ConsumerState<WisdomListPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(adminWisdomsProvider);
    return AdminPageFrame(
      title: AdminStrings.wisdom,
      actions: [
        FilledButton.icon(
          onPressed: () => context.go('${AdminRoutes.wisdom}/new'),
          icon: const Icon(Icons.add, size: 18),
          label: const Text(AdminStrings.addNew),
        ),
      ],
      child: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorState(message: e.toString()),
        data: (items) {
          final filtered = items.where((w) {
            if (_query.isEmpty) return true;
            final q = _query.toLowerCase();
            return w.title.en.toLowerCase().contains(q) ||
                w.title.hi.contains(_query) ||
                w.title.mr.contains(_query) ||
                w.id.toLowerCase().contains(q);
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
                          final w = filtered[i];
                          return _WisdomRow(
                            wisdom: w,
                            onTap: () =>
                                context.go('${AdminRoutes.wisdom}/${w.id}'),
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

class _WisdomRow extends StatelessWidget {
  const _WisdomRow({required this.wisdom, required this.onTap});

  final Wisdom wisdom;
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
                  child: wisdom.imageUrl != null
                      ? Image.network(
                          wisdom.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) => const Icon(
                            Icons.broken_image_outlined,
                          ),
                        )
                      : const Icon(Icons.image_outlined),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      wisdom.title.resolve('en'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      wisdom.id,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    if (AdminResponsive.isCompact(context))
                      Text(
                        wisdom.isActive
                            ? AdminStrings.active
                            : AdminStrings.inactive,
                        style: TextStyle(
                          color: wisdom.isActive
                              ? AppColors.success
                              : AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              if (!AdminResponsive.isCompact(context))
                Text(
                  wisdom.isActive ? AdminStrings.active : AdminStrings.inactive,
                  style: TextStyle(
                    color: wisdom.isActive
                        ? AppColors.success
                        : AppColors.textSecondary,
                  ),
                ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
