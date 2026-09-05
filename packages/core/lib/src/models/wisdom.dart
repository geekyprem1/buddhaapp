import 'package:freezed_annotation/freezed_annotation.dart';

import 'localised_text.dart';

part 'wisdom.freezed.dart';
part 'wisdom.g.dart';

/// `wisdoms/{wisdomId}` — one "Today Wisdom" card: a banner image plus a
/// short text shown on its detail page. Admin uploads ~20 rows; the app
/// picks one per day.
@freezed
class Wisdom with _$Wisdom {
  const factory Wisdom({
    required String id,
    required LocalisedText title,
    required LocalisedText body,
    String? imageUrl,
    @Default(0) int sortOrder,
    @Default(true) bool isActive,
  }) = _Wisdom;

  factory Wisdom.fromJson(Map<String, dynamic> json) => _$WisdomFromJson(json);
}
