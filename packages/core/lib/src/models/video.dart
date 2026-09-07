import 'package:freezed_annotation/freezed_annotation.dart';

import '../utils/youtube_utils.dart';
import 'localised_text.dart';

part 'video.freezed.dart';
part 'video.g.dart';

/// `videos/{videoId}` — one YouTube video curated by an admin. The admin
/// pastes a YouTube URL; [videoId] is the parsed 11-char id, and the app
/// derives the thumbnail and play link from it (no media is stored in
/// Firebase Storage).
@freezed
class Video with _$Video {
  const factory Video({
    required String id,
    required LocalisedText title,
    required String youtubeUrl,
    required String videoId,
    @Default(0) int sortOrder,
    @Default(true) bool isActive,
  }) = _Video;

  factory Video.fromJson(Map<String, dynamic> json) => _$VideoFromJson(json);
}

extension VideoX on Video {
  /// YouTube thumbnail for this video's [videoId].
  String get thumbnailUrl => youTubeThumbnail(videoId);

  /// Canonical watch URL to open in the YouTube app / browser.
  String get watchUrl => youTubeWatchUrl(videoId);
}
