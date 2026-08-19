import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/admin_access.dart';
import '../../../app/admin_strings.dart';
import '../../../widgets/admin_page_frame.dart';
import '../application/pages_providers.dart';

class PagesListPage extends ConsumerWidget {
  const PagesListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(adminStaticPagesProvider);
    return AdminPageFrame(
      title: AdminStrings.pages,
      child: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorState(message: e.toString()),
        data: (pages) {
          final bySlug = {for (final page in pages) page.slug: page};
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(32, 16, 32, 32),
            itemCount: StaticPageSlugs.all.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final slug = StaticPageSlugs.all[i];
              final page = bySlug[slug];
              return Material(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => context.go('${AdminRoutes.pages}/$slug'),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.description_outlined),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                StaticPageSlugs.label(slug),
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                page == null
                                    ? AdminStrings.pageNotAuthored
                                    : page.title.resolve('en'),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          page == null
                              ? AdminStrings.pageDraft
                              : AdminStrings.pageSaved,
                          style: TextStyle(
                            color: page == null
                                ? AppColors.textSecondary
                                : AppColors.success,
                          ),
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
