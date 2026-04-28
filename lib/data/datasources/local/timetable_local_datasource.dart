import '../../../../domain/entities/timetable_item.dart';

abstract class TimetableLocalDataSource {
  Future<List<TimetableItem>> getTimetable();
  Future<TimetableItem> getTimetableItemById(String id);
  Future<List<TimetableItem>> getTimetableForDay(DayOfWeek day);
  Future<TimetableItem> addTimetableItem(TimetableItem item);
  Future<TimetableItem> updateTimetableItem(TimetableItem item);
  Future<void> deleteTimetableItem(String id);
  Future<List<TimetableItem>> getClassesForDate(DateTime date);
  Future<Map<DayOfWeek, int>> getClassCountByDay();
  Future<void> saveTimetable(List<TimetableItem> items);
  Future<void> deleteAllItems();
  Future<void> updateReminderSettings(String itemId, bool enabled, int? reminderMinutes);
}

class TimetableLocalDataSourceImpl implements TimetableLocalDataSource {
  TimetableLocalDataSourceImpl();

  @override
  Future<List<TimetableItem>> getTimetable() async => [];

  @override
  Future<TimetableItem> getTimetableItemById(String id) async {
    throw Exception();
  }

  @override
  Future<List<TimetableItem>> getTimetableForDay(DayOfWeek day) async => [];

  @override
  Future<TimetableItem> addTimetableItem(TimetableItem item) async => item;

  @override
  Future<TimetableItem> updateTimetableItem(TimetableItem item) async => item;

  @override
  Future<void> deleteTimetableItem(String id) async {}

  @override
  Future<List<TimetableItem>> getClassesForDate(DateTime date) async => [];

  @override
  Future<Map<DayOfWeek, int>> getClassCountByDay() async => {};

  @override
  Future<void> saveTimetable(List<TimetableItem> items) async {}

  @override
  Future<void> deleteAllItems() async {}

  @override
  Future<void> updateReminderSettings(String itemId, bool enabled, int? reminderMinutes) async {}
}
