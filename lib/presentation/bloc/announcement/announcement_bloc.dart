import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/logger.dart';
import '../../../domain/entities/announcement.dart';
import '../../../domain/repositories/announcement_repository.dart';

part 'announcement_event.dart';
part 'announcement_state.dart';

class AnnouncementBloc extends Bloc<AnnouncementEvent, AnnouncementState> {
  AnnouncementBloc({required AnnouncementRepository repository})
      : _repository = repository,
        super(const AnnouncementState()) {
    on<LoadAnnouncements>(_onLoadAnnouncements);
    on<RefreshAnnouncements>(_onRefreshAnnouncements);
    on<MarkAnnouncementAsRead>(_onMarkAnnouncementAsRead);
    on<MarkAllAnnouncementsAsRead>(_onMarkAllAnnouncementsAsRead);
    on<SearchAnnouncements>(_onSearchAnnouncements);
    on<FilterByCategory>(_onFilterByCategory);
    on<CreateAnnouncement>(_onCreateAnnouncement);
    on<DeleteAnnouncement>(_onDeleteAnnouncement);
  }
  final AnnouncementRepository _repository;

  Future<void> _onLoadAnnouncements(
    LoadAnnouncements event,
    Emitter<AnnouncementState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final result = await _repository.getAnnouncements(
      forceRefresh: event.forceRefresh,
      category: event.category,
      priority: event.priority,
    );

    result.fold(
      (failure) {
        AppLogger.error('Failed to load announcements', failure);
        emit(state.copyWith(
          isLoading: false,
          error: failure.message,
        ),);
      },
      (announcements) {
        AppLogger.info('Loaded ${announcements.length} announcements');
        emit(state.copyWith(
          isLoading: false,
          announcements: announcements,
          filteredAnnouncements: announcements,
        ),);
      },
    );
  }

  Future<void> _onRefreshAnnouncements(
    RefreshAnnouncements event,
    Emitter<AnnouncementState> emit,
  ) async {
    add(const LoadAnnouncements(forceRefresh: true));
  }

  Future<void> _onMarkAnnouncementAsRead(
    MarkAnnouncementAsRead event,
    Emitter<AnnouncementState> emit,
  ) async {
    final result = await _repository.markAsRead(event.id);

    result.fold(
      (failure) {
        AppLogger.error('Failed to mark announcement as read', failure);
      },
      (_) {
        // Update local state
        final updatedAnnouncements = state.announcements.map((a) {
          if (a.id == event.id) {
            return a.copyWith(isRead: true, readAt: DateTime.now());
          }
          return a;
        }).toList();

        emit(state.copyWith(announcements: updatedAnnouncements));
        AppLogger.info('Announcement marked as read: ${event.id}');
      },
    );
  }

  Future<void> _onMarkAllAnnouncementsAsRead(
    MarkAllAnnouncementsAsRead event,
    Emitter<AnnouncementState> emit,
  ) async {
    final result = await _repository.markAllAsRead();

    result.fold(
      (failure) {
        AppLogger.error('Failed to mark all announcements as read', failure);
      },
      (_) {
        final updatedAnnouncements = state.announcements
            .map((a) => a.copyWith(isRead: true, readAt: DateTime.now()))
            .toList();

        emit(state.copyWith(announcements: updatedAnnouncements));
        AppLogger.info('All announcements marked as read');
      },
    );
  }

  Future<void> _onSearchAnnouncements(
    SearchAnnouncements event,
    Emitter<AnnouncementState> emit,
  ) async {
    if (event.query.isEmpty) {
      emit(state.copyWith(
        filteredAnnouncements: state.announcements,
        searchQuery: '',
      ),);
      return;
    }

    emit(state.copyWith(isLoading: true));

    final result = await _repository.searchAnnouncements(event.query);

    result.fold(
      (failure) {
        emit(state.copyWith(
          isLoading: false,
          error: failure.message,
        ),);
      },
      (announcements) {
        emit(state.copyWith(
          isLoading: false,
          filteredAnnouncements: announcements,
          searchQuery: event.query,
        ),);
      },
    );
  }

  Future<void> _onFilterByCategory(
    FilterByCategory event,
    Emitter<AnnouncementState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final result = await _repository.getAnnouncements(
      category: event.category,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(
          isLoading: false,
          error: failure.message,
        ),);
      },
      (announcements) {
        emit(state.copyWith(
          isLoading: false,
          filteredAnnouncements: announcements,
          selectedCategory: event.category,
        ),);
      },
    );
  }

  Future<void> _onCreateAnnouncement(
    CreateAnnouncement event,
    Emitter<AnnouncementState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final result = await _repository.createAnnouncement(
      title: event.title,
      content: event.content,
      category: event.category,
      priority: event.priority,
      expiresAt: event.expiresAt,
      imageUrl: event.imageUrl,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(
          isLoading: false,
          error: failure.message,
        ),);
      },
      (announcement) {
        final updatedAnnouncements = [announcement, ...state.announcements];
        emit(state.copyWith(
          isLoading: false,
          announcements: updatedAnnouncements,
          filteredAnnouncements: updatedAnnouncements,
        ),);
        AppLogger.info('Announcement created: ${announcement.id}');
      },
    );
  }

  Future<void> _onDeleteAnnouncement(
    DeleteAnnouncement event,
    Emitter<AnnouncementState> emit,
  ) async {
    final result = await _repository.deleteAnnouncement(event.id);

    result.fold(
      (failure) {
        AppLogger.error('Failed to delete announcement', failure);
      },
      (_) {
        final updatedAnnouncements =
            state.announcements.where((a) => a.id != event.id).toList();
        emit(state.copyWith(
          announcements: updatedAnnouncements,
          filteredAnnouncements: updatedAnnouncements,
        ),);
        AppLogger.info('Announcement deleted: ${event.id}');
      },
    );
  }
}
