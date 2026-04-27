import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  // Authentication
  Future<Either<AuthenticationFailure, User>> login({
    required String email,
    required String password,
  });
  
  Future<Either<AuthenticationFailure, User>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? studentId,
  });
  
  Future<Either<AuthenticationFailure, void>> logout();
  
  Future<Either<AuthenticationFailure, User?>> getCurrentUser();
  
  Future<Either<AuthenticationFailure, bool>> isAuthenticated();
  
  // Biometric Authentication
  Future<Either<BiometricFailure, bool>> authenticateWithBiometrics({
    String localizedReason = 'Please authenticate to access the app',
  });
  
  Future<Either<BiometricFailure, bool>> isBiometricAvailable();
  
  Future<Either<Failure, void>> setBiometricEnabled(bool enabled);
  
  Future<Either<Failure, bool>> isBiometricEnabled();
  
  // Token Management
  Future<Either<CacheFailure, String?>> getAuthToken();
  
  Future<Either<CacheFailure, void>> refreshToken();
  
  // Session Management
  Future<Either<Failure, void>> clearSession();
  
  Future<Either<Failure, bool>> validateSession();
  
  // Password Management
  Future<Either<ServerFailure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });
  
  Future<Either<ServerFailure, void>> resetPassword({
    required String email,
  });
  
  // Profile Management
  Future<Either<Failure, User>> updateProfile({
    String? firstName,
    String? lastName,
    String? avatarUrl,
    String? department,
  });
  
  Future<Either<Failure, String>> uploadAvatar(String filePath);
}
