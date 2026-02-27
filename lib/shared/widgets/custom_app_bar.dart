import 'package:flutter/material.dart';
import 'package:employee_portal/core/theme/app_colors.dart';
import 'package:employee_portal/core/theme/app_typography.dart';
import 'package:employee_portal/core/theme/app_spacing.dart';

/// Reusable CustomAppBar used across the entire app
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBack;
  final bool centerTitle;
  final Color? backgroundColor;
  final VoidCallback? onBack;
  final Widget? bottom;
  final double? elevation;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showBack = true,
    this.centerTitle = false,
    this.backgroundColor,
    this.onBack,
    this.bottom,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.scaffoldBackgroundColor,
        boxShadow: elevation != null && elevation! > 0
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md, // Increased top padding
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: Row(
                children: [
                  // Leading / Back
                  if (leading != null)
                    leading!
                  else if (showBack && Navigator.of(context).canPop())
                    _BackButton(onBack: onBack),

                  if ((leading != null ||
                      (showBack && Navigator.of(context).canPop())))
                    const SizedBox(width: AppSpacing.md),

                  // Title
                  Expanded(
                    child: centerTitle
                        ? Center(
                            child: Text(
                              title,
                              style: AppTypography.titleLarge.copyWith(
                                color: isDark
                                    ? AppColors.onSurfaceDark
                                    : AppColors.onSurfaceLight,
                              ),
                            ),
                          )
                        : Text(
                            title,
                            style: AppTypography.titleLarge.copyWith(
                              color: isDark
                                  ? AppColors.onSurfaceDark
                                  : AppColors.onSurfaceLight,
                            ),
                          ),
                  ),

                  // Actions
                  if (actions != null) ...actions!,
                ],
              ),
            ),
            if (bottom != null) bottom!,
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize {
    const toolbarHeight = kToolbarHeight + 50;
    final extra = bottom != null ? 52.0 : 0.0;
    return Size.fromHeight(toolbarHeight + extra);
  }

  /// Dynamic height that accounts for the status-bar safe area.
  /// Call this from within build to get the true rendered height.
  static double effectiveHeight(BuildContext context,
      {bool hasBottom = false}) {
    final statusBar = MediaQuery.of(context).padding.top;
    return statusBar + kToolbarHeight + 20 + (hasBottom ? 52 : 0);
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback? onBack;

  const _BackButton({this.onBack});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onBack ?? () => Navigator.of(context).pop(),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.surfaceVariantDark
              : AppColors.surfaceVariantLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 18,
          color: isDark ? AppColors.onSurfaceDark : AppColors.onSurfaceLight,
        ),
      ),
    );
  }
}
