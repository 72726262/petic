import 'package:intl/intl.dart';

/// General utilities — locale-aware
abstract class AppUtils {
  AppUtils._();

  // ─── Date Formatting ──────────────────────────────────────────────
  static String formatDate(DateTime date, {String locale = 'ar'}) {
    return DateFormat('yyyy/MM/dd', locale).format(date);
  }

  static String formatDateTime(DateTime date, {String locale = 'ar'}) {
    return DateFormat('yyyy/MM/dd - hh:mm a', locale).format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }

  static String formatRelative(DateTime date, {bool isAr = true}) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (isAr) {
      if (diff.inMinutes < 1) return 'الآن';
      if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
      if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
      if (diff.inDays < 30) return 'منذ ${diff.inDays} يوم';
      if (diff.inDays < 365) return 'منذ ${(diff.inDays / 30).floor()} شهر';
      return 'منذ ${(diff.inDays / 365).floor()} سنة';
    } else {
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 30) return '${diff.inDays}d ago';
      if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo ago';
      return '${(diff.inDays / 365).floor()}y ago';
    }
  }

  // ─── Greeting ─────────────────────────────────────────────────────
  static String getGreeting({bool isAr = true}) {
    final hour = DateTime.now().hour;
    if (isAr) {
      if (hour < 12) return 'صباح الخير';
      if (hour < 17) return 'مساء الخير';
      return 'مساء النور';
    } else {
      if (hour < 12) return 'Good Morning';
      if (hour < 17) return 'Good Afternoon';
      return 'Good Evening';
    }
  }

  // ─── Day Name ─────────────────────────────────────────────────────
  static String getDayName({bool isAr = true}) {
    final days = isAr
        ? ['الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد']
        : ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[DateTime.now().weekday - 1];
  }

  /// Kept for legacy call sites
  static String getDayInArabic() => getDayName(isAr: true);

  // ─── Month Name ───────────────────────────────────────────────────
  static String getMonthName(int month, {bool isAr = true}) {
    final months = isAr
        ? ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
           'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر']
        : ['January', 'February', 'March', 'April', 'May', 'June',
           'July', 'August', 'September', 'October', 'November', 'December'];
    return months[month - 1];
  }

  /// Kept for legacy call sites
  static String getMonthInArabic(int month) => getMonthName(month, isAr: true);

  // ─── String Helpers ───────────────────────────────────────────────
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  // ─── Validation ───────────────────────────────────────────────────
  static String? validateEmail(String? value, {bool isAr = true}) {
    if (value == null || value.isEmpty) {
      return isAr ? 'البريد الإلكتروني مطلوب' : 'Email is required';
    }
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!regex.hasMatch(value)) {
      return isAr ? 'البريد الإلكتروني غير صحيح' : 'Invalid email address';
    }
    return null;
  }

  static String? validatePassword(String? value, {bool isAr = true}) {
    if (value == null || value.isEmpty) {
      return isAr ? 'كلمة المرور مطلوبة' : 'Password is required';
    }
    if (value.length < 6) {
      return isAr
          ? 'كلمة المرور يجب أن تكون 6 أحرف على الأقل'
          : 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? validateRequired(String? value,
      {String field = '', bool isAr = true}) {
    if (value == null || value.trim().isEmpty) {
      return isAr ? '$field مطلوب' : '$field is required';
    }
    return null;
  }

  // ─── File Size ────────────────────────────────────────────────────
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }
}
