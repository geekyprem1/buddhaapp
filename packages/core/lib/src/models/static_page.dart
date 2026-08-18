import 'package:freezed_annotation/freezed_annotation.dart';

import '../utils/timestamp_converter.dart';
import 'localised_text.dart';

part 'static_page.freezed.dart';
part 'static_page.g.dart';

/// `staticPages/{slug}` — About / Privacy / Terms / Contact / Help,
/// rich text per language (PRD FR-14.4, AR-7.2).
@freezed
class StaticPage with _$StaticPage {
  const factory StaticPage({
    required String slug,
    required LocalisedText title,

    /// Rich text (HTML or Markdown — decided at implementation time in
    /// the editor task) per language.
    required LocalisedText body,
    @TimestampConverter() DateTime? updatedAt,
  }) = _StaticPage;

  factory StaticPage.fromJson(Map<String, dynamic> json) =>
      _$StaticPageFromJson(json);
}
