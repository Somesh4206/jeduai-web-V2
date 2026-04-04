import 'dart:async';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../config/supabase_config.dart';
import '../models/online_class_model.dart';
import '../services/user_service.dart' as user_svc;
import '../services/notification_service.dart';

/// Database Service - Handles all Supabase operations with automatic cleanup
class DatabaseService extends GetxService {
  final SupabaseClient _client = SupabaseConfig.client;
  final Uuid _uuid = const Uuid();
  Timer? _cleanupTimer;

  @override
  void onInit() {
    super.onInit();
    initializeDatabase();
  }

  @override
  void onClose() {
    _cleanupTimer?.cancel();
    super.onClose();
  }

  /// Initialize database with sample data
  Future<void> initializeDatabase() async {
    try {
      // Check if users table exists and has data
      final usersCount = await _client
          .from(DatabaseTables.users)
          .select('id')
          .count(CountOption.exact);

      if (usersCount.count == 0) {
        await _createSampleData();
      }

      // Start automatic cleanup job
      _startAutomaticCleanup();
    } catch (e) {
      print('Database initialization error: $e');
      // If tables don't exist, create sample data anyway
      await _createSampleData();
      _startAutomaticCleanup();
    }
  }

  /// Start automatic cleanup of old data
  void _startAutomaticCleanup() {
    // Run cleanup every hour
    _cleanupTimer = Timer.periodic(const Duration(hours: 1), (timer) {
      _cleanupOldData();
    });

    // Run initial cleanup
    _cleanupOldData();
  }

  /// Clean up data older than 2 days
  Future<void> _cleanupOldData() async {
    try {
      final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));

      print(
        'Running automatic cleanup for data older than ${twoDaysAgo.toIso8601String()}',
      );

      // Delete old completed classes
      await _client
          .from(DatabaseTables.onlineClasses)
          .delete()
          .eq('status', 'completed')
          .lt('scheduled_time', twoDaysAgo.toIso8601String());

      // Delete old cancelled classes
      await _client
          .from(DatabaseTables.onlineClasses)
          .delete()
          .eq('status', 'cancelled')
          .lt('created_at', twoDaysAgo.toIso8601String());

      // Delete old notifications
      await _client
          .from(DatabaseTables.notifications)
          .delete()
          .lt('created_at', twoDaysAgo.toIso8601String());

      // Delete old chat messages
      await _client
          .from(DatabaseTables.chatMessages)
          .delete()
          .lt('created_at', twoDaysAgo.toIso8601String());

      // Delete old translation history
      await _client
          .from(DatabaseTables.translations)
          .delete()
          .lt('created_at', twoDaysAgo.toIso8601String());

      print('✅ Automatic cleanup completed successfully');
    } catch (e) {
      print('❌ Error during automatic cleanup: $e');
    }
  }

  /// Create sample data
  Future<void> _createSampleData() async {
    try {
      // Insert sample users
      await _client.from(DatabaseTables.users).upsert([
        {
          'id': 'USR001',
          'name': 'Kathirvel P',
          'email': 'mpkathir@gmail.com',
          'role': 'admin',
          'phone': '+91 9876543210',
          'department': 'Administration',
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'id': 'STF001',
          'name': 'Kathirvel P',
          'email': 'kathirvel.staff@jeduai.com',
          'role': 'staff',
          'phone': '+91 9876543210',
          'department': 'Computer Science',
          'subjects': [
            'Artificial Intelligence',
            'Data Structures',
            'Algorithms',
          ],
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'id': 'STU001',
          'name': 'Kathirvel P',
          'email': 'kathirvel.student@jeduai.com',
          'role': 'student',
          'phone': '+91 9876543210',
          'department': 'Computer Science',
          'class_name': 'Class 12',
          'roll_number': 'CS12001',
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'id': 'STU002',
          'name': 'Priya Sharma',
          'email': 'student2@jeduai.com',
          'role': 'student',
          'class_name': 'Class 12',
          'roll_number': 'CS12002',
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'id': 'STF002',
          'name': 'Dr. Rajesh Kumar',
          'email': 'teacher1@jeduai.com',
          'role': 'staff',
          'department': 'Mathematics',
          'subjects': ['Calculus', 'Algebra', 'Statistics'],
          'created_at': DateTime.now().toIso8601String(),
        },
      ]);

      print('✅ Sample data created successfully');
    } catch (e) {
      print('❌ Error creating sample data: $e');
    }
  }

  /// User Operations
  Future<user_svc.User?> authenticateUser(
    String email,
    String password,
    user_svc.UserRole role,
  ) async {
    try {
      final response = await _client
          .from(DatabaseTables.users)
          .select()
          .eq('email', email)
          .eq('role', role.name)
          .single();

      return user_svc.User(
        id: response['id'],
        name: response['name'],
        email: response['email'],
        role: user_svc.UserRole.values.firstWhere(
          (r) => r.name == response['role'],
        ),
        phone: response['phone'],
        department: response['department'],
        subjects: response['subjects'] != null
            ? List<String>.from(response['subjects'])
            : null,
        className: response['class_name'],
        rollNumber: response['roll_number'],
        joinDate: DateTime.parse(response['created_at']),
      );
    } catch (e) {
      print('❌ Authentication error: $e');
      return null;
    }
  }

  Future<List<user_svc.User>> getAllUsers() async {
    try {
      final response = await _client
          .from(DatabaseTables.users)
          .select()
          .order('created_at', ascending: false);

      return response
          .map<user_svc.User>(
            (data) => user_svc.User(
              id: data['id'],
              name: data['name'],
              email: data['email'],
              role: user_svc.UserRole.values.firstWhere(
                (r) => r.name == data['role'],
              ),
              phone: data['phone'],
              department: data['department'],
              subjects: data['subjects'] != null
                  ? List<String>.from(data['subjects'])
                  : null,
              className: data['class_name'],
              rollNumber: data['roll_number'],
              joinDate: DateTime.parse(data['created_at']),
            ),
          )
          .toList();
    } catch (e) {
      print('❌ Error fetching users: $e');
      return [];
    }
  }

  /// Online Class Operations
  Future<String> createOnlineClass({
    required String title,
    required String subject,
    required String teacherId,
    required String teacherName,
    required DateTime scheduledTime,
    required int duration,
    required String description,
    required int maxStudents,
    required String meetingLink,
    required String classCode,
  }) async {
    try {
      final classId = _uuid.v4();

      await _client.from(DatabaseTables.onlineClasses).insert({
        'id': classId,
        'title': title,
        'subject': subject,
        'teacher_id': teacherId,
        'teacher_name': teacherName,
        'scheduled_time': scheduledTime.toIso8601String(),
        'duration': duration,
        'meeting_link': meetingLink,
        'meeting_id': classCode,
        'status': 'scheduled',
        'description': description,
        'max_students': maxStudents,
        'class_code': classCode,
        'created_at': DateTime.now().toIso8601String(),
      });

      // Send notifications to all students
      await _sendClassNotification(
        classId: classId,
        title: 'New Class Scheduled',
        message: '$title by $teacherName on ${_formatDateTime(scheduledTime)}',
        category: NotificationCategory.classScheduled,
      );

      print('✅ Online class created: $classId');
      return classId;
    } catch (e) {
      print('❌ Error creating class: $e');
      throw Exception('Failed to create class');
    }
  }

  Future<List<OnlineClass>> getAllOnlineClasses() async {
    try {
      final response = await _client
          .from(DatabaseTables.onlineClasses)
          .select()
          .order('scheduled_time', ascending: true);

      return response
          .map<OnlineClass>(
            (data) => OnlineClass(
              id: data['id'],
              title: data['title'],
              subject: data['subject'],
              teacherId: data['teacher_id'],
              teacherName: data['teacher_name'],
              scheduledTime: DateTime.parse(data['scheduled_time']),
              duration: data['duration'],
              meetingLink: data['meeting_link'],
              status: ClassStatus.values.firstWhere(
                (s) => s.name == data['status'],
                orElse: () => ClassStatus.scheduled,
              ),
              enrolledStudents: [], // Will be populated separately
              maxStudents: data['max_students'],
              description: data['description'],
              classCode: data['class_code'],
            ),
          )
          .toList();
    } catch (e) {
      print('❌ Error fetching classes: $e');
      return [];
    }
  }

  Future<void> enrollInClass(String classId, String studentId) async {
    try {
      await _client.from(DatabaseTables.classEnrollments).insert({
        'id': _uuid.v4(),
        'class_id': classId,
        'student_id': studentId,
        'enrolled_at': DateTime.now().toIso8601String(),
      });

      print('✅ Student enrolled in class: $studentId -> $classId');
    } catch (e) {
      print('❌ Error enrolling in class: $e');
      throw Exception('Failed to enroll in class');
    }
  }

  Future<List<String>> getClassEnrollments(String classId) async {
    try {
      final response = await _client
          .from(DatabaseTables.classEnrollments)
          .select('student_id')
          .eq('class_id', classId);

      return response
          .map<String>((data) => data['student_id'] as String)
          .toList();
    } catch (e) {
      print('❌ Error fetching enrollments: $e');
      return [];
    }
  }

  Future<void> updateClassStatus(String classId, ClassStatus status) async {
    try {
      await _client
          .from(DatabaseTables.onlineClasses)
          .update({'status': status.name})
          .eq('id', classId);

      // Send notification based on status
      if (status == ClassStatus.live) {
        await _sendClassNotification(
          classId: classId,
          title: 'Class Started!',
          message: 'Your class is now live. Join now!',
          category: NotificationCategory.classStarted,
        );
      }

      print('✅ Class status updated: $classId -> ${status.name}');
    } catch (e) {
      print('❌ Error updating class status: $e');
    }
  }

  /// Notification Operations
  Future<void> _sendClassNotification({
    required String classId,
    required String title,
    required String message,
    required NotificationCategory category,
  }) async {
    try {
      // Get all students for notification
      final students = await _client
          .from(DatabaseTables.users)
          .select('id')
          .eq('role', 'student');

      final studentIds = students
          .map<String>((s) => s['id'] as String)
          .toList();

      // Insert notification
      await _client.from(DatabaseTables.notifications).insert({
        'id': _uuid.v4(),
        'title': title,
        'message': message,
        'category': category.name,
        'recipient_ids': studentIds,
        'action_id': classId,
        'created_at': DateTime.now().toIso8601String(),
      });

      print('✅ Notification sent to ${studentIds.length} students');
    } catch (e) {
      print('❌ Error sending notification: $e');
    }
  }

  Future<List<SystemNotification>> getNotificationsForUser(
    String userId,
  ) async {
    try {
      final response = await _client
          .from(DatabaseTables.notifications)
          .select()
          .contains('recipient_ids', [userId])
          .order('created_at', ascending: false);

      return response
          .map<SystemNotification>(
            (data) => SystemNotification(
              id: data['id'],
              title: data['title'],
              message: data['message'],
              category: NotificationCategory.values.firstWhere(
                (c) => c.name == data['category'],
                orElse: () => NotificationCategory.system,
              ),
              recipientIds: List<String>.from(data['recipient_ids']),
              timestamp: DateTime.parse(data['created_at']),
              actionId: data['action_id'],
            ),
          )
          .toList();
    } catch (e) {
      print('❌ Error fetching notifications: $e');
      return [];
    }
  }

  /// Assessment Operations
  Future<String> createAssessment({
    required String title,
    required String subject,
    required String teacherId,
    required String description,
    required DateTime dueDate,
    required int totalMarks,
    required List<Map<String, dynamic>> questions,
  }) async {
    try {
      final assessmentId = _uuid.v4();

      await _client.from(DatabaseTables.assessments).insert({
        'id': assessmentId,
        'title': title,
        'subject': subject,
        'teacher_id': teacherId,
        'description': description,
        'due_date': dueDate.toIso8601String(),
        'total_marks': totalMarks,
        'questions': questions,
        'created_at': DateTime.now().toIso8601String(),
      });

      // Send notification to students
      await _sendAssessmentNotification(
        assessmentId: assessmentId,
        title: 'New Assessment Created',
        message: '$title - Due: ${_formatDateTime(dueDate)}',
        category: NotificationCategory.assessmentCreated,
      );

      print('✅ Assessment created: $assessmentId');
      return assessmentId;
    } catch (e) {
      print('❌ Error creating assessment: $e');
      throw Exception('Failed to create assessment');
    }
  }

  Future<void> _sendAssessmentNotification({
    required String assessmentId,
    required String title,
    required String message,
    required NotificationCategory category,
  }) async {
    try {
      final students = await _client
          .from(DatabaseTables.users)
          .select('id')
          .eq('role', 'student');

      final studentIds = students
          .map<String>((s) => s['id'] as String)
          .toList();

      await _client.from(DatabaseTables.notifications).insert({
        'id': _uuid.v4(),
        'title': title,
        'message': message,
        'category': category.name,
        'recipient_ids': studentIds,
        'action_id': assessmentId,
        'created_at': DateTime.now().toIso8601String(),
      });

      print('✅ Assessment notification sent');
    } catch (e) {
      print('❌ Error sending assessment notification: $e');
    }
  }

  /// Translation Operations
  Future<void> saveTranslation({
    required String sourceText,
    required String targetText,
    required String sourceLanguage,
    required String targetLanguage,
    required String userId,
  }) async {
    try {
      await _client.from(DatabaseTables.translations).insert({
        'id': _uuid.v4(),
        'user_id': userId,
        'source_text': sourceText,
        'target_text': targetText,
        'source_language': sourceLanguage,
        'target_language': targetLanguage,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('❌ Error saving translation: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getTranslationHistory(
    String userId,
  ) async {
    try {
      final response = await _client
          .from(DatabaseTables.translations)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(50);

      return response;
    } catch (e) {
      print('❌ Error fetching translation history: $e');
      return [];
    }
  }

  /// Chat Operations
  Future<void> saveChatMessage({
    required String meetingId,
    required String senderId,
    required String senderName,
    required String message,
  }) async {
    try {
      await _client.from(DatabaseTables.chatMessages).insert({
        'id': _uuid.v4(),
        'meeting_id': meetingId,
        'sender_id': senderId,
        'sender_name': senderName,
        'message': message,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('❌ Error saving chat message: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getChatMessages(String meetingId) async {
    try {
      final response = await _client
          .from(DatabaseTables.chatMessages)
          .select()
          .eq('meeting_id', meetingId)
          .order('created_at', ascending: true);

      return response;
    } catch (e) {
      print('❌ Error fetching chat messages: $e');
      return [];
    }
  }

  /// Utility Methods
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Real-time subscriptions
  Stream<List<Map<String, dynamic>>> subscribeToClasses() {
    return _client
        .from(DatabaseTables.onlineClasses)
        .stream(primaryKey: ['id'])
        .order('scheduled_time');
  }

  Stream<List<Map<String, dynamic>>> subscribeToNotifications(String userId) {
    return _client
        .from(DatabaseTables.notifications)
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false);
  }

  /// Manual cleanup trigger (for admin)
  Future<void> manualCleanup() async {
    await _cleanupOldData();
    Get.snackbar(
      'Cleanup Complete',
      'Old data has been removed successfully',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
