import 'package:core/core.dart';

/// Builds the playback queue for a tapped meditation (FR-10.3).
///
/// If the item belongs to a series (`audio.seriesId` set), the queue is that
/// series' parts ordered by `partNumber`, so completing one part flows
/// straight into the next (the audio handler auto-advances on completion).
/// A standalone meditation queues the whole loaded list as before.
///
/// Parts are taken from [loadedItems] (the already-fetched list page). At
/// launch volumes the full meditation set is loaded, so every part is
/// present; if a series ever spans beyond the loaded page, playback simply
/// stops at the last loaded part.
List<ContentItem> meditationPlayQueue(
  ContentItem tapped,
  List<ContentItem> loadedItems,
) {
  final seriesId = tapped.audio?.seriesId;
  if (seriesId == null || seriesId.isEmpty) {
    return loadedItems.isEmpty ? [tapped] : loadedItems;
  }

  final parts = loadedItems
      .where((e) => (e.audio?.seriesId ?? '') == seriesId)
      .toList()
    ..sort(
      (a, b) => (a.audio?.partNumber ?? 0).compareTo(b.audio?.partNumber ?? 0),
    );

  // Guard against the tapped item not being in the loaded page.
  if (parts.isEmpty) return [tapped];
  if (!parts.any((e) => e.id == tapped.id)) {
    return [tapped, ...parts.where((e) => e.id != tapped.id)];
  }
  return parts;
}
