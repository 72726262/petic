import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:employee_portal/core/error_handling/failure.dart';
import 'package:employee_portal/core/theme/app_colors.dart';
import 'package:employee_portal/core/theme/app_typography.dart';
import 'package:employee_portal/core/theme/app_radius.dart';

/// Centralized error display utilities
class ErrorHandler {
  ErrorHandler._();

  // ─── Snackbar ─────────────────────────────────────────────────────
  static void showErrorSnackbar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style:
                    AppTypography.bodyMedium.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: AppRadius.mdBorderRadius),
        duration: duration,
        action: actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: Colors.white,
                onPressed: onAction ?? () {},
              )
            : null,
      ),
    );
  }

  static void showSuccessSnackbar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline,
                color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style:
                    AppTypography.bodyMedium.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: AppRadius.mdBorderRadius),
        duration: duration,
      ),
    );
  }

  static void showWarningSnackbar(
    BuildContext context,
    String message,
  ) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber_outlined,
                color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style:
                    AppTypography.bodyMedium.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.warning,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: AppRadius.mdBorderRadius),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ─── Failure to User-Friendly String ──────────────────────────────
  static String failureToMessage(Failure failure) {
    return switch (failure) {
      AuthFailure f => f.message,
      NetworkFailure _ =>
        'لا يوجد اتصال بالإنترنت. يرجى التحقق من الاتصال.',
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
