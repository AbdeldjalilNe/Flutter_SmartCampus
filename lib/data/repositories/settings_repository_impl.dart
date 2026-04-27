import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/logger.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/local/settings_local_datasource.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl({required SettingsLocalDataSource localDataSource})
      : _localDataSource = localDataSource;
  final SettingsLocalDataSource _localDataSource;

  @override
  Future<Either<CacheFailure, AppLanguage>> getLanguage() async {
    try {
      final language = await _localDataSource.getLanguage();
      return Right(language);
    } catch (e) {
      AppLogger.error('Error getting language', e);
      return const Right(AppLanguage.english);
    }
  }

  @override
  Future<Either<CacheFailure, void>> setLanguage(AppLanguage language) async {
    try {
      await _localDataSource.setLanguage(language);
      AppLogger.info('Language set to: ${language.displayName}');
      return const Right(null);
    } catch (e) {
      AppLogger.error('Error setting language', e);
      return Left(CacheFailure(message: 'Failed to set language: $e'));
    }
  }

  @override
  Future<Either<CacheFailure, Locale>> getLocale() async {
    final result = await getLanguage();
    return result.fold(
      (failure) => const Right(Locale('en', 'US')),
      (language) => Right(language.locale),
    );
  }

  @override
  Future<Either<CacheFailure, ThemeMode>> getThemeMode() async {
    try {
      final themeMode = await _localDataSource.getThemeMode();
      return Right(themeMode);
    } catch (e) {
      AppLogger.error('Error getting theme mode', e);
      return const Right(ThemeMode.system);
    }
  }

  @override
  Future<Either<CacheFailure, void>> setThemeMode(ThemeMode mode) async {
    try {
      await _localDataSource.setThemeMode(mode);
      AppLogger.info('Theme mode set to: $mode');
      return const Right(null);
    } catch (e) {
      AppLogger.error('Error setting theme mode', e);
      return Left(CacheFailure(message: 'Failed to set theme mode: $e'));
    }
  }

  @override
  Future<Either<CacheFailure, bool>> areNotificationsEnabled() async {
    try {
      final enabled = await _localDataSource.areNotificationsEnabled();
      return Right(enabled);
    } catch (e) {
      AppLogger.error('Error getting notification setting', e);
      return const Right(true);
    }
  }

  @override
  Future<Either<CacheFailure, void>> setNotificationsEnabled(
      bool enabled,) async {
    try {
      await _localDataSource.setNotificationsEnabled(enabled);
      AppLogger.info('Notifications enabled: $enabled');
      return const Right(null);
    } catch (e) {
      AppLogger.error('Error setting notification preference', e);
      return Left(CacheFailure(message: 'Failed to set notification: $e'));
    }
  }

  @override
  Future<Either<CacheFailure, Map<String, bool>>>
      getNotificationPreferences() async {
    try {
      final prefs = await _localDataSource.getNotificationPreferences();
      return Right(prefs);
    } catch (e) {
      AppLogger.error('Error getting notification preferences', e);
      return const Right({});
    }
  }

  @override
  Future<Either<CacheFailure, void>> setNotificationPreference({
    required String key,
    required bool enabled,
  }) async {
    try {
      await _localDataSource.setNotificationPreference(
        key: key,
        enabled: enabled,
      );
      AppLogger.info('Notification preference set: $key = $enabled');
      return const Right(null);
    } catch (e) {
      AppLogger.error('Error setting notification preference', e);
      return Left(CacheFailure(message: 'Failed to set preference: $e'));
    }
  }

  @override
  Future<Either<CacheFailure, bool>> isBiometricEnabled() async {
    try {
      final enabled = await _localDataSource.isBiometricEnabled();
      return Right(enabled);
    } catch (e) {
      AppLogger.error('Error getting biometric setting', e);
      return const Right(false);
    }
  }

  @override
  Future<Either<CacheFailure, void>> setBiometricEnabled(bool enabled) async {
    try {
      await _localDataSource.setBiometricEnabled(enabled);
      AppLogger.info('Biometric enabled: $enabled');
      return const Right(null);
    } catch (e) {
      AppLogger.error('Error setting biometric', e);
      return Left(CacheFailure(message: 'Failed to set biometric: $e'));
    }
  }

  @override
  Future<Either<CacheFailure, bool>> isAnalyticsEnabled() async {
    try {
      final enabled = await _localDataSource.isAnalyticsEnabled();
      return Right(enabled);
    } catch (e) {
      AppLogger.error('Error getting analytics setting', e);
      return const Right(true);
    }
  }

  @override
  Future<Either<CacheFailure, void>> setAnalyticsEnabled(bool enabled) async {
    try {
      await _localDataSource.setAnalyticsEnabled(enabled);
      AppLogger.info('Analytics enabled: $enabled');
      return const Right(null);
    } catch (e) {
      AppLogger.error('Error setting analytics', e);
      return Left(CacheFailure(message: 'Failed to set analytics: $e'));
    }
  }

  @override
  Future<Either<CacheFailure, bool>> isLocationSharingEnabled() async {
    try {
      final enabled = await _localDataSource.isLocationSharingEnabled();
      return Right(enabled);
    } catch (e) {
      AppLogger.error('Error getting location sharing setting', e);
      return const Right(false);
    }
  }

  @override
  Future<Either<CacheFailure, void>> setLocationSharingEnabled(
      bool enabled,) async {
    try {
      await _localDataSource.setLocationSharingEnabled(enabled);
      AppLogger.info('Location sharing enabled: $enabled');
      return const Right(null);
    } catch (e) {
      AppLogger.error('Error setting location sharing', e);
      return Left(
          CacheFailure(message: 'Failed to set location sharing: $e'),);
    }
  }

  @override
  Future<Either<CacheFailure, int>> getDefaultReminderMinutes() async {
    try {
      final minutes = await _localDataSource.getDefaultReminderMinutes();
      return Right(minutes);
    } catch (e) {
      AppLogger.error('Error getting default reminder minutes', e);
      return const Right(10);
    }
  }

  @override
  Future<Either<CacheFailure, void>> setDefaultReminderMinutes(
      int minutes,) async {
    try {
      await _localDataSource.setDefaultReminderMinutes(minutes);
      AppLogger.info('Default reminder minutes set to: $minutes');
      return const Right(null);
    } catch (e) {
      AppLogger.error('Error setting default reminder minutes', e);
      return Left(
          CacheFailure(message: 'Failed to set reminder minutes: $e'),);
    }
  }

  @override
  Future<Either<CacheFailure, Duration>> getCacheValidityDuration() async {
    try {
      final duration = await _localDataSource.getCacheValidityDuration();
      return Right(duration);
    } catch (e) {
      AppLogger.error('Error getting cache validity duration', e);
      return const Right(Duration(hours: 24));
    }
  }

  @override
  Future<Either<CacheFailure, void>> setCacheValidityDuration(
      Duration duration,) async {
    try {
      await _localDataSource.setCacheValidityDuration(duration);
      AppLogger.info('Cache validity duration set to: $duration');
      return const Right(null);
    } catch (e) {
      AppLogger.error('Error setting cache validity duration', e);
      return Left(CacheFailure(message: 'Failed to set cache duration: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearAllCache() async {
    try {
      await _localDataSource.clearAllCache();
      AppLogger.info('All cache cleared');
      return const Right(null);
    } catch (e) {
      AppLogger.error('Error clearing cache', e);
      return Left(CacheFailure(message: 'Failed to clear cache: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearAppData() async {
    try {
      await _localDataSource.clearAppData();
      AppLogger.info('App data cleared');
      return const Right(null);
    } catch (e) {
      AppLogger.error('Error clearing app data', e);
      return Left(CacheFailure(message: 'Failed to clear app data: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, int>>> getStorageUsage() async {
    try {
      final usage = await _localDataSource.getStorageUsage();
      return Right(usage);
    } catch (e) {
      AppLogger.error('Error getting storage usage', e);
      return const Right({});
    }
  }

  @override
  Future<Either<Failure, String>> getAppVersion() async {
    try {
      final version = await _localDataSource.getAppVersion();
      return Right(version);
    } catch (e) {
      AppLogger.error('Error getting app version', e);
      return const Right('1.0.0');
    }
  }

  @override
  Future<Either<Failure, String>> getBuildNumber() async {
    try {
      final buildNumber = await _localDataSource.getBuildNumber();
      return Right(buildNumber);
    } catch (e) {
      AppLogger.error('Error getting build number', e);
      return const Right('1');
    }
  }

  @override
  Future<Either<CacheFailure, void>> resetToDefaults() async {
    try {
      await _localDataSource.resetToDefaults();
      AppLogger.info('Settings reset to defaults');
      return const Right(null);
    } catch (e) {
      AppLogger.error('Error resetting settings', e);
      return Left(CacheFailure(message: 'Failed to reset settings: $e'));
    }
  }

  @override
  Future<Either<CacheFailure, String>> exportSettings() async {
    try {
      final settings = await _localDataSource.exportSettings();
      return Right(settings);
    } catch (e) {
      AppLogger.error('Error exporting settings', e);
      return Left(CacheFailure(message: 'Failed to export settings: $e'));
    }
  }

  @override
  Future<Either<CacheFailure, void>> importSettings(
      String jsonSettings,) async {
    try {
      await _localDataSource.importSettings(jsonSettings);
      AppLogger.info('Settings imported');
      return const Right(null);
    } catch (e) {
      AppLogger.error('Error importing settings', e);
      return Left(CacheFailure(message: 'Failed to import settings: $e'));
    }
  }
}
