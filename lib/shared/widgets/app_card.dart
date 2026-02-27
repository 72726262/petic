import 'package:flutter/material.dart';
import 'package:employee_portal/core/theme/app_colors.dart';
import 'package:employee_portal/core/theme/app_radius.dart';
import 'package:employee_portal/core/theme/app_shadows.dart';
import 'package:employee_portal/core/theme/app_spacing.dart';
import 'package:employee_portal/core/animations/app_animations.dart';

/// Reusable AppCard with shadow, press effect, and border radius
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final List<BoxShadow>? shadows;
  final Border? border;
  final Gradient? gradient;
  final double? width;
  final double? height;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.borderRadius,
    this.onTap,
    this.shadows,
    this.border,
    this.gradient,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget card = Container(
      width: width,
      height: height,
      padding: padding ?? AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: gradient == null
            ? (color ??
                (isDark ? AppColors.surfaceDark : AppColors.surfaceLight))
            : null,
        gradient: gradient,
        borderRadius: borderRadius ?? AppRadius.lgBorderRadius,
        boxShadow: shadows ?? (isDark ? AppShadows.softDark : AppShadows.soft),
        border: border,
      ),
      child: child,
    );

    if (onTap != null) {
      return PressEffect(
        onTap: onTap,
        child: card,
      );
    }
    return card;
  }
}

/// Gradient card variant
class GradientCard extends StatelessWidget {
  final Widget child;
  final Gradient gradient;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  const GradientCard({
    super.key,
    required this.child,
    required this.gradient,
    this.padding,
    this.borderRadius,
    this.onTap,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      gradient: gradient,
      padding: padding,
      borderRadius: borderRadius,
      onTap: onTap,
      width: width,
      height: height,
      shadows: AppShadows.card,
      child: child,
    );
  }
}
