import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/check_in.dart';
import '../entities/event.dart';

abstract class EventRepository {
  // Get events
  Future<Either<Failure, List<Event>>> getEvents({
    bool forceRefresh = false,
    EventCategory? category,
    EventStatus? status,
  });

  Future<Either<Failure, Event>> getEventById(String id);

  Future<Either<Failure, List<Event>>> getUpcomingEvents();

  Future<Either<Failure, List<Event>>> getOngoingEvents();

  Future<Either<Failure, List<Event>>> getRegisteredEvents();

  // Registration
  Future<Either<ServerFailure, Event>> registerForEvent(String eventId);

  Future<Either<ServerFailure, Event>> unregisterFromEvent(String eventId);

  // Check-in
  Future<Either<Failure, CheckIn>> checkInToEvent({
    required String eventId,
    String? qrCodeData,
    double? latitude,
    double? longitude,
  });

  Future<Either<Failure, bool>> hasCheckedIn(String eventId);

  Future<Either<Failure, List<CheckIn>>> getEventCheckIns(String eventId);

  // QR Code
  Future<Either<Failure, String>> generateCheckInQrCode(String eventId);

  Future<Either<Failure, String>> validateCheckInQrCode(String qrData);

  // Admin operations
  Future<Either<ServerFailure, Event>> createEvent({
    required String title,
    required String description,
    required String location,
    required DateTime startTime,
    required DateTime endTime,
    required EventCategory category,
    int? maxAttendees,
    String? imageUrl,
    bool requiresCheckIn = false,
  });

  Future<Either<ServerFailure, Event>> updateEvent({
    required String id,
    String? title,
    String? description,
    String? location,
    DateTime? startTime,
    DateTime? endTime,
    EventCategory? category,
    EventStatus? status,
    int? maxAttendees,
    String? imageUrl,
  });

  Future<Either<ServerFailure, void>> deleteEvent(String id);

  // Search
  Future<Either<Failure, List<Event>>> searchEvents(String query);

  // Cache management
  Future<Either<CacheFailure, void>> clearCache();

  Future<Either<CacheFailure, DateTime?>> getLastSyncTime();

  // Sync
  Future<Either<Failure, void>> syncEvents();
}
