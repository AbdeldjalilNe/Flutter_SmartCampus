part of 'timetable_bloc.dart';

class TimetableState extends Equatable {
  const TimetableState({
    this.items = const [],
    this.isLoading = false,
    this.error,
    this.exportedJson,
  });
  final List<TimetableItem> items;
  final bool isLoading;
  final String? error;
  final String? exportedJson;

  TimetableState copyWith({
    List<TimetableItem>? items,
    bool? isLoading,
    String? error,
    String? exportedJson,
  }) =>
      TimetableState(
        items: items ?? this.items,
        isLoading: isLoading ?? this.isLoading,
        error: error,
        exportedJson: exportedJson ?? this.exportedJson,
      );

  List<TimetableItem> getItemsForDay(DayOfWeek day) =>
      items.where((item) => item.dayOfWeek == day).toList()
        ..sort((a, b) => a.startTime.compareTo(b.startTime));

  List<TimetableItem> get upcomingClasses {
    final now = DateTime.now();
    return items.where((item) {
      final nextOccurrence = item.getNextOccurrence();
      return nextOccurrence != null && nextOccurrence.isAfter(now);
    }).toList();
  }

  int get totalWeeklyHours => items.fold<int>(
        0,
        (sum, item) => sum + item.duration.inHours,
      );

  @override
  List<Object?> get props => [items, isLoading, error, exportedJson];
}
