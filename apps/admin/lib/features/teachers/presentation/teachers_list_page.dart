import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/admin_access.dart';
import '../../../app/admin_strings.dart';
import '../../../widgets/admin_page_frame.dart';
import '../application/teachers_providers.dart';

class TeachersListPage extends ConsumerStatefulWidget {
  const TeachersListPage({super.key});

  @override
  ConsumerState<TeachersListPage> createState() => _TeachersListPageState();
}

class _TeachersListPageState extends ConsumerState<TeachersListPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(adminTeachersProvider);
    return AdminPageFrame(
      title: AdminStrings.teachers,
      actions: [
        FilledButton.icon(
          onPressed: () => context.go('${AdminRoutes.teachers}/new'),
          icon: const Icon(Icons.add, size: 18),
          label: const Text(AdminStrings.addNew),
        ),
      ],
      child: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorState(message: e.toString()),
        data: (teachers) {
          final filtered = teachers.where((t) {
            if (_query.isEmpty) return true;
            final q = _query.toLowerCase();
            return t.name.en.toLowerCase().contains(q) ||
                t.name.hi.contains(_query) ||
                t.name.mr.contains(_query) ||
                t.id.toLowerCase().contains(q);
          }).toList();
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 16, 32, 8),
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
                        padding: const EdgeInsets.fromLTRB(32, 8, 32, 32),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final t = filtered[i];
                          return _TeacherRow(
                            teacher: t,
                            onTap: () =>
                                context.go('${AdminRoutes.teachers}/${t.id}'),
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

class _TeacherRow extends StatelessWidget {
  const _TeacherRow({required this.teacher, required this.onTap});

  final Teacher teacher;
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
              CircleAvatar(
                radius: 24,
                backgroundImage: teacher.thumbUrl != null
                    ? NetworkImage(teacher.thumbUrl!)
                    : null,
                child: teacher.thumbUrl == null
                    ? const Icon(Icons.person_outline)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      teacher.name.resolve('en'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      teacher.id,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                teacher.isActive
                    ? AdminStrings.active
                    : AdminStrings.inactive,
                style: TextStyle(
                  color: teacher.isActive
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
