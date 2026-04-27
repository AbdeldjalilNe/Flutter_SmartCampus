import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../domain/entities/announcement.dart';
import '../../../../domain/repositories/announcement_repository.dart';
import '../datasources/local/announcement_local_datasource.dart';
import '../datasources/remote/announcement_remote_datasource.dart';

class AnnouncementRepositoryImpl implements AnnouncementRepository {

  AnnouncementRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    this.connectivity,
  });
  final AnnouncementRemoteDataSource remoteDataSource;
  final AnnouncementLocalDataSource localDataSource;
  final dynamic connectivity;

  @override
  Future<Either<Failure, List<Announcement>>> getAnnouncements({
    bool forceRefresh = false,
    AnnouncementCategory? category,
    AnnouncementPriority? priority,
  }) async => Right([]);

  @override
  Future<Either<Failure, Announcement>> getAnnouncementById(String id) async => Left(ServerFailure(message: 'Not implemented'));

  @override
  Future<Either<Failure, List<Announcement>>> getUnreadAnnouncements() async => Right([]);

  @override
  Future<Either<Failure, List<Announcement>>> getUrgentAnnouncements() async => Right([]);

  @override
  Future<Either<CacheFailure, void>> markAsRead(String id) async => Right(null);

  @override
  Future<Either<CacheFailure, void>> markAllAsRead() async => Right(null);

  @override
  Future<Either<Failure, List<Announcement>>> searchAnnouncements(String query) async => Right([]);

  @override
  Future<Either<ServerFailure, Announcement>> createAnnouncement({
    required String title,
    required String content,
    required AnnouncementCategory category,
    AnnouncementPriority priority = AnnouncementPriority.normal,
    DateTime? expiresAt,
    String? imageUrl,
  }) async => Left(ServerFailure(message: 'Not implemented'));

  @override
  Future<Either<ServerFailure, Announcement>> updateAnnouncement({
    required String id,
    String? title,
    String? content,
    AnnouncementCategory? category,
    AnnouncementPriority? priority,
    DateTime? expiresAt,
    String? imageUrl,
  }) async => Left(ServerFailure(message: 'Not implemented'));

  @override
  Future<Either<ServerFailure, void>> deleteAnnouncement(String id) async => Right(null);

  @override
  Future<Either<CacheFailure, void>> clearCache() async => Right(null);

  @override
  Future<Either<CacheFailure, DateTime?>> getLastSyncTime() async => Right(null);

  @override
  Future<Either<Failure, void>> syncAnnouncements() async => Right(null);
}
