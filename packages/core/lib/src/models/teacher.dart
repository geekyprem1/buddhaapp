import 'package:freezed_annotation/freezed_annotation.dart';

import 'localised_text.dart';

part 'teacher.freezed.dart';
part 'teacher.g.dart';

/// `teachers/{teacherId}` — see Architecture §6.2 and PRD FR-5.x.
@freezed
class Teacher with _$Teacher {
  const factory Teacher({
    required String id,
    required LocalisedText name,
    String? portraitUrl,
    String? thumbUrl,
    LocalisedText? bio,
    String? signatureUrl,

    /// Prefix used for Supporter ID Card unique ids, e.g. `BUD`. Phase 2.
    String? idCardPrefix,
    @Default(0) int sortOrder,
    @Default(true) bool isActive,
  }) = _Teacher;

  factory Teacher.fromJson(Map<String, dynamic> json) =>
      _$TeacherFromJson(json);
}
