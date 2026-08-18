import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Typography per PRD §10 — Poppins for Latin script, Noto Sans Devanagari
/// as the companion for Hindi/Marathi. Both are loaded via [GoogleFonts] so
/// there is no bundled-font-asset maintenance burden.
abstract class AppTypography {
  AppTypography._();

  static TextTheme textTheme({Color color = AppColors.textPrimary}) {
    final base = GoogleFonts.poppinsTextTheme();
    return base
        .copyWith(
          displayLarge: base.displayLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          headlineMedium: base.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          titleLarge: base.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          bodyLarge: base.bodyLarge,
          bodyMedium: base.bodyMedium,
          labelLarge: base.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        )
        .apply(bodyColor: color, displayColor: color);
  }

  /// Devanagari-capable fallback text style, used when rendering Hindi or
  /// Marathi content strings so Latin-only fonts never show tofu glyphs.
  static TextStyle devanagari({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
  }) {
    return GoogleFonts.notoSansDevanagari(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? AppColors.textPrimary,
    );
  }
}
