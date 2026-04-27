import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/errors/failures.dart';
import '../../../core/utils/logger.dart';
import '../../../domain/repositories/settings_repository.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc({required SettingsRepository repository})
      : _repository = repository,
        super(const SettingsState()) {
    on<LoadSettings>(_onLoadSettings);
    on<ChangeLanguage>(_onChangeLanguage);
    on<ChangeThemeMode>(_onChangeThemeMode);
    on<ToggleNotifications>(_onToggleNotifications);
    on<ToggleBiometric>(_onToggleBiometric);
    on<ToggleAnalytics>(_onToggleAnalytics);
    on<ToggleLocationSharing>(_onToggleLocationSharing);
    on<ChangeDefaultReminder>(_onChangeDefaultReminder);
    on<ClearCache>(_onClearCache);
    on<ResetSettings>(_onResetSettings);
    on<ExportSettings>(_onExportSettings);
    on<ImportSettings>(_onImportSettings);
  }
  final SettingsRepository _repository;

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final results = await Future.wait([
      _repository.getLanguage(),
      _repository.getThemeMode(),
      _repository.areNotificationsEnabled(),
      _repository.isBiometricEnabled(),
      _repository.isAnalyticsEnabled(),
      _repository.isLocationSharingEnabled(),
      _repository.getDefaultReminderMinutes(),
      _repository.getStorageUsage(),
    ]);

    final language = (results[0] as Either<Failure, AppLanguage>).getOrElse(() => AppLanguage.english);
    final themeMode = (results[1] as Either<Failure, ThemeMode>).getOrElse(() => ThemeMode.system);
    final notificationsEnabled = (results[2] as Either<Failure, bool>).getOrElse(() => true);
    final biometricEnabled = (results[3] as Either<Failure, bool>).getOrElse(() => false);
    final analyticsEnabled = (results[4] as Either<Failure, bool>).getOrElse(() => true);
    final locationSharingEnabled = (results[5] as Either<Failure, bool>).getOrElse(() => false);
    final defaultReminder = (results[6] as Either<Failure, int>).getOrElse(() => 10);
    final storageUsage = (results[7] as Either<Failure, Map<String, int>>).getOrElse(() => {});

    emit(state.copyWith(
      isLoading: false,
      language: language,
      themeMode: themeMode,
      notificationsEnabled: notificationsEnabled,
      biometricEnabled: biometricEnabled,
      analyticsEnabled: analyticsEnabled,
      locationSharingEnabled: locationSharingEnabled,
      defaultReminderMinutes: defaultReminder,
      storageUsage: storageUsage,
    ),);

    AppLogger.info('Settings loaded');
  }

  Future<void> _onChangeLanguage(
    ChangeLanguage event,
    Emitter<SettingsState> emit,
  ) async {
    final result = await _repository.setLanguage(event.language);

    result.fold(
      (failure) {
        AppLogger.error('Failed to change language', failure);
        emit(state.copyWith(error: failure.message));
      },
      (_) {
        emit(state.copyWith(language: event.language));
        AppLogger.info('Language changed to: ${event.language.displayName}');
      },
    );
  }

  Future<void> _onChangeThemeMode(
    ChangeThemeMode event,
    Emitter<SettingsState> emit,
  ) async {
    final result = await _repository.setThemeMode(event.mode);

    result.fold(
      (failure) {
        AppLogger.error('Failed to change theme', failure);
        emit(state.copyWith(error: failure.message));
      },
      (_) {
        emit(state.copyWith(themeMode: event.mode));
        AppLogger.info('Theme mode changed to: ${event.mode}');
      },
    );
  }

  Future<void> _onToggleNotifications(
    ToggleNotifications event,
    Emitter<SettingsState> emit,
  ) async {
    final result = await _repository.setNotificationsEnabled(event.enabled);

    result.fold(
      (failure) {
        AppLogger.error('Failed to toggle notifications', failure);
        emit(state.copyWith(error: failure.message));
      },
      (_) {
        emit(state.copyWith(notificationsEnabled: event.enabled));
        AppLogger.info('Notifications enabled: ${event.enabled}');
      },
    );
  }

  Future<void> _onToggleBiometric(
    ToggleBiometric event,
    Emitter<SettingsState> emit,
  ) async {
    final result = await _repository.setBiometricEnabled(event.enabled);

    result.fold(
      (failure) {
        AppLogger.error('Failed to toggle biometric', failure);
        emit(state.copyWith(error: failure.message));
      },
      (_) {
        emit(state.copyWith(biometricEnabled: event.enabled));
        AppLogger.info('Biometric enabled: ${event.enabled}');
      },
    );
  }

  Future<void> _onToggleAnalytics(
    ToggleAnalytics event,
    Emitter<SettingsState> emit,
  ) async {
    final result = await _repository.setAnalyticsEnabled(event.enabled);

    result.fold(
      (failure) {
        AppLogger.error('Failed to toggle analytics', failure);
        emit(state.copyWith(error: failure.message));
      },
      (_) {
        emit(state.copyWith(analyticsEnabled: event.enabled));
        AppLogger.info('Analytics enabled: ${event.enabled}');
      },
    );
  }

  Future<void> _onToggleLocationSharing(
    ToggleLocationSharing event,
    Emitter<SettingsState> emit,
  ) async {
    final result = await _repository.setLocationSharingEnabled(event.enabled);

    result.fold(
      (failure) {
        AppLogger.error('Failed to toggle location sharing', failure);
        emit(state.copyWith(error: failure.message));
      },
      (_) {
        emit(state.copyWith(locationSharingEnabled: event.enabled));
        AppLogger.info('Location sharing enabled: ${event.enabled}');
      },
    );
  }

  Future<void> _onChangeDefaultReminder(
    ChangeDefaultReminder event,
    Emitter<SettingsState> emit,
  ) async {
    final result = await _repository.setDefaultReminderMinutes(event.minutes);

    result.fold(
      (failure) {
        AppLogger.error('Failed to change default reminder', failure);
        emit(state.copyWith(error: failure.message));
      },
      (_) {
        emit(state.copyWith(defaultReminderMinutes: event.minutes));
        AppLogger.info('Default reminder minutes: ${event.minutes}');
      },
    );
  }

  Future<void> _onClearCache(
    ClearCache event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final result = await _repository.clearAllCache();

    result.fold(
      (failure) {
        AppLogger.error('Failed to clear cache', failure);
        emit(state.copyWith(
          isLoading: false,
          error: failure.message,
        ),);
      },
      (_) async {
        final storageResult = await _repository.getStorageUsage();
        final storageUsage = storageResult.getOrElse(() => {});

        emit(state.copyWith(
          isLoading: false,
          storageUsage: storageUsage,
        ),);
        AppLogger.info('Cache cleared');
      },
    );
  }

  Future<void> _onResetSettings(
    ResetSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final result = await _repository.resetToDefaults();

    result.fold(
      (failure) {
        AppLogger.error('Failed to reset settings', failure);
        emit(state.copyWith(
          isLoading: false,
          error: failure.message,
        ),);
      },
      (_) {
        emit(const SettingsState());
        AppLogger.info('Settings reset to defaults');
      },
    );
  }

  Future<void> _onExportSettings(
    ExportSettings event,
    Emitter<SettingsState> emit,
  ) async {
    final result = await _repository.exportSettings();

    result.fold(
      (failure) {
        AppLogger.error('Failed to export settings', failure);
        emit(state.copyWith(error: failure.message));
      },
      (settingsJson) {
        emit(state.copyWith(
          exportedSettings: settingsJson,
        ),);
        AppLogger.info('Settings exported');
      },
    );
  }

  Future<void> _onImportSettings(
    ImportSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final result = await _repository.importSettings(event.jsonSettings);

    result.fold(
      (failure) {
        AppLogger.error('Failed to import settings', failure);
        emit(state.copyWith(
          isLoading: false,
          error: failure.message,
        ),);
      },
      (_) {
        add(LoadSettings());
        AppLogger.info('Settings imported');
      },
    );
  }
}
