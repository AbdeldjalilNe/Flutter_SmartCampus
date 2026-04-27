import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../errors/exceptions.dart';
import '../utils/logger.dart';

class SecureStorageService {
  SecureStorageService(this._secureStorage);
  final FlutterSecureStorage _secureStorage;

  // Write data
  Future<void> write({required String key, required String value}) async {
    try {
      await _secureStorage.write(key: key, value: value);
      AppLogger.debug('Secure storage write: $key');
    } catch (e) {
      AppLogger.error('Error writing to secure storage', e);
      throw CacheException(message: 'Failed to write secure data: $e');
    }
  }

  // Read data
  Future<String?> read({required String key}) async {
    try {
      final value = await _secureStorage.read(key: key);
      AppLogger.debug('Secure storage read: $key');
      return value;
    } catch (e) {
      AppLogger.error('Error reading from secure storage', e);
      throw CacheException(message: 'Failed to read secure data: $e');
    }
  }

  // Delete data
  Future<void> delete({required String key}) async {
    try {
      await _secureStorage.delete(key: key);
      AppLogger.debug('Secure storage delete: $key');
    } catch (e) {
      AppLogger.error('Error deleting from secure storage', e);
      throw CacheException(message: 'Failed to delete secure data: $e');
    }
  }

  // Delete all data
  Future<void> deleteAll() async {
    try {
      await _secureStorage.deleteAll();
      AppLogger.info('Secure storage cleared');
    } catch (e) {
      AppLogger.error('Error clearing secure storage', e);
      throw CacheException(message: 'Failed to clear secure data: $e');
    }
  }

  // Check if key exists
  Future<bool> containsKey({required String key}) async {
    try {
      return await _secureStorage.containsKey(key: key);
    } catch (e) {
      AppLogger.error('Error checking secure storage key', e);
      return false;
    }
  }

  // Get all keys
  Future<Set<String>> getAllKeys() async {
    try {
      final allData = await _secureStorage.readAll();
      return allData.keys.toSet();
    } catch (e) {
      AppLogger.error('Error reading all secure storage keys', e);
      return {};
    }
  }

  // Write object (JSON)
  Future<void> writeObject({
    required String key,
    required Map<String, dynamic> value,
  }) async {
    final jsonString = jsonEncode(value);
    await write(key: key, value: jsonString);
  }

  // Read object (JSON)
  Future<Map<String, dynamic>?> readObject({required String key}) async {
    final jsonString = await read(key: key);
    if (jsonString == null) return null;

    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      AppLogger.error('Error parsing JSON from secure storage', e);
      return null;
    }
  }

  // Write list
  Future<void> writeList({
    required String key,
    required List<String> value,
  }) async {
    final jsonString = jsonEncode(value);
    await write(key: key, value: jsonString);
  }

  // Read list
  Future<List<String>?> readList({required String key}) async {
    final jsonString = await read(key: key);
    if (jsonString == null) return null;

    try {
      final list = jsonDecode(jsonString) as List<dynamic>;
      return list.cast<String>();
    } catch (e) {
      AppLogger.error('Error parsing list from secure storage', e);
      return null;
    }
  }

  // Token management
  Future<void> saveAuthToken(String token) async {
    await write(key: 'auth_token', value: token);
  }

  Future<String?> getAuthToken() async => read(key: 'auth_token');

  Future<void> deleteAuthToken() async {
    await delete(key: 'auth_token');
  }

  Future<void> saveRefreshToken(String token) async {
    await write(key: 'refresh_token', value: token);
  }

  Future<String?> getRefreshToken() async => read(key: 'refresh_token');

  Future<void> deleteRefreshToken() async {
    await delete(key: 'refresh_token');
  }

  // User data
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    await writeObject(key: 'user_data', value: userData);
  }

  Future<Map<String, dynamic>?> getUserData() async =>
      readObject(key: 'user_data');

  Future<void> deleteUserData() async {
    await delete(key: 'user_data');
  }

  // Session management
  Future<void> clearSession() async {
    await deleteAuthToken();
    await deleteRefreshToken();
    await deleteUserData();
    AppLogger.info('Session cleared from secure storage');
  }

  // Biometric settings
  Future<void> setBiometricEnabled(bool enabled) async {
    await write(key: 'biometric_enabled', value: enabled.toString());
  }

  Future<bool> isBiometricEnabled() async {
    final value = await read(key: 'biometric_enabled');
    return value?.toLowerCase() == 'true';
  }

  // PIN/Password
  Future<void> savePin(String pin) async {
    // In production, hash the PIN before storing
    await write(key: 'user_pin', value: pin);
  }

  Future<String?> getPin() async => read(key: 'user_pin');

  Future<void> deletePin() async {
    await delete(key: 'user_pin');
  }

  // Verify PIN
  Future<bool> verifyPin(String pin) async {
    final storedPin = await getPin();
    return storedPin == pin;
  }
}
