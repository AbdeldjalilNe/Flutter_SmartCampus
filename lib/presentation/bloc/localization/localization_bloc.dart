import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/logger.dart';
import '../../../domain/repositories/settings_repository.dart';

part 'localization_event.dart';
part 'localization_state.dart';

class LocalizationBloc extends Bloc<LocalizationEvent, LocalizationState> {
  LocalizationBloc({required SettingsRepository settingsRepository})
      : _settingsRepository = settingsRepository,
        super(const LocalizationState()) {
    on<LoadLocalization>(_onLoadLocalization);
    on<ChangeLanguage>(_onChangeLanguage);
  }
  final SettingsRepository _settingsRepository;

  Future<void> _onLoadLocalization(
    LoadLocalization event,
    Emitter<LocalizationState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final result = await _settingsRepository.getLanguage();

    result.fold(
      (failure) {
        AppLogger.error('Failed to load language', failure);
        emit(state.copyWith(
          isLoading: false,
          locale: AppLanguage.english.locale,
        ),);
      },
      (language) {
        AppLogger.info('Language loaded: ${language.displayName}');
        emit(state.copyWith(
          isLoading: false,
          locale: language.locale,
          currentLanguage: language,
        ),);
      },
    );
  }

  Future<void> _onChangeLanguage(
    ChangeLanguage event,
    Emitter<LocalizationState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final result = await _settingsRepository.setLanguage(event.language);

    result.fold(
      (failure) {
        AppLogger.error('Failed to change language', failure);
        emit(state.copyWith(isLoading: false));
      },
      (_) {
        AppLogger.info('Language changed to: ${event.language.displayName}');
        emit(state.copyWith(
          isLoading: false,
          locale: event.language.locale,
          currentLanguage: event.language,
        ),);
      },
    );
  }
}
