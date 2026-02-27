import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:employee_portal/core/theme/app_colors.dart';
import 'package:employee_portal/core/theme/app_radius.dart';

/// Full-screen or inline loading widget
class LoadingWidget extends StatelessWidget {
  final bool fullScreen;

  const LoadingWidget({super.key, this.fullScreen = false});

  @override
  Widget build(BuildContext context) {
    final widget = const Center(
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
      ),
    );
    return fullScreen ? Scaffold(body: widget) : widget;
  }
}

/// Skeleton shimmer loader for list/card placeholders
class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF2D3F5A) : const Color(0xFFE8EDF5),
      highlightColor: isDark ? const Color(0xFF3A4E6A) : const Color(0xFFF5F8FF),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? AppRadius.mdBorderRadius,
        ),
      ),
    );
  }
}

/// Card skeleton for news/event items
class CardSkeleton extends StatelessWidget {
  const CardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.surfaceDark
            : AppColors.surfaceLight,
        borderRadius: AppRadius.lgBorderRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonLoader(width: double.infinity, height: 160, borderRadius: AppRadius.mdBorderRadius),
          const SizedBox(height: 12),
          const SkeletonLoader(width: 200, height: 16),
          const SizedBox(height: 8),
          const SkeletonLoader(width: 280, height: 12),
          const SizedBox(height: 8),
          const SkeletonLoader(width: 120, height: 12),
        ],
      ),
    );
  }
}

/// Horizontal card skeleton
class HorizontalCardSkeleton extends StatelessWidget {
  const HorizontalCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(left: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.surfaceDark
            : AppColors.surfaceLight,
        borderRadius: AppRadius.lgBorderRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonLoader(width: double.infinity, height: 120, borderRadius: AppRadius.mdBorderRadius),
          const SizedBox(height: 10),
          const SkeletonLoader(width: 150, height: 14),
          const SizedBox(height: 6),
          const SkeletonLoader(width: 100, height: 11),
        ],
      ),
    );
  }
}
