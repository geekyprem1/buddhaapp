import 'package:freezed_annotation/freezed_annotation.dart';

part 'buddhist_place.freezed.dart';
part 'buddhist_place.g.dart';

/// `places/{placeId}` — a Buddhist place/pilgrimage site curated by an admin.
/// Single-language text (no [LocalisedText]) per product decision. Has a
/// thumbnail (grid preview) plus a gallery of uploaded images shown on the
/// detail screen.
@freezed
class BuddhistPlace with _$BuddhistPlace {
  const factory BuddhistPlace({
    required String id,
    required String title,
    @Default('') String description,
    String? thumbUrl,
    @Default(<String>[]) List<String> imageUrls,
    @Default(0) int sortOrder,
    @Default(true) bool isActive,
  }) = _BuddhistPlace;

  factory BuddhistPlace.fromJson(Map<String, dynamic> json) =>
      _$BuddhistPlaceFromJson(json);
}
