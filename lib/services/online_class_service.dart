import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/online_class_model.dart';
import 'notification_service.dart';

/// Real-time Online Class Service
/// Manages online class creation, notifications, and student participation
class OnlineClassService extends GetxService {
  final NotificationService _notificationService =
      Get.find<NotificationService>();

  // Observable list of all online classes
  var allClasses = <OnlineClass>[].obs;

  // Observable list of upcoming classes
  var upcomingClasses = <OnlineClass>[].obs;

  // Observable list of live classes
  var liveClasses = <OnlineClass>[].obs;

  // Observable list of notifications
  var notifications = <ClassNotification>[].obs;

  // Observable unread notification count
  var unreadNotificationCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadClassesFromStorage(); // Load saved classes first
    _initializeMockData();
    _startRealTimeUpdates();
  }

  /// Load classes from persistent storage
  Future<void> _loadClassesFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final classesString = prefs.getString('online_classes');
      if (classesString != null && classesString.isNotEmpty) {
        final List<dynamic> classesJson = jsonDecode(classesString);
        final loadedClasses = classesJson
            .map((json) => OnlineClass.fromJson(json))
            .toList();

        if (loadedClasses.isNotEmpty) {
          allClasses.value = loadedClasses;
          _updateClassLists();
          print('📂 Loaded ${allClasses.length} classes from storage');
        }
      }
    } catch (e) {
      print('⚠️ Error loading classes: $e');
    }
  }

  /// Save classes to persistent storage
  Future<void> _saveClassesToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final classesJson = allClasses.map((c) => c.toJson()).toList();
      await prefs.setString('online_classes', jsonEncode(classesJson));
      print('💾 Saved ${allClasses.length} classes to storage');
    } catch (e) {
      print('❌ Error saving classes: $e');
    }
  }

  /// Initialize with mock data for demonstration
  void _initializeMockData() {
    // Add some sample classes
    allClasses.addAll([
      OnlineClass(
        id: 'CLS001',
        title: 'Mathematics - Algebra Basics',
        subject: 'Mathematics',
        teacherName: 'Prof. Rajesh Kumar',
        teacherId: 'TCH001',
        scheduledTime: DateTime.now().add(const Duration(hours: 2)),
        duration: 60,
        meetingLink: 'https://meet.google.com/abc-defg-hij',
        status: ClassStatus.scheduled,
        enrolledStudents: ['STU001', 'STU002', 'STU003'],
        maxStudents: 50,
        description: 'Introduction to algebraic expressions and equations',
        classCode: 'MATH101',
      ),
      OnlineClass(
        id: 'CLS002',
        title: 'Physics - Newton\'s Laws',
        subject: 'Physics',
        teacherName: 'Dr. Priya Sharma',
        teacherId: 'TCH002',
        scheduledTime: DateTime.now().add(const Duration(minutes: 30)),
        duration: 45,
        meetingLink: 'https://zoom.us/j/123456789',
        status: ClassStatus.scheduled,
        enrolledStudents: ['STU001', 'STU004'],
        maxStudents: 40,
        description: 'Understanding force, mass, and acceleration',
        classCode: 'PHY201',
      ),
    ]);

    _updateClassLists();
  }

  /// Simulate real-time updates (in production, use WebSocket or Firebase)
  void _startRealTimeUpdates() {
    // Check for class status updates every 30 seconds
    Future.delayed(const Duration(seconds: 30), () {
      _checkClassStatusUpdates();
      _startRealTimeUpdates();
    });
  }

  /// Check and update class statuses
  void _checkClassStatusUpdates() {
    final now = DateTime.now();

    for (var classItem in allClasses) {
      final timeDiff = classItem.scheduledTime.difference(now).inMinutes;

      // Start class if it's time
      if (timeDiff <= 0 &&
          timeDiff > -classItem.duration &&
          classItem.status == ClassStatus.scheduled) {
        classItem.status = ClassStatus.live;
        _sendNotification(
          'Class Started!',
          '${classItem.title} is now live. Join now!',
          NotificationType.classStarted,
          classItem.id,
        );
      }

      // End class if duration exceeded
      if (timeDiff < -classItem.duration &&
          classItem.status == ClassStatus.live) {
        classItem.status = ClassStatus.completed;
      }

      // Send reminder 10 minutes before class
      if (timeDiff == 10 && classItem.status == ClassStatus.scheduled) {
        _sendNotification(
          'Class Reminder',
          '${classItem.title} starts in 10 minutes',
          NotificationType.reminder,
          classItem.id,
        );
      }
    }

    _updateClassLists();
  }

  /// Update class lists based on status
  void _updateClassLists() {
    // Create new lists to trigger reactivity
    liveClasses.value = List<OnlineClass>.from(
      allClasses.where((c) => c.status == ClassStatus.live),
    );

    upcomingClasses.value = List<OnlineClass>.from(
      allClasses.where((c) => c.status == ClassStatus.scheduled),
    )..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));

    // Log for debugging
    print('📊 Updated lists:');
    print('   - All: ${allClasses.length}');
    print('   - Live: ${liveClasses.length}');
    print('   - Upcoming: ${upcomingClasses.length}');

    // Force UI update
    allClasses.refresh();
    liveClasses.refresh();
    upcomingClasses.refresh();
  }

  /// Staff creates a new online class
  Future<OnlineClass> createClass({
    required String title,
    required String subject,
    required String teacherName,
    required String teacherId,
    required DateTime scheduledTime,
    required int duration,
    required String meetingLink,
    required String description,
    required String classCode,
    required String targetClass, // e.g., "III CSBS", "All Classes"
    int maxStudents = 50,
  }) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // Auto-enroll students based on target class
    List<String> autoEnrolledStudents = [];
    if (targetClass == 'All Classes') {
      // Enroll all students (in production, fetch from database)
      autoEnrolledStudents = ['STU001', 'STU_ADMIN'];
    } else {
      // Enroll students from specific class
      // In production, query database for students in this class
      autoEnrolledStudents = ['STU001']; // Mock enrollment
    }

    final newClass = OnlineClass(
      id: 'CLS${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      subject: subject,
      teacherName: teacherName,
      teacherId: teacherId,
      scheduledTime: scheduledTime,
      duration: duration,
      meetingLink: meetingLink,
      status: ClassStatus.scheduled,
      enrolledStudents: autoEnrolledStudents,
      maxStudents: maxStudents,
      description: description,
      classCode: classCode,
    );

    // Add to observable list with proper reactivity
    allClasses.add(newClass);

    // Create new list to trigger change detection
    allClasses.value = List<OnlineClass>.from(allClasses);

    // Save to persistent storage so it survives logout/login
    await _saveClassesToStorage();

    // Update categorized lists
    _updateClassLists();

    // Wait a moment for UI to update
    await Future.delayed(const Duration(milliseconds: 100));

    // Send notification to all enrolled students
    _sendNotification(
      'New Class Scheduled',
      '$title by $teacherName on ${_formatDateTime(scheduledTime)}',
      NotificationType.newClass,
      newClass.id,
    );

    // Show success with details
    Get.snackbar(
      'Success',
      'Online class created! ${autoEnrolledStudents.length} students enrolled.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.primary,
      colorText: Get.theme.colorScheme.onPrimary,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );

    // Log for debugging
    print('✅ Class created: ${newClass.id} - ${newClass.title}');
    print('📊 Total classes: ${allClasses.length}');
    print('📅 Upcoming classes: ${upcomingClasses.length}');
    print('🔄 Lists updated and UI should refresh');

    return newClass;
  }

  /// Student joins a class
  Future<bool> joinClass(String classId, String studentId) async {
    final classIndex = allClasses.indexWhere((c) => c.id == classId);

    if (classIndex == -1) {
      Get.snackbar('Error', 'Class not found');
      return false;
    }

    final classItem = allClasses[classIndex];

    // Check if already enrolled
    if (classItem.enrolledStudents.contains(studentId)) {
      Get.snackbar('Info', 'You are already enrolled in this class');
      return true;
    }

    // Check if class is full
    if (classItem.enrolledStudents.length >= classItem.maxStudents) {
      Get.snackbar('Error', 'Class is full');
      return false;
    }

    // Enroll student
    classItem.enrolledStudents.add(studentId);
    allClasses[classIndex] = classItem;

    Get.snackbar(
      'Success',
      'Successfully enrolled in ${classItem.title}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.primary,
      colorText: Get.theme.colorScheme.onPrimary,
    );

    return true;
  }

  /// Student leaves a class
  Future<bool> leaveClass(String classId, String studentId) async {
    final classIndex = allClasses.indexWhere((c) => c.id == classId);

    if (classIndex == -1) return false;

    final classItem = allClasses[classIndex];
    classItem.enrolledStudents.remove(studentId);
    allClasses[classIndex] = classItem;

    Get.snackbar('Success', 'Left the class successfully');
    return true;
  }

  /// Cancel a class (staff only)
  Future<bool> cancelClass(String classId, String reason) async {
    final classIndex = allClasses.indexWhere((c) => c.id == classId);

    if (classIndex == -1) return false;

    final classItem = allClasses[classIndex];
    classItem.status = ClassStatus.cancelled;
    allClasses[classIndex] = classItem;

    // Notify all enrolled students
    _sendNotification(
      'Class Cancelled',
      '${classItem.title} has been cancelled. Reason: $reason',
      NotificationType.classCancelled,
      classId,
    );

    _updateClassLists();
    return true;
  }

  /// Send notification to students
  void _sendNotification(
    String title,
    String message,
    NotificationType type,
    String classId,
  ) {
    final notification = ClassNotification(
      id: 'NOT${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      message: message,
      type: type,
      classId: classId,
      timestamp: DateTime.now(),
      isRead: false,
    );

    notifications.insert(0, notification);
    unreadNotificationCount.value++;

    // Show in-app notification
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 5),
      backgroundColor: _getNotificationColor(type),
      colorText: Get.theme.colorScheme.onPrimary,
      icon: Icon(
        _getNotificationIcon(type),
        color: Get.theme.colorScheme.onPrimary,
      ),
    );
  }

  /// Mark notification as read
  void markNotificationAsRead(String notificationId) {
    final index = notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1 && !notifications[index].isRead) {
      notifications[index].isRead = true;
      unreadNotificationCount.value--;
    }
  }

  /// Mark all notifications as read
  void markAllNotificationsAsRead() {
    for (var notification in notifications) {
      notification.isRead = true;
    }
    unreadNotificationCount.value = 0;
  }

  /// Get classes for a specific student
  List<OnlineClass> getStudentClasses(String studentId) {
    return allClasses
        .where((c) => c.enrolledStudents.contains(studentId))
        .toList();
  }

  /// Get classes created by a specific teacher
  List<OnlineClass> getTeacherClasses(String teacherId) {
    return allClasses.where((c) => c.teacherId == teacherId).toList();
  }

  /// Helper methods
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.newClass:
        return Get.theme.colorScheme.primary;
      case NotificationType.classStarted:
        return const Color(0xFF4CAF50);
      case NotificationType.reminder:
        return const Color(0xFFFF9800);
      case NotificationType.classCancelled:
        return const Color(0xFFF44336);
      case NotificationType.classUpdated:
        return const Color(0xFF2196F3);
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.newClass:
        return Icons.add_circle;
      case NotificationType.classStarted:
        return Icons.play_circle;
      case NotificationType.reminder:
        return Icons.alarm;
      case NotificationType.classCancelled:
        return Icons.cancel;
      case NotificationType.classUpdated:
        return Icons.update;
    }
  }
}
