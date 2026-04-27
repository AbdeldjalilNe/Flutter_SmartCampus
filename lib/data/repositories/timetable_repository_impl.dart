import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../domain/entities/timetable_item.dart';
import '../../../../domain/repositories/timetable_repository.dart';
import '../datasources/local/timetable_local_datasource.dart';

class TimetableRepositoryImpl implements TimetableRepository {

  TimetableRepositoryImpl({
    required this.localDataSource,
  });
  final TimetableLocalDataSource localDataSource;

  @override
  Future<Either<CacheFailure, List<TimetableItem>>> getTimetable() async => Right([]);

  @override
  Future<Either<CacheFailure, TimetableItem>> getTimetableItemById(String id) async => Left(CacheFailure(message: 'Not implemented'));

  @override
  Future<Either<CacheFailure, List<TimetableItem>>> getTimetableForDay(DayOfWeek day) async => Right([]);

  @override
  Future<Either<CacheFailure, TimetableItem>> addTimetableItem(TimetableItem item) async => Right(item);

  @override
  Future<Either<CacheFailure, TimetableItem>> updateTimetableItem(TimetableItem item) async => Right(item);

  @override
  Future<Either<CacheFailure, void>> deleteTimetableItem(String id) async => Right(null);

  @override
  Future<Either<CacheFailure, List<TimetableItem>>> getUpcomingClasses() async => Right([]);

  @override
  Future<Either<CacheFailure, TimetableItem?>> getNextClass() async => Right(null);

  @override
  Future<Either<CacheFailure, List<TimetableItem>>> getClassesForDate(DateTime date) async => Right([]);

  @override
  Future<Either<CacheFailure, List<TimetableItem>>> findConflicts(TimetableItem item) async => Right([]);

  @override
  Future<Either<CacheFailure, bool>> hasConflicts(TimetableItem item) async => Right(false);

  @override
  Future<Either<CacheFailure, void>> scheduleClassReminder(String itemId) async => Right(null);

  @override
  Future<Either<CacheFailure, void>> cancelClassReminder(String itemId) async => Right(null);

  @override
  Future<Either<CacheFailure, void>> updateReminderSettings({
    required String itemId,
    required bool enabled,
    int? reminderMinutesBefore,
  }) async => Right(null);

  @override
  Future<Either<Failure, String>> exportToJson() async => Right('{}');

  @override
  Future<Either<Failure, List<TimetableItem>>> importFromJson(String jsonData) async => Right([]);

  @override
  Future<Either<CacheFailure, void>> addMultipleItems(List<TimetableItem> items) async => Right(null);

  @override
  Future<Either<CacheFailure, void>> deleteAllItems() async => Right(null);

  @override
  Future<Either<CacheFailure, Map<DayOfWeek, int>>> getClassCountByDay() async => Right({});

  @override
  Future<Either<CacheFailure, int>> getTotalWeeklyHours() async => Right(0);
}
