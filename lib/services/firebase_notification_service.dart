import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

/// Firebase Real-time Notification Service
/// Syncs notifications across all devices instantly
class FirebaseNotificationService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // All notifications for current user
  var notifications = <SystemNotification>[].obs;
  
  // Unread count
  var unreadCount = 0.obs;
  
  // Stream subscription
  StreamSubscription<QuerySnapshot>? _notificationSubscription;
  
  String? _currentUserId;

  /// Initialize real-time listener for user notifications
  void initializeForUser(String userId) {
    _currentUserId = userId;
    
    // Cancel previous subscription
    _notificationSubscription?.cancel();
    
    // Listen to notifications in real-time
    _notificationSubscription = _firestore
        .collection('notifications')
        .where('recipientIds', arrayContains: userId)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .listen((snapshot) {
      notifications.value = snapshot.docs
          .map((doc) => SystemNotification.fromFirestore(doc))
          .toList();
      
      // Update unread count
      unreadCount.value = notifications.where((n) => !n.isRead).length;
      
      print('📬 Loaded ${notifications.length} notifications (${unreadCount.value} unread)');
    });
  }

  /// Send notification to specific users (saves to Firestore)
  Future<void> sendNotification({
    required String title,
    required String message,
    required NotificationCategory category,
    required List<String> recipientIds,
    String? actionId,
    Map<String, dynamic>? data,
  }) async {
    try {
      final notification = {
        'title': title,
        'message': message,
        'category': category.toString().split('.').last,
        'recipientIds': recipientIds,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'actionId': actionId,
        'data': data,
      };

      // Save to Firestore - will trigger real-time update for all recipients
      await _firestore.collection('notifications').add(notification);
      
      print('✅ Notification sent to ${recipientIds.length} users');

      // Show in-app notification for current user if they're a recipient
      if (_currentUserId != null && recipientIds.contains(_currentUserId)) {
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
    } catch (e) {
      print('❌ Error sending notification: $e');
    }
  }

  /// Broadcast notification to all users of specific roles
  Future<void> broadcastNotification({
    required String title,
    required String message,
    required NotificationCategory category,
    required List<String> roles, // 'admin', 'staff', 'student'
    String? actionId,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Get all user IDs for specified roles from Firestore
      List<String> recipientIds = [];

      for (String role in roles) {
        QuerySnapshot snapshot;
        
        if (role == 'student') {
          snapshot = await _firestore.collection('students').get();
        } else if (role == 'staff') {
          snapshot = await _firestore.collection('staff').get();
        } else if (role == 'admin') {
          snapshot = await _firestore.collection('admins').get();
        } else {
          continue;
        }

        recipientIds.addAll(snapshot.docs.map((doc) => doc.id));
      }

      if (recipientIds.isEmpty) {
        print('⚠️ No recipients found for roles: $roles');
        return;
      }

      await sendNotification(
        title: title,
        message: message,
        category: category,
        recipientIds: recipientIds,
        actionId: actionId,
        data: data,
      );
    } catch (e) {
      print('❌ Error broadcasting notification: $e');
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
      
      print('✅ Notification marked as read');
    } catch (e) {
      print('❌ Error marking notification as read: $e');
    }
  }

  /// Mark all as read for current user
  Future<void> markAllAsRead() async {
    if (_currentUserId == null) return;

    try {
      final batch = _firestore.batch();
      
      final unreadNotifications = await _firestore
          .collection('notifications')
          .where('recipientIds', arrayContains: _currentUserId)
          .where('isRead', isEqualTo: false)
          .get();

      for (var doc in unreadNotifications.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
      print('✅ All notifications marked as read');
    } catch (e) {
      print('❌ Error marking all as read: $e');
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).delete();
      print('✅ Notification deleted');
    } catch (e) {
      print('❌ Error deleting notification: $e');
    }
  }

  /// Clear all notifications for current user
  Future<void> clearAllNotifications() async {
    if (_currentUserId == null) return;

    try {
      final batch = _firestore.batch();
      
      final userNotifications = await _firestore
          .collection('notifications')
          .where('recipientIds', arrayContains: _currentUserId)
          .get();

      for (var doc in userNotifications.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('✅ All notifications cleared');
    } catch (e) {
      print('❌ Error clearing notifications: $e');
    }
  }

  /// Dispose listener
  @override
  void onClose() {
    _notificationSubscription?.cancel();
    super.onClose();
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
  final bool isRead;
  final String? actionId;
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

  factory SystemNotification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return SystemNotification(
      id: doc.id,
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      category: _categoryFromString(data['category'] ?? 'system'),
      recipientIds: List<String>.from(data['recipientIds'] ?? []),
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] ?? false,
      actionId: data['actionId'],
      data: data['data'],
    );
  }

  static NotificationCategory _categoryFromString(String category) {
    switch (category) {
      case 'classScheduled':
        return NotificationCategory.classScheduled;
      case 'classStarted':
        return NotificationCategory.classStarted;
      case 'classCancelled':
        return NotificationCategory.classCancelled;
      case 'assessmentCreated':
        return NotificationCategory.assessmentCreated;
      case 'assessmentDue':
        return NotificationCategory.assessmentDue;
      case 'announcement':
        return NotificationCategory.announcement;
      case 'reminder':
        return NotificationCategory.reminder;
      default:
        return NotificationCategory.system;
    }
  }

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
