/// Central route name constants
abstract class RouteNames {
  RouteNames._();

  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';

  // News
  static const String newsList = '/news';
  static const String newsDetail = '/news/:id';
  static const String addNews = '/news/add';
  static const String editNews = '/news/edit/:id';

  // Events
  static const String eventsList = '/events';
  static const String eventDetail = '/events/:id';

  // HR
  static const String hr = '/hr';

  // IT
  static const String it = '/it';

  // Mood
  static const String mood = '/mood';

  // Chatbot
  static const String chatbot = '/chatbot';

  // Admin
  static const String adminDashboard = '/admin';
  static const String adminManageNews = '/admin/news';
  static const String adminManageEvents = '/admin/events';
  static const String adminManageHR = '/admin/hr';
  static const String adminManageIT = '/admin/it';
  static const String adminEmployees = '/admin/employees';
  static const String adminEmployeeDetail = '/admin/employees/:id';

  // Profile
  static const String profile = '/profile';

  // Notifications
  static const String notifications = '/notifications';

  // Auth
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
}
