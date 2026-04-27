import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/utils/logger.dart';
import '../../../domain/entities/user.dart';

abstract class AuthLocalDataSource {
  // Token management
  Future<void> saveAuthToken(String token);
  Future<String?> getAuthToken();
  Future<void> deleteAuthToken();

  Future<void> saveRefreshToken(String token);
  Future<String?> getRefreshToken();
  Future<void> deleteRefreshToken();

  // User data
  Future<void> saveUser(User user);
  Future<User?> getUser();
  Future<void> deleteUser();

  // Session
  Future<void> clearSession();
  Future<bool> hasValidSession();

  // Biometric
  Future<void> setBiometricEnabled(bool enabled);
  Future<bool> isBiometricEnabled();

  // PIN
  Future<void> savePin(String pin);
  Future<String?> getPin();
  Future<bool> verifyPin(String pin);
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  AuthLocalDataSourceImpl({
    required FlutterSecureStorage secureStorage,
    required SharedPreferences sharedPreferences,
  })  : _secureStorage = secureStorage,
        _sharedPreferences = sharedPreferences;
  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _sharedPreferences;

  @override
  Future<void> saveAuthToken(String token) async {
    try {
      await _secureStorage.write(
        key: AppConstants.authTokenKey,
        value: token,
      );
      AppLogger.debug('Auth token saved');
    } catch (e) {
      AppLogger.error('Error saving auth token', e);
      throw const CacheException(message: 'Failed to save auth token');
    }
  }

  @override
  Future<String?> getAuthToken() async {
    try {
      return await _secureStorage.read(key: AppConstants.authTokenKey);
    } catch (e) {
      AppLogger.error('Error reading auth token', e);
      return null;
    }
  }

  @override
  Future<void> deleteAuthToken() async {
    try {
      await _secureStorage.delete(key: AppConstants.authTokenKey);
      AppLogger.debug('Auth token deleted');
    } catch (e) {
      AppLogger.error('Error deleting auth token', e);
    }
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    try {
      await _secureStorage.write(
        key: AppConstants.refreshTokenKey,
        value: token,
      );
      AppLogger.debug('Refresh token saved');
    } catch (e) {
      AppLogger.error('Error saving refresh token', e);
      throw const CacheException(message: 'Failed to save refresh token');
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      return await _secureStorage.read(key: AppConstants.refreshTokenKey);
    } catch (e) {
      AppLogger.error('Error reading refresh token', e);
      return null;
    }
  }

  @override
  Future<void> deleteRefreshToken() async {
    try {
      await _secureStorage.delete(key: AppConstants.refreshTokenKey);
      AppLogger.debug('Refresh token deleted');
    } catch (e) {
      AppLogger.error('Error deleting refresh token', e);
    }
  }

  @override
  Future<void> saveUser(User user) async {
    try {
      final userJson = jsonEncode(user.toJson());
      await _secureStorage.write(
        key: AppConstants.userDataKey,
        value: userJson,
      );
      AppLogger.debug('User data saved');
    } catch (e) {
      AppLogger.error('Error saving user data', e);
      throw const CacheException(message: 'Failed to save user data');
    }
  }

  @override
  Future<User?> getUser() async {
    try {
      final userJson = await _secureStorage.read(key: AppConstants.userDataKey);
      if (userJson == null) return null;

      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      return User.fromJson(userMap);
    } catch (e) {
      AppLogger.error('Error reading user data', e);
      return null;
    }
  }

  @override
  Future<void> deleteUser() async {
    try {
      await _secureStorage.delete(key: AppConstants.userDataKey);
      AppLogger.debug('User data deleted');
    } catch (e) {
      AppLogger.error('Error deleting user data', e);
    }
  }

  @override
  Future<void> clearSession() async {
    try {
      await Future.wait([
        deleteAuthToken(),
        deleteRefreshToken(),
        deleteUser(),
      ]);
      AppLogger.info('Session cleared');
    } catch (e) {
      AppLogger.error('Error clearing session', e);
      throw const CacheException(message: 'Failed to clear session');
    }
  }

  @override
  Future<bool> hasValidSession() async {
    try {
      final token = await getAuthToken();
      final user = await getUser();
      return token != null && user != null;
    } catch (e) {
      AppLogger.error('Error checking session validity', e);
      return false;
    }
  }

  @override
  Future<void> setBiometricEnabled(bool enabled) async {
    try {
      await _sharedPreferences.setBool(
        AppConstants.biometricEnabledKey,
        enabled,
      );
      AppLogger.debug('Biometric setting saved: $enabled');
    } catch (e) {
      AppLogger.error('Error saving biometric setting', e);
      throw const CacheException(message: 'Failed to save biometric setting');
    }
  }

  @override
  Future<bool> isBiometricEnabled() async {
    try {
      return _sharedPreferences.getBool(AppConstants.biometricEnabledKey) ??
          false;
    } catch (e) {
      AppLogger.error('Error reading biometric setting', e);
      return false;
    }
  }

  @override
  Future<void> savePin(String pin) async {
    try {
      // In production, hash the PIN before storing
      await _secureStorage.write(key: 'user_pin', value: pin);
      AppLogger.debug('PIN saved');
    } catch (e) {
      AppLogger.error('Error saving PIN', e);
      throw const CacheException(message: 'Failed to save PIN');
    }
  }

  @override
  Future<String?> getPin() async {
    try {
      return await _secureStorage.read(key: 'user_pin');
    } catch (e) {
      AppLogger.error('Error reading PIN', e);
      return null;
    }
  }

  @override
  Future<bool> verifyPin(String pin) async {
    try {
      final storedPin = await getPin();
      return storedPin == pin;
    } catch (e) {
      AppLogger.error('Error verifying PIN', e);
      return false;
    }
  }
}
