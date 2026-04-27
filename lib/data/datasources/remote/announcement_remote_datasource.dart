import '../../../../domain/entities/announcement.dart';

abstract class AnnouncementRemoteDataSource {
  Future<List<Announcement>> getAnnouncements({
    AnnouncementCategory? category,
    AnnouncementPriority? priority,
  });
  Future<Announcement> getAnnouncementById(String id);
  Future<List<Announcement>> getUnreadAnnouncements();
  Future<List<Announcement>> getUrgentAnnouncements();
  Future<List<Announcement>> searchAnnouncements(String query);
  Future<Announcement> createAnnouncement(Map<String, dynamic> data);
  Future<Announcement> updateAnnouncement(String id, Map<String, dynamic> data);
  Future<void> deleteAnnouncement(String id);
}

class AnnouncementRemoteDataSourceImpl implements AnnouncementRemoteDataSource {
  AnnouncementRemoteDataSourceImpl();

  @override
  Future<List<Announcement>> getAnnouncements({
    AnnouncementCategory? category,
    AnnouncementPriority? priority,
  }) async => [];

  @override
  Future<Announcement> getAnnouncementById(String id) async {
    throw Exception();
  }

  @override
  Future<List<Announcement>> getUnreadAnnouncements() async => [];

  @override
  Future<List<Announcement>> getUrgentAnnouncements() async => [];

  @override
  Future<List<Announcement>> searchAnnouncements(String query) async => [];

  @override
  Future<Announcement> createAnnouncement(Map<String, dynamic> data) async {
    throw Exception();
  }

  @override
  Future<Announcement> updateAnnouncement(String id, Map<String, dynamic> data) async {
    throw Exception();
  }

  @override
  Future<void> deleteAnnouncement(String id) async {}
}
