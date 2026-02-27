import 'package:equatable/equatable.dart';

// Base class for all application exceptions
abstract class AppException extends Equatable implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException({required this.message, this.code, this.originalError});

  @override
  List<Object?> get props => [message, code, originalError];

  @override
  String toString() => 'AppException(message: $message, code: $code)';
}

/// Authentication related exceptions
class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Network/connectivity exceptions
class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Server exceptions (5xx)
class ServerException extends AppException {
  const ServerException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Data parsing/mapping exceptions
class ParseException extends AppException {
  const ParseException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Not found exceptions (404)
class NotFoundException extends AppException {
  const NotFoundException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Permission/access exceptions
class PermissionException extends AppException {
  const PermissionException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Cache/local storage exceptions
class CacheException extends AppException {
  const CacheException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Unknown/unexpected exceptions
class UnknownException extends AppException {
  const UnknownException({
    required super.message,
    super.code,
    super.originalError,
  });
}
