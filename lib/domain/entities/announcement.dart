import 'package:equatable/equatable.dart';

enum AnnouncementPriority { low, normal, high, urgent }

enum AnnouncementCategory {
  general,
  academic,
  administrative,
  events,
  emergency,
  sports,
  career,
}

class Announcement extends Equatable {
  const Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.authorId,
    this.category = AnnouncementCategory.general,
    this.priority = AnnouncementPriority.normal,
    required this.createdAt,
    this.expiresAt,
    this.imageUrl,
    this.attachments,
    this.isRead = false,
    this.readAt,
    this.cachedAt,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) => Announcement(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      author: json['author'] as String,
      authorId: json['authorId'] as String,
      category: AnnouncementCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => AnnouncementCategory.general,
      ),
      priority: AnnouncementPriority.values[json['priority'] as int? ?? 1],
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
      imageUrl: json['imageUrl'] as String?,
      attachments: (json['attachments'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      isRead: json['isRead'] as bool? ?? false,
      readAt: json['readAt'] != null
          ? DateTime.parse(json['readAt'] as String)
          : null,
      cachedAt: json['cachedAt'] != null
          ? DateTime.parse(json['cachedAt'] as String)
          : null,
    );
  final String id;
  final String title;
  final String content;
  final String author;
  final String authorId;
  final AnnouncementCategory category;
  final AnnouncementPriority priority;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final String? imageUrl;
  final List<String>? attachments;
  final bool isRead;
  final DateTime? readAt;
  final DateTime? cachedAt;

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);

  bool get isUrgent => priority == AnnouncementPriority.urgent;

  bool get isHighPriority =>
      priority == AnnouncementPriority.high ||
      priority == AnnouncementPriority.urgent;

  String get summary =>
      content.length > 150 ? '${content.substring(0, 150)}...' : content;

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 30) {
      return '${difference.inDays ~/ 30} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  Announcement copyWith({
    String? id,
    String? title,
    String? content,
    String? author,
    String? authorId,
    AnnouncementCategory? category,
    AnnouncementPriority? priority,
    DateTime? createdAt,
    DateTime? expiresAt,
    String? imageUrl,
    List<String>? attachments,
    bool? isRead,
    DateTime? readAt,
    DateTime? cachedAt,
  }) =>
      Announcement(
        id: id ?? this.id,
        title: title ?? this.title,
        content: content ?? this.content,
        author: author ?? this.author,
        authorId: authorId ?? this.authorId,
        category: category ?? this.category,
        priority: priority ?? this.priority,
        createdAt: createdAt ?? this.createdAt,
        expiresAt: expiresAt ?? this.expiresAt,
        imageUrl: imageUrl ?? this.imageUrl,
        attachments: attachments ?? this.attachments,
        isRead: isRead ?? this.isRead,
        readAt: readAt ?? this.readAt,
        cachedAt: cachedAt ?? this.cachedAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'author': author,
        'authorId': authorId,
        'category': category.name,
        'priority': priority.index,
        'createdAt': createdAt.toIso8601String(),
        'expiresAt': expiresAt?.toIso8601String(),
        'imageUrl': imageUrl,
        'attachments': attachments,
        'isRead': isRead,
        'readAt': readAt?.toIso8601String(),
        'cachedAt': cachedAt?.toIso8601String(),
      };

  @override
  List<Object?> get props => [
        id,
        title,
        content,
        author,
        authorId,
        category,
        priority,
        createdAt,
        expiresAt,
        imageUrl,
        attachments,
        isRead,
        readAt,
        cachedAt,
      ];
}

// Extension for category display
extension AnnouncementCategoryExtension on AnnouncementCategory {
  String get displayName {
    switch (this) {
      case AnnouncementCategory.general:
        return 'General';
      case AnnouncementCategory.academic:
        return 'Academic';
      case AnnouncementCategory.administrative:
        return 'Administrative';
      case AnnouncementCategory.events:
        return 'Events';
      case AnnouncementCategory.emergency:
        return 'Emergency';
      case AnnouncementCategory.sports:
        return 'Sports';
      case AnnouncementCategory.career:
        return 'Career';
    }
  }

  int get colorValue {
    switch (this) {
      case AnnouncementCategory.general:
        return 0xFF6C63FF;
      case AnnouncementCategory.academic:
        return 0xFF00BFA6;
      case AnnouncementCategory.administrative:
        return 0xFFFFA726;
      case AnnouncementCategory.events:
        return 0xFF29B6F6;
      case AnnouncementCategory.emergency:
        return 0xFFEF5350;
      case AnnouncementCategory.sports:
        return 0xFFAB47BC;
      case AnnouncementCategory.career:
        return 0xFF66BB6A;
    }
  }
}

// Extension for priority display
extension AnnouncementPriorityExtension on AnnouncementPriority {
  String get displayName {
    switch (this) {
      case AnnouncementPriority.low:
        return 'Low';
      case AnnouncementPriority.normal:
        return 'Normal';
      case AnnouncementPriority.high:
        return 'High';
      case AnnouncementPriority.urgent:
        return 'Urgent';
    }
  }

  int get colorValue {
    switch (this) {
      case AnnouncementPriority.low:
        return 0xFF9E9E9E;
      case AnnouncementPriority.normal:
        return 0xFF4CAF50;
      case AnnouncementPriority.high:
        return 0xFFFFA726;
      case AnnouncementPriority.urgent:
        return 0xFFEF5350;
    }
  }
}
