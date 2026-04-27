part of 'settings_bloc.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {}

class ChangeLanguage extends SettingsEvent {
  const ChangeLanguage({required this.language});
  final AppLanguage language;

  @override
  List<Object?> get props => [language];
}

class ChangeThemeMode extends SettingsEvent {
  const ChangeThemeMode({required this.mode});
  final ThemeMode mode;

  @override
  List<Object?> get props => [mode];
}

class ToggleNotifications extends SettingsEvent {
  const ToggleNotifications({required this.enabled});
  final bool enabled;

  @override
  List<Object?> get props => [enabled];
}

class ToggleBiometric extends SettingsEvent {
  const ToggleBiometric({required this.enabled});
  final bool enabled;

  @override
  List<Object?> get props => [enabled];
}

class ToggleAnalytics extends SettingsEvent {
  const ToggleAnalytics({required this.enabled});
  final bool enabled;

  @override
  List<Object?> get props => [enabled];
}

class ToggleLocationSharing extends SettingsEvent {
  const ToggleLocationSharing({required this.enabled});
  final bool enabled;

  @override
  List<Object?> get props => [enabled];
}

class ChangeDefaultReminder extends SettingsEvent {
  const ChangeDefaultReminder({required this.minutes});
  final int minutes;

  @override
  List<Object?> get props => [minutes];
}

class ClearCache extends SettingsEvent {}

class ResetSettings extends SettingsEvent {}

class ExportSettings extends SettingsEvent {}

class ImportSettings extends SettingsEvent {
  const ImportSettings({required this.jsonSettings});
  final String jsonSettings;

  @override
  List<Object?> get props => [jsonSettings];
}
