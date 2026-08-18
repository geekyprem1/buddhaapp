/// Spacing and radius scale from PRD §10 — heavily rounded cards, pill
/// buttons and chips. No magic numbers should appear outside this file.
abstract class AppSpacing {
  AppSpacing._();

  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;

  /// Minimum touch target size (NFR accessibility, PRD §3.1).
  static const minTouchTarget = 48.0;
}

abstract class AppRadius {
  AppRadius._();

  static const card = 20.0;
  static const cardLarge = 24.0;
  static const chip = 999.0; // fully pill-shaped
  static const button = 999.0;
  static const sheet = 24.0;
}
