import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:employee_portal/core/error_handling/app_exception.dart';
import 'package:employee_portal/features/auth/cubit/auth_state.dart';
import 'package:employee_portal/features/auth/services/auth_service.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;

  AuthCubit({required AuthService authService})
      : _authService = authService,
        super(const AuthInitial());

  // ─── Check Current Session ────────────────────────────────────────
  Future<void> checkAuthStatus() async {
    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(user: user));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (_) {
      emit(const AuthUnauthenticated());
    }
  }

  // ─── Sign In ──────────────────────────────────────────────────────
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    emit(const AuthLoading());
    try {
      final user = await _authService.signIn(
        email: email,
        password: password,
      );
      emit(AuthAuthenticated(user: user));
    } on AuthException catch (e) {
      emit(AuthError(message: e.message));
    } on AppException catch (e) {
      emit(AuthError(message: e.message));
    } catch (e) {
      emit(
          const AuthError(message: 'حدث خطأ غير متوقع. يرجى المحاولة مجددًا.'));
    }
  }

  // ─── Sign Up ──────────────────────────────────────────────────────
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    String role = 'user',
  }) async {
    emit(const AuthLoading());
    try {
      await _authService.signUp(
        email: email,
        password: password,
        fullName: fullName,
        role: role,
      );
      // Fetch current session (which might be the admin, or the new user if auto-login happened)
      final currentUser = await _authService.getCurrentUser();
      if (currentUser != null) {
        emit(AuthAuthenticated(user: currentUser));
      } else {
        emit(const AuthUnauthenticated());
      }
    } on AuthException catch (e) {
      emit(AuthError(message: e.message));
    } on AppException catch (e) {
      emit(AuthError(message: e.message));
    } catch (e) {
      emit(
          const AuthError(message: 'حدث خطأ غير متوقع. يرجى المحاولة مجددًا.'));
    }
  }

  // ─── Reset Password ───────────────────────────────────────────────
  Future<void> resetPassword(String email) async {
    emit(const AuthLoading());
    try {
      await _authService.resetPassword(email);
      emit(const AuthPasswordResetSent());
    } on AuthException catch (e) {
      emit(AuthError(message: e.message));
    } on AppException catch (e) {
      emit(AuthError(message: e.message));
    } catch (e) {
      emit(
          const AuthError(message: 'حدث خطأ غير متوقع. يرجى المحاولة مجددًا.'));
    }
  }

  // ─── Sign Out ─────────────────────────────────────────────────────
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      emit(const AuthUnauthenticated());
    } catch (_) {
      emit(const AuthUnauthenticated());
    }
  }

  // ─── Refresh User Profile ─────────────────────────────────────────
  Future<void> refreshUser() async {
    try {
      final user = await _authService.getCurrentUser();
      if (user != null) emit(AuthAuthenticated(user: user));
    } catch (_) {}
  }
}
