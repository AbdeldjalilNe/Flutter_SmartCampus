import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:smartcampus_companion/core/errors/failures.dart';
import 'package:smartcampus_companion/data/datasources/local/auth_local_datasource.dart';
import 'package:smartcampus_companion/data/datasources/remote/auth_remote_datasource.dart';
import 'package:smartcampus_companion/data/repositories/auth_repository_impl.dart';
import 'package:smartcampus_companion/domain/entities/user.dart';

import 'auth_repository_test.mocks.dart';

@GenerateMocks([AuthRemoteDataSource, AuthLocalDataSource, LocalAuthentication])
void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockAuthLocalDataSource mockLocalDataSource;
  late MockLocalAuthentication mockLocalAuth;

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockLocalDataSource = MockAuthLocalDataSource();
    mockLocalAuth = MockLocalAuthentication();
    repository = AuthRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      localAuth: mockLocalAuth,
    );
  });

  group('login', () {
    const tEmail = 'test@university.edu';
    const tPassword = 'password123';
    final tUser = User(
      id: '1',
      email: tEmail,
      firstName: 'Test',
      lastName: 'User',
      createdAt: DateTime.now(),
    );

    test('should return user when login is successful', () async {
      // Arrange
      when(mockRemoteDataSource.login(
        email: anyNamed('email'),
        password: anyNamed('password'),
      ),).thenAnswer((_) async => tUser);
      when(mockLocalDataSource.saveUser(any)).thenAnswer((_) async => {});
      when(mockLocalDataSource.saveAuthToken(any)).thenAnswer((_) async => {});

      // Act
      final result = await repository.login(
        email: tEmail,
        password: tPassword,
      );

      // Assert
      expect(result, Right(tUser));
      verify(mockRemoteDataSource.login(email: tEmail, password: tPassword));
      verify(mockLocalDataSource.saveUser(tUser));
      verify(mockLocalDataSource.saveAuthToken(any));
    });

    test('should return AuthenticationFailure when login fails', () async {
      // Arrange
      when(mockRemoteDataSource.login(
        email: anyNamed('email'),
        password: anyNamed('password'),
      ),).thenThrow(
          const AuthenticationFailure(message: 'Invalid credentials'),);

      // Act
      final result = await repository.login(
        email: tEmail,
        password: tPassword,
      );

      // Assert
      expect(
        result,
        const Left(AuthenticationFailure(message: 'Invalid credentials')),
      );
    });
  });

  group('isAuthenticated', () {
    test('should return true when user has valid session', () async {
      // Arrange
      when(mockLocalDataSource.hasValidSession()).thenAnswer((_) async => true);

      // Act
      final result = await repository.isAuthenticated();

      // Assert
      expect(result, const Right(true));
    });

    test('should return false when user has no valid session', () async {
      // Arrange
      when(mockLocalDataSource.hasValidSession())
          .thenAnswer((_) async => false);

      // Act
      final result = await repository.isAuthenticated();

      // Assert
      expect(result, const Right(false));
    });
  });

  group('authenticateWithBiometrics', () {
    test('should return true when biometric auth succeeds', () async {
      // Arrange
      when(mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => true);
      when(mockLocalAuth.getAvailableBiometrics())
          .thenAnswer((_) async => [BiometricType.fingerprint]);
      when(mockLocalAuth.authenticate(
        localizedReason: anyNamed('localizedReason'),
        authMessages: anyNamed('authMessages'),
        options: anyNamed('options'),
      ),).thenAnswer((_) async => true);

      // Act
      final result = await repository.authenticateWithBiometrics();

      // Assert
      expect(result, const Right(true));
    });

    test('should return BiometricFailure when biometrics not available',
        () async {
      // Arrange
      when(mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => false);

      // Act
      final result = await repository.authenticateWithBiometrics();

      // Assert
      expect(
        result,
        const Left(BiometricFailure(
          message: 'Biometric authentication not available',
          type: 'notAvailable',
        ),),
      );
    });
  });

  group('logout', () {
    test('should clear session on logout', () async {
      // Arrange
      when(mockRemoteDataSource.logout()).thenAnswer((_) async => {});
      when(mockLocalDataSource.clearSession()).thenAnswer((_) async => {});

      // Act
      final result = await repository.logout();

      // Assert
      expect(result, const Right(null));
      verify(mockRemoteDataSource.logout());
      verify(mockLocalDataSource.clearSession());
    });
  });
}
