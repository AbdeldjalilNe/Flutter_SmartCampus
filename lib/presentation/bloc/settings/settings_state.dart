part of 'settings_bloc.dart';

class SettingsState extends Equatable {
  const SettingsState({
    this.isLoading = false,
    this.language = AppLanguage.english,
    this.themeMode = ThemeMode.system,
    this.notificationsEnabled = true,
    this.biometricEnabled = false,
    this.analyticsEnabled = true,
    this.locationSharingEnabled = false,
    this.defaultReminderMinutes = 10,
    this.storageUsage = const {},
    this.exportedSettings,
    this.error,
  });
  final bool isLoading;
  final AppLanguage language;
  final ThemeMode themeMode;
  final bool notificationsEnabled;
  final bool biometricEnabled;
  final bool analyticsEnabled;
  final bool locationSharingEnabled;
  final int defaultReminderMinutes;
  final Map<String, int> storageUsage;
  final String? exportedSettings;
  final String? error;

  SettingsState copyWith({
    bool? isLoading,
    AppLanguage? language,
    ThemeMode? themeMode,
    bool? notificationsEnabled,
    bool? biometricEnabled,
    bool? analyticsEnabled,
    bool? locationSharingEnabled,
    int? defaultReminderMinutes,
    Map<String, int>? storageUsage,
    String? exportedSettings,
    String? error,
  }) =>
      SettingsState(
        isLoading: isLoading ?? this.isLoading,
        language: language ?? this.language,
        themeMode: themeMode ?? this.themeMode,
        notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
        biometricEnabled: biometricEnabled ?? this.biometricEnabled,
        analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
        locationSharingEnabled:
            locationSharingEnabled ?? this.locationSharingEnabled,
        defaultReminderMinutes:
            defaultReminderMinutes ?? this.defaultReminderMinutes,
        storageUsage: storageUsage ?? this.storageUsage,
        exportedSettings: exportedSettings ?? this.exportedSettings,
        error: error,
      );

  int get totalStorageUsed =>
      storageUsage.values.fold(0, (sum, value) => sum + value);

  String get formattedStorageUsage {
    final bytes = totalStorageUsed;
    if (bytes >= 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    } else if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else {
      return '$bytes B';
    }
  }

  @override
  List<Object?> get props => [
        isLoading,
        language,
        themeMode,
        notificationsEnabled,
        biometricEnabled,
        analyticsEnabled,
        locationSharingEnabled,
        defaultReminderMinutes,
        storageUsage,
        exportedSettings,
        error,
      ];
}
