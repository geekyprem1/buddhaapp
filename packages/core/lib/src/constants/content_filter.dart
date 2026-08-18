import 'package:equatable/equatable.dart';

/// The filter key every content list screen queries by.
///
/// `teacherId == null` means "All" (no teacher constraint — still scoped to
/// published content only). `categoryId` is optional secondary filtering
/// (e.g. the wallpaper sub-category chip row).
class ContentFilter extends Equatable {
  const ContentFilter({
    this.teacherId,
    this.categoryId,
    this.seriesId,
  });

  final String? teacherId;
  final String? categoryId;
  final String? seriesId;

  ContentFilter copyWith({
    String? teacherId,
    bool clearTeacher = false,
    String? categoryId,
    bool clearCategory = false,
  }) {
    return ContentFilter(
      teacherId: clearTeacher ? null : (teacherId ?? this.teacherId),
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      seriesId: seriesId,
    );
  }

  @override
  List<Object?> get props => [teacherId, categoryId, seriesId];
}
