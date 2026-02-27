import 'package:flutter/material.dart';

/// Complete color palette for Internal Employee Portal
/// Supports both Light and Dark modes
abstract class AppColors {
  // ─── Brand Colors ──────────────────────────────────────────────────
  static const Color primary = Color(0xFF1E6BE6);
  static const Color primaryLight = Color(0xFF4D8DF0);
  static const Color primaryDark = Color(0xFF1450C0);
  static const Color primaryContainer = Color(0xFFD6E4FF);

  static const Color secondary = Color(0xFF0ABFBC);
  static const Color secondaryLight = Color(0xFF3ECFCD);
  static const Color secondaryDark = Color(0xFF079A97);
  static const Color secondaryContainer = Color(0xFFCCF5F4);

  // ─── Accent ────────────────────────────────────────────────────────
  static const Color accent = Color(0xFF6C63FF);
  static const Color accentLight = Color(0xFF9D97FF);

  // ─── Semantic Colors ───────────────────────────────────────────────
  static const Color success = Color(0xFF22C55E);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color successDark = Color(0xFF16A34A);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color warningDark = Color(0xFFD97706);

  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color errorDark = Color(0xFFDC2626);

  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);

  // ─── Light Theme Neutrals ──────────────────────────────────────────
  static const Color backgroundLight = Color(0xFFF2F5FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFEEF2F8);
  static const Color onSurfaceLight = Color(0xFF1A2340);
  static const Color onSurfaceVariantLight = Color(0xFF64748B);
  static const Color dividerLight = Color(0xFFE2E8F0);

  // ─── Dark Theme Neutrals ───────────────────────────────────────────
  static const Color backgroundDark = Color(0xFF0F1623);
  static const Color surfaceDark = Color(0xFF1A2236);
  static const Color surfaceVariantDark = Color(0xFF243047);
  static const Color onSurfaceDark = Color(0xFFE8EDF7);
  static const Color onSurfaceVariantDark = Color(0xFF94A3B8);
  static const Color dividerDark = Color(0xFF2D3F5A);

  // ─── Gradient Presets ──────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E6BE6), Color(0xFF6C63FF)],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0ABFBC), Color(0xFF1E6BE6)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E6BE6), Color(0xFF0ABFBC)],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A2236), Color(0xFF243047)],
  );

  // ─── Specific Feature Colors ────────────────────────────────────────
  static const Color hrColor = Color(0xFF8B5CF6);
  static const Color hrColorLight = Color(0xFFEDE9FE);
  static const Color itColor = Color(0xFF0ABFBC);
  static const Color itColorLight = Color(0xFFCCF5F4);
  static const Color newsColor = Color(0xFFF59E0B);
  static const Color newsColorLight = Color(0xFFFEF3C7);
  static const Color eventsColor = Color(0xFFEC4899);
  static const Color eventsColorLight = Color(0xFFFCE7F3);
  static const Color moodColor = Color(0xFF22C55E);
  static const Color moodColorLight = Color(0xFFDCFCE7);
  static const Color chatbotColor = Color(0xFF6C63FF);
  static const Color chatbotColorLight = Color(0xFFEDE9FE);
  static const Color secondaryOrange = Color(0xFFF97316);

  // ─── Mood Gradient ──────────────────────────────────────────────
  static const LinearGradient moodGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF22C55E), Color(0xFF0ABFBC)],
  );

  // ─── Mood Colors ───────────────────────────────────────────────────
  static const Color moodExcellent = Color(0xFF22C55E);
  static const Color moodGood = Color(0xFF84CC16);
  static const Color moodNeutral = Color(0xFFF59E0B);
  static const Color moodBad = Color(0xFFEF4444);
  static const Color moodTerrible = Color(0xFF7C3AED);

  // ─── Overlay ───────────────────────────────────────────────────────
  static const Color overlay = Color(0x801A2340);
  static const Color shimmerBase = Color(0xFFEEF2F8);
  static const Color shimmerHighlight = Color(0xFFF8FAFF);
}
