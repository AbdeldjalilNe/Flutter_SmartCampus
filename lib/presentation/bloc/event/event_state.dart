part of 'event_bloc.dart';

class EventState extends Equatable {
  const EventState({
    this.events = const [],
    this.filteredEvents = const [],
    this.isLoading = false,
    this.isCheckingIn = false,
    this.error,
    this.searchQuery = '',
    this.selectedCategory,
    this.lastCheckIn,
  });
  final List<Event> events;
  final List<Event> filteredEvents;
  final bool isLoading;
  final bool isCheckingIn;
  final String? error;
  final String searchQuery;
  final EventCategory? selectedCategory;
  final dynamic lastCheckIn;

  EventState copyWith({
    List<Event>? events,
    List<Event>? filteredEvents,
    bool? isLoading,
    bool? isCheckingIn,
    String? error,
    String? searchQuery,
    EventCategory? selectedCategory,
    dynamic lastCheckIn,
  }) =>
      EventState(
        events: events ?? this.events,
        filteredEvents: filteredEvents ?? this.filteredEvents,
        isLoading: isLoading ?? this.isLoading,
        isCheckingIn: isCheckingIn ?? this.isCheckingIn,
        error: error,
        searchQuery: searchQuery ?? this.searchQuery,
        selectedCategory: selectedCategory ?? this.selectedCategory,
        lastCheckIn: lastCheckIn ?? this.lastCheckIn,
      );

  List<Event> get upcomingEvents => events.where((e) => e.isUpcoming).toList();

  List<Event> get ongoingEvents => events.where((e) => e.isOngoing).toList();

  List<Event> get registeredEvents =>
      events.where((e) => e.isRegistered).toList();

  @override
  List<Object?> get props => [
        events,
        filteredEvents,
        isLoading,
        isCheckingIn,
        error,
        searchQuery,
        selectedCategory,
        lastCheckIn,
      ];
}
