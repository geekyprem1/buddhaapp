import 'package:freezed_annotation/freezed_annotation.dart';

part 'localised_text.freezed.dart';
part 'localised_text.g.dart';

/// A string stored per supported language, e.g. a content title.
///
/// Resolution order (see `LocalisedTextX.resolve`): requested language ->
/// English -> first non-empty value. This is how a partially-translated
/// admin entry still renders instead of showing a blank string.
@freezed
class LocalisedText with _$LocalisedText {
  const factory LocalisedText({
    @Default('') String en,
    @Default('') String hi,
    @Default('') String mr,
  }) = _LocalisedText;

  factory LocalisedText.fromJson(Map<String, dynamic> json) =>
      _$LocalisedTextFromJson(json);
}

extension LocalisedTextX on LocalisedText {
  /// Resolve the best available string for [languageCode].
  String resolve(String languageCode) {
    final byCode = switch (languageCode) {
      'hi' => hi,
      'mr' => mr,
      _ => en,
    };
    if (byCode.trim().isNotEmpty) return byCode;
    if (en.trim().isNotEmpty) return en;
    if (hi.trim().isNotEmpty) return hi;
    if (mr.trim().isNotEmpty) return mr;
    return '';
  }

  bool get isEmpty => en.isEmpty && hi.isEmpty && mr.isEmpty;
}
