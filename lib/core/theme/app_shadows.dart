import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Shadow system for cards and elevated elements
abstract class AppShadows {
  // ─── Soft Shadow (cards, containers) ──────────────────────────────
  static List<BoxShadow> get soft => [
        BoxShadow(
          color: AppColors.primary.withOpacity(0.08),
          blurRadius: 20,
          spreadRadius: 0,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 8,
          spreadRadius: 0,
          offset: const Offset(0, 2),
        ),
      ];

  // ─── Card Elevation ────────────────────────────────────────────────
  static List<BoxShadow> get card => [
        BoxShadow(
          color: AppColors.primary.withOpacity(0.12),
          blurRadius: 24,
          spreadRadius: 0,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 12,
          spreadRadius: 0,
          offset: const Offset(0, 4),
        ),
      ];

  // ─── Button Shadow ─────────────────────────────────────────────────
  static List<BoxShadow> get button => [
        BoxShadow(
          color: AppColors.primary.withOpacity(0.35),
          blurRadius: 16,
          spreadRadius: 0,
          offset: const Offset(0, 6),
        ),
      ];

  // ─── Floating Action ───────────────────────────────────────────────
  static List<BoxShadow> get floating => [
        BoxShadow(
          color: AppColors.primary.withOpacity(0.30),
          blurRadius: 32,
          spreadRadius: 4,
          offset: const Offset(0, 12),
        ),
      ];

  // ─── Dark Mode Variants ────────────────────────────────────────────
  static List<BoxShadow> get softDark => [
        BoxShadow(
          color: Colors.black.withOpacity(0.30),
          blurRadius: 20,
          spreadRadius: 0,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get cardDark => [
        BoxShadow(
          color: Colors.black.withOpacity(0.40),
          blurRadius: 24,
          spreadRadius: 0,
          offset: const Offset(0, 8),
        ),
      ];
}
