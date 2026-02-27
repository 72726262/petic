import 'package:flutter/material.dart';

/// Border radius constants
abstract class AppRadius {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double full = 999.0;

  // ─── BorderRadius Objects ──────────────────────────────────────────
  static final BorderRadius xsBorderRadius = BorderRadius.circular(xs);
  static final BorderRadius smBorderRadius = BorderRadius.circular(sm);
  static final BorderRadius mdBorderRadius = BorderRadius.circular(md);
  static final BorderRadius lgBorderRadius = BorderRadius.circular(lg);
  static final BorderRadius xlBorderRadius = BorderRadius.circular(xl);
  static final BorderRadius xxlBorderRadius = BorderRadius.circular(xxl);
  static final BorderRadius fullBorderRadius = BorderRadius.circular(full);

  // ─── Top Only ──────────────────────────────────────────────────────
  static final BorderRadius topMdBorderRadius = BorderRadius.only(
    topLeft: Radius.circular(md),
    topRight: Radius.circular(md),
  );

  static final BorderRadius topXlBorderRadius = BorderRadius.only(
    topLeft: Radius.circular(xl),
    topRight: Radius.circular(xl),
  );

  // ─── Bottom Only ───────────────────────────────────────────────────
  static final BorderRadius bottomMdBorderRadius = BorderRadius.only(
    bottomLeft: Radius.circular(md),
    bottomRight: Radius.circular(md),
  );
}
