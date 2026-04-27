import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/logger.dart';

abstract class SettingsLocalDataSource {
  // Language
  Future<AppLanguage> getLanguage();
  Future<void> setLanguage(AppLanguage language);

  // Theme
  Future<ThemeMode> getThemeMode();
  Future<void> setThemeMode(ThemeMode mode);

  // Notifications
  Future<bool> areNotificationsEnabled();
  Future<void> setNotificationsEnabled(bool enabled);
  Future<Map<String, bool>> getNotificationPreferences();
  Future<void> setNotificationPreference({
    required String key,
    required bool enabled,
  });

  // Biometric
  Future<bool> isBiometricEnabled();
  Future<void> setBiometricEnabled(bool enabled);

  // Privacy
  Future<bool> isAnalyticsEnabled();
  Future<void> setAnalyticsEnabled(bool enabled);
  Future<bool> isLocationSharingEnabled();
  Future<void> setLocationSharingEnabled(bool enabled);

  // Reminders
  Future<int> getDefaultReminderMinutes();
  Future<void> setDefaultReminderMinutes(int minutes);

  // Cache
  Future<Duration> getCacheValidityDuration();
  Future<void> setCacheValidityDuration(Duration duration);

  // Data management
  Future<void> clearAllCache();
  Future<void> clearAppData();
  Future<Map<String, int>> getStorageUsage();

  // App info
  Future<String> getAppVersion();
  Future<String> getBuildNumber();

  // Import/Export
  Future<void> resetToDefaults();
  Future<String> exportSettings();
  Future<void> importSettings(String jsonSettings);
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  SettingsLocalDataSourceImpl({required SharedPreferences sharedPreferences})
      : _sharedPreferences = sharedPreferences;
  final SharedPreferences _sharedPreferences;

  @override
  Future<AppLanguage> getLanguage() async {
    final languageCode = _sharedPreferences.getString(AppConstants.languageKey);
    if (languageCode == null) return AppLanguage.english;

    return AppLanguage.values.firstWhere(
      (lang) => lang.code == languageCode,
      orElse: () => AppLanguage.english,
    );
  }

  @override
  Future<void> setLanguage(AppLanguage language) async {
    await _sharedPreferences.setString(AppConstants.languageKey, language.code);
    AppLogger.info('Language saved: ${language.code}');
  }

  @override
  Future<ThemeMode> getThemeMode() async {
    final themeString = _sharedPreferences.getString(AppConstants.themeKey);
    if (themeString == null) return ThemeMode.system;

    return ThemeMode.values.firstWhere(
      (mode) => mode.name == themeString,
      orElse: () => ThemeMode.system,
    );
  }

  @override
  Future<void> setThemeMode(ThemeMode mode) async {
    await _sharedPreferences.setString(AppConstants.themeKey, mode.name);
    AppLogger.info('Theme mode saved: ${mode.name}');
  }

  @override
  Future<bool> areNotificationsEnabled() async =>
      _sharedPreferences.getBool(AppConstants.notificationsEnabledKey) ?? true;

  @override
  Future<void> setNotificationsEnabled(bool enabled) async {
    await _sharedPreferences.setBool(
        AppConstants.notificationsEnabledKey, enabled,);
    AppLogger.info('Notifications enabled: $enabled');
  }

  @override
  Future<Map<String, bool>> getNotificationPreferences() async {
    final prefsJson = _sharedPreferences.getString('notification_preferences');
    if (prefsJson == null) {
      return {
        'class_reminders': true,
        'event_reminders': true,
        'announcements': true,
        'emergency_alerts': true,
      };
    }

    final Map<String, dynamic> decoded = jsonDecode(prefsJson);
    return decoded.map((key, value) => MapEntry(key, value as bool));
  }

  @override
  Future<void> setNotificationPreference({
    required String key,
    required bool enabled,
  }) async {
    final prefs = await getNotificationPreferences();
    prefs[key] = enabled;
    await _sharedPreferences.setString(
        'notification_preferences', jsonEncode(prefs),);
    AppLogger.info('Notification preference saved: $key = $enabled');
  }

  @override
  Future<bool> isBiometricEnabled() async =>
      _sharedPreferences.getBool(AppConstants.biometricEnabledKey) ?? false;

  @override
  Future<void> setBiometricEnabled(bool enabled) async {
    await _sharedPreferences.setBool(AppConstants.biometricEnabledKey, enabled);
    AppLogger.info('Biometric enabled: $enabled');
  }

  @override
  Future<bool> isAnalyticsEnabled() async =>
      _sharedPreferences.getBool('analytics_enabled') ?? true;

  @override
  Future<void> setAnalyticsEnabled(bool enabled) async {
    await _sharedPreferences.setBool('analytics_enabled', enabled);
    AppLogger.info('Analytics enabled: $enabled');
  }

  @override
  Future<bool> isLocationSharingEnabled() async =>
      _sharedPreferences.getBool('location_sharing_enabled') ?? false;

  @override
  Future<void> setLocationSharingEnabled(bool enabled) async {
    await _sharedPreferences.setBool('location_sharing_enabled', enabled);
    AppLogger.info('Location sharing enabled: $enabled');
  }

  @override
  Future<int> getDefaultReminderMinutes() async =>
      _sharedPreferences.getInt('default_reminder_minutes') ?? 10;

  @override
  Future<void> setDefaultReminderMinutes(int minutes) async {
    await _sharedPreferences.setInt('default_reminder_minutes', minutes);
    AppLogger.info('Default reminder minutes: $minutes');
  }

  @override
  Future<Duration> getCacheValidityDuration() async {
    final hours = _sharedPreferences.getInt('cache_validity_hours') ?? 24;
    return Duration(hours: hours);
  }

  @override
  Future<void> setCacheValidityDuration(Duration duration) async {
    await _sharedPreferences.setInt('cache_validity_hours', duration.inHours);
    AppLogger.info('Cache validity duration: ${duration.inHours} hours');
  }

  @override
  Future<void> clearAllCache() async {
    // Clear cached data keys
    await _sharedPreferences.remove(AppConstants.cachedAnnouncementsKey);
    await _sharedPreferences.remove(AppConstants.cachedEventsKey);
    AppLogger.info('All cache cleared');
  }

  @override
  Future<void> clearAppData() async {
    await _sharedPreferences.clear();
    AppLogger.info('App data cleared');
  }

  @override
  Future<Map<String, int>> getStorageUsage() async {
    // This is a simplified implementation
    // In production, you'd calculate actual storage usage
    return {
      'cache': 1024 * 1024 * 10, // 10 MB
      'database': 1024 * 1024 * 5, // 5 MB
      'preferences': 1024 * 100, // 100 KB
    };
  }

  @override
  Future<String> getAppVersion() async => AppConstants.appVersion;

  @override
  Future<String> getBuildNumber() async => '1';

  @override
  Future<void> resetToDefaults() async {
    await _sharedPreferences.remove(AppConstants.languageKey);
    await _sharedPreferences.remove(AppConstants.themeKey);
    await _sharedPreferences.remove(AppConstants.notificationsEnabledKey);
    await _sharedPreferences.remove(AppConstants.biometricEnabledKey);
    await _sharedPreferences.remove('analytics_enabled');
    await _sharedPreferences.remove('location_sharing_enabled');
    await _sharedPreferences.remove('default_reminder_minutes');
    await _sharedPreferences.remove('cache_validity_hours');
    await _sharedPreferences.remove('notification_preferences');
    AppLogger.info('Settings reset to defaults');
  }

  @override
  Future<String> exportSettings() async {
    final settings = {
      'language': (await getLanguage()).code,
      'themeMode': (await getThemeMode()).name,
      'notificationsEnabled': await areNotificationsEnabled(),
      'biometricEnabled': await isBiometricEnabled(),
      'analyticsEnabled': await isAnalyticsEnabled(),
      'locationSharingEnabled': await isLocationSharingEnabled(),
      'defaultReminderMinutes': await getDefaultReminderMinutes(),
      'cacheValidityHours': (await getCacheValidityDuration()).inHours,
      'notificationPreferences': await getNotificationPreferences(),
    };
    return jsonEncode(settings);
  }

  @override
  Future<void> importSettings(String jsonSettings) async {
    final Map<String, dynamic> settings = jsonDecode(jsonSettings);

    if (settings['language'] != null) {
      final lang = AppLanguage.values.firstWhere(
        (l) => l.code == settings['language'],
        orElse: () => AppLanguage.english,
      );
      await setLanguage(lang);
    }

    if (settings['themeMode'] != null) {
      final mode = ThemeMode.values.firstWhere(
        (m) => m.name == settings['themeMode'],
        orElse: () => ThemeMode.system,
      );
      await setThemeMode(mode);
    }

    if (settings['notificationsEnabled'] != null) {
      await setNotificationsEnabled(settings['notificationsEnabled'] as bool);
    }

    if (settings['biometricEnabled'] != null) {
      await setBiometricEnabled(settings['biometricEnabled'] as bool);
    }

    if (settings['analyticsEnabled'] != null) {
      await setAnalyticsEnabled(settings['analyticsEnabled'] as bool);
    }

    if (settings['locationSharingEnabled'] != null) {
      await setLocationSharingEnabled(settings['locationSharingEnabled'] as bool);
    }

    if (settings['defaultReminderMinutes'] != null) {
      await setDefaultReminderMinutes(settings['defaultReminderMinutes'] as int);
    }

    if (settings['cacheValidityHours'] != null) {
      await setCacheValidityDuration(
          Duration(hours: settings['cacheValidityHours'] as int),);
    }

    if (settings['notificationPreferences'] != null) {
      final prefs =
          (settings['notificationPreferences'] as Map<String, dynamic>)
              .map((k, v) => MapEntry(k, v as bool));
      for (final entry in prefs.entries) {
        await setNotificationPreference(key: entry.key, enabled: entry.value);
      }
    }

    AppLogger.info('Settings imported successfully');
  }
}
