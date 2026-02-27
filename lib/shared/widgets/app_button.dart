import 'package:flutter/material.dart';
import 'package:employee_portal/core/theme/app_colors.dart';
import 'package:employee_portal/core/theme/app_typography.dart';
import 'package:employee_portal/core/theme/app_radius.dart';
import 'package:employee_portal/core/theme/app_shadows.dart';
import 'package:employee_portal/core/animations/app_animations.dart';

/// Primary Button
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final ButtonStyle? style;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? height;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.style,
    this.backgroundColor,
    this.foregroundColor,
    this.height,
  });

  // ─── Factory: Primary ────────────────────────────────────────────
  factory AppButton.primary({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isFullWidth = true,
    IconData? icon,
  }) =>
      AppButton(
        key: key,
        label: label,
        onPressed: onPressed,
        isLoading: isLoading,
        isFullWidth: isFullWidth,
        icon: icon,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      );

  // ─── Factory: Secondary ──────────────────────────────────────────
  factory AppButton.secondary({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isFullWidth = true,
    IconData? icon,
  }) =>
      AppButton(
        key: key,
        label: label,
        onPressed: onPressed,
        isLoading: isLoading,
        isFullWidth: isFullWidth,
        icon: icon,
        backgroundColor: AppColors.primaryContainer,
        foregroundColor: AppColors.primary,
      );

  // ─── Factory: Outline ────────────────────────────────────────────
  factory AppButton.outline({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isFullWidth = true,
    IconData? icon,
  }) =>
      _OutlineButton(
        key: key,
        label: label,
        onPressed: onPressed,
        isLoading: isLoading,
        isFullWidth: isFullWidth,
        icon: icon,
      ) as AppButton;

  @override
  Widget build(BuildContext context) {
    final btn = PressEffect(
      onTap: isLoading ? null : onPressed,
      scaleDown: 0.97,
      child: Container(
        height: height ?? 52,
        width: isFullWidth ? double.infinity : null,
        decoration: BoxDecoration(
          color: onPressed == null || isLoading
              ? (backgroundColor ?? AppColors.primary).withOpacity(0.5)
              : (backgroundColor ?? AppColors.primary),
          borderRadius: AppRadius.mdBorderRadius,
          boxShadow: onPressed != null && !isLoading ? AppShadows.button : [],
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      foregroundColor ?? Colors.white,
                    ),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: foregroundColor ?? Colors.white, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      label,
                      style: AppTypography.buttonText.copyWith(
                        color: foregroundColor ?? Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );

    return btn;
  }
}

/// Outline button implementation
class _OutlineButton extends AppButton {
  const _OutlineButton({
    super.key,
    required super.label,
    super.onPressed,
    super.isLoading,
    super.isFullWidth,
    super.icon,
  });

  @override
  Widget build(BuildContext context) {
    return PressEffect(
      onTap: isLoading ? null : onPressed,
      scaleDown: 0.97,
      child: Container(
        height: height ?? 52,
        width: isFullWidth ? double.infinity : null,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: AppRadius.mdBorderRadius,
          border: Border.all(
            color: AppColors.primary.withOpacity(
                onPressed == null || isLoading ? 0.4 : 1.0),
            width: 1.5,
          ),
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      label,
                      style: AppTypography.buttonText.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Icon-only button
class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final String? tooltip;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.backgroundColor,
    this.iconColor,
    this.size = 44,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PressEffect(
      onTap: onTap,
      child: Tooltip(
        message: tooltip ?? '',
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor ??
                (isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight),
            borderRadius: BorderRadius.circular(size / 3),
          ),
          child: Icon(
            icon,
            color: iconColor ??
                (isDark ? AppColors.onSurfaceDark : AppColors.onSurfaceLight),
            size: size * 0.48,
          ),
        ),
      ),
    );
  }
}
