import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/online_class_service.dart';
import '../models/online_class_model.dart';

class OnlineClassController extends GetxController {
  // Lazy initialization to avoid dependency issues
  OnlineClassService get _classService => Get.find<OnlineClassService>();

  // Getters for reactive data
  List<OnlineClass> get allClasses => _classService.allClasses;
  List<OnlineClass> get upcomingClasses => _classService.upcomingClasses;
  List<OnlineClass> get liveClasses => _classService.liveClasses;
  List<ClassNotification> get notifications => _classService.notifications;
  int get unreadNotificationCount =>
      _classService.unreadNotificationCount.value;

  // Create a new class
  Future<OnlineClass?> createClass({
    required String title,
    required String subject,
    required String teacherName,
    required String teacherId,
    required DateTime scheduledTime,
    required int duration,
    required String meetingLink,
    required String description,
    required String classCode,
    required String targetClass,
    int maxStudents = 50,
  }) async {
    try {
      print('🔄 Controller: Creating class...');
      final newClass = await _classService.createClass(
        title: title,
        subject: subject,
        teacherName: teacherName,
        teacherId: teacherId,
        scheduledTime: scheduledTime,
        duration: duration,
        meetingLink: meetingLink,
        description: description,
        classCode: classCode,
        targetClass: targetClass,
        maxStudents: maxStudents,
      );
      print('✅ Controller: Class created successfully');

      // Force refresh of all lists
      _classService.allClasses.refresh();
      _classService.upcomingClasses.refresh();

      return newClass;
    } catch (e) {
      print('❌ Controller Error: $e');
      Get.snackbar(
        'Error',
        'Failed to create class: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    }
  }

  // Join a class
  Future<bool> joinClass(String classId, String studentId) async {
    return await _classService.joinClass(classId, studentId);
  }

  // Leave a class
  Future<bool> leaveClass(String classId, String studentId) async {
    return await _classService.leaveClass(classId, studentId);
  }

  // Cancel a class
  Future<bool> cancelClass(String classId, String reason) async {
    return await _classService.cancelClass(classId, reason);
  }

  // Get student's enrolled classes
  List<OnlineClass> getStudentClasses(String studentId) {
    return _classService.getStudentClasses(studentId);
  }

  // Get teacher's classes
  List<OnlineClass> getTeacherClasses(String teacherId) {
    return _classService.getTeacherClasses(teacherId);
  }

  // Mark notification as read
  void markNotificationAsRead(String notificationId) {
    _classService.markNotificationAsRead(notificationId);
  }

  // Mark all notifications as read
  void markAllNotificationsAsRead() {
    _classService.markAllNotificationsAsRead();
  }

  // Get class by ID
  OnlineClass? getClassById(String classId) {
    try {
      return allClasses.firstWhere((c) => c.id == classId);
    } catch (e) {
      return null;
    }
  }

  // Check if student is enrolled in a class
  bool isStudentEnrolled(String classId, String studentId) {
    final classItem = getClassById(classId);
    return classItem?.enrolledStudents.contains(studentId) ?? false;
  }
}
