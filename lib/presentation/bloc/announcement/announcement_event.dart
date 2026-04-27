part of 'announcement_bloc.dart';

abstract class AnnouncementEvent extends Equatable {
  const AnnouncementEvent();

  @override
  List<Object?> get props => [];
}

class LoadAnnouncements extends AnnouncementEvent {
  const LoadAnnouncements({
    this.forceRefresh = false,
    this.category,
    this.priority,
  });
  final bool forceRefresh;
  final AnnouncementCategory? category;
  final AnnouncementPriority? priority;

  @override
  List<Object?> get props => [forceRefresh, category, priority];
}

class RefreshAnnouncements extends AnnouncementEvent {}

class MarkAnnouncementAsRead extends AnnouncementEvent {
  const MarkAnnouncementAsRead({required this.id});
  final String id;

  @override
  List<Object?> get props => [id];
}

class MarkAllAnnouncementsAsRead extends AnnouncementEvent {}

class SearchAnnouncements extends AnnouncementEvent {
  const SearchAnnouncements({required this.query});
  final String query;

  @override
  List<Object?> get props => [query];
}

class FilterByCategory extends AnnouncementEvent {
  const FilterByCategory({this.category});
  final AnnouncementCategory? category;

  @override
  List<Object?> get props => [category];
}

class CreateAnnouncement extends AnnouncementEvent {
  const CreateAnnouncement({
    required this.title,
    required this.content,
    this.category = AnnouncementCategory.general,
    this.priority = AnnouncementPriority.normal,
    this.expiresAt,
    this.imageUrl,
  });
  final String title;
  final String content;
  final AnnouncementCategory category;
  final AnnouncementPriority priority;
  final DateTime? expiresAt;
  final String? imageUrl;

  @override
  List<Object?> get props =>
      [title, content, category, priority, expiresAt, imageUrl];
}

class DeleteAnnouncement extends AnnouncementEvent {
  const DeleteAnnouncement({required this.id});
  final String id;

  @override
  List<Object?> get props => [id];
}
