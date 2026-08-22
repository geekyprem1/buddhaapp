import 'package:core/core.dart';

import '../../../app/admin_access.dart';
import '../../../app/admin_strings.dart';

enum ContentMediaKind { image, audio }

/// Declares which fields a content type exposes (Architecture §11, T1.17).
/// Adding a type means adding one object to [contentTypeConfigs].
class ContentTypeConfig {
  const ContentTypeConfig({
    required this.type,
    required this.collection,
    required this.label,
    required this.route,
    required this.media,
    this.artistLabel,
    this.hasAlbum = false,
    this.hasLyrics = false,
    this.hasTrim = false,
    this.hasSeries = false,
    this.hasLevel = false,
    this.hasWallpaperMeta = false,
    this.hasStatusMeta = false,
    this.hasPrarthanaExtras = false,
  });

  final String type;
  final String collection;
  final String label;
  final String route;
  final ContentMediaKind media;
  final String? artistLabel;
  final bool hasAlbum;
  final bool hasLyrics;
  final bool hasTrim;
  final bool hasSeries;
  final bool hasLevel;
  final bool hasWallpaperMeta;
  final bool hasStatusMeta;
  final bool hasPrarthanaExtras;

  bool get hasAudioMeta =>
      media == ContentMediaKind.audio ||
      hasAlbum ||
      hasLyrics ||
      hasTrim ||
      hasSeries ||
      hasLevel ||
      hasPrarthanaExtras;
}

const contentTypeConfigs = <ContentTypeConfig>[
  ContentTypeConfig(
    type: ContentType.wallpaper,
    collection: FirestoreCollections.wallpapers,
    label: AdminStrings.wallpapers,
    route: AdminRoutes.wallpapers,
    media: ContentMediaKind.image,
    hasWallpaperMeta: true,
  ),
  ContentTypeConfig(
    type: ContentType.ringtone,
    collection: FirestoreCollections.ringtones,
    label: AdminStrings.ringtones,
    route: AdminRoutes.ringtones,
    media: ContentMediaKind.audio,
    artistLabel: AdminStrings.artistField,
    hasTrim: true,
  ),
  ContentTypeConfig(
    type: ContentType.song,
    collection: FirestoreCollections.songs,
    label: AdminStrings.songs,
    route: AdminRoutes.songs,
    media: ContentMediaKind.audio,
    artistLabel: AdminStrings.artistField,
    hasAlbum: true,
    hasLyrics: true,
  ),
  ContentTypeConfig(
    type: ContentType.vandana,
    collection: FirestoreCollections.vandanas,
    label: AdminStrings.vandanas,
    route: AdminRoutes.vandanas,
    media: ContentMediaKind.audio,
    artistLabel: AdminStrings.artistField,
    hasAlbum: true,
    hasLyrics: true,
  ),
  ContentTypeConfig(
    type: ContentType.meditation,
    collection: FirestoreCollections.meditations,
    label: AdminStrings.meditations,
    route: AdminRoutes.meditations,
    media: ContentMediaKind.audio,
    artistLabel: AdminStrings.narratorField,
    hasSeries: true,
    hasLevel: true,
  ),
  ContentTypeConfig(
    type: ContentType.chanting,
    collection: FirestoreCollections.chantings,
    label: AdminStrings.chantings,
    route: AdminRoutes.chantings,
    media: ContentMediaKind.audio,
    artistLabel: AdminStrings.artistField,
  ),
  ContentTypeConfig(
    type: ContentType.status,
    collection: FirestoreCollections.statuses,
    label: AdminStrings.statuses,
    route: AdminRoutes.statuses,
    media: ContentMediaKind.image,
    hasStatusMeta: true,
  ),
  ContentTypeConfig(
    type: ContentType.prarthana,
    collection: FirestoreCollections.prarthanas,
    label: AdminStrings.prarthanas,
    route: AdminRoutes.prarthanas,
    media: ContentMediaKind.audio,
    artistLabel: AdminStrings.artistField,
    hasPrarthanaExtras: true,
  ),
];

ContentTypeConfig configForType(String type) =>
    contentTypeConfigs.firstWhere((c) => c.type == type);

ContentTypeConfig configForRoute(String route) =>
    contentTypeConfigs.firstWhere((c) => c.route == route);
