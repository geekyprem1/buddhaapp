import 'package:freezed_annotation/freezed_annotation.dart';

import '../utils/timestamp_converter.dart';
import 'content_counters.dart';
import 'content_type_metas.dart';
import 'localised_text.dart';

part 'content_item.freezed.dart';
part 'content_item.g.dart';

/// One shape for all six content types (wallpaper, ringtone, song,
/// meditation, status, prarthana) — see Architecture §6.2 design notes.
///
/// Only the sub-object matching [type] is expected to be non-null:
/// `wallpaper` for `ContentType.wallpaper`, `audio` for ringtone/song/
/// meditation/prarthana, `status` for `ContentType.status`.
@freezed
class ContentItem with _$ContentItem {
  const factory ContentItem({
    required String id,

    /// wallpaper | ringtone | song | meditation | status | prarthana
    required String type,
    @Default(<String>[]) List<String> teacherIds,
    String? categoryId,
    required LocalisedText title,

    /// Artist / narrator display name. Defaults to "Anonymous" in the UI
    /// layer, not stored here, so admin can distinguish "unset" from
    /// "explicitly anonymous".
    String? artist,
    String? mediaUrl,
    String? thumbUrl,
    String? storagePath,

    /// `null` = language-agnostic (images). Set for audio items.
    String? language,

    /// draft | published | unpublished | archived
    @Default('draft') String status,
    @Default(0) int sortOrder,
    @Default(false) bool isFeatured,
    @Default(false) bool isPremium,
    @Default(<String>[]) List<String> tags,
    @Default(ContentCounters()) ContentCounters counters,

    /// Licence provenance — mandatory per PRD §8 / Q8. e.g. "own-artwork",
    /// "licensed-stock", "public-domain".
    String? source,
    String? licence,
    @TimestampConverter() DateTime? publishAt,
    @TimestampConverter() DateTime? expireAt,
    String? createdBy,
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? updatedAt,
    @TimestampConverter() DateTime? deletedAt,

    // Type-specific payloads (see content_type_metas.dart).
    // Stored under `statusMeta` in Firestore — NOT `status`, which is
    // reserved for the draft/published workflow field above.
    WallpaperMeta? wallpaper,
    AudioMeta? audio,
    StatusMeta? statusMeta,
  }) = _ContentItem;

  factory ContentItem.fromJson(Map<String, dynamic> json) =>
      _$ContentItemFromJson(json);
}

/// Content type discriminator values stored in [ContentItem.type].
abstract class ContentType {
  ContentType._();

  static const wallpaper = 'wallpaper';
  static const ringtone = 'ringtone';
  static const song = 'song';
  static const meditation = 'meditation';
  static const status = 'status';
  static const prarthana = 'prarthana';
}

/// Publish workflow states stored in [ContentItem.status].
abstract class ContentStatus {
  ContentStatus._();

  static const draft = 'draft';
  static const published = 'published';
  static const unpublished = 'unpublished';
  static const archived = 'archived';
}

extension ContentItemX on ContentItem {
  bool get isPublished =>
      status == ContentStatus.published && deletedAt == null;

  bool get isAudio => audio != null;
}
