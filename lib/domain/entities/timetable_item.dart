import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum DayOfWeek {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday,
}

class TimetableItem extends Equatable {
  const TimetableItem({
    required this.id,
    required this.courseName,
    required this.courseCode,
    required this.instructor,
    required this.room,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.color,
    this.notificationEnabled = true,
    this.reminderMinutesBefore = 10,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory TimetableItem.fromJson(Map<String, dynamic> json) => TimetableItem(
      id: json['id'] as String,
      courseName: json['courseName'] as String,
      courseCode: json['courseCode'] as String,
      instructor: json['instructor'] as String,
      room: json['room'] as String,
      dayOfWeek: DayOfWeek.values[json['dayOfWeek'] as int],
      startTime: TimeOfDay(
        hour: json['startTimeHour'] as int,
        minute: json['startTimeMinute'] as int,
      ),
      endTime: TimeOfDay(
        hour: json['endTimeHour'] as int,
        minute: json['endTimeMinute'] as int,
      ),
      color: json['color'] != null ? Color(json['color'] as int) : null,
      notificationEnabled: json['notificationEnabled'] as bool? ?? true,
      reminderMinutesBefore: json['reminderMinutesBefore'] as int? ?? 10,
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  final String id;
  final String courseName;
  final String courseCode;
  final String instructor;
  final String room;
  final DayOfWeek dayOfWeek;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final Color? color;
  final bool notificationEnabled;
  final int reminderMinutesBefore;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get displayTime =>
      '${startTime.formatAsString()} - ${endTime.formatAsString()}';

  String get shortCode => courseCode.toUpperCase();

  Duration get duration {
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;
    return Duration(minutes: endMinutes - startMinutes);
  }

  String get formattedDuration {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) {
      return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
    }
    return '${minutes}m';
  }

  bool isAtSameTime(TimetableItem other) =>
      dayOfWeek == other.dayOfWeek &&
      startTime.hour == other.startTime.hour &&
      startTime.minute == other.startTime.minute;

  bool overlapsWith(TimetableItem other) {
    if (dayOfWeek != other.dayOfWeek) return false;

    final thisStart = startTime.hour * 60 + startTime.minute;
    final thisEnd = endTime.hour * 60 + endTime.minute;
    final otherStart = other.startTime.hour * 60 + other.startTime.minute;
    final otherEnd = other.endTime.hour * 60 + other.endTime.minute;

    return thisStart < otherEnd && thisEnd > otherStart;
  }

  DateTime? getNextOccurrence() {
    final now = DateTime.now();
    final currentWeekday = now.weekday; // 1 = Monday, 7 = Sunday
    final targetWeekday = dayOfWeek.index + 1;

    int daysUntil;
    if (targetWeekday >= currentWeekday) {
      daysUntil = targetWeekday - currentWeekday;
    } else {
      daysUntil = 7 - (currentWeekday - targetWeekday);
    }

    var nextDate = DateTime(
      now.year,
      now.month,
      now.day + daysUntil,
      startTime.hour,
      startTime.minute,
    );

    // If the time has already passed today, move to next week
    if (daysUntil == 0 && now.isAfter(nextDate)) {
      nextDate = nextDate.add(const Duration(days: 7));
    }

    return nextDate;
  }

  DateTime getReminderTime() {
    final nextOccurrence = getNextOccurrence();
    if (nextOccurrence == null) {
      throw Exception('Could not calculate next occurrence');
    }
    return nextOccurrence.subtract(Duration(minutes: reminderMinutesBefore));
  }

  TimetableItem copyWith({
    String? id,
    String? courseName,
    String? courseCode,
    String? instructor,
    String? room,
    DayOfWeek? dayOfWeek,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    Color? color,
    bool? notificationEnabled,
    int? reminderMinutesBefore,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      TimetableItem(
        id: id ?? this.id,
        courseName: courseName ?? this.courseName,
        courseCode: courseCode ?? this.courseCode,
        instructor: instructor ?? this.instructor,
        room: room ?? this.room,
        dayOfWeek: dayOfWeek ?? this.dayOfWeek,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        color: color ?? this.color,
        notificationEnabled: notificationEnabled ?? this.notificationEnabled,
        reminderMinutesBefore:
            reminderMinutesBefore ?? this.reminderMinutesBefore,
        notes: notes ?? this.notes,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'courseName': courseName,
        'courseCode': courseCode,
        'instructor': instructor,
        'room': room,
        'dayOfWeek': dayOfWeek.index,
        'startTimeHour': startTime.hour,
        'startTimeMinute': startTime.minute,
        'endTimeHour': endTime.hour,
        'endTimeMinute': endTime.minute,
        'color': color?.value,
        'notificationEnabled': notificationEnabled,
        'reminderMinutesBefore': reminderMinutesBefore,
        'notes': notes,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  @override
  List<Object?> get props => [
        id,
        courseName,
        courseCode,
        instructor,
        room,
        dayOfWeek,
        startTime,
        endTime,
        color,
        notificationEnabled,
        reminderMinutesBefore,
        notes,
        createdAt,
        updatedAt,
      ];
}

// Extension for TimeOfDay
extension TimeOfDayExtension on TimeOfDay {
  String formatAsString() {
    final hour = this.hour.toString().padLeft(2, '0');
    final minute = this.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  int compareTo(TimeOfDay other) {
    if (hour != other.hour) {
      return hour.compareTo(other.hour);
    }
    return minute.compareTo(other.minute);
  }

  bool isBefore(TimeOfDay other) => compareTo(other) < 0;
  bool isAfter(TimeOfDay other) => compareTo(other) > 0;
}

// Extension for DayOfWeek
extension DayOfWeekExtension on DayOfWeek {
  String get displayName {
    switch (this) {
      case DayOfWeek.monday:
        return 'Monday';
      case DayOfWeek.tuesday:
        return 'Tuesday';
      case DayOfWeek.wednesday:
        return 'Wednesday';
      case DayOfWeek.thursday:
        return 'Thursday';
      case DayOfWeek.friday:
        return 'Friday';
      case DayOfWeek.saturday:
        return 'Saturday';
      case DayOfWeek.sunday:
        return 'Sunday';
    }
  }

  String get shortName => displayName.substring(0, 3);
}
