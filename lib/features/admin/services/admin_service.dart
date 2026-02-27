import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:employee_portal/core/error_handling/app_exception.dart';
import 'package:employee_portal/core/utils/app_constants.dart';
import 'package:employee_portal/features/auth/models/user_model.dart';

class AdminStats {
  final int usersCount;
  final int newsCount;
  final int eventsCount;

  const AdminStats({
    required this.usersCount,
    required this.newsCount,
    required this.eventsCount,
  });
}

class AdminService {
  final SupabaseClient _client;
  AdminService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  // ─── Fetch Dashboard Stats ───────────────────────────────────────────
  Future<AdminStats> fetchStats() async {
    try {
      // Count each table independently using .count()
      int usersCount = 0;
      int newsCount = 0;
      int eventsCount = 0;

      final usersData = await _client
          .from(AppConstants.usersTable)
          .select('id');
      usersCount = (usersData as List).length;

      final newsData = await _client
          .from(AppConstants.newsTable)
          .select('id');
      newsCount = (newsData as List).length;

      final eventsData = await _client
          .from(AppConstants.eventsTable)
          .select('id');
      eventsCount = (eventsData as List).length;

      return AdminStats(
        usersCount: usersCount,
        newsCount: newsCount,
        eventsCount: eventsCount,
      );
    } catch (e) {
      return const AdminStats(usersCount: 0, newsCount: 0, eventsCount: 0);
    }
  }

  // ─── Fetch All Users ────────────────────────────────────────────────
  Future<List<UserModel>> fetchAllUsers() async {
    try {
      final data = await _client
          .from(AppConstants.usersTable)
          .select()
          .order('created_at', ascending: false);
      return (data as List)
          .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(
          message: 'فشل تحميل قائمة الموظفين.',
          code: e.code,
          originalError: e);
    } catch (e) {
      throw UnknownException(message: 'خطأ غير متوقع.', originalError: e);
    }
  }

  // ─── Update User Role via RPC ───────────────────────────────────────────
  Future<void> updateUserRole(
      {required String userId, required String role}) async {
    try {
      // Uses a SECURITY DEFINER function to bypass RLS
      await _client.rpc('update_user_role', params: {
        'target_user_id': userId,
        'new_role': role,
      });
    } on PostgrestException catch (e) {
      throw ServerException(
          message: 'فشل تحديث صلاحية الموظف. تأكد من صلاحيات المدير.',
          code: e.code,
          originalError: e);
    } catch (e) {
      throw UnknownException(message: 'خطأ غير متوقع.', originalError: e);
    }
  }

  // ─── Delete User ────────────────────────────────────────────────────
  Future<void> deleteUser(String userId) async {
    try {
      await _client.from(AppConstants.usersTable).delete().eq('id', userId);
    } on PostgrestException catch (e) {
      throw ServerException(
          message: 'فشل حذف الموظف.', code: e.code, originalError: e);
    } catch (e) {
      throw UnknownException(message: 'خطأ غير متوقع.', originalError: e);
    }
  }
}
