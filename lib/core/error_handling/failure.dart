import 'package:equatable/equatable.dart';
import 'app_exception.dart';

/// Failure sealed classes for use in Either<Failure, T> returns
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.code});
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.code});
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.code});
}

class ParseFailure extends Failure {
  const ParseFailure({required super.message, super.code});
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({required super.message, super.code});
}

class PermissionFailure extends Failure {
  const PermissionFailure({required super.message, super.code});
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message, super.code});
}

class UnknownFailure extends Failure {
  const UnknownFailure({required super.message, super.code});
}

/// Maps an [AppException] to the corresponding [Failure]
Failure mapExceptionToFailure(AppException exception) {
  return switch (exception) {
    AuthException e => AuthFailure(message: e.message, code: e.code),
    NetworkException e => NetworkFailure(message: e.message, code: e.code),
    ServerException e => ServerFailure(message: e.message, code: e.code),
    ParseException e => ParseFailure(message: e.message, code: e.code),
    NotFoundException e => NotFoundFailure(message: e.message, code: e.code),
    PermissionException e =>
      PermissionFailure(message: e.message, code: e.code),
    CacheException e => CacheFailure(message: e.message, code: e.code),
    _ => UnknownFailure(message: exception.message, code: exception.code),
  };
}
