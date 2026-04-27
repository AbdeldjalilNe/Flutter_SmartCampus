part of 'announcement_bloc.dart';

class AnnouncementState extends Equatable {
  const AnnouncementState({
    this.announcements = const [],
    this.filteredAnnouncements = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
    this.selectedCategory,
  });
  final List<Announcement> announcements;
  final List<Announcement> filteredAnnouncements;
  final bool isLoading;
  final String? error;
  final String searchQuery;
  final AnnouncementCategory? selectedCategory;

  AnnouncementState copyWith({
    List<Announcement>? announcements,
    List<Announcement>? filteredAnnouncements,
    bool? isLoading,
    String? error,
    String? searchQuery,
    AnnouncementCategory? selectedCategory,
  }) =>
      AnnouncementState(
        announcements: announcements ?? this.announcements,
        filteredAnnouncements:
            filteredAnnouncements ?? this.filteredAnnouncements,
        isLoading: isLoading ?? this.isLoading,
        error: error,
        searchQuery: searchQuery ?? this.searchQuery,
        selectedCategory: selectedCategory ?? this.selectedCategory,
      );

  int get unreadCount => announcements.where((a) => !a.isRead).length;
  int get urgentCount => announcements.where((a) => a.isUrgent).length;

  List<Announcement> get unreadAnnouncements =>
      announcements.where((a) => !a.isRead).toList();

  List<Announcement> get urgentAnnouncements =>
      announcements.where((a) => a.isUrgent).toList();

  @override
  List<Object?> get props => [
        announcements,
        filteredAnnouncements,
        isLoading,
        error,
        searchQuery,
        selectedCategory,
      ];
}
