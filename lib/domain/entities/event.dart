import 'package:equatable/equatable.dart';

enum EventCategory {
  academic,
  social,
  sports,
  career,
  cultural,
  workshop,
  seminar,
  other,
}

enum EventStatus {
  upcoming,
  ongoing,
  completed,
  cancelled,
}

class Event extends Equatable {
  const Event({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.startTime,
    required this.endTime,
    required this.organizer,
    required this.organizerId,
    this.category = EventCategory.other,
    this.status = EventStatus.upcoming,
    this.maxAttendees,
    this.currentAttendees = 0,
    this.imageUrl,
    this.tags,
    this.requiresCheckIn = false,
    this.checkInCode,
    this.isRegistered = false,
    this.registeredAt,
    this.cachedAt,
  });

  factory Event.fromJson(Map<String, dynamic> json) => Event(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      location: json['location'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      organizer: json['organizer'] as String,
      organizerId: json['organizerId'] as String,
      category: EventCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => EventCategory.other,
      ),
      status: EventStatus.values[json['status'] as int? ?? 0],
      maxAttendees: json['maxAttendees'] as int?,
      currentAttendees: json['currentAttendees'] as int? ?? 0,
      imageUrl: json['imageUrl'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      requiresCheckIn: json['requiresCheckIn'] as bool? ?? false,
      checkInCode: json['checkInCode'] as String?,
      isRegistered: json['isRegistered'] as bool? ?? false,
      registeredAt: json['registeredAt'] != null
          ? DateTime.parse(json['registeredAt'] as String)
          : null,
      cachedAt: json['cachedAt'] != null
          ? DateTime.parse(json['cachedAt'] as String)
          : null,
    );
  final String id;
  final String title;
  final String description;
  final String location;
  final DateTime startTime;
  final DateTime endTime;
  final String organizer;
  final String organizerId;
  final EventCategory category;
  final EventStatus status;
  final int? maxAttendees;
  final int currentAttendees;
  final String? imageUrl;
  final List<String>? tags;
  final bool requiresCheckIn;
  final String? checkInCode;
  final bool isRegistered;
  final DateTime? registeredAt;
  final DateTime? cachedAt;

  bool get isFull => maxAttendees != null && currentAttendees >= maxAttendees!;

  bool get hasAvailableSpots => !isFull;

  bool get isOngoing {
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(endTime);
  }

  bool get isUpcoming => DateTime.now().isBefore(startTime);

  bool get isPast => DateTime.now().isAfter(endTime);

  Duration get duration => endTime.difference(startTime);

  String get formattedDuration {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) {
      return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
    }
    return '${minutes}m';
  }

  String get timeRange {
    final start =
        '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
    final end =
        '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
    return '$start - $end';
  }

  String get dateDisplay {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDate = DateTime(startTime.year, startTime.month, startTime.day);
    final difference = eventDate.difference(today).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Tomorrow';
    if (difference == -1) return 'Yesterday';
    if (difference > 1 && difference < 7) {
      final weekdays = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ];
      return weekdays[startTime.weekday - 1];
    }
    return '${startTime.day}/${startTime.month}/${startTime.year}';
  }

  int? get availableSpots =>
      maxAttendees != null ? maxAttendees! - currentAttendees : null;

  double? get occupancyPercentage =>
      maxAttendees != null ? (currentAttendees / maxAttendees!) * 100 : null;

  Event copyWith({
    String? id,
    String? title,
    String? description,
    String? location,
    DateTime? startTime,
    DateTime? endTime,
    String? organizer,
    String? organizerId,
    EventCategory? category,
    EventStatus? status,
    int? maxAttendees,
    int? currentAttendees,
    String? imageUrl,
    List<String>? tags,
    bool? requiresCheckIn,
    String? checkInCode,
    bool? isRegistered,
    DateTime? registeredAt,
    DateTime? cachedAt,
  }) =>
      Event(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        location: location ?? this.location,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        organizer: organizer ?? this.organizer,
        organizerId: organizerId ?? this.organizerId,
        category: category ?? this.category,
        status: status ?? this.status,
        maxAttendees: maxAttendees ?? this.maxAttendees,
        currentAttendees: currentAttendees ?? this.currentAttendees,
        imageUrl: imageUrl ?? this.imageUrl,
        tags: tags ?? this.tags,
        requiresCheckIn: requiresCheckIn ?? this.requiresCheckIn,
        checkInCode: checkInCode ?? this.checkInCode,
        isRegistered: isRegistered ?? this.isRegistered,
        registeredAt: registeredAt ?? this.registeredAt,
        cachedAt: cachedAt ?? this.cachedAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'location': location,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'organizer': organizer,
        'organizerId': organizerId,
        'category': category.name,
        'status': status.index,
        'maxAttendees': maxAttendees,
        'currentAttendees': currentAttendees,
        'imageUrl': imageUrl,
        'tags': tags,
        'requiresCheckIn': requiresCheckIn,
        'checkInCode': checkInCode,
        'isRegistered': isRegistered,
        'registeredAt': registeredAt?.toIso8601String(),
        'cachedAt': cachedAt?.toIso8601String(),
      };

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        location,
        startTime,
        endTime,
        organizer,
        organizerId,
        category,
        status,
        maxAttendees,
        currentAttendees,
        imageUrl,
        tags,
        requiresCheckIn,
        checkInCode,
        isRegistered,
        registeredAt,
        cachedAt,
      ];
}

// Extension for category display
extension EventCategoryExtension on EventCategory {
  String get displayName {
    switch (this) {
      case EventCategory.academic:
        return 'Academic';
      case EventCategory.social:
        return 'Social';
      case EventCategory.sports:
        return 'Sports';
      case EventCategory.career:
        return 'Career';
      case EventCategory.cultural:
        return 'Cultural';
      case EventCategory.workshop:
        return 'Workshop';
      case EventCategory.seminar:
        return 'Seminar';
      case EventCategory.other:
        return 'Other';
    }
  }

  int get colorValue {
    switch (this) {
      case EventCategory.academic:
        return 0xFF6C63FF;
      case EventCategory.social:
        return 0xFFFF6584;
      case EventCategory.sports:
        return 0xFF00BFA6;
      case EventCategory.career:
        return 0xFF29B6F6;
      case EventCategory.cultural:
        return 0xFFAB47BC;
      case EventCategory.workshop:
        return 0xFFFFA726;
      case EventCategory.seminar:
        return 0xFF66BB6A;
      case EventCategory.other:
        return 0xFF9E9E9E;
    }
  }
}

// Extension for status display
extension EventStatusExtension on EventStatus {
  String get displayName {
    switch (this) {
      case EventStatus.upcoming:
        return 'Upcoming';
      case EventStatus.ongoing:
        return 'Ongoing';
      case EventStatus.completed:
        return 'Completed';
      case EventStatus.cancelled:
        return 'Cancelled';
    }
  }

  int get colorValue {
    switch (this) {
      case EventStatus.upcoming:
        return 0xFF29B6F6;
      case EventStatus.ongoing:
        return 0xFF4CAF50;
      case EventStatus.completed:
        return 0xFF9E9E9E;
      case EventStatus.cancelled:
        return 0xFFEF5350;
    }
  }
}
