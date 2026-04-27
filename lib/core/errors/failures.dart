import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {

  const Failure({required this.message});
  final String message;

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure({super.message = 'Server Error'});
}

class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Cache Error'});
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'Network Error'});
}

class AuthenticationFailure extends Failure {
  const AuthenticationFailure({super.message = 'Authentication Error'});
}

class BiometricFailure extends Failure {
  const BiometricFailure({super.message = 'Biometric Error', this.type = 'unknown'});
  final String type;
  
  @override
  List<Object?> get props => [message, type];
}

class PermissionDeniedFailure extends Failure {
  const PermissionDeniedFailure({super.message = 'Permission Denied', required this.permission});
  final String permission;

  @override
  List<Object?> get props => [message, permission];
}

class ValidationFailure extends Failure {
  const ValidationFailure({super.message = 'Validation Error', this.errors});
  final Map<String, String>? errors;

  @override
  List<Object?> get props => [message, errors];
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({super.message = 'Not Found Error'});
}

class BackgroundTaskFailure extends Failure {
  const BackgroundTaskFailure({super.message = 'Background Task Error', required this.taskId});
  final String taskId;

  @override
  List<Object?> get props => [message, taskId];
}
