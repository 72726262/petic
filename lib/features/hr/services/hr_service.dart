import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:employee_portal/core/error_handling/app_exception.dart';
import 'package:employee_portal/core/utils/app_constants.dart';
import 'package:employee_portal/features/hr/models/hr_content_model.dart';

class HRService {
  final SupabaseClient _client;
  HRService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  Future<List<HRContentModel>> fetchByCategory(String category) async {
    try {
      final data = await _client
          .from(AppConstants.hrContentTable)
          .select()
          .eq('category', category)
          .order('created_at', ascending: false);

      return (data as List)
          .map((e) => HRContentModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: 'فشل تحميل بيانات الموارد البشرية.', code: e.code, originalError: e);
    } catch (e) {
      throw UnknownException(message: 'خطأ غير متوقع.', originalError: e);
    }
  }

  Future<List<HRContentModel>> fetchAll() async {
    try {
      final data = await _client
          .from(AppConstants.hrContentTable)
          .select()
          .order('created_at', ascending: false);

      return (data as List)
          .map((e) => HRContentModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: 'فشل تحميل بيانات الموارد البشرية.', code: e.code, originalError: e);
    } catch (e) {
      throw UnknownException(message: 'خطأ غير متوقع.', originalError: e);
    }
  }

  /// Send an HR announcement visible in real-time to all users.
  /// Inserts into hr_content (policy category), which triggers the
  /// NotificationOverlayCubit Realtime listener app-wide.
  Future<void> sendAnnouncement({
    required String title,
    required String description,
    String category = 'policy',
  }) async {
    try {
      await _client.from(AppConstants.hrContentTable).insert({
        'title': title,
        'description': description,
        'category': category,
      });
    } on PostgrestException catch (e) {
      throw ServerException(
          message: 'فشل إرسال الإعلان.',
          code: e.code,
          originalError: e);
    } catch (e) {
      throw UnknownException(message: 'خطأ غير متوقع.', originalError: e);
    }
  }

  /// Fetch all users (for HR to target specific employee warning)
  Future<List<Map<String, dynamic>>> fetchUsers() async {
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
