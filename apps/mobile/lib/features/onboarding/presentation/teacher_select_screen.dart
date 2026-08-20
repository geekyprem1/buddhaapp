import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../application/onboarding_controller.dart';

/// Teacher Selection (PRD FR-5.1–5.6): search box, 2-column grid,
/// multi-select, minimum 1 required to continue.
class TeacherSelectScreen extends ConsumerStatefulWidget {
  const TeacherSelectScreen({super.key});

  @override
  ConsumerState<TeacherSelectScreen> createState() =>
      _TeacherSelectScreenState();
}

class _TeacherSelectScreenState extends ConsumerState<TeacherSelectScreen> {
  final _searchController = TextEditingController();
  final Set<String> _selectedIds = {};
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (_selectedIds.isEmpty) return;
    await ref
        .read(onboardingControllerProvider.notifier)
        .submitTeachers(_selectedIds.toList());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final teachersValue = ref.watch(activeTeachersProvider);
    final onboardingState = ref.watch(onboardingControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n?.teacherScreenTitle ?? 'Select Your Teacher',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text(
                l10n?.teacherScreenSubtitle ?? 'अपने गुरु चुनें',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText:
                      l10n?.teacherSearchHint ??
                      'Search for a Teacher (e.g. Buddha)...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                onChanged: (value) =>
                    setState(() => _query = value.trim().toLowerCase()),
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: teachersValue.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, st) => ErrorState(
                    message: 'Could not load teachers.',
                    onRetry: () => ref.invalidate(activeTeachersProvider),
                  ),
                  data: (teachers) {
                    final filtered = _query.isEmpty
                        ? teachers
                        : teachers
                              .where(
                                (t) => t.name
                                    .resolve('en')
                                    .toLowerCase()
                                    .contains(_query),
                              )
                              .toList();
                    if (filtered.isEmpty) {
                      return const EmptyState(
                        message: 'No teachers found.',
                        icon: Icons.person_search_outlined,
                      );
                    }
                    return GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: AppSpacing.md,
                      mainAxisSpacing: AppSpacing.md,
                      childAspectRatio: 0.78,
                      children: [
                        for (final teacher in filtered)
                          _TeacherCard(
                            name: teacher.name.resolve('en'),
                            portraitUrl: teacher.portraitUrl,
                            selected: _selectedIds.contains(teacher.id),
                            onTap: () => setState(() {
                              if (!_selectedIds.remove(teacher.id)) {
                                _selectedIds.add(teacher.id);
                              }
                            }),
                          ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n?.teacherHelperText ??
                    'You can select multiple Teachers to personalise your experience',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              PrimaryPillButton(
                label: l10n?.continueButton ?? 'Continue',
                isLoading: onboardingState.isLoading,
                onPressed: _selectedIds.isEmpty ? null : _continue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TeacherCard extends StatelessWidget {
  const _TeacherCard({
    required this.name,
    required this.portraitUrl,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final String? portraitUrl;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ContentCard(
      thumbUrl: portraitUrl,
      title: name,
      aspectRatio: 0.9,
      onTap: onTap,
      overlay: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.sm,
                horizontal: AppSpacing.sm,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black54],
                ),
              ),
              child: Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          if (selected)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(4),
                child: const Icon(Icons.check, size: 16, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
