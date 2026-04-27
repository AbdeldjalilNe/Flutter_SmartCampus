import 'package:dartz/dartz.dart';
import 'package:local_auth/local_auth.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/auth_local_datasource.dart';
import '../datasources/remote/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
    required LocalAuthentication localAuth,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _localAuth = localAuth;
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;
  final LocalAuthentication _localAuth;

  @override
  Future<Either<AuthenticationFailure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _remoteDataSource.login(
        email: email,
        password: password,
      );

      // Save user data and tokens locally
      await _localDataSource.saveUser(user);
      await _localDataSource.saveAuthToken(_generateMockToken());

      AppLogger.info('User logged in successfully: ${user.email}');
      return Right(user);
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } catch (e) {
      AppLogger.error('Login error in repository', e);
      return Left(AuthenticationFailure(message: 'Login failed: $e'));
    }
  }

  @override
  Future<Either<AuthenticationFailure, User>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? studentId,
  }) async {
    try {
      final user = await _remoteDataSource.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        studentId: studentId,
      );

      // Save user data locally
      await _localDataSource.saveUser(user);
      await _localDataSource.saveAuthToken(_generateMockToken());

      AppLogger.info('User registered successfully: ${user.email}');
      return Right(user);
    } on ValidationException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } catch (e) {
      AppLogger.error('Registration error in repository', e);
      return Left(AuthenticationFailure(message: 'Registration failed: $e'));
    }
  }

  @override
  Future<Either<AuthenticationFailure, void>> logout() async {
    try {
      await _remoteDataSource.logout();
      await _localDataSource.clearSession();

      AppLogger.info('User logged out successfully');
      return const Right(null);
    } catch (e) {
      AppLogger.error('Logout error in repository', e);
      // Still clear local session even if remote fails
      await _localDataSource.clearSession();
      return const Right(null);
    }
  }

  @override
  Future<Either<AuthenticationFailure, User?>> getCurrentUser() async {
    try {
      // First try to get from local storage
      final localUser = await _localDataSource.getUser();
      if (localUser != null) {
        AppLogger.debug('User retrieved from local storage');
        return Right(localUser);
      }

      // If not in local storage, try to fetch from remote
      final remoteUser = await _remoteDataSource.getCurrentUser();
      await _localDataSource.saveUser(remoteUser);

      AppLogger.info('User retrieved from remote');
      return Right(remoteUser);
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } catch (e) {
      AppLogger.error('Get current user error in repository', e);
      return Left(AuthenticationFailure(message: 'Failed to get user: $e'));
    }
  }

  @override
  Future<Either<AuthenticationFailure, bool>> isAuthenticated() async {
    try {
      final hasValidSession = await _localDataSource.hasValidSession();
      return Right(hasValidSession);
    } catch (e) {
      AppLogger.error('Is authenticated check error', e);
      return const Right(false);
    }
  }

  @override
  Future<Either<BiometricFailure, bool>> authenticateWithBiometrics({
    String localizedReason = 'Please authenticate to access the app',
  }) async {
    try {
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      if (!canCheckBiometrics) {
        return const Left(BiometricFailure(
          message: 'Biometric authentication not available',
          type: 'notAvailable',
        ),);
      }

      final availableBiometrics =
          await _localAuth.getAvailableBiometrics();

      if (availableBiometrics.isEmpty) {
        return const Left(BiometricFailure(
          message: 'No biometric methods enrolled',
          type: 'notEnrolled',
        ),);
      }

      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          stickyAuth: true,
        ),
      );

      if (didAuthenticate) {
        AppLogger.info('Biometric authentication successful');
        return const Right(true);
      } else {
        return const Left(BiometricFailure(
          message: 'Biometric authentication cancelled',
          type: 'cancelled',
        ),);
      }
    } on BiometricException catch (e) {
      return Left(BiometricFailure(message: e.message));
    } catch (e) {
      AppLogger.error('Biometric authentication error', e);
      return Left(BiometricFailure(
        message: 'Biometric authentication failed: $e',
      ),);
    }
  }

  @override
  Future<Either<BiometricFailure, bool>> isBiometricAvailable() async {
    try {
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final availableBiometrics =
          await _localAuth.getAvailableBiometrics();

      final isAvailable = canCheckBiometrics && availableBiometrics.isNotEmpty;
      return Right(isAvailable);
    } catch (e) {
      AppLogger.error('Biometric availability check error', e);
      return const Right(false);
    }
  }

  @override
  Future<Either<Failure, void>> setBiometricEnabled(bool enabled) async {
    try {
      await _localDataSource.setBiometricEnabled(enabled);
      AppLogger.info('Biometric setting updated: $enabled');
      return const Right(null);
    } catch (e) {
      AppLogger.error('Set biometric enabled error', e);
      return Left(CacheFailure(message: 'Failed to save setting: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isBiometricEnabled() async {
    try {
      final enabled = await _localDataSource.isBiometricEnabled();
      return Right(enabled);
    } catch (e) {
      AppLogger.error('Is biometric enabled check error', e);
      return const Right(false);
    }
  }

  @override
  Future<Either<CacheFailure, String?>> getAuthToken() async {
    try {
      final token = await _localDataSource.getAuthToken();
      return Right(token);
    } catch (e) {
      AppLogger.error('Get auth token error', e);
      return Left(CacheFailure(message: 'Failed to get token: $e'));
    }
  }

  @override
  Future<Either<CacheFailure, void>> refreshToken() async {
    try {
      final newToken = await _remoteDataSource.refreshToken();
      await _localDataSource.saveAuthToken(newToken);
      AppLogger.info('Token refreshed successfully');
      return const Right(null);
    } on AuthenticationException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      AppLogger.error('Token refresh error', e);
      return Left(CacheFailure(message: 'Failed to refresh token: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearSession() async {
    try {
      await _localDataSource.clearSession();
      AppLogger.info('Session cleared');
      return const Right(null);
    } catch (e) {
      AppLogger.error('Clear session error', e);
      return Left(CacheFailure(message: 'Failed to clear session: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> validateSession() async {
    try {
      final hasValidSession = await _localDataSource.hasValidSession();
      return Right(hasValidSession);
    } catch (e) {
      AppLogger.error('Validate session error', e);
      return const Right(false);
    }
  }

  @override
  Future<Either<ServerFailure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _remoteDataSource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      AppLogger.info('Password changed successfully');
      return const Right(null);
    } on ValidationException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      AppLogger.error('Change password error', e);
      return Left(ServerFailure(message: 'Failed to change password: $e'));
    }
  }

  @override
  Future<Either<ServerFailure, void>> resetPassword({
    required String email,
  }) async {
    try {
      await _remoteDataSource.resetPassword(email: email);
      AppLogger.info('Password reset requested for: $email');
      return const Right(null);
    } on ValidationException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      AppLogger.error('Reset password error', e);
      return Left(ServerFailure(message: 'Failed to reset password: $e'));
    }
  }

  @override
  Future<Either<Failure, User>> updateProfile({
    String? firstName,
    String? lastName,
    String? avatarUrl,
    String? department,
  }) async {
    try {
      final updatedUser = await _remoteDataSource.updateProfile(
        firstName: firstName,
        lastName: lastName,
        avatarUrl: avatarUrl,
        department: department,
      );

      await _localDataSource.saveUser(updatedUser);

      AppLogger.info('Profile updated successfully');
      return Right(updatedUser);
    } catch (e) {
      AppLogger.error('Update profile error', e);
      return Left(ServerFailure(message: 'Failed to update profile: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadAvatar(String filePath) async {
    try {
      // In production, this would upload the file to a server
      // For demo, we'll just return a mock URL
      await Future.delayed(const Duration(seconds: 1));

      final mockUrl =
          'https://example.com/avatars/${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Update user with new avatar URL
      final currentUser = await _localDataSource.getUser();
      if (currentUser != null) {
        final updatedUser = currentUser.copyWith(avatarUrl: mockUrl);
        await _localDataSource.saveUser(updatedUser);
      }

      AppLogger.info('Avatar uploaded successfully');
      return Right(mockUrl);
    } catch (e) {
      AppLogger.error('Upload avatar error', e);
      return Left(ServerFailure(message: 'Failed to upload avatar: $e'));
    }
  }

  // Helper method to generate mock token
  String _generateMockToken() =>
      'mock_token_${DateTime.now().millisecondsSinceEpoch}';
}
