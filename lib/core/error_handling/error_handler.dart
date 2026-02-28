import 'package:employee_portal/core/theme/app_shadows.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:employee_portal/core/error_handling/failure.dart';
import 'package:employee_portal/core/theme/app_colors.dart';
import 'package:employee_portal/core/theme/app_typography.dart';
import 'package:employee_portal/core/theme/app_radius.dart';

/// Centralized error display utilities
class ErrorHandler {
  ErrorHandler._();

  // ─── Snackbar Custom Builder ──────────────────────────────────────
  static void _showCustomSnackbar(
    BuildContext context, {
    required String message,
    required Color iconColor,
    required Color iconBgColor,
    required IconData icon,
    required Duration duration,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        padding: EdgeInsets.zero,
        duration: duration,
        content: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: AppRadius.lgBorderRadius,
            boxShadow: isDark ? AppShadows.floating : AppShadows.soft,
            border: Border.all(
              color: iconColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.onSurfaceDark
                        : AppColors.onSurfaceLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    onAction();
                  },
                  child: Text(
                    actionLabel,
                    style: AppTypography.labelMedium.copyWith(
                      color: iconColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ]
            ],
          ),
        ),
      ),
    );
  }

  // ─── Snackbar ─────────────────────────────────────────────────────
  static void showErrorSnackbar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    _showCustomSnackbar(
      context,
      message: message,
      iconColor: AppColors.error,
      iconBgColor: AppColors.errorLight,
      icon: Icons.error_outline_rounded,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static void showSuccessSnackbar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _showCustomSnackbar(
      context,
      message: message,
      iconColor: AppColors.success,
      iconBgColor: AppColors.successLight,
      icon: Icons.check_circle_outline_rounded,
      duration: duration,
    );
  }

  static void showWarningSnackbar(
    BuildContext context,
    String message,
  ) {
    _showCustomSnackbar(
      context,
      message: message,
      iconColor: AppColors.warning,
      iconBgColor: AppColors.warningLight,
      icon: Icons.warning_amber_rounded,
      duration: const Duration(seconds: 4),
    );
  }

  // ─── Failure to User-Friendly String ──────────────────────────────
  static String failureToMessage(Failure failure) {
    return switch (failure) {
      AuthFailure f => f.message,
      NetworkFailure _ => 'لا يوجد اتصال بالإنترنت. يرجى التحقق من الاتصال.',
      ServerFailure f => 'خطأ في الخادم: ${f.message}',
      ParseFailure _ => 'خطأ في معالجة البيانات. يرجى المحاولة مجددًا.',
      NotFoundFailure _ => 'البيانات المطلوبة غير موجودة.',
      PermissionFailure _ => 'ليس لديك صلاحية الوصول لهذا المحتوى.',
      CacheFailure _ => 'خطأ في قاعدة البيانات المحلية.',
      _ => 'حدث خطأ غير متوقع. يرجى المحاولة مجددًا.',
    };
  }

  // ─── Clipboard Copy ───────────────────────────────────────────────
  static void copyError(BuildContext context, String error) {
    Clipboard.setData(ClipboardData(text: error));
    showSuccessSnackbar(context, 'تم نسخ رسالة الخطأ');
  }
}
