import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:employee_portal/core/error_handling/app_exception.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import 'package:employee_portal/core/error_handling/app_exception.dart'
    as app_ex;
import 'package:employee_portal/core/utils/app_constants.dart';
import 'package:employee_portal/features/auth/models/user_model.dart';

/// Authentication service using Supabase Auth
class AuthService {
  final SupabaseClient _client;

  AuthService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  // ─── Current Session ──────────────────────────────────────────────
  User? get currentAuthUser => _client.auth.currentUser;

  bool get isLoggedIn => _client.auth.currentSession != null;

  // ─── Sign In ──────────────────────────────────────────────────────
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      if (response.user == null) {
        throw const AuthException(
          message: 'فشل تسجيل الدخول. يرجى التحقق من البيانات.',
          code: 'AUTH_FAILED',
        );
      }

      return await _fetchUserProfile(response.user!.id);
    } on AuthException {
      rethrow;
    } on AuthApiException catch (e) {
      debugPrint('DEBUG: Unknown error during signIn: $e');
      throw AuthException(
        message: _parseAuthError(e.message),
        code: e.statusCode.toString(),
        originalError: e,
      );
    } catch (e) {
      debugPrint('DEBUG: Unknown error during signIn: $e');
      throw UnknownException(
        message: 'حدث خطأ غير متوقع أثناء تسجيل الدخول.',
        originalError: e,
      );
    }
  }

  // ─── Sign Up ──────────────────────────────────────────────────────
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    String role = 'user',
  }) async {
    try {
      print('DEBUG: Starting admin signup for email: $email, role: $role via REST API');

      final url = Uri.parse('${AppConstants.supabaseUrl}/auth/v1/signup');
      final response = await http.post(
        url,
        headers: {
          'apikey': AppConstants.supabaseAnonKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email.trim(),
          'password': password,
          'data': {
            'full_name': fullName,
            'role': role,
          },
        }),
      );

      final responseBody = jsonDecode(response.body);

      // Handle custom error codes
      if (response.statusCode >= 400) {
        final message = responseBody['msg'] ?? responseBody['message'] ?? 'فشل إنشاء الحساب';
        throw AuthException(
          message: _parseSignUpError(message),
          code: response.statusCode.toString(),
        );
      }

      print('DEBUG: Auth signup response success: \${response.statusCode}');

      // Note: User profile is automatically created by the Supabase database
      // trigger 'handle_new_user' via 'auth.users' insert.

    } on AuthException {
      rethrow;
    } catch (e) {
      debugPrint('DEBUG: Unknown error: $e');
      throw UnknownException(
        message: 'حدث خطأ غير متوقع أثناء إنشاء الحساب.',
        originalError: e,
      );
    }
  }

  // ─── Reset Password ───────────────────────────────────────────────
  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(
        email.trim(),
      );
    } on AuthException {
      rethrow;
    } on AuthApiException catch (e) {
      throw AuthException(
        message: _parseAuthError(e.message),
        code: e.statusCode.toString(),
        originalError: e,
      );
    } catch (e) {
      throw UnknownException(
        message: 'حدث خطأ أثناء إرسال رابط إعادة تعيين كلمة المرور.',
        originalError: e,
      );
    }
  }

  // ─── Sign Out ─────────────────────────────────────────────────────
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw UnknownException(
        message: 'فشل تسجيل الخروج.',
        originalError: e,
      );
    }
  }

  // ─── Get Current User Profile ─────────────────────────────────────
  Future<UserModel?> getCurrentUser() async {
    try {
      final authUser = currentAuthUser;
      if (authUser == null) return null;
      return await _fetchUserProfile(authUser.id);
    } catch (e) {
      return null;
    }
  }

  // ─── Fetch User Profile from DB ──────────────────────────────────
  Future<UserModel> _fetchUserProfile(String userId) async {
    try {
      final data = await _client
          .from(AppConstants.usersTable)
          .select()
          .eq('id', userId)
          .single();

      return UserModel.fromJson(data);
    } on PostgrestException catch (e) {
      print('DEBUG: PostgrestException code=${e.code} msg=${e.message}');
      // Handle all DB errors by falling back to auth metadata:
      // - PGRST116 = row not found
      // - 42P17 = infinite recursion in RLS policy
      // - Any other DB error
      final authUser = currentAuthUser;
      if (authUser != null) {
        final role = authUser.userMetadata?['role'] as String? ?? 'user';
        final fullName = authUser.userMetadata?['full_name'] as String? ??
            authUser.email?.split('@').first ??
            'مستخدم';

        print(
            'DEBUG: Using auth metadata fallback. role: $role, name: $fullName');

        return UserModel(
          id: authUser.id,
          email: authUser.email ?? '',
          fullName: fullName,
          role: role,
          createdAt: DateTime.tryParse(
                  authUser.createdAt.isNotEmpty ? authUser.createdAt : '') ??
              DateTime.now(),
        );
      }
      throw ServerException(
        message: 'فشل جلب بيانات المستخدم.',
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      // Last resort: try auth metadata
      final authUser = currentAuthUser;
      if (authUser != null) {
        final role = authUser.userMetadata?['role'] as String? ?? 'user';
        final fullName = authUser.userMetadata?['full_name'] as String? ??
            authUser.email?.split('@').first ??
            'مستخدم';
        print('DEBUG: Generic error fallback. Using auth metadata.');
        return UserModel(
          id: authUser.id,
          email: authUser.email ?? '',
          fullName: fullName,
          role: role,
          createdAt: DateTime.now(),
        );
      }
      throw UnknownException(
        message: 'حدث خطأ أثناء جلب بيانات المستخدم.',
        originalError: e,
      );
    }
  }

  // ─── Update User Profile ──────────────────────────────────────────
  Future<UserModel> updateProfile({
    required String userId,
    String? fullName,
    String? avatarUrl,
    String? department,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (fullName != null) updates['full_name'] = fullName;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
      if (department != null) updates['department'] = department;

      // Use the secured RPC instead of direct table update to bypass strict RLS
      final data = await _client.rpc('update_user_profile', params: {
        'p_user_id': userId,
        'p_full_name': fullName,
        'p_department': department,
        'p_avatar_url': avatarUrl,
      });

      return UserModel.fromJson(data);
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'فشل تحديث الملف الشخصي.',
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      throw UnknownException(
        message: 'حدث خطأ أثناء تحديث الملف الشخصي.',
        originalError: e,
      );
    }
  }

  // ─── Auth State Changes Stream ────────────────────────────────────
  Stream<dynamic> get authStateChanges => _client.auth.onAuthStateChange;

  // ─── Parse Auth Error ─────────────────────────────────────────────
  String _parseAuthError(String message) {
    if (message.contains('Invalid login credentials')) {
      return 'البريد الإلكتروني أو كلمة المرور غير صحيحة.';
    }
    if (message.contains('Email not confirmed')) {
      return 'يرجى تأكيد بريدك الإلكتروني أولًا.';
    }
    if (message.contains('Too many requests')) {
      return 'تجاوزت الحد المسموح من المحاولات. يرجى الانتظار.';
    }
    return 'فشل تسجيل الدخول. يرجى المحاولة مجددًا.';
  }

  // ─── Parse Sign Up Error ─────────────────────────────────────────
  String _parseSignUpError(String message) {
    if (message.contains('User already registered')) {
      return 'هذا البريد الإلكتروني مسجل بالفعل.';
    }
    if (message.contains('Password should be at least')) {
      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل.';
    }
    if (message.contains('Invalid email')) {
      return 'البريد الإلكتروني غير صالح.';
    }
    return 'فشل إنشاء الحساب. يرجى المحاولة مجددًا.';
  }
}
