/// Shared helpers for the full player and mini player.
double sliderValue(Duration position, Duration duration) {
  final total = duration.inMilliseconds;
  if (total <= 0) return 0;
  final v = position.inMilliseconds / total;
  if (v.isNaN || v.isInfinite) return 0;
  return v.clamp(0.0, 1.0);
}

String formatPlayerTime(Duration d) {
  final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  final h = d.inHours;
  if (h > 0) return '$h:$m:$s';
  return '$m:$s';
}

Duration resolveDuration(Duration? fromMedia, Duration? fromPlayer) {
  if (fromMedia != null && fromMedia > Duration.zero) return fromMedia;
  if (fromPlayer != null && fromPlayer > Duration.zero) return fromPlayer;
  return Duration.zero;
}
