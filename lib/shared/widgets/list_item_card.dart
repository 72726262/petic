import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:employee_portal/core/theme/app_colors.dart';
import 'package:employee_portal/core/theme/app_typography.dart';
import 'package:employee_portal/core/theme/app_radius.dart';
import 'package:employee_portal/core/theme/app_shadows.dart';
import 'package:employee_portal/core/animations/app_animations.dart';

/// Generic list item card for news, events, HR, IT content
class ListItemCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final String? date;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? accentColor;
  final List<Widget>? tags;
  final int animationIndex;

  const ListItemCard({
    super.key,
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.date,
    this.leading,
    this.trailing,
    this.onTap,
    this.accentColor,
    this.tags,
    this.animationIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StaggeredListItem(
      index: animationIndex,
      child: PressEffect(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: AppRadius.lgBorderRadius,
            boxShadow: isDark ? AppShadows.softDark : AppShadows.soft,
            border: accentColor != null
                ? Border(
                    right: BorderSide(color: accentColor!, width: 3),
                  )
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image (if provided)
              if (imageUrl != null)
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl!,
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      height: 180,
                      color: isDark
                          ? AppColors.surfaceVariantDark
                          : AppColors.surfaceVariantLight,
                      child: const Center(
                        child: Icon(
                          Icons.image_outlined,
                          color: AppColors.primary,
                          size: 40,
                        ),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      height: 180,
                      color: isDark
                          ? AppColors.surfaceVariantDark
                          : AppColors.surfaceVariantLight,
                      child: const Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: AppColors.primary,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ),

              // Content
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (leading != null) ...[
                      leading!,
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (tags != null && tags!.isNotEmpty) ...[
                            Wrap(spacing: 6, children: tags!),
                            const SizedBox(height: 6),
                          ],
                          Text(
                            title,
                            style: AppTypography.titleSmall.copyWith(
                              color: isDark
                                  ? AppColors.onSurfaceDark
                                  : AppColors.onSurfaceLight,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              subtitle!,
                              style: AppTypography.bodySmall.copyWith(
                                color: isDark
                                    ? AppColors.onSurfaceVariantDark
                                    : AppColors.onSurfaceVariantLight,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          if (date != null) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 13,
                                  color: isDark
                                      ? AppColors.onSurfaceVariantDark
                                      : AppColors.onSurfaceVariantLight,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  date!,
                                  style: AppTypography.labelSmall.copyWith(
                                    color: isDark
                                        ? AppColors.onSurfaceVariantDark
                                        : AppColors.onSurfaceVariantLight,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (trailing != null) ...[
                      const SizedBox(width: 8),
                      trailing!,
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
