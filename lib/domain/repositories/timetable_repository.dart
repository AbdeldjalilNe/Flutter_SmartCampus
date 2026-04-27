import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/timetable_item.dart';

abstract class TimetableRepository {
  // CRUD operations
  Future<Either<CacheFailure, List<TimetableItem>>> getTimetable();
  
  Future<Either<CacheFailure, TimetableItem>> getTimetableItemById(String id);
  
  Future<Either<CacheFailure, List<TimetableItem>>> getTimetableForDay(
    DayOfWeek day,
  );
  
  Future<Either<CacheFailure, TimetableItem>> addTimetableItem(
    TimetableItem item,
  );
  
  Future<Either<CacheFailure, TimetableItem>> updateTimetableItem(
    TimetableItem item,
  );
  
  Future<Either<CacheFailure, void>> deleteTimetableItem(String id);
  
  // Schedule queries
  Future<Either<CacheFailure, List<TimetableItem>>> getUpcomingClasses();
  
  Future<Either<CacheFailure, TimetableItem?>> getNextClass();
  
  Future<Either<CacheFailure, List<TimetableItem>>> getClassesForDate(
    DateTime date,
  );
  
  // Conflict detection
  Future<Either<CacheFailure, List<TimetableItem>>> findConflicts(
    TimetableItem item,
  );
  
  Future<Either<CacheFailure, bool>> hasConflicts(TimetableItem item);
  
  // Notifications
  Future<Either<CacheFailure, void>> scheduleClassReminder(String itemId);
  
  Future<Either<CacheFailure, void>> cancelClassReminder(String itemId);
  
  Future<Either<CacheFailure, void>> updateReminderSettings({
    required String itemId,
    required bool enabled,
    int? reminderMinutesBefore,
  });
  
  // Import/Export
  Future<Either<Failure, String>> exportToJson();
  
  Future<Either<Failure, List<TimetableItem>>> importFromJson(String jsonData);
  
  // Bulk operations
  Future<Either<CacheFailure, void>> addMultipleItems(
    List<TimetableItem> items,
  );
  
  Future<Either<CacheFailure, void>> deleteAllItems();
  
  // Statistics
  Future<Either<CacheFailure, Map<DayOfWeek, int>>> getClassCountByDay();
  
  Future<Either<CacheFailure, int>> getTotalWeeklyHours();
}
