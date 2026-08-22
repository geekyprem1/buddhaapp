/**
 * Shared content-collection metadata used by the media, audit, publish,
 * counter and cleanup Functions. Keep this aligned with `packages/core`
 * collection constants and Architecture §6.2 / §6.4.
 */

export type MediaKind = "image" | "audio";

/** Admin-managed content collections (Architecture §6.2). */
export const CONTENT_COLLECTIONS = [
  "wallpapers",
  "ringtones",
  "songs",
  "vandanas",
  "meditations",
  "chantings",
  "statuses",
  "prarthanas",
] as const;

export type ContentCollection = (typeof CONTENT_COLLECTIONS)[number];

/** Which derivative pipeline a collection's original upload runs through. */
export const CONTENT_MEDIA_KIND: Record<ContentCollection, MediaKind> = {
  wallpapers: "image",
  statuses: "image",
  ringtones: "audio",
  songs: "audio",
  vandanas: "audio",
  meditations: "audio",
  chantings: "audio",
  prarthanas: "audio",
};

export function isContentCollection(value: unknown): value is ContentCollection {
  return (
    typeof value === "string" &&
    (CONTENT_COLLECTIONS as readonly string[]).includes(value)
  );
}

/**
 * Map a client `events/{id}.type` to the `counters` key it increments
 * (Architecture §6.2: `counters { views, downloads, shares, plays }`).
 */
export const EVENT_TYPE_TO_COUNTER: Record<string, string> = {
  view: "views",
  views: "views",
  download: "downloads",
  downloads: "downloads",
  share: "shares",
  shares: "shares",
  play: "plays",
  plays: "plays",
  song_play: "plays",
  song_complete: "plays",
  vandana_play: "plays",
  vandana_complete: "plays",
};
