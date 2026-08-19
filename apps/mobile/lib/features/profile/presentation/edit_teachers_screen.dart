import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';

class EditTeachersScreen extends ConsumerStatefulWidget {
  const EditTeachersScreen({super.key});

  @override
  ConsumerState<EditTeachersScreen> createState() => _EditTeachersScreenState();
}

class _EditTeachersScreenState extends ConsumerState<EditTeachersScreen> {
  final Set<String> _selected = {};
  var _seeded = false;
  var _busy = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(currentAppUserProvider).valueOrNull;
    if (user != null && !_seeded) {
      _selected.addAll(user.selectedTeachers);
      _seeded = true;
    }
    final teachers = ref.watch(activeTeachersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n?.profileMyTeachers ?? 'My Teachers'),
      ),
      body: teachers.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const ErrorState(message: 'Could not load teachers.'),
        data: (list) {
          final language = user?.language ?? 'en';
          return Column(
            children: [
              Expanded(
                child: GridView.count(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  crossAxisCount: 2,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                  childAspectRatio: 0.85,
                  children: [
                    for (final teacher in list)
                      ContentCard(
                        thumbUrl: teacher.portraitUrl,
                        title: teacher.name.resolve(language),
                        aspectRatio: 0.9,
                        onTap: () => setState(() {
                          if (!_selected.remove(teacher.id)) {
                            _selected.add(teacher.id);
                          }
                        }),
                        overlay: _selected.contains(teacher.id)
                            ? const Align(
                                alignment: Alignment.topRight,
                                child: Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Icon(
                                    Icons.check_circle,
                                    color: AppColors.primary,
                                  ),
                                ),
                              )
                            : null,
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: PrimaryPillButton(
                  label: l10n?.profileSave ?? 'Save',
                  isLoading: _busy,
                  onPressed: _selected.isEmpty || _busy ? null : _save,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _save() async {
    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    if (uid == null) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(userRepositoryProvider)
          .updateSelectedTeachers(uid, _selected.toList());
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
