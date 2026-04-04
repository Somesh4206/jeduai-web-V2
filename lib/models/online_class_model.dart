import 'package:flutter/material.dart';

/// Online Class Model
class OnlineClass {
  final String id;
  final String title;
  final String subject;
  final String teacherName;
  final String teacherId;
  final DateTime scheduledTime;
  final int duration; // in minutes
  final String meetingLink;
  ClassStatus status;
  final List<String> enrolledStudents;
  final int maxStudents;
  final String description;
  final String classCode;
  final String? recordingLink;
  final List<String>? attachments;

  OnlineClass({
    required this.id,
    required this.title,
    required this.subject,
    required this.teacherName,
    required this.teacherId,
    required this.scheduledTime,
    required this.duration,
    required this.meetingLink,
    required this.status,
    required this.enrolledStudents,
    required this.maxStudents,
    required this.description,
    required this.classCode,
    this.recordingLink,
    this.attachments,
  });

  // Get end time
  DateTime get endTime => scheduledTime.add(Duration(minutes: duration));

  // Check if class is happening now
  bool get isLive => status == ClassStatus.live;

  // Check if class is upcoming
  bool get isUpcoming => status == ClassStatus.scheduled;

  // Check if class is full
  bool get isFull => enrolledStudents.length >= maxStudents;

  // Get available seats
  int get availableSeats => maxStudents - enrolledStudents.length;

  // Get formatted time
  String get formattedTime {
    final hour = scheduledTime.hour;
    final minute = scheduledTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  // Get formatted date
  String get formattedDate {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${scheduledTime.day} ${months[scheduledTime.month - 1]} ${scheduledTime.year}';
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subject': subject,
      'teacherName': teacherName,
      'teacherId': teacherId,
      'scheduledTime': scheduledTime.toIso8601String(),
      'duration': duration,
      'meetingLink': meetingLink,
      'status': status.toString(),
      'enrolledStudents': enrolledStudents,
      'maxStudents': maxStudents,
      'description': description,
      'classCode': classCode,
      'recordingLink': recordingLink,
      'attachments': attachments,
    };
  }

  // Create from JSON
  factory OnlineClass.fromJson(Map<String, dynamic> json) {
    return OnlineClass(
      id: json['id'],
      title: json['title'],
      subject: json['subject'],
      teacherName: json['teacherName'],
      teacherId: json['teacherId'],
      scheduledTime: DateTime.parse(json['scheduledTime']),
      duration: json['duration'],
      meetingLink: json['meetingLink'],
      status: ClassStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => ClassStatus.scheduled,
      ),
      enrolledStudents: List<String>.from(json['enrolledStudents']),
      maxStudents: json['maxStudents'],
      description: json['description'],
      classCode: json['classCode'],
      recordingLink: json['recordingLink'],
      attachments: json['attachments'] != null
          ? List<String>.from(json['attachments'])
          : null,
    );
  }
}

/// Class Status Enum
enum ClassStatus { scheduled, live, completed, cancelled }

/// Class Notification Model
class ClassNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final String classId;
  final DateTime timestamp;
  bool isRead;

  ClassNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.classId,
    required this.timestamp,
    this.isRead = false,
  });

  // Get time ago string
  String get timeAgo {
    final difference = DateTime.now().difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.toString(),
      'classId': classId,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }

  // Create from JSON
  factory ClassNotification.fromJson(Map<String, dynamic> json) {
    return ClassNotification(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => NotificationType.classUpdated,
      ),
      classId: json['classId'],
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['isRead'] ?? false,
    );
  }
}

/// Notification Type Enum
enum NotificationType {
  newClass,
  classStarted,
  reminder,
  classCancelled,
  classUpdated,
}

/// Extension for ClassStatus
extension ClassStatusExtension on ClassStatus {
  String get displayName {
    switch (this) {
      case ClassStatus.scheduled:
        return 'Scheduled';
      case ClassStatus.live:
        return 'Live Now';
      case ClassStatus.completed:
        return 'Completed';
      case ClassStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get color {
    switch (this) {
      case ClassStatus.scheduled:
        return const Color(0xFF2196F3);
      case ClassStatus.live:
        return const Color(0xFF4CAF50);
      case ClassStatus.completed:
        return const Color(0xFF9E9E9E);
      case ClassStatus.cancelled:
        return const Color(0xFFF44336);
    }
  }

  IconData get icon {
    switch (this) {
      case ClassStatus.scheduled:
        return Icons.schedule;
      case ClassStatus.live:
        return Icons.play_circle_filled;
      case ClassStatus.completed:
        return Icons.check_circle;
      case ClassStatus.cancelled:
        return Icons.cancel;
    }
  }
}
