import '../../../../domain/entities/event.dart';
import '../../../../domain/entities/check_in.dart';

abstract class EventLocalDataSource {
  Future<List<Event>> getCachedEvents();
  Future<void> cacheEvents(List<Event> events);
  Future<Event> getCachedEventById(String id);
  Future<void> cacheEvent(Event event);
  Future<void> clearCache();
  Future<DateTime?> getLastSyncTime();
  Future<void> saveCheckIn(CheckIn checkIn);
  Future<List<CheckIn>> getCheckIns(String eventId);
  Future<bool> hasCheckedIn(String eventId);
}

class EventLocalDataSourceImpl implements EventLocalDataSource {
  EventLocalDataSourceImpl();

  @override
  Future<List<Event>> getCachedEvents() async => [];

  @override
  Future<void> cacheEvents(List<Event> events) async {}

  @override
  Future<Event> getCachedEventById(String id) async {
    throw Exception();
  }

  @override
  Future<void> cacheEvent(Event event) async {}

  @override
  Future<void> clearCache() async {}

  @override
  Future<DateTime?> getLastSyncTime() async => null;

  @override
  Future<void> saveCheckIn(CheckIn checkIn) async {}

  @override
  Future<List<CheckIn>> getCheckIns(String eventId) async => [];

  @override
  Future<bool> hasCheckedIn(String eventId) async => false;
}
