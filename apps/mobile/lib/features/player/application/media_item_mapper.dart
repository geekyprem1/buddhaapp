import 'package:audio_service/audio_service.dart';
import 'package:core/core.dart';

/// Maps a Firestore content row to an [audio_service] [MediaItem].
MediaItem mediaItemFromContent(ContentItem item, {String language = 'en'}) {
  final secs = item.audio?.durationSec;
  return MediaItem(
    id: item.id,
    title: item.title.resolve(language),
    artist: (item.artist == null || item.artist!.trim().isEmpty)
        ? 'Anonymous'
        : item.artist!,
    artUri: item.thumbUrl == null || item.thumbUrl!.isEmpty
        ? null
        : Uri.tryParse(item.thumbUrl!),
    duration: secs == null ? null : Duration(seconds: secs),
    extras: <String, dynamic>{
      'url': item.mediaUrl,
      'type': item.type,
    },
  );
}

String? mediaUrlOf(MediaItem item) => item.extras?['url'] as String?;

String? contentTypeOf(MediaItem item) => item.extras?['type'] as String?;

bool isMeditationMedia(MediaItem item) =>
    contentTypeOf(item) == ContentType.meditation;
