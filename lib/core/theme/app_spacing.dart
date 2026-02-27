import 'package:flutter/material.dart';

/// Spacing system — 4pt base grid
abstract class AppSpacing {
  // ─── Base Scale ────────────────────────────────────────────────────
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double huge = 40.0;
  static const double massive = 48.0;
  static const double giant = 64.0;

  // ─── Horizontal Padding ────────────────────────────────────────────
  static const EdgeInsets hPaddingSm =
      EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets hPaddingMd =
      EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets hPaddingLg =
      EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets hPaddingXl =
      EdgeInsets.symmetric(horizontal: xl);
  static const EdgeInsets hPaddingXxl =
      EdgeInsets.symmetric(horizontal: xxl);

  // ─── Page Padding ──────────────────────────────────────────────────
  static const EdgeInsets pagePadding = EdgeInsets.all(lg);
  static const EdgeInsets pagePaddingH = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets cardPadding = EdgeInsets.all(lg);
  static const EdgeInsets cardPaddingSm = EdgeInsets.all(md);

  // ─── Gaps ──────────────────────────────────────────────────────────
  static const SizedBox gapXs = SizedBox(height: xs, width: xs);
  static const SizedBox gapSm = SizedBox(height: sm, width: sm);
  static const SizedBox gapMd = SizedBox(height: md, width: md);
  static const SizedBox gapLg = SizedBox(height: lg, width: lg);
  static const SizedBox gapXl = SizedBox(height: xl, width: xl);
  static const SizedBox gapXxl = SizedBox(height: xxl, width: xxl);
  static const SizedBox gapXxxl = SizedBox(height: xxxl, width: xxxl);

  static SizedBox hGap(double width) => SizedBox(width: width);
  static SizedBox vGap(double height) => SizedBox(height: height);
}
