import 'package:freezed_annotation/freezed_annotation.dart';

import 'localised_text.dart';

part 'category.freezed.dart';
part 'category.g.dart';

/// `categories/{categoryId}` — scoped to one module
/// (wallpaper | ringtone | song | meditation | status | prarthana).
@freezed
class Category with _$Category {
  const factory Category({
    required String id,
    required String module,
    required LocalisedText name,
    @Default(0) int sortOrder,
    @Default(true) bool isActive,
  }) = _Category;

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);
}
