import '../../../../domain/entities/announcement.dart';

abstract class AnnouncementLocalDataSource {
  Future<List<Announcement>> getCachedAnnouncements();
  Future<void> cacheAnnouncements(List<Announcement> announcements);
  Future<Announcement> getCachedAnnouncementById(String id);
  Future<void> cacheAnnouncement(Announcement announcement);
  Future<void> clearCache();
  Future<DateTime?> getLastSyncTime();
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
}

class AnnouncementLocalDataSourceImpl implements AnnouncementLocalDataSource {
  AnnouncementLocalDataSourceImpl({dynamic sharedPreferences});

  @override
  Future<List<Announcement>> getCachedAnnouncements() async => [];

  @override
  Future<void> cacheAnnouncements(List<Announcement> announcements) async {}

  @override
  Future<Announcement> getCachedAnnouncementById(String id) async {
    throw Exception();
  }

  @override
  Future<void> cacheAnnouncement(Announcement announcement) async {}

  @override
  Future<void> clearCache() async {}

  @override
  Future<DateTime?> getLastSyncTime() async => null;

  @override
  Future<void> markAsRead(String id) async {}

  @override
  Future<void> markAllAsRead() async {}
}
