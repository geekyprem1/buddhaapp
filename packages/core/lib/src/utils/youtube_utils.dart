// Helpers for turning a YouTube URL (as pasted by an admin) into a stable
// video id, a thumbnail URL and a canonical watch URL. Keeping this in core
// means the admin (which validates + stores the id) and the app (which builds
// the thumbnail + play link) agree on exactly the same parsing.

/// Extracts the 11-character YouTube video id from any common URL shape:
/// `youtu.be/ID`, `watch?v=ID`, `/embed/ID`, `/shorts/ID`, `/live/ID`,
/// `/v/ID`, or a bare id. Returns `null` when no id can be found.
String? extractYouTubeId(String url) {
  final trimmed = url.trim();
  if (trimmed.isEmpty) return null;

  const idPart = r'([A-Za-z0-9_-]{11})';
  final patterns = <RegExp>[
    RegExp('youtu\\.be/$idPart'),
    RegExp('[?&]v=$idPart'),
    RegExp('/embed/$idPart'),
    RegExp('/shorts/$idPart'),
    RegExp('/live/$idPart'),
    RegExp('/v/$idPart'),
  ];
  for (final pattern in patterns) {
    final match = pattern.firstMatch(trimmed);
    if (match != null) return match.group(1);
  }

  // A bare id pasted on its own.
  if (RegExp('^$idPart\$').hasMatch(trimmed)) return trimmed;
  return null;
}

/// `true` when [url] contains a parseable YouTube video id.
bool isValidYouTubeUrl(String url) => extractYouTubeId(url) != null;

/// High-quality thumbnail for a given video id (always available, 480×360).
String youTubeThumbnail(String videoId) =>
    'https://img.youtube.com/vi/$videoId/hqdefault.jpg';

/// Max-resolution thumbnail (may 404 for some very old videos; the app falls
/// back to [youTubeThumbnail]).
String youTubeThumbnailMax(String videoId) =>
    'https://img.youtube.com/vi/$videoId/maxresdefault.jpg';

/// Canonical watch URL used to open the video in the YouTube app / browser.
String youTubeWatchUrl(String videoId) =>
    'https://www.youtube.com/watch?v=$videoId';
