import 'package:flutter/material.dart';

/// Colour tokens from PRD §10. No raw hex values should appear anywhere
/// outside this file — every screen references these constants instead.
abstract class AppColors {
  AppColors._();

  /// Cream / ivory background.
  static const background = Color(0xFFFDF3E0);

  /// Deep maroon — primary brand colour, filled chips, primary buttons.
  static const primary = Color(0xFF8B1A1A);

  /// Gold — accents, highlights, ID card (Phase 2) trims.
  static const accent = Color(0xFFD4A24C);

  /// Near-black — primary text colour.
  static const textPrimary = Color(0xFF1F1F1F);

  /// WhatsApp green — used exclusively for share-to-WhatsApp actions.
  static const whatsappGreen = Color(0xFF25D366);

  static const textSecondary = Color(0xFF6B6B6B);
  static const disabled = Color(0xFFE8DCC4);
  static const surface = Color(0xFFFFFFFF);
  static const error = Color(0xFFB3261E);
  static const success = Color(0xFF2E7D32);
  static const divider = Color(0xFFE0D3B8);
}
