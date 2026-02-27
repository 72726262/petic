/// App-wide constants
abstract class AppConstants {
  AppConstants._();

  // ─── Supabase ─────────────────────────────────────────────────────
  static const String supabaseUrl = 'https://dxdhundmoszoeaxsbphd.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR4ZGh1bmRtb3N6b2VheHNicGhkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzE5ODAwNzAsImV4cCI6MjA4NzU1NjA3MH0.sYDLyVqe6WqvDVCN6SqZzpXdrhWnIYQJI2TSxiIpQto';

  // ─── Table Names ──────────────────────────────────────────────────
  static const String usersTable = 'users';
  static const String newsTable = 'news';
  static const String eventsTable = 'events';
  static const String eventVotesTable = 'event_votes';
  static const String commentsTable = 'comments';
  static const String hrContentTable = 'hr_content';
  static const String itContentTable = 'it_content';
  static const String moodsTable = 'moods';
  static const String ceoMessagesTable = 'ceo_messages';
  static const String chatMessagesTable = 'chat_messages';

  // ─── Storage Buckets ──────────────────────────────────────────────
  static const String newsBucket = 'news-images';
  static const String avatarsBucket = 'avatars';
  static const String hrFilesBucket = 'hr-files';

  // ─── Pagination ───────────────────────────────────────────────────
  static const int defaultPageSize = 20;

  // ─── App Info ─────────────────────────────────────────────────────
  static const String appName = 'Petic';
  static const String appNameEn = 'Petic';
  static const String appVersion = '1.0.0';

  // ─── User Roles ───────────────────────────────────────────────────
  static const String roleAdmin = 'admin';
  static const String roleUser = 'user';
  static const String roleHR = 'hr';
  static const String roleIT = 'it';

  // ─── SharedPrefs Keys ─────────────────────────────────────────────
  static const String prefThemeMode = 'theme_mode';
  static const String prefLanguage = 'language';
  static const String prefUserId = 'user_id';
}
