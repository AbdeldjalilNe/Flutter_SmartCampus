import 'dart:ui';

class AppConstants {
  // App Info
  static const String appName = 'SmartCampus Companion';
  static const String appVersion = '1.0.0';

  // API Endpoints (Using JSONPlaceholder for demo)
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';
  static const String postsEndpoint = '/posts';
  static const String usersEndpoint = '/users';
  static const String commentsEndpoint = '/comments';

  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String settingsKey = 'app_settings';
  static const String cachedAnnouncementsKey = 'cached_announcements';
  static const String cachedEventsKey = 'cached_events';
  static const String timetableKey = 'timetable_data';
  static const String languageKey = 'app_language';
  static const String themeKey = 'app_theme';
  static const String notificationsEnabledKey = 'notifications_enabled';
  static const String biometricEnabledKey = 'biometric_enabled';

  // Database
  static const String databaseName = 'smartcampus.db';
  static const int databaseVersion = 1;

  // Notification Channels
  static const String reminderChannelId = 'reminder_channel';
  static const String reminderChannelName = 'Class Reminders';
  static const String reminderChannelDesc =
      'Notifications for upcoming classes';
  static const String alertChannelId = 'alert_channel';
  static const String alertChannelName = 'Campus Alerts';
  static const String alertChannelDesc = 'Important campus announcements';

  // Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds

  // Cache Duration
  static const Duration cacheValidityDuration = Duration(hours: 24);
  static const Duration announcementCacheDuration = Duration(hours: 6);

  // Location Settings
  static const double defaultLatitude = 37.7749; // San Francisco
  static const double defaultLongitude = -122.4194;
  static const double campusRadiusMeters = 2000; // 2km radius

  // Campus POIs
  static final List<CampusLocation> campusLocations = [
    const CampusLocation(
      id: 'library',
      name: 'University Library',
      latitude: 37.7749,
      longitude: -122.4194,
      type: LocationType.building,
      description: 'Main campus library with study areas',
    ),
    const CampusLocation(
      id: 'cafeteria',
      name: 'Student Cafeteria',
      latitude: 37.7755,
      longitude: -122.4188,
      type: LocationType.dining,
      description: 'Main dining hall with various food options',
    ),
    const CampusLocation(
      id: 'gym',
      name: 'Sports Complex',
      latitude: 37.7742,
      longitude: -122.4200,
      type: LocationType.sports,
      description: 'Gymnasium and sports facilities',
    ),
    const CampusLocation(
      id: 'admin',
      name: 'Administration Building',
      latitude: 37.7750,
      longitude: -122.4190,
      type: LocationType.building,
      description: 'Student services and administration offices',
    ),
    const CampusLocation(
      id: 'parking',
      name: 'Main Parking',
      latitude: 37.7735,
      longitude: -122.4205,
      type: LocationType.parking,
      description: 'Student and staff parking area',
    ),
  ];
}

class CampusLocation {
  const CampusLocation({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.type,
    required this.description,
  });
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final LocationType type;
  final String description;
}

enum LocationType {
  building,
  dining,
  sports,
  parking,
  emergency,
  other,
}

enum AppLanguage {
  english('en', 'US', 'English'),
  french('fr', 'FR', 'Français'),
  arabic('ar', 'SA', 'العربية');

  final String code;
  final String country;
  final String displayName;

  const AppLanguage(this.code, this.country, this.displayName);

  Locale get locale => Locale(code, country);
}

enum UserRole {
  student,
  staff,
  admin,
}
