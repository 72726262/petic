import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography system using Cairo for Arabic and English
abstract class AppTypography {
  // ─── Font Family ───────────────────────────────────────────────────
  static TextStyle get _base => GoogleFonts.cairo();

  // ─── Display ───────────────────────────────────────────────────────
  static TextStyle displayLarge = _base.copyWith(
    fontSize: 57,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.25,
    height: 1.12,
  );

  static TextStyle displayMedium = _base.copyWith(
    fontSize: 45,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.16,
  );

  static TextStyle displaySmall = _base.copyWith(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.22,
  );

  // ─── Headline ──────────────────────────────────────────────────────
  static TextStyle headlineLarge = _base.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.25,
  );

  static TextStyle headlineMedium = _base.copyWith(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.29,
  );

  static TextStyle headlineSmall = _base.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.33,
  );

  // ─── Title ─────────────────────────────────────────────────────────
  static TextStyle titleLarge = _base.copyWith(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.27,
  );

  static TextStyle titleMedium = _base.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.5,
  );

  static TextStyle titleSmall = _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.43,
  );

  // ─── Body ──────────────────────────────────────────────────────────
  static TextStyle bodyLarge = _base.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.5,
  );

  static TextStyle bodyMedium = _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
  );

  static TextStyle bodySmall = _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
  );

  // ─── Label ─────────────────────────────────────────────────────────
  static TextStyle labelLarge = _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.43,
  );

  static TextStyle labelMedium = _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.33,
  );

  static TextStyle labelSmall = _base.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.45,
  );

  // ─── Specific Styles ───────────────────────────────────────────────
  static TextStyle buttonText = _base.copyWith(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.0,
  );

  static TextStyle caption = _base.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    color: AppColors.onSurfaceVariantLight,
    height: 1.4,
  );

  static TextStyle overline = _base.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.5,
    height: 1.6,
  );

  // ─── Build TextTheme ───────────────────────────────────────────────
  static TextTheme buildTextTheme({bool isDark = false}) {
    final Color textColor =
        isDark ? AppColors.onSurfaceDark : AppColors.onSurfaceLight;
    return TextTheme(
      displayLarge: displayLarge.copyWith(color: textColor),
      displayMedium: displayMedium.copyWith(color: textColor),
      displaySmall: displaySmall.copyWith(color: textColor),
      headlineLarge: headlineLarge.copyWith(color: textColor),
      headlineMedium: headlineMedium.copyWith(color: textColor),
      headlineSmall: headlineSmall.copyWith(color: textColor),
      titleLarge: titleLarge.copyWith(color: textColor),
      titleMedium: titleMedium.copyWith(color: textColor),
      titleSmall: titleSmall.copyWith(color: textColor),
      bodyLarge: bodyLarge.copyWith(color: textColor),
      bodyMedium: bodyMedium.copyWith(color: textColor),
      bodySmall: bodySmall.copyWith(
        color: isDark
            ? AppColors.onSurfaceVariantDark
            : AppColors.onSurfaceVariantLight,
      ),
      labelLarge: labelLarge.copyWith(color: textColor),
      labelMedium: labelMedium.copyWith(
        color: isDark
            ? AppColors.onSurfaceVariantDark
            : AppColors.onSurfaceVariantLight,
      ),
      labelSmall: labelSmall.copyWith(
        color: isDark
            ? AppColors.onSurfaceVariantDark
            : AppColors.onSurfaceVariantLight,
      ),
    );
  }
}
