import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

/// Parent Portal Service - Allows parents to monitor their children
class ParentPortalService extends GetxService {
  final SupabaseClient _client = SupabaseConfig.client;

  /// Link parent to student
  Future<bool> linkParentToStudent(
    String parentId,
    String studentId,
    String relationshipType,
  ) async {
    try {
      await _client.from('parent_student_links').insert({
        'parent_id': parentId,
        'student_id': studentId,
        'relationship': relationshipType, // father, mother, guardian
        'created_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      print('❌ Error linking parent: $e');
      return false;
    }
  }

  /// Get linked students
  Future<List<Map<String, dynamic>>> getLinkedStudents(String parentId) async {
    try {
      final response = await _client
          .from('parent_student_links')
          .select('*, users!student_id(*)')
          .eq('parent_id', parentId);

      return response;
    } catch (e) {
      return [];
    }
  }

  /// Get student progress report
  Future<Map<String, dynamic>> getStudentProgressReport(
    String studentId,
  ) async {
    try {
      // Get attendance
      final enrollments = await _client
          .from(DatabaseTables.classEnrollments)
          .select('*, online_classes(*)')
          .eq('student_id', studentId);

      final totalClasses = enrollments.length;
      final attendedClasses = enrollments
          .where((e) => e['online_classes']['status'] == 'completed')
          .length;
      final attendanceRate = totalClasses == 0
          ? 0.0
          : (attendedClasses / totalClasses) * 100;

      // Get assessment scores
      final submissions = await _client
          .from(DatabaseTables.assessmentSubmissions)
          .select('*, assessments(*)')
          .eq('student_id', studentId)
          .order('submitted_at', ascending: false);

      final totalAssessments = submissions.length;
      final averageScore = submissions.isEmpty
          ? 0.0
          : submissions.map((s) => s['score'] ?? 0).reduce((a, b) => a + b) /
                totalAssessments;

      // Subject-wise performance
      final subjectPerformance = <String, Map<String, dynamic>>{};
      for (var submission in submissions) {
        final subject = submission['assessments']['subject'];
        if (!subjectPerformance.containsKey(subject)) {
          subjectPerformance[subject] = {'scores': <int>[], 'assessments': 0};
        }
        subjectPerformance[subject]!['scores'].add(submission['score'] ?? 0);
        subjectPerformance[subject]!['assessments']++;
      }

      // Calculate subject averages
      final subjectAverages = <String, double>{};
      subjectPerformance.forEach((subject, data) {
        final scores = data['scores'] as List<int>;
        subjectAverages[subject] =
            scores.reduce((a, b) => a + b) / scores.length;
      });

      // Get recent activity
      final recentActivity = await _getRecentActivity(studentId);

      // Get upcoming assessments
      final upcomingAssessments = await _client
          .from(DatabaseTables.assessments)
          .select()
          .gte('due_date', DateTime.now().toIso8601String())
          .order('due_date', ascending: true)
          .limit(5);

      return {
        'studentId': studentId,
        'attendanceRate': attendanceRate,
        'totalClasses': totalClasses,
        'attendedClasses': attendedClasses,
        'totalAssessments': totalAssessments,
        'averageScore': averageScore,
        'subjectPerformance': subjectAverages,
        'recentActivity': recentActivity,
        'upcomingAssessments': upcomingAssessments,
        'strengths': _identifyStrengths(subjectAverages),
        'areasForImprovement': _identifyWeaknesses(subjectAverages),
      };
    } catch (e) {
      print('❌ Error getting progress report: $e');
      return {};
    }
  }

  /// Get recent activity
  Future<List<Map<String, dynamic>>> _getRecentActivity(
    String studentId,
  ) async {
    try {
      final activities = <Map<String, dynamic>>[];

      // Recent class attendance
      final classes = await _client
          .from(DatabaseTables.classEnrollments)
          .select('*, online_classes(*)')
          .eq('student_id', studentId)
          .order('enrolled_at', ascending: false)
          .limit(5);

      for (var classData in classes) {
        activities.add({
          'type': 'class',
          'title': classData['online_classes']['title'],
          'date': classData['enrolled_at'],
          'status': classData['online_classes']['status'],
        });
      }

      // Recent assessments
      final assessments = await _client
          .from(DatabaseTables.assessmentSubmissions)
          .select('*, assessments(*)')
          .eq('student_id', studentId)
          .order('submitted_at', ascending: false)
          .limit(5);

      for (var assessment in assessments) {
        activities.add({
          'type': 'assessment',
          'title': assessment['assessments']['title'],
          'date': assessment['submitted_at'],
          'score': assessment['score'],
        });
      }

      // Sort by date
      activities.sort(
        (a, b) =>
            DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])),
      );

      return activities.take(10).toList();
    } catch (e) {
      return [];
    }
  }

  /// Identify strengths
  List<String> _identifyStrengths(Map<String, double> subjectAverages) {
    final strengths = <String>[];
    subjectAverages.forEach((subject, avg) {
      if (avg >= 80) {
        strengths.add(subject);
      }
    });
    return strengths;
  }

  /// Identify weaknesses
  List<String> _identifyWeaknesses(Map<String, double> subjectAverages) {
    final weaknesses = <String>[];
    subjectAverages.forEach((subject, avg) {
      if (avg < 60) {
        weaknesses.add(subject);
      }
    });
    return weaknesses;
  }

  /// Send message to teacher
  Future<bool> sendMessageToTeacher(
    String parentId,
    String teacherId,
    String studentId,
    String message,
  ) async {
    try {
      await _client.from('parent_teacher_messages').insert({
        'parent_id': parentId,
        'teacher_id': teacherId,
        'student_id': studentId,
        'message': message,
        'created_at': DateTime.now().toIso8601String(),
      });

      Get.snackbar(
        '✅ Message Sent',
        'Your message has been sent to the teacher',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      print('❌ Error sending message: $e');
      return false;
    }
  }

  /// Get messages with teacher
  Future<List<Map<String, dynamic>>> getMessagesWithTeacher(
    String parentId,
    String teacherId,
  ) async {
    try {
      final response = await _client
          .from('parent_teacher_messages')
          .select()
          .or('parent_id.eq.$parentId,teacher_id.eq.$teacherId')
          .order('created_at', ascending: true);

      return response;
    } catch (e) {
      return [];
    }
  }

  /// Request parent-teacher meeting
  Future<bool> requestMeeting(
    String parentId,
    String teacherId,
    String studentId,
    DateTime preferredDate,
    String reason,
  ) async {
    try {
      await _client.from('meeting_requests').insert({
        'parent_id': parentId,
        'teacher_id': teacherId,
        'student_id': studentId,
        'preferred_date': preferredDate.toIso8601String(),
        'reason': reason,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      });

      Get.snackbar(
        '✅ Meeting Requested',
        'Your meeting request has been sent',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      print('❌ Error requesting meeting: $e');
      return false;
    }
  }

  /// Get attendance alerts
  Future<List<Map<String, dynamic>>> getAttendanceAlerts(
    String studentId,
  ) async {
    try {
      // Get classes with low attendance
      final enrollments = await _client
          .from(DatabaseTables.classEnrollments)
          .select('*, online_classes(*)')
          .eq('student_id', studentId);

      final alerts = <Map<String, dynamic>>[];

      // Check for missed classes
      for (var enrollment in enrollments) {
        final classData = enrollment['online_classes'];
        if (classData['status'] == 'completed') {
          // Check if student attended
          final participants = await _client
              .from(DatabaseTables.meetingParticipants)
              .select()
              .eq('meeting_id', classData['meeting_id'])
              .eq('user_id', studentId);

          if (participants.isEmpty) {
            alerts.add({
              'type': 'missed_class',
              'title': 'Missed Class',
              'message': 'Student missed ${classData['title']}',
              'date': classData['scheduled_time'],
              'severity': 'warning',
            });
          }
        }
      }

      return alerts;
    } catch (e) {
      return [];
    }
  }

  /// Get performance alerts
  Future<List<Map<String, dynamic>>> getPerformanceAlerts(
    String studentId,
  ) async {
    try {
      final alerts = <Map<String, dynamic>>[];

      // Get recent submissions
      final submissions = await _client
          .from(DatabaseTables.assessmentSubmissions)
          .select('*, assessments(*)')
          .eq('student_id', studentId)
          .order('submitted_at', ascending: false)
          .limit(5);

      for (var submission in submissions) {
        final score = submission['score'] ?? 0;
        final maxScore = submission['assessments']['total_marks'];
        final percentage = maxScore == 0 ? 0.0 : (score / maxScore) * 100;

        if (percentage < 50) {
          alerts.add({
            'type': 'low_score',
            'title': 'Low Assessment Score',
            'message':
                'Scored ${percentage.toStringAsFixed(1)}% in ${submission['assessments']['title']}',
            'date': submission['submitted_at'],
            'severity': 'critical',
          });
        } else if (percentage < 70) {
          alerts.add({
            'type': 'below_average',
            'title': 'Below Average Score',
            'message':
                'Scored ${percentage.toStringAsFixed(1)}% in ${submission['assessments']['title']}',
            'date': submission['submitted_at'],
            'severity': 'warning',
          });
        }
      }

      return alerts;
    } catch (e) {
      return [];
    }
  }
}
