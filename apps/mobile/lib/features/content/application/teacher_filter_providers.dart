import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'teacher_filter_providers.g.dart';

/// The user's selected teachers, resolved to chip data (id + localised
/// label) for the `All | <teachers> | ⊕` filter row shared by every content
/// list screen (Architecture §5.1, FR-5.7).
///
/// Cross-references the user's `selectedTeachers` ids against the live
/// `teachers` collection so labels stay correct and inactive teachers drop
/// out automatically.
@riverpod
List<TeacherChipData> selectedTeacherChips(Ref ref) {
  final user = ref.watch(currentAppUserProvider).valueOrNull;
  final teachers = ref.watch(activeTeachersProvider).valueOrNull ?? const [];
  if (user == null) return const [];

  final byId = {for (final t in teachers) t.id: t};
  final language = user.language;

  return [
    for (final id in user.selectedTeachers)
      if (byId[id] != null)
        TeacherChipData(id: id, label: byId[id]!.name.resolve(language)),
  ];
}

/// The currently-selected teacher in a content screen's filter row.
/// `null` = "All". Scoped per content module so switching screens doesn't
/// leak filter state between them.
@riverpod
class ContentTeacherFilter extends _$ContentTeacherFilter {
  @override
  String? build(String module) => null;

  void select(String? teacherId) => state = teacherId;
}
