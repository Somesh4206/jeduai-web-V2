import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Unified Notification Service for all portals
/// Sends notifications to Admin, Staff, and Students
class NotificationService extends GetxService {
  // All notifications across the system
  var allNotifications = <SystemNotification>[].obs;

  // Unread count per user
  var unreadCounts = <String, int>{}.obs;

  /// Send notification to specific users
  void sendNotification({
    required String title,
    required String message,
    required NotificationCategory category,
    required List<String> recipientIds,
    String? actionId,
    Map<String, dynamic>? data,
  }) {
    final notification = SystemNotification(
      id: 'NOT${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      message: message,
      category: category,
      recipientIds: recipientIds,
      timestamp: DateTime.now(),
      isRead: false,
      actionId: actionId,
      data: data,
    );

    allNotifications.insert(0, notification);

    // Update unread counts
    for (var recipientId in recipientIds) {
      unreadCounts[recipientId] = (unreadCounts[recipientId] ?? 0) + 1;
    }

    // Show in-app notification
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: _getCategoryColor(category),
      colorText: Colors.white,
      icon: Icon(_getCategoryIcon(category), color: Colors.white),
      duration: const Duration(seconds: 4),
    );
  }

  /// Broadcast notification to all users of specific roles
  void broadcastNotification({
    required String title,
    required String message,
    required NotificationCategory category,
    required List<String> roles, // 'admin', 'staff', 'student'
    String? actionId,
    Map<String, dynamic>? data,
  }) {
    // In production, get actual user IDs from database
    // For now, using mock recipient IDs
    final recipientIds = <String>[];

    if (roles.contains('admin')) recipientIds.add('USR001');
    if (roles.contains('staff')) recipientIds.addAll(['STF001', 'STF002']);
    if (roles.contains('student')) recipientIds.addAll(['STU001', 'STU002']);

    sendNotification(
      title: title,
      message: message,
      category: category,
      recipientIds: recipientIds,
      actionId: actionId,
      data: data,
    );
  }

  /// Get notifications for specific user
  List<SystemNotification> getNotificationsForUser(String userId) {
    return allNotifications
        .where((n) => n.recipientIds.contains(userId))
        .toList();
  }

  /// Get unread count for user
  int getUnreadCount(String userId) {
    return unreadCounts[userId] ?? 0;
  }

  /// Mark notification as read
  void markAsRead(String notificationId, String userId) {
    final index = allNotifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      allNotifications[index].isRead = true;
      allNotifications.refresh();

      if (unreadCounts[userId] != null && unreadCounts[userId]! > 0) {
        unreadCounts[userId] = unreadCounts[userId]! - 1;
      }
    }
  }

  /// Mark all as read for user
  void markAllAsRead(String userId) {
    for (var notification in allNotifications) {
      if (notification.recipientIds.contains(userId)) {
        notification.isRead = true;
      }
    }
    allNotifications.refresh();
    unreadCounts[userId] = 0;
  }

  /// Clear all notifications for user
  void clearNotifications(String userId) {
    allNotifications.removeWhere((n) => n.recipientIds.contains(userId));
    unreadCounts[userId] = 0;
  }

  Color _getCategoryColor(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.classScheduled:
        return Colors.blue;
      case NotificationCategory.classStarted:
        return Colors.green;
      case NotificationCategory.classCancelled:
        return Colors.red;
      case NotificationCategory.assessmentCreated:
        return Colors.purple;
      case NotificationCategory.assessmentDue:
        return Colors.orange;
      case NotificationCategory.announcement:
        return Colors.indigo;
      case NotificationCategory.reminder:
        return Colors.amber;
      case NotificationCategory.system:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.classScheduled:
        return Icons.event;
      case NotificationCategory.classStarted:
        return Icons.play_circle;
      case NotificationCategory.classCancelled:
        return Icons.cancel;
      case NotificationCategory.assessmentCreated:
        return Icons.assignment;
      case NotificationCategory.assessmentDue:
        return Icons.alarm;
      case NotificationCategory.announcement:
        return Icons.campaign;
      case NotificationCategory.reminder:
        return Icons.notifications;
      case NotificationCategory.system:
        return Icons.info;
    }
  }
}

/// System Notification Model
class SystemNotification {
  final String id;
  final String title;
  final String message;
  final NotificationCategory category;
  final List<String> recipientIds;
  final DateTime timestamp;
  bool isRead;
  final String? actionId; // ID of related item (class, assessment, etc.)
  final Map<String, dynamic>? data;

  SystemNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.category,
    required this.recipientIds,
    required this.timestamp,
    this.isRead = false,
    this.actionId,
    this.data,
  });

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
}

/// Notification Category Enum
enum NotificationCategory {
  classScheduled,
  classStarted,
  classCancelled,
  assessmentCreated,
  assessmentDue,
  announcement,
  reminder,
  system,
}
