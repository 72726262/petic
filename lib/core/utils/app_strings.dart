import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:employee_portal/core/locale/locale_cubit.dart';

/// Centralized bilingual strings helper.
/// Usage: AppStrings.of(context).profileTitle
class AppStrings {
  final bool isAr;
  const AppStrings._(this.isAr);

  factory AppStrings.of(BuildContext context) {
    final locale = context.read<LocaleCubit>().state;
    return AppStrings._(locale.languageCode == 'ar');
  }

  // ─── App General ─────────────────────────────────────────────────
  String get appName => isAr ? 'البوابة الداخلية' : 'Employee Portal';
  String get loading => isAr ? 'جارٍ التحميل...' : 'Loading...';
  String get retry => isAr ? 'إعادة المحاولة' : 'Retry';
  String get save => isAr ? 'حفظ' : 'Save';
  String get cancel => isAr ? 'إلغاء' : 'Cancel';
  String get delete => isAr ? 'حذف' : 'Delete';
  String get edit => isAr ? 'تعديل' : 'Edit';
  String get add => isAr ? 'إضافة' : 'Add';
  String get confirm => isAr ? 'تأكيد' : 'Confirm';
  String get yes => isAr ? 'نعم' : 'Yes';
  String get no => isAr ? 'لا' : 'No';
  String get seeAll => isAr ? 'عرض الكل' : 'See All';
  String get readMore => isAr ? 'اقرأ المزيد' : 'Read More';
  String get send => isAr ? 'إرسال' : 'Send';
  String get noData => isAr ? 'لا توجد بيانات متاحة' : 'No data available';
  String get download => isAr ? 'تحميل' : 'Download';
  String get preview => isAr ? 'معاينة' : 'Preview';
  String get saveChanges => isAr ? 'حفظ التغييرات' : 'Save Changes';
  String get unknownError => isAr ? 'حدث خطأ غير متوقع' : 'An unexpected error occurred';
  String get error => isAr ? 'حدث خطأ' : 'An error occurred';
  String get networkError => isAr ? 'لا يوجد اتصال بالإنترنت' : 'No internet connection';
  String get serverError => isAr ? 'خطأ في الخادم' : 'Server error';

  // ─── Success Messages ─────────────────────────────────────────────
  String get saveSuccess => isAr ? 'تم الحفظ بنجاح' : 'Saved successfully';
  String get deleteSuccess => isAr ? 'تم الحذف بنجاح' : 'Deleted successfully';
  String get addSuccess => isAr ? 'تمت الإضافة بنجاح' : 'Added successfully';
  String get updateSuccess => isAr ? 'تم التحديث بنجاح' : 'Updated successfully';
  String get profileSaveSuccess =>
      isAr ? 'تم حفظ التغييرات بنجاح.' : 'Changes saved successfully.';
  String get profileSaveError =>
      isAr ? 'فشل في حفظ التغييرات.' : 'Failed to save changes.';
  String get deleteConfirm =>
      isAr ? 'هل أنت متأكد من الحذف؟' : 'Are you sure you want to delete?';

  // ─── Auth Strings ─────────────────────────────────────────────────
  String get login => isAr ? 'تسجيل الدخول' : 'Sign In';
  String get logout => isAr ? 'تسجيل الخروج' : 'Sign Out';
  String get loginSubtitle =>
      isAr ? 'سجّل دخولك للمتابعة' : 'Sign in to continue';
  String get email => isAr ? 'البريد الإلكتروني' : 'Email';
  String get emailHint =>
      isAr ? 'البريد الإلكتروني' : 'Enter your email';
  String get password => isAr ? 'كلمة المرور' : 'Password';
  String get passwordHint =>
      isAr ? 'كلمة المرور' : 'Enter your password';
  String get forgotPassword =>
      isAr ? 'نسيت كلمة المرور؟' : 'Forgot password?';
  String get copyright =>
      isAr ? 'جميع الحقوق محفوظة © 2025' : '© 2025 All Rights Reserved';
  String get appSubtitle =>
      isAr ? 'بوابة الموظفين الداخلية' : 'Internal Employee Portal';
  String get createAccount => isAr ? 'إنشاء حساب' : 'Create Account';
  String get createAccountSubtitle =>
      isAr ? 'انضم إلى بوابة الموظفين' : 'Join the Employee Portal';
  String get fullName => isAr ? 'الاسم الكامل' : 'Full Name';
  String get confirmPassword =>
      isAr ? 'تأكيد كلمة المرور' : 'Confirm Password';
  String get selectRole => isAr ? 'اختر الدور' : 'Select Role';
  String get haveAccount =>
      isAr ? 'لديك حساب بالفعل؟ ' : 'Already have an account? ';
  String get signIn => isAr ? 'تسجيل الدخول' : 'Sign In';
  String get accessDenied =>
      isAr ? 'غير مصرح لك بالوصول لهذه الصفحة.' : 'Access denied.';
  String get adminOnlyPage =>
      isAr ? 'هذه الصفحة مخصصة للمسؤولين فقط.' : 'This page is for admins only.';
  String get accountCreatedSuccess =>
      isAr ? 'تم إنشاء الحساب بنجاح!' : 'Account created successfully!';

  // ─── Role Labels ──────────────────────────────────────────────────
  String get roleUser => isAr ? 'مستخدم عادي' : 'Employee';
  String get roleAdmin => isAr ? 'مسؤول' : 'Admin';
  String get roleHR => isAr ? 'موارد بشرية' : 'Human Resources';
  String get roleIT => isAr ? 'تقنية المعلومات' : 'Information Technology';

  String roleLabel(String role) {
    switch (role) {
      case 'admin':
        return isAr ? 'مدير النظام' : 'System Admin';
      case 'hr':
        return isAr ? 'الموارد البشرية' : 'Human Resources';
      case 'it':
        return isAr ? 'تقنية المعلومات' : 'Information Technology';
      default:
        return isAr ? 'موظف' : 'Employee';
    }
  }

  // ─── Validation ───────────────────────────────────────────────────
  String get emailRequired =>
      isAr ? 'البريد الإلكتروني مطلوب' : 'Email is required';
  String get emailInvalid =>
      isAr ? 'البريد الإلكتروني غير صحيح' : 'Invalid email address';
  String get passwordRequired =>
      isAr ? 'كلمة المرور مطلوبة' : 'Password is required';
  String get passwordMin =>
      isAr ? 'كلمة المرور يجب أن تكون 6 أحرف على الأقل' : 'Password must be at least 6 characters';
  String get nameRequired =>
      isAr ? 'يرجى إدخال الاسم' : 'Please enter your name';
  String get confirmPasswordRequired =>
      isAr ? 'يرجى تأكيد كلمة المرور' : 'Please confirm your password';
  String get passwordsDoNotMatch =>
      isAr ? 'كلمات المرور غير متطابقة' : 'Passwords do not match';

  String fieldRequired(String field) =>
      isAr ? '$field مطلوب' : '$field is required';

  // ─── Navigation / Tabs ────────────────────────────────────────────
  String get home => isAr ? 'الرئيسية' : 'Home';
  String get news => isAr ? 'الأخبار' : 'News';
  String get events => isAr ? 'الفعاليات' : 'Events';
  String get hr => isAr ? 'الموارد البشرية' : 'Human Resources';
  String get it => isAr ? 'تقنية المعلومات' : 'Information Technology';
  String get mood => isAr ? 'مزاجي' : 'My Mood';
  String get chatbot => isAr ? 'المساعد الذكي' : 'Smart Assistant';
  String get admin => isAr ? 'لوحة التحكم' : 'Admin Panel';
  String get profile => isAr ? 'الملف الشخصي' : 'Profile';
  String get notifications => isAr ? 'الإشعارات' : 'Notifications';
  String get settings => isAr ? 'الإعدادات' : 'Settings';

  // ─── Home Screen ──────────────────────────────────────────────────
  String get quickActions => isAr ? 'الوصول السريع' : 'Quick Actions';
  String get latestNews => isAr ? 'آخر الأخبار' : 'Latest News';
  String get upcomingEvents => isAr ? 'الفعاليات القادمة' : 'Upcoming Events';
  String get noNewsYet => isAr ? 'لا توجد أخبار بعد' : 'No news yet';
  String get noEventsYet =>
      isAr ? 'لا توجد فعاليات قادمة' : 'No upcoming events';
  String get ceoMessage => isAr ? 'كلمة المدير العام' : 'CEO Message';
  String get ceoMessageSubtitle =>
      isAr ? 'رسالة خاصة للموظفين' : 'A special message for employees';
  String get howAreYou =>
      isAr ? 'كيف حالك اليوم؟' : 'How are you today?';
  String get usefulLinks => isAr ? 'روابط مفيدة' : 'Useful Links';
  String get employeeFallback => isAr ? 'الموظف' : 'Employee';
  String get yourLocation => isAr ? 'موقعك الحالي' : 'Your Location';
  String get riyadh => isAr ? 'الرياض' : 'Riyadh';

  // Weather labels
  String weatherLabel(int code, String city) {
    if (code == 0) return isAr ? 'مشمس صافٍ • $city' : 'Clear Sky • $city';
    if (code <= 3) return isAr ? 'غائم جزئياً • $city' : 'Partly Cloudy • $city';
    if (code <= 48) return isAr ? 'ضبابي • $city' : 'Foggy • $city';
    if (code <= 67) return isAr ? 'ممطر • $city' : 'Rainy • $city';
    if (code <= 77) return isAr ? 'ثلجي • $city' : 'Snowy • $city';
    return isAr ? 'عواصف رعدية • $city' : 'Thunderstorm • $city';
  }

  String get weatherLoading =>
      isAr ? 'جارٍ التحميل...' : 'Loading...';

  // Quick action labels
  String get hrLabel => isAr ? 'الموارد البشرية' : 'HR';
  String get itLabel => isAr ? 'تقنية المعلومات' : 'IT';
  String get newsLabel => isAr ? 'الأخبار' : 'News';
  String get eventsLabel => isAr ? 'الفعاليات' : 'Events';
  String get moodLabel => isAr ? 'مزاجي' : 'My Mood';
  String get chatbotLabel => isAr ? 'المساعد الذكي' : 'Assistant';

  // ─── Profile Screen ───────────────────────────────────────────────
  String get myProfile => isAr ? 'ملفي الشخصي' : 'My Profile';
  String get nameLabel => isAr ? 'الاسم' : 'Name';
  String get emailLabel => isAr ? 'البريد الإلكتروني' : 'Email';
  String get departmentLabel => isAr ? 'القسم' : 'Department';
  String get jobRoleLabel => isAr ? 'الدور الوظيفي' : 'Job Role';
  String get fullNameLabel => isAr ? 'الاسم الكامل' : 'Full Name';
  String get notSpecified => isAr ? 'غير محدد' : 'Not specified';
  String get logoutTitle => isAr ? 'تسجيل الخروج' : 'Sign Out';
  String get logoutConfirm =>
      isAr ? 'هل تريد تسجيل الخروج من الحساب؟' : 'Do you want to sign out?';
  String get logoutButton => isAr ? 'خروج' : 'Sign Out';
  String get themeLabel => isAr ? 'المظهر' : 'Theme';
  String get darkModeLabel => isAr ? 'الوضع الليلي' : 'Dark Mode';
  String get lightModeLabel => isAr ? 'الوضع النهاري' : 'Light Mode';
  String get languageLabel => isAr ? 'اللغة' : 'Language';
  String get arabicLabel => isAr ? 'العربية' : 'Arabic';
  String get englishLabel => isAr ? 'الإنجليزية' : 'English';
  String get currentLangLabel => isAr ? 'العربية' : 'English';

  // ─── Greeting ─────────────────────────────────────────────────────
  String get greeting {
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

  // ─── Day / Month Names ────────────────────────────────────────────
  String get dayName {
    final days = isAr
        ? ['الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد']
        : ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[DateTime.now().weekday - 1];
  }

  String monthName(int month) {
    final months = isAr
        ? ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
           'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر']
        : ['January', 'February', 'March', 'April', 'May', 'June',
           'July', 'August', 'September', 'October', 'November', 'December'];
    return months[month - 1];
  }

  String formatRelative(DateTime date) {
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

  // ─── Mood ─────────────────────────────────────────────────────────
  String get excellent => isAr ? 'ممتاز' : 'Excellent';
  String get good => isAr ? 'جيد' : 'Good';
  String get neutral => isAr ? 'محايد' : 'Neutral';
  String get bad => isAr ? 'سيئ' : 'Bad';
  String get terrible => isAr ? 'رديء' : 'Terrible';
  String get moodStats => isAr ? 'إحصائيات المزاج' : 'Mood Statistics';
  String get moodSubmitted =>
      isAr ? 'تم تسجيل مزاجك بنجاح' : 'Your mood has been recorded';
  String get moodQuestion => isAr ? 'كيف حالك اليوم؟' : 'How are you today?';
  String get moodScreenTitle => isAr ? 'مزاجي' : 'My Mood';
  String get submitMood => isAr ? 'تسجيل المزاج' : 'Submit Mood';
  String get noMoodDataYet => isAr ? 'لا توجد بيانات مزاج بعد' : 'No mood data yet';
  String get alreadySubmittedToday =>
      isAr ? 'لقد سجّلت مزاجك اليوم بالفعل' : 'You already submitted your mood today';

  // ─── News ─────────────────────────────────────────────────────────
  String get newsScreenTitle => isAr ? 'الأخبار' : 'News';
  String get noNewsAvailable => isAr ? 'لا توجد أخبار متاحة' : 'No news available';
  String get addNews => isAr ? 'إضافة خبر' : 'Add News';
  String get editNews => isAr ? 'تعديل الخبر' : 'Edit News';
  String get manageNews => isAr ? 'إدارة الأخبار' : 'Manage News';
  String get newsTitle => isAr ? 'عنوان الخبر' : 'News Title';
  String get newsContent => isAr ? 'تفاصيل الخبر' : 'News Content';

  // ─── Events ──────────────────────────────────────────────────────
  String get eventsScreenTitle => isAr ? 'الفعاليات' : 'Events';
  String get noEventsAvailable =>
      isAr ? 'لا توجد فعاليات متاحة' : 'No events available';
  String get addEvent => isAr ? 'إضافة فعالية' : 'Add Event';
  String get editEvent => isAr ? 'تعديل الفعالية' : 'Edit Event';
  String get manageEvents => isAr ? 'إدارة الفعاليات' : 'Manage Events';
  String get eventTitle => isAr ? 'عنوان الفعالية' : 'Event Title';
  String get eventDate => isAr ? 'تاريخ الفعالية' : 'Event Date';
  String get eventLocation => isAr ? 'مكان الفعالية' : 'Event Location';
  String get eventDescription => isAr ? 'وصف الفعالية' : 'Event Description';
  String get registerEvent => isAr ? 'التسجيل' : 'Register';
  String get alreadyRegistered =>
      isAr ? 'مسجّل بالفعل' : 'Already Registered';

  // ─── HR and IT Shared ─────────────────────────────────────────────
  String get hrScreenTitle => isAr ? 'الموارد البشرية' : 'Human Resources';
  String get itScreenTitle => isAr ? 'تقنية المعلومات' : 'Information Technology';
  String get manageHR => isAr ? 'إدارة الموارد البشرية' : 'Manage HR Content';
  String get manageIT => isAr ? 'إدارة تقنية المعلومات' : 'Manage IT Content';
  String get policies => isAr ? 'السياسات' : 'Policies';
  String get training => isAr ? 'التدريب' : 'Training';
  String get jobs => isAr ? 'الوظائف' : 'Jobs';
  String get alerts => isAr ? 'التنبيهات' : 'Alerts';
  String get tips => isAr ? 'النصائح' : 'Tips';

  // ─── Chatbot ─────────────────────────────────────────────────────
  String get chatbotScreenTitle => isAr ? 'المساعد الذكي' : 'Smart Assistant';
  String get chatbotWelcome =>
      isAr ? 'مرحبًا! كيف يمكنني مساعدتك؟' : 'Hello! How can I help you?';
  String get typeMessage => isAr ? 'اكتب رسالتك...' : 'Type your message...';
  String get typing => isAr ? 'جارٍ الكتابة...' : 'Typing...';

  // ─── Admin ───────────────────────────────────────────────────────
  String get adminDashboard => isAr ? 'لوحة التحكم' : 'Admin Dashboard';
  String get totalUsers => isAr ? 'إجمالي المستخدمين' : 'Total Users';
  String get totalNews => isAr ? 'إجمالي الأخبار' : 'Total News';
  String get totalEvents => isAr ? 'إجمالي الفعاليات' : 'Total Events';
  String get employees => isAr ? 'الموظفون' : 'Employees';
  String get employeeList => isAr ? 'قائمة الموظفين' : 'Employee List';
  String get employeeDetail => isAr ? 'تفاصيل الموظف' : 'Employee Details';
  String get department => isAr ? 'القسم' : 'Department';
  String get role => isAr ? 'الدور' : 'Role';
  String get searchEmployee =>
      isAr ? 'ابحث عن موظف...' : 'Search employees...';
  String get noEmployeesFound =>
      isAr ? 'لا يوجد موظفون' : 'No employees found';

  // ─── Notifications ───────────────────────────────────────────────
  String get notificationsTitle => isAr ? 'الإشعارات' : 'Notifications';
  String get noNotifications =>
      isAr ? 'لا توجد إشعارات' : 'No notifications';
  String get markAllRead => isAr ? 'تعيين الكل كمقروء' : 'Mark All as Read';

  // ─── Polls / Voting ──────────────────────────────────────────────
  String get vote => isAr ? 'تصويت' : 'Vote';
  String get voteSuccess => isAr ? 'تم تسجيل تصويتك' : 'Vote recorded';
  String get alreadyVoted => isAr ? 'لقد صوّتت مسبقًا' : 'You have already voted';
  String get totalVotes => isAr ? 'إجمالي الأصوات' : 'Total Votes';
  String get submittingVote => isAr ? 'جارٍ تسجيل التصويت...' : 'Submitting vote...';
  String get selectOption => isAr ? 'اختر خيارًا' : 'Select an option';
  String get pollOptions => isAr ? 'خيارات الاستطلاع' : 'Poll Options';

  // ─── Comments ────────────────────────────────────────────────────
  String get comment => isAr ? 'تعليق' : 'Comment';
  String get comments => isAr ? 'التعليقات' : 'Comments';
  String get addComment => isAr ? 'أضف تعليقًا' : 'Add a comment';

  // ─── Forgot Password ─────────────────────────────────────────────
  String get forgotPasswordTitle =>
      isAr ? 'نسيت كلمة المرور' : 'Forgot Password';
  String get forgotPasswordSubtitle =>
      isAr ? 'أدخل بريدك الإلكتروني لإعادة تعيين كلمة المرور'
           : 'Enter your email to reset your password';
  String get sendResetLink => isAr ? 'إرسال رابط إعادة التعيين' : 'Send Reset Link';
  String get resetEmailSent =>
      isAr ? 'تم إرسال رابط إعادة التعيين على بريدك الإلكتروني'
           : 'Reset link sent to your email';
  String get backToLogin => isAr ? 'العودة لتسجيل الدخول' : 'Back to Login';

  // ─── Validation helpers (as functions) ───────────────────────────
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return emailRequired;
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!regex.hasMatch(value)) return emailInvalid;
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return passwordRequired;
    if (value.length < 6) return passwordMin;
    return null;
  }

  String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null ? fieldRequired(fieldName) : (isAr ? 'هذا الحقل مطلوب' : 'This field is required');
    }
    return null;
  }
}
