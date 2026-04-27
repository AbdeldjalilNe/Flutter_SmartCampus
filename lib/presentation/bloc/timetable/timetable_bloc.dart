import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/logger.dart';
import '../../../domain/entities/timetable_item.dart';
import '../../../domain/repositories/timetable_repository.dart';

part 'timetable_event.dart';
part 'timetable_state.dart';

class TimetableBloc extends Bloc<TimetableEvent, TimetableState> {
  TimetableBloc({required TimetableRepository repository})
      : _repository = repository,
        super(const TimetableState()) {
    on<LoadTimetable>(_onLoadTimetable);
    on<AddTimetableItem>(_onAddTimetableItem);
    on<UpdateTimetableItem>(_onUpdateTimetableItem);
    on<DeleteTimetableItem>(_onDeleteTimetableItem);
    on<ExportTimetable>(_onExportTimetable);
    on<ImportTimetable>(_onImportTimetable);
    on<ToggleNotification>(_onToggleNotification);
  }
  final TimetableRepository _repository;

  Future<void> _onLoadTimetable(
    LoadTimetable event,
    Emitter<TimetableState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final result = await _repository.getTimetable();

    result.fold(
      (failure) {
        AppLogger.error('Failed to load timetable', failure);
        emit(state.copyWith(
          isLoading: false,
          error: failure.message,
        ),);
      },
      (items) {
        AppLogger.info('Loaded ${items.length} timetable items');
        emit(state.copyWith(
          isLoading: false,
          items: items,
        ),);
      },
    );
  }

  Future<void> _onAddTimetableItem(
    AddTimetableItem event,
    Emitter<TimetableState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final result = await _repository.addTimetableItem(event.item);

    result.fold(
      (failure) {
        AppLogger.error('Failed to add timetable item', failure);
        emit(state.copyWith(
          isLoading: false,
          error: failure.message,
        ),);
      },
      (item) {
        final updatedItems = [...state.items, item];
        emit(state.copyWith(
          isLoading: false,
          items: updatedItems,
        ),);
        AppLogger.info('Added timetable item: ${item.id}');
      },
    );
  }

  Future<void> _onUpdateTimetableItem(
    UpdateTimetableItem event,
    Emitter<TimetableState> emit,
  ) async {
    final result = await _repository.updateTimetableItem(event.item);

    result.fold(
      (failure) {
        AppLogger.error('Failed to update timetable item', failure);
        emit(state.copyWith(error: failure.message));
      },
      (item) {
        final updatedItems =
            state.items.map((i) => i.id == item.id ? item : i).toList();

        emit(state.copyWith(items: updatedItems));
        AppLogger.info('Updated timetable item: ${item.id}');
      },
    );
  }

  Future<void> _onDeleteTimetableItem(
    DeleteTimetableItem event,
    Emitter<TimetableState> emit,
  ) async {
    final result = await _repository.deleteTimetableItem(event.id);

    result.fold(
      (failure) {
        AppLogger.error('Failed to delete timetable item', failure);
        emit(state.copyWith(error: failure.message));
      },
      (_) {
        final updatedItems =
            state.items.where((i) => i.id != event.id).toList();

        emit(state.copyWith(items: updatedItems));
        AppLogger.info('Deleted timetable item: ${event.id}');
      },
    );
  }

  Future<void> _onExportTimetable(
    ExportTimetable event,
    Emitter<TimetableState> emit,
  ) async {
    final result = await _repository.exportToJson();

    result.fold(
      (failure) {
        AppLogger.error('Failed to export timetable', failure);
        emit(state.copyWith(error: failure.message));
      },
      (json) {
        emit(state.copyWith(exportedJson: json));
        AppLogger.info('Timetable exported');
      },
    );
  }

  Future<void> _onImportTimetable(
    ImportTimetable event,
    Emitter<TimetableState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final result = await _repository.importFromJson(event.json);

    result.fold(
      (failure) {
        AppLogger.error('Failed to import timetable', failure);
        emit(state.copyWith(
          isLoading: false,
          error: failure.message,
        ),);
      },
      (items) {
        emit(state.copyWith(
          isLoading: false,
          items: items,
        ),);
        AppLogger.info('Timetable imported with ${items.length} items');
      },
    );
  }

  Future<void> _onToggleNotification(
    ToggleNotification event,
    Emitter<TimetableState> emit,
  ) async {
    final result = await _repository.updateReminderSettings(
      itemId: event.itemId,
      enabled: event.enabled,
    );

    result.fold(
      (failure) {
        AppLogger.error('Failed to toggle notification', failure);
        emit(state.copyWith(error: failure.message));
      },
      (_) {
        final updatedItems = state.items.map((item) {
          if (item.id == event.itemId) {
            return item.copyWith(notificationEnabled: event.enabled);
          }
          return item;
        }).toList();

        emit(state.copyWith(items: updatedItems));
        AppLogger.info('Notification toggled for: ${event.itemId}');
      },
    );
  }
}
