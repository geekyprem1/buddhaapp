import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/admin_access.dart';
import '../../../app/admin_strings.dart';
import '../../../widgets/admin_page_frame.dart';
import '../application/categories_providers.dart';

class CategoriesListPage extends ConsumerStatefulWidget {
  const CategoriesListPage({super.key});

  @override
  ConsumerState<CategoriesListPage> createState() =>
      _CategoriesListPageState();
}

class _CategoriesListPageState extends ConsumerState<CategoriesListPage> {
  String? _module;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(adminCategoriesProvider);
    return AdminPageFrame(
      title: AdminStrings.categories,
      actions: [
        FilledButton.icon(
          onPressed: () => context.go('${AdminRoutes.categories}/new'),
          icon: const Icon(Icons.add, size: 18),
          label: const Text(AdminStrings.addNew),
        ),
      ],
      child: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorState(message: e.toString()),
        data: (all) {
          final modules = all.map((c) => c.module).toSet().toList()..sort();
          final rows = _module == null
              ? all
              : all.where((c) => c.module == _module).toList();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 16, 32, 8),
                child: Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: _module == null,
                      onSelected: (_) => setState(() => _module = null),
                    ),
                    for (final m in modules)
                      FilterChip(
                        label: Text(m),
                        selected: _module == m,
                        onSelected: (_) => setState(() => _module = m),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: rows.isEmpty
                    ? const EmptyState(message: AdminStrings.emptyList)
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(32, 8, 32, 32),
                        itemCount: rows.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final c = rows[i];
                          return Material(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            child: ListTile(
                              title: Text(c.name.resolve('en')),
                              subtitle: Text('${c.module} · ${c.id}'),
                              trailing: Text(
                                c.isActive
                                    ? AdminStrings.active
                                    : AdminStrings.inactive,
                              ),
                              onTap: () => context.go(
                                '${AdminRoutes.categories}/${c.id}',
                              ),
                            ),
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
