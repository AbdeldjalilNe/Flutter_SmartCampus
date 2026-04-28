import 'dart:convert';
import 'dart:math';

import '../../../core/errors/exceptions.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/utils/logger.dart';
import '../../../domain/entities/user.dart';

abstract class AuthRemoteDataSource {
  Future<User> login({
    required String email,
    required String password,
  });

  Future<User> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? studentId,
  });

  Future<void> logout();

  Future<String> refreshToken();

  Future<User> getCurrentUser();

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<void> resetPassword({required String email});

  Future<User> updateProfile({
    String? firstName,
    String? lastName,
    String? avatarUrl,
    String? department,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._dioClient);
  final DioClient _dioClient;

  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    try {
      // For demo purposes, we'll simulate a successful login
      // In production, this would make an actual API call

      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // Validate credentials (demo validation)
      if (email.isEmpty || password.isEmpty) {
        throw const AuthenticationException(
          message: 'Email and password are required',
        );
      }

      // Generate mock user
      final user = _generateMockUser(email);

      AppLogger.info('User logged in: ${user.email}');
      return user;
    } on AuthenticationException {
      rethrow;
    } catch (e) {
      AppLogger.error('Login error', e);
      throw AuthenticationException(message: 'Login failed: $e');
    }
  }

  @override
  Future<User> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? studentId,
  }) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // Validate input
      if (email.isEmpty ||
          password.isEmpty ||
          firstName.isEmpty ||
          lastName.isEmpty) {
        throw const ValidationException(
          message: 'All fields are required',
        );
      }

      // Generate mock user
      final user = User(
        id: _generateId(),
        email: email,
        firstName: firstName,
        lastName: lastName,
        studentId: studentId,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      AppLogger.info('User registered: ${user.email}');
      return user;
    } on ValidationException {
      rethrow;
    } catch (e) {
      AppLogger.error('Registration error', e);
      throw ServerException(message: 'Registration failed: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      AppLogger.info('User logged out');
    } catch (e) {
      AppLogger.error('Logout error', e);
      throw ServerException(message: 'Logout failed: $e');
    }
  }

  @override
  Future<String> refreshToken() async {
    try {
      // Simulate token refresh
      await Future.delayed(const Duration(milliseconds: 500));
      final newToken = _generateMockToken();
      AppLogger.debug('Token refreshed');
      return newToken;
    } catch (e) {
      AppLogger.error('Token refresh error', e);
      throw AuthenticationException(message: 'Token refresh failed: $e');
    }
  }

  @override
  Future<User> getCurrentUser() async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      // Return mock user
      return _generateMockUser('user@university.edu');
    } catch (e) {
      AppLogger.error('Get current user error', e);
      throw ServerException(message: 'Failed to get user: $e');
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      // Validate passwords
      if (currentPassword.isEmpty || newPassword.isEmpty) {
        throw const ValidationException(
          message: 'Both current and new password are required',
        );
      }

      if (newPassword.length < 6) {
        throw const ValidationException(
          message: 'New password must be at least 6 characters',
        );
      }

      AppLogger.info('Password changed successfully');
    } on ValidationException {
      rethrow;
    } catch (e) {
      AppLogger.error('Change password error', e);
      throw ServerException(message: 'Failed to change password: $e');
    }
  }

  @override
  Future<void> resetPassword({required String email}) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      if (email.isEmpty) {
        throw const ValidationException(message: 'Email is required');
      }

      AppLogger.info('Password reset requested for: $email');
    } on ValidationException {
      rethrow;
    } catch (e) {
      AppLogger.error('Reset password error', e);
      throw ServerException(message: 'Failed to reset password: $e');
    }
  }

  @override
  Future<User> updateProfile({
    String? firstName,
    String? lastName,
    String? avatarUrl,
    String? department,
  }) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      final currentUser = await getCurrentUser();
      final updatedUser = currentUser.copyWith(
        firstName: firstName,
        lastName: lastName,
        avatarUrl: avatarUrl,
        department: department,
      );

      AppLogger.info('Profile updated for: ${updatedUser.email}');
      return updatedUser;
    } catch (e) {
      AppLogger.error('Update profile error', e);
      throw ServerException(message: 'Failed to update profile: $e');
    }
  }

  // Helper methods for mock data
  User _generateMockUser(String email) {
    final names = email.split('@')[0].split('.');
    final firstName =
        names[0].substring(0, 1).toUpperCase() + names[0].substring(1);
    final lastName = names.length > 1
        ? names[1].substring(0, 1).toUpperCase() + names[1].substring(1)
        : 'Student';

    return User(
      id: _generateId(),
      email: email,
      firstName: firstName,
      lastName: lastName,
      studentId: 'S${_generateRandomNumber(100000, 999999)}',
      department: 'Computer Science',
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
      lastLoginAt: DateTime.now(),
    );
  }

  String _generateId() =>
      '${DateTime.now().millisecondsSinceEpoch}_${_generateRandomNumber(1000, 9999)}';

  String _generateMockToken() {
    final header =
        base64Encode(utf8.encode(jsonEncode({'alg': 'HS256', 'typ': 'JWT'})));
    final payload = base64Encode(utf8.encode(jsonEncode({
      'sub': _generateId(),
      'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'exp': DateTime.now()
              .add(const Duration(hours: 24))
              .millisecondsSinceEpoch ~/
          1000,
    }),),);
    final signature = base64Encode(utf8.encode('mock_signature'));
    return '$header.$payload.$signature';
  }

  int _generateRandomNumber(int min, int max) =>
      min + Random().nextInt(max - min);
}
