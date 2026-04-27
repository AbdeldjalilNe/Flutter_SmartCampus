part of 'event_bloc.dart';

abstract class EventEvent extends Equatable {
  const EventEvent();

  @override
  List<Object?> get props => [];
}

class LoadEvents extends EventEvent {
  const LoadEvents({
    this.forceRefresh = false,
    this.category,
    this.status,
  });
  final bool forceRefresh;
  final EventCategory? category;
  final EventStatus? status;

  @override
  List<Object?> get props => [forceRefresh, category, status];
}

class RefreshEvents extends EventEvent {}

class RegisterForEvent extends EventEvent {
  const RegisterForEvent({required this.eventId});
  final String eventId;

  @override
  List<Object?> get props => [eventId];
}

class UnregisterFromEvent extends EventEvent {
  const UnregisterFromEvent({required this.eventId});
  final String eventId;

  @override
  List<Object?> get props => [eventId];
}

class CheckInToEvent extends EventEvent {
  const CheckInToEvent({
    required this.eventId,
    this.qrCodeData,
  });
  final String eventId;
  final String? qrCodeData;

  @override
  List<Object?> get props => [eventId, qrCodeData];
}

class SearchEvents extends EventEvent {
  const SearchEvents({required this.query});
  final String query;

  @override
  List<Object?> get props => [query];
}

class FilterByCategory extends EventEvent {
  const FilterByCategory({this.category});
  final EventCategory? category;

  @override
  List<Object?> get props => [category];
}
