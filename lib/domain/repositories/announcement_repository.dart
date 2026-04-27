import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/announcement.dart';

abstract class AnnouncementRepository {
  // Get announcements
  Future<Either<Failure, List<Announcement>>> getAnnouncements({
    bool forceRefresh = false,
    AnnouncementCategory? category,
    AnnouncementPriority? priority,
  });
  
  Future<Either<Failure, Announcement>> getAnnouncementById(String id);
  
  Future<Either<Failure, List<Announcement>>> getUnreadAnnouncements();
  
  Future<Either<Failure, List<Announcement>>> getUrgentAnnouncements();
  
  // Mark as read
  Future<Either<CacheFailure, void>> markAsRead(String id);
  
  Future<Either<CacheFailure, void>> markAllAsRead();
  
  // Search and filter
  Future<Either<Failure, List<Announcement>>> searchAnnouncements(
    String query,
  );
  
  // Admin operations (for staff/admin users)
  Future<Either<ServerFailure, Announcement>> createAnnouncement({
    required String title,
    required String content,
    required AnnouncementCategory category,
    AnnouncementPriority priority = AnnouncementPriority.normal,
    DateTime? expiresAt,
    String? imageUrl,
  });
  
  Future<Either<ServerFailure, Announcement>> updateAnnouncement({
    required String id,
    String? title,
    String? content,
    AnnouncementCategory? category,
    AnnouncementPriority? priority,
    DateTime? expiresAt,
    String? imageUrl,
  });
  
  Future<Either<ServerFailure, void>> deleteAnnouncement(String id);
  
  // Cache management
  Future<Either<CacheFailure, void>> clearCache();
  
  Future<Either<CacheFailure, DateTime?>> getLastSyncTime();
  
  // Sync
  Future<Either<Failure, void>> syncAnnouncements();
}
