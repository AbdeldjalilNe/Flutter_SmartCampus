import '../../../../domain/entities/event.dart';
import '../../../../domain/entities/check_in.dart';

abstract class EventRemoteDataSource {
  Future<List<Event>> getEvents({EventCategory? category, EventStatus? status});
  Future<Event> getEventById(String id);
  Future<List<Event>> getUpcomingEvents();
  Future<List<Event>> getOngoingEvents();
  Future<List<Event>> getRegisteredEvents();
  Future<Event> registerForEvent(String eventId);
  Future<Event> unregisterFromEvent(String eventId);
  Future<CheckIn> checkInToEvent(Map<String, dynamic> data);
  Future<List<CheckIn>> getEventCheckIns(String eventId);
  Future<String> generateCheckInQrCode(String eventId);
  Future<String> validateCheckInQrCode(String qrData);
  Future<Event> createEvent(Map<String, dynamic> data);
  Future<Event> updateEvent(String id, Map<String, dynamic> data);
  Future<void> deleteEvent(String id);
  Future<List<Event>> searchEvents(String query);
}

class EventRemoteDataSourceImpl implements EventRemoteDataSource {
  EventRemoteDataSourceImpl();

  @override
  Future<List<Event>> getEvents({EventCategory? category, EventStatus? status}) async => [];

  @override
  Future<Event> getEventById(String id) async {
    throw Exception();
  }

  @override
  Future<List<Event>> getUpcomingEvents() async => [];

  @override
  Future<List<Event>> getOngoingEvents() async => [];

  @override
  Future<List<Event>> getRegisteredEvents() async => [];

  @override
  Future<Event> registerForEvent(String eventId) async {
    throw Exception();
  }

  @override
  Future<Event> unregisterFromEvent(String eventId) async {
    throw Exception();
  }

  @override
  Future<CheckIn> checkInToEvent(Map<String, dynamic> data) async {
    throw Exception();
  }

  @override
  Future<List<CheckIn>> getEventCheckIns(String eventId) async => [];

  @override
  Future<String> generateCheckInQrCode(String eventId) async => '';

  @override
  Future<String> validateCheckInQrCode(String qrData) async => '';

  @override
  Future<Event> createEvent(Map<String, dynamic> data) async {
    throw Exception();
  }

  @override
  Future<Event> updateEvent(String id, Map<String, dynamic> data) async {
    throw Exception();
  }

  @override
  Future<void> deleteEvent(String id) async {}

  @override
  Future<List<Event>> searchEvents(String query) async => [];
}
