import 'package:flutter/material.dart';
import 'package:employee_portal/core/theme/app_colors.dart';
import 'package:employee_portal/core/theme/app_typography.dart';
import 'package:employee_portal/core/theme/app_radius.dart';
import 'package:employee_portal/core/theme/app_shadows.dart';
import 'package:employee_portal/core/animations/app_animations.dart';

/// Grid menu item for Quick Actions section on Home screen
class GridMenuItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color lightColor;
  final VoidCallback onTap;
  final int animationIndex;

  const GridMenuItem({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.lightColor,
    required this.onTap,
    this.animationIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StaggeredListItem(
      index: animationIndex,
      child: PressEffect(
        onTap: onTap,
        scaleDown: 0.93,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: AppRadius.lgBorderRadius,
            boxShadow: isDark ? AppShadows.softDark : AppShadows.soft,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon container with gradient background
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: lightColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: AppTypography.labelLarge.copyWith(
                  color:
                      isDark ? AppColors.onSurfaceDark : AppColors.onSurfaceLight,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
