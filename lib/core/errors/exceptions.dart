class ServerException implements Exception {
  const ServerException({
    this.message = 'Server error occurred',
    this.statusCode,
  });
  final String message;
  final int? statusCode;

  @override
  String toString() => 'ServerException: $message (Status: $statusCode)';
}

class CacheException implements Exception {
  const CacheException({this.message = 'Cache error occurred'});
  final String message;

  @override
  String toString() => 'CacheException: $message';
}

class NetworkException implements Exception {
  const NetworkException({this.message = 'Network error occurred'});
  final String message;

  @override
  String toString() => 'NetworkException: $message';
}

class AuthenticationException implements Exception {
  const AuthenticationException({this.message = 'Authentication failed'});
  final String message;

  @override
  String toString() => 'AuthenticationException: $message';
}

class BiometricException implements Exception {
  const BiometricException({
    this.message = 'Biometric authentication failed',
    this.type = BiometricErrorType.unknown,
  });
  final String message;
  final BiometricErrorType type;

  @override
  String toString() => 'BiometricException: $message (Type: $type)';
}

enum BiometricErrorType {
  notAvailable,
  notEnrolled,
  cancelled,
  failed,
  unknown,
}

class PermissionDeniedException implements Exception {
  const PermissionDeniedException({
    this.message = 'Permission denied',
    required this.permission,
  });
  final String message;
  final String permission;

  @override
  String toString() => 'PermissionDeniedException: $message ($permission)';
}

class ValidationException implements Exception {
  const ValidationException({
    this.message = 'Validation failed',
    this.errors,
  });
  final String message;
  final Map<String, String>? errors;

  @override
  String toString() => 'ValidationException: $message';
}

class NotFoundException implements Exception {
  const NotFoundException({this.message = 'Resource not found'});
  final String message;

  @override
  String toString() => 'NotFoundException: $message';
}

class BackgroundTaskException implements Exception {
  const BackgroundTaskException({
    this.message = 'Background task failed',
    required this.taskId,
  });
  final String message;
  final String taskId;

  @override
  String toString() => 'BackgroundTaskException: $message (Task: $taskId)';
}
