import 'package:flutter/services.dart';

/// Centralised, premium haptic feedback for the app. Keeping every buzz in
/// one place makes them consistent and easy to tune. All methods are
/// fire-and-forget (never awaited on the UI path) and safe on devices/desktop
/// without a vibrator — the platform simply ignores unsupported calls.
abstract class AppHaptics {
  AppHaptics._();

  /// Light tick — the everyday interaction: list/card taps, chip selection,
  /// opening a detail, sheet items.
  static void tap() {
    HapticFeedback.selectionClick();
  }

  /// A slightly firmer tick for discrete transitions like swiping to the next
  /// reel page or switching a bottom-nav tab.
  static void selection() {
    HapticFeedback.selectionClick();
  }

  /// Medium impact — a primary/confirming action (Set wallpaper, Play,
  /// primary buttons).
  static void impact() {
    HapticFeedback.mediumImpact();
  }

  /// Light impact — a secondary confirmation (download, save).
  static void light() {
    HapticFeedback.lightImpact();
  }

  /// Success — a completed action (wallpaper/ringtone set). Slightly stronger
  /// so it reads as "done".
  static void success() {
    HapticFeedback.mediumImpact();
  }

  /// Warning/error — something failed or was blocked.
  static void error() {
    HapticFeedback.heavyImpact();
  }
}
