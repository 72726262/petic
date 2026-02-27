import 'package:equatable/equatable.dart';
import 'package:employee_portal/features/auth/models/user_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any action
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading state during signIn/signOut
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Successfully authenticated
class AuthAuthenticated extends AuthState {
  final UserModel user;

  const AuthAuthenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

/// Unauthenticated / logged out
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Error state
class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Password reset email sent successfully
class AuthPasswordResetSent extends AuthState {
  const AuthPasswordResetSent();
}
