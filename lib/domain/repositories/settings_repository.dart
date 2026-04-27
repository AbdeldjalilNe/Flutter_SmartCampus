import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/failures.dart';

abstract class SettingsRepository {
  // Language settings
  Future<Either<CacheFailure, AppLanguage>> getLanguage();
  
  Future<Either<CacheFailure, void>> setLanguage(AppLanguage language);
  
  Future<Either<CacheFailure, Locale>> getLocale();
  
  // Theme settings
  Future<Either<CacheFailure, ThemeMode>> getThemeMode();
  
  Future<Either<CacheFailure, void>> setThemeMode(ThemeMode mode);
  
  // Notification settings
  Future<Either<CacheFailure, bool>> areNotificationsEnabled();
  
  Future<Either<CacheFailure, void>> setNotificationsEnabled(bool enabled);
  
  Future<Either<CacheFailure, Map<String, bool>>> getNotificationPreferences();
  
  Future<Either<CacheFailure, void>> setNotificationPreference({
    required String key,
    required bool enabled,
  });
  
  // Biometric settings
  Future<Either<CacheFailure, bool>> isBiometricEnabled();
  
  Future<Either<CacheFailure, void>> setBiometricEnabled(bool enabled);
  
  // Privacy settings
  Future<Either<CacheFailure, bool>> isAnalyticsEnabled();
  
  Future<Either<CacheFailure, void>> setAnalyticsEnabled(bool enabled);
  
  Future<Either<CacheFailure, bool>> isLocationSharingEnabled();
  
  Future<Either<CacheFailure, void>> setLocationSharingEnabled(bool enabled);
  
  // Default reminder settings
  Future<Either<CacheFailure, int>> getDefaultReminderMinutes();
  
  Future<Either<CacheFailure, void>> setDefaultReminderMinutes(int minutes);
  
  // Cache settings
  Future<Either<CacheFailure, Duration>> getCacheValidityDuration();
  
  Future<Either<CacheFailure, void>> setCacheValidityDuration(
    Duration duration,
  );
  
  // Data management
  Future<Either<Failure, void>> clearAllCache();
  
  Future<Either<Failure, void>> clearAppData();
  
  Future<Either<Failure, Map<String, int>>> getStorageUsage();
  
  // App info
  Future<Either<Failure, String>> getAppVersion();
  
  Future<Either<Failure, String>> getBuildNumber();
  
  // Reset settings
  Future<Either<CacheFailure, void>> resetToDefaults();
  
  // Export/Import settings
  Future<Either<CacheFailure, String>> exportSettings();
  
  Future<Either<CacheFailure, void>> importSettings(String jsonSettings);
}
