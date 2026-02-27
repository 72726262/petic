import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:employee_portal/core/error_handling/app_exception.dart';
import 'package:employee_portal/core/utils/app_constants.dart';
import 'package:employee_portal/features/mood/models/mood_model.dart';

/// A mood entry enriched with the employee's name (for admin view)
class AdminMoodEntry {
  final MoodModel mood;
  final String userId;
  final String employeeName;
  final String employeeEmail;

  const AdminMoodEntry({
    required this.mood,
    required this.userId,
    required this.employeeName,
    required this.employeeEmail,
  });
}

class MoodService {
  final SupabaseClient _client;
  MoodService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  /// Fetch mood history for the current user (last 30 days)
  Future<List<MoodModel>> fetchHistory(String userId) async {
    try {
      final since = DateTime.now().subtract(const Duration(days: 30));
      final data = await _client
          .from(AppConstants.moodsTable)
          .select()
          .eq('user_id', userId)
          .gte('created_at', since.toIso8601String())
          .order('created_at', ascending: false);

      return (data as List)
          .map((e) => MoodModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: 'فشل تحميل سجل المزاج.', code: e.code, originalError: e);
    } catch (e) {
      throw UnknownException(message: 'خطأ غير متوقع.', originalError: e);
    }
  }

  /// Fetch today's mood for user (if submitted)
  Future<MoodModel?> fetchTodayMood(String userId) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final data = await _client
          .from(AppConstants.moodsTable)
          .select()
          .eq('user_id', userId)
          .gte('created_at', startOfDay.toIso8601String())
          .limit(1);

      if ((data as List).isEmpty) return null;
      return MoodModel.fromJson(data.first as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// Submit or update today's mood
  Future<MoodModel> submitMood({
    required String userId,
    required MoodLevel mood,
    String? note,
  }) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);

      // Check if already submitted today
      final existing = await _client
          .from(AppConstants.moodsTable)
          .select('id')
          .eq('user_id', userId)
          .gte('created_at', startOfDay.toIso8601String())
          .limit(1);

      Map<String, dynamic> result;
      final moodKey = MoodModel(
              id: '', userId: userId, mood: mood, createdAt: DateTime.now())
          .moodKey;

      if ((existing as List).isNotEmpty) {
        // Update existing
        result = await _client
            .from(AppConstants.moodsTable)
            .update({'mood': moodKey, 'note': note})
            .eq('id', existing.first['id'] as String)
            .select()
            .single();
      } else {
        // Insert new
        result = await _client
            .from(AppConstants.moodsTable)
            .insert({
              'user_id': userId,
              'mood': moodKey,
              'note': note,
            })
            .select()
            .single();
      }
      return MoodModel.fromJson(result);
    } on PostgrestException catch (e) {
      throw ServerException(message: 'فشل تسجيل المزاج.', code: e.code, originalError: e);
    } catch (e) {
      throw UnknownException(message: 'خطأ غير متوقع.', originalError: e);
    }
  }

  /// [Admin only] Fetch all employees' moods for a specific date
  Future<List<AdminMoodEntry>> fetchAllMoodsForDate(DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final data = await _client
          .from(AppConstants.moodsTable)
          .select('*, users(full_name, email)')
          .gte('created_at', startOfDay.toIso8601String())
          .lt('created_at', endOfDay.toIso8601String())
          .order('created_at', ascending: false);

      return (data as List).map((e) {
        final map = e as Map<String, dynamic>;
        final userMap = map['users'] as Map<String, dynamic>? ?? {};
        return AdminMoodEntry(
          mood: MoodModel.fromJson(map),
          userId: map['user_id'] as String? ?? '',
          employeeName: userMap['full_name'] as String? ?? 'موظف',
          employeeEmail: userMap['email'] as String? ?? '',
        );
      }).toList();
    } on PostgrestException catch (e) {
      throw ServerException(
          message: 'فشل تحميل مزاج الموظفين.',
          code: e.code,
          originalError: e);
    } catch (e) {
      throw UnknownException(message: 'خطأ غير متوقع.', originalError: e);
    }
  }

  /// Fetch all users for "not submitted" tracking in admin view
  Future<List<Map<String, dynamic>>> fetchAllUsers() async {
    try {
      final data = await _client
          .from(AppConstants.usersTable)
          .select('id, full_name, email, role')
          .order('full_name');
      return (data as List).cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }
}
