import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// A single item in the teacher chip row.
class TeacherChipData {
  const TeacherChipData({required this.id, required this.label});
  final String id;
  final String label;
}

/// The `All | <selected teachers> | +` filter row shared by every content
/// list screen (Architecture §5.1, PRD FR-5.7). `null` teacher id means
/// "All". The `+` chip opens a picker to add more teachers to the user's
/// selection — that behaviour is wired by the caller via [onAddTeacher].
class TeacherFilterChipRow extends StatelessWidget {
  const TeacherFilterChipRow({
    required this.teachers,
    required this.selectedTeacherId,
    required this.onSelect,
    required this.onAddTeacher,
    super.key,
  });

  /// The user's currently-selected teachers (from `users/{uid}.selectedTeachers`),
  /// already resolved to display labels.
  final List<TeacherChipData> teachers;

  /// `null` represents "All".
  final String? selectedTeacherId;
  final ValueChanged<String?> onSelect;
  final VoidCallback onAddTeacher;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        children: [
          _Chip(
            label: 'All',
            selected: selectedTeacherId == null,
            onTap: () => onSelect(null),
          ),
          const SizedBox(width: AppSpacing.sm),
          for (final teacher in teachers) ...[
            _Chip(
              label: teacher.label,
              selected: selectedTeacherId == teacher.id,
              onTap: () => onSelect(teacher.id),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          Semantics(
            label: 'Add another teacher',
            button: true,
            child: InkWell(
              onTap: onAddTeacher,
              customBorder: const CircleBorder(),
              child: const CircleAvatar(
                radius: AppSpacing.minTouchTarget / 2,
                child: Icon(Icons.add),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}
