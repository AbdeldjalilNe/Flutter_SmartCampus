import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/logger.dart';
import '../../../domain/entities/event.dart';
import '../../../domain/repositories/event_repository.dart';

part 'event_event.dart';
part 'event_state.dart';

class EventBloc extends Bloc<EventEvent, EventState> {
  EventBloc({required EventRepository repository})
      : _repository = repository,
        super(const EventState()) {
    on<LoadEvents>(_onLoadEvents);
    on<RefreshEvents>(_onRefreshEvents);
    on<RegisterForEvent>(_onRegisterForEvent);
    on<UnregisterFromEvent>(_onUnregisterFromEvent);
    on<CheckInToEvent>(_onCheckInToEvent);
    on<SearchEvents>(_onSearchEvents);
    on<FilterByCategory>(_onFilterByCategory);
  }
  final EventRepository _repository;

  Future<void> _onLoadEvents(
    LoadEvents event,
    Emitter<EventState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final result = await _repository.getEvents(
      forceRefresh: event.forceRefresh,
      category: event.category,
      status: event.status,
    );

    result.fold(
      (failure) {
        AppLogger.error('Failed to load events', failure);
        emit(state.copyWith(
          isLoading: false,
          error: failure.message,
        ),);
      },
      (events) {
        AppLogger.info('Loaded ${events.length} events');
        emit(state.copyWith(
          isLoading: false,
          events: events,
          filteredEvents: events,
        ),);
      },
    );
  }

  Future<void> _onRefreshEvents(
    RefreshEvents event,
    Emitter<EventState> emit,
  ) async {
    add(const LoadEvents(forceRefresh: true));
  }

  Future<void> _onRegisterForEvent(
    RegisterForEvent event,
    Emitter<EventState> emit,
  ) async {
    final result = await _repository.registerForEvent(event.eventId);

    result.fold(
      (failure) {
        AppLogger.error('Failed to register for event', failure);
        emit(state.copyWith(error: failure.message));
      },
      (updatedEvent) {
        final updatedEvents = state.events
            .map((e) => e.id == updatedEvent.id ? updatedEvent : e)
            .toList();

        emit(state.copyWith(events: updatedEvents));
        AppLogger.info('Registered for event: ${event.eventId}');
      },
    );
  }

  Future<void> _onUnregisterFromEvent(
    UnregisterFromEvent event,
    Emitter<EventState> emit,
  ) async {
    final result = await _repository.unregisterFromEvent(event.eventId);

    result.fold(
      (failure) {
        AppLogger.error('Failed to unregister from event', failure);
        emit(state.copyWith(error: failure.message));
      },
      (updatedEvent) {
        final updatedEvents = state.events
            .map((e) => e.id == updatedEvent.id ? updatedEvent : e)
            .toList();

        emit(state.copyWith(events: updatedEvents));
        AppLogger.info('Unregistered from event: ${event.eventId}');
      },
    );
  }

  Future<void> _onCheckInToEvent(
    CheckInToEvent event,
    Emitter<EventState> emit,
  ) async {
    emit(state.copyWith(isCheckingIn: true));

    final result = await _repository.checkInToEvent(
      eventId: event.eventId,
      qrCodeData: event.qrCodeData,
    );

    result.fold(
      (failure) {
        AppLogger.error('Failed to check in', failure);
        emit(state.copyWith(
          isCheckingIn: false,
          error: failure.message,
        ),);
      },
      (checkIn) {
        emit(state.copyWith(
          isCheckingIn: false,
          lastCheckIn: checkIn,
        ),);
        AppLogger.info('Checked in to event: ${event.eventId}');
      },
    );
  }

  Future<void> _onSearchEvents(
    SearchEvents event,
    Emitter<EventState> emit,
  ) async {
    if (event.query.isEmpty) {
      emit(state.copyWith(
        filteredEvents: state.events,
        searchQuery: '',
      ),);
      return;
    }

    emit(state.copyWith(isLoading: true));

    final result = await _repository.searchEvents(event.query);

    result.fold(
      (failure) {
        emit(state.copyWith(
          isLoading: false,
          error: failure.message,
        ),);
      },
      (events) {
        emit(state.copyWith(
          isLoading: false,
          filteredEvents: events,
          searchQuery: event.query,
        ),);
      },
    );
  }

  Future<void> _onFilterByCategory(
    FilterByCategory event,
    Emitter<EventState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final result = await _repository.getEvents(
      category: event.category,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(
          isLoading: false,
          error: failure.message,
        ),);
      },
      (events) {
        emit(state.copyWith(
          isLoading: false,
          filteredEvents: events,
          selectedCategory: event.category,
        ),);
      },
    );
  }
}
