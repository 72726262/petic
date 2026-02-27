import 'package:employee_portal/core/theme/app_shadows.dart';
import 'package:flutter/material.dart';
import 'package:employee_portal/core/theme/app_colors.dart';
import 'package:employee_portal/core/theme/app_typography.dart';
import 'package:employee_portal/core/theme/app_spacing.dart';
import 'package:employee_portal/core/theme/app_radius.dart';
import 'package:intl/intl.dart';

/// A reusable date filter bar widget.
/// Shows "كل المحتوى" chip + selected date chip + a calendar icon button.
/// Calls [onDateChanged] with the new date, or null to clear the filter.
class DateFilterBar extends StatelessWidget {
  final DateTime? selectedDate;
  final Color accentColor;
  final ValueChanged<DateTime?> onDateChanged;

  const DateFilterBar({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
    this.accentColor = AppColors.primary,
  });

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: DateTime(2020),
      lastDate: now,
      locale: const Locale('ar'),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.fromSeed(
            seedColor: accentColor,
            brightness: Theme.of(ctx).brightness,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) onDateChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isFiltered = selectedDate != null;

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        boxShadow: isDark ? AppShadows.softDark : AppShadows.soft,
      ),
      child: Row(
        children: [
          // ── "All" chip ──
          _FilterChip(
            label: 'كل المحتوى',
            selected: !isFiltered,
            accentColor: accentColor,
            onTap: () => onDateChanged(null),
          ),
          const SizedBox(width: AppSpacing.sm),

          // ── Selected date chip (shown when date is set) ──
          if (isFiltered) ...[
            _FilterChip(
              label: DateFormat('dd MMM yyyy', 'ar').format(selectedDate!),
              selected: true,
              accentColor: accentColor,
              trailing: GestureDetector(
                onTap: () => onDateChanged(null),
                child: Icon(Icons.close_rounded, size: 14, color: accentColor),
              ),
              onTap: () => _pickDate(context),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],

          const Spacer(),

          // ── Calendar picker button ──
          GestureDetector(
            onTap: () => _pickDate(context),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isFiltered
                    ? accentColor.withOpacity(0.12)
                    : (isDark
                        ? AppColors.surfaceVariantDark
                        : AppColors.surfaceVariantLight),
                borderRadius: AppRadius.mdBorderRadius,
                border: isFiltered
                    ? Border.all(color: accentColor.withOpacity(0.3))
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_month_rounded,
                    size: 16,
                    color: isFiltered
                        ? accentColor
                        : (isDark
                            ? AppColors.onSurfaceVariantDark
                            : AppColors.onSurfaceVariantLight),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'اختر يوماً',
                    style: AppTypography.labelSmall.copyWith(
                      color: isFiltered
                          ? accentColor
                          : (isDark
                              ? AppColors.onSurfaceVariantDark
                              : AppColors.onSurfaceVariantLight),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color accentColor;
  final VoidCallback onTap;
  final Widget? trailing;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.accentColor,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? accentColor.withOpacity(0.12)
              : (isDark
                  ? AppColors.surfaceVariantDark
                  : AppColors.surfaceVariantLight),
          borderRadius: AppRadius.fullBorderRadius,
          border: selected
              ? Border.all(color: accentColor.withOpacity(0.4))
              : Border.all(color: Colors.transparent),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: selected
                    ? accentColor
                    : (isDark
                        ? AppColors.onSurfaceVariantDark
                        : AppColors.onSurfaceVariantLight),
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 4),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Helper: returns true if [itemDate] matches [filterDate] (same calendar day)
bool matchesDateFilter(DateTime itemDate, DateTime? filterDate) {
  if (filterDate == null) return true;
  return itemDate.year == filterDate.year &&
      itemDate.month == filterDate.month &&
      itemDate.day == filterDate.day;
}
