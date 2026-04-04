import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

/// Advanced Analytics Service
/// Provides detailed analytics for students, staff, and admins
class AdvancedAnalyticsService extends GetxService {
  final SupabaseClient _client = SupabaseConfig.client;

  /// Get student performance analytics
  Future<Map<String, dynamic>> getStudentAnalytics(String studentId) async {
    try {
      // Get all assessments taken by student
      final submissions = await _client
          .from(DatabaseTables.assessmentSubmissions)
          .select('*, assessments(*)')
          .eq('student_id', studentId);

      // Get class attendance
      final enrollments = await _client
          .from(DatabaseTables.classEnrollments)
          .select('*, online_classes(*)')
          .eq('student_id', studentId);

      // Calculate statistics
      final totalAssessments = submissions.length;
      final averageScore = submissions.isEmpty
          ? 0.0
          : submissions.map((s) => s['score'] ?? 0).reduce((a, b) => a + b) /
                totalAssessments;

      final totalClasses = enrollments.length;
      final completedClasses = enrollments
          .where((e) => e['online_classes']['status'] == 'completed')
          .length;
      final attendanceRate = totalClasses == 0
          ? 0.0
          : (completedClasses / totalClasses) * 100;

      // Subject-wise performance
      final subjectPerformance = <String, Map<String, dynamic>>{};
      for (var submission in submissions) {
        final subject = submission['assessments']['subject'];
        if (!subjectPerformance.containsKey(subject)) {
          subjectPerformance[subject] = {
            'totalAssessments': 0,
            'totalScore': 0,
            'maxScore': 0,
          };
        }
        subjectPerformance[subject]!['totalAssessments']++;
        subjectPerformance[subject]!['totalScore'] += submission['score'] ?? 0;
        subjectPerformance[subject]!['maxScore'] +=
            submission['assessments']['total_marks'];
      }

      // Calculate subject averages
      final subjectAverages = <String, double>{};
      subjectPerformance.forEach((subject, data) {
        final avg = data['maxScore'] == 0
            ? 0.0
            : (data['totalScore'] / data['maxScore']) * 100;
        subjectAverages[subject] = avg;
      });

      return {
        'studentId': studentId,
        'totalAssessments': totalAssessments,
        'averageScore': averageScore,
        'totalClasses': totalClasses,
        'completedClasses': completedClasses,
        'attendanceRate': attendanceRate,
        'subjectPerformance': subjectAverages,
        'recentSubmissions': submissions.take(5).toList(),
        'upcomingClasses': enrollments
            .where((e) => e['online_classes']['status'] == 'scheduled')
            .take(5)
            .toList(),
      };
    } catch (e) {
      print('❌ Error fetching student analytics: $e');
      return {};
    }
  }

  /// Get teacher analytics
  Future<Map<String, dynamic>> getTeacherAnalytics(String teacherId) async {
    try {
      // Get all classes created by teacher
      final classes = await _client
          .from(DatabaseTables.onlineClasses)
          .select('*, class_enrollments(*)')
          .eq('teacher_id', teacherId);

      // Get all assessments created by teacher
      final assessments = await _client
          .from(DatabaseTables.assessments)
          .select('*, assessment_submissions(*)')
          .eq('teacher_id', teacherId);

      final totalClasses = classes.length;
      final completedClasses = classes
          .where((c) => c['status'] == 'completed')
          .length;
      final liveClasses = classes.where((c) => c['status'] == 'live').length;
      final scheduledClasses = classes
          .where((c) => c['status'] == 'scheduled')
          .length;

      // Calculate total students reached
      final uniqueStudents = <String>{};
      for (var classData in classes) {
        final enrollments = classData['class_enrollments'] as List;
        for (var enrollment in enrollments) {
          uniqueStudents.add(enrollment['student_id']);
        }
      }

      // Assessment statistics
      final totalAssessments = assessments.length;
      final totalSubmissions = assessments.fold<int>(
        0,
        (sum, a) => sum + (a['assessment_submissions'] as List).length,
      );

      // Average class size
      final totalEnrollments = classes.fold<int>(
        0,
        (sum, c) => sum + (c['class_enrollments'] as List).length,
      );
      final avgClassSize = totalClasses == 0
          ? 0.0
          : totalEnrollments / totalClasses;

      return {
        'teacherId': teacherId,
        'totalClasses': totalClasses,
        'completedClasses': completedClasses,
        'liveClasses': liveClasses,
        'scheduledClasses': scheduledClasses,
        'totalStudentsReached': uniqueStudents.length,
        'totalAssessments': totalAssessments,
        'totalSubmissions': totalSubmissions,
        'averageClassSize': avgClassSize,
        'recentClasses': classes.take(5).toList(),
        'recentAssessments': assessments.take(5).toList(),
      };
    } catch (e) {
      print('❌ Error fetching teacher analytics: $e');
      return {};
    }
  }

  /// Get system-wide analytics (Admin)
  Future<Map<String, dynamic>> getSystemAnalytics() async {
    try {
      // Get counts
      final usersCount = await _client
          .from(DatabaseTables.users)
          .select('id, role')
          .count(CountOption.exact);

      final classesCount = await _client
          .from(DatabaseTables.onlineClasses)
          .select('id, status')
          .count(CountOption.exact);

      final assessmentsCount = await _client
          .from(DatabaseTables.assessments)
          .select('id')
          .count(CountOption.exact);

      // Get detailed data
      final users = await _client.from(DatabaseTables.users).select('role');

      final classes = await _client
          .from(DatabaseTables.onlineClasses)
          .select('status');

      // Count by role
      final studentCount = users.where((u) => u['role'] == 'student').length;
      final staffCount = users.where((u) => u['role'] == 'staff').length;
      final adminCount = users.where((u) => u['role'] == 'admin').length;

      // Count by status
      final liveClasses = classes.where((c) => c['status'] == 'live').length;
      final scheduledClasses = classes
          .where((c) => c['status'] == 'scheduled')
          .length;
      final completedClasses = classes
          .where((c) => c['status'] == 'completed')
          .length;

      // Get recent activity
      final recentClasses = await _client
          .from(DatabaseTables.onlineClasses)
          .select()
          .order('created_at', ascending: false)
          .limit(10);

      final recentUsers = await _client
          .from(DatabaseTables.users)
          .select()
          .order('created_at', ascending: false)
          .limit(10);

      // Calculate growth (last 7 days vs previous 7 days)
      final now = DateTime.now();
      final last7Days = now.subtract(const Duration(days: 7));
      final previous7Days = now.subtract(const Duration(days: 14));

      final recentUsersCount = await _client
          .from(DatabaseTables.users)
          .select('id')
          .gte('created_at', last7Days.toIso8601String())
          .count(CountOption.exact);

      final previousUsersCount = await _client
          .from(DatabaseTables.users)
          .select('id')
          .gte('created_at', previous7Days.toIso8601String())
          .lt('created_at', last7Days.toIso8601String())
          .count(CountOption.exact);

      final userGrowth = previousUsersCount.count == 0
          ? 0.0
          : ((recentUsersCount.count - previousUsersCount.count) /
                    previousUsersCount.count) *
                100;

      return {
        'totalUsers': usersCount.count,
        'studentCount': studentCount,
        'staffCount': staffCount,
        'adminCount': adminCount,
        'totalClasses': classesCount.count,
        'liveClasses': liveClasses,
        'scheduledClasses': scheduledClasses,
        'completedClasses': completedClasses,
        'totalAssessments': assessmentsCount.count,
        'userGrowth': userGrowth,
        'recentClasses': recentClasses,
        'recentUsers': recentUsers,
      };
    } catch (e) {
      print('❌ Error fetching system analytics: $e');
      return {};
    }
  }

  /// Get engagement metrics
  Future<Map<String, dynamic>> getEngagementMetrics() async {
    try {
      final now = DateTime.now();
      final last30Days = now.subtract(const Duration(days: 30));

      // Classes created in last 30 days
      final recentClasses = await _client
          .from(DatabaseTables.onlineClasses)
          .select()
          .gte('created_at', last30Days.toIso8601String());

      // Assessments created in last 30 days
      final recentAssessments = await _client
          .from(DatabaseTables.assessments)
          .select()
          .gte('created_at', last30Days.toIso8601String());

      // Translations in last 30 days
      final recentTranslations = await _client
          .from(DatabaseTables.translations)
          .select()
          .gte('created_at', last30Days.toIso8601String());

      // Chat messages in last 30 days
      final recentChats = await _client
          .from(DatabaseTables.chatMessages)
          .select()
          .gte('created_at', last30Days.toIso8601String());

      return {
        'classesCreated': recentClasses.length,
        'assessmentsCreated': recentAssessments.length,
        'translationsUsed': recentTranslations.length,
        'chatMessages': recentChats.length,
        'period': '30 days',
      };
    } catch (e) {
      print('❌ Error fetching engagement metrics: $e');
      return {};
    }
  }

  /// Get performance trends
  Future<List<Map<String, dynamic>>> getPerformanceTrends(
    String studentId,
    int days,
  ) async {
    try {
      final startDate = DateTime.now().subtract(Duration(days: days));

      final submissions = await _client
          .from(DatabaseTables.assessmentSubmissions)
          .select('*, assessments(*)')
          .eq('student_id', studentId)
          .gte('submitted_at', startDate.toIso8601String())
          .order('submitted_at', ascending: true);

      final trends = <Map<String, dynamic>>[];
      for (var submission in submissions) {
        final score = submission['score'] ?? 0;
        final maxScore = submission['assessments']['total_marks'];
        final percentage = maxScore == 0 ? 0.0 : (score / maxScore) * 100;

        trends.add({
          'date': submission['submitted_at'],
          'subject': submission['assessments']['subject'],
          'score': score,
          'maxScore': maxScore,
          'percentage': percentage,
          'title': submission['assessments']['title'],
        });
      }

      return trends;
    } catch (e) {
      print('❌ Error fetching performance trends: $e');
      return [];
    }
  }

  /// Get class attendance report
  Future<Map<String, dynamic>> getAttendanceReport(String classId) async {
    try {
      final enrollments = await _client
          .from(DatabaseTables.classEnrollments)
          .select('*, users(*)')
          .eq('class_id', classId);

      final participants = await _client
          .from(DatabaseTables.meetingParticipants)
          .select()
          .eq('meeting_id', classId);

      final totalEnrolled = enrollments.length;
      final totalAttended = participants.length;
      final attendanceRate = totalEnrolled == 0
          ? 0.0
          : (totalAttended / totalEnrolled) * 100;

      // Get list of students who attended
      final attendedStudentIds = participants.map((p) => p['user_id']).toSet();

      final attendedStudents = enrollments
          .where((e) => attendedStudentIds.contains(e['student_id']))
          .map((e) => e['users'])
          .toList();

      final absentStudents = enrollments
          .where((e) => !attendedStudentIds.contains(e['student_id']))
          .map((e) => e['users'])
          .toList();

      return {
        'classId': classId,
        'totalEnrolled': totalEnrolled,
        'totalAttended': totalAttended,
        'attendanceRate': attendanceRate,
        'attendedStudents': attendedStudents,
        'absentStudents': absentStudents,
      };
    } catch (e) {
      print('❌ Error fetching attendance report: $e');
      return {};
    }
  }

  /// Export analytics to CSV format
  String exportToCSV(Map<String, dynamic> data, String type) {
    final buffer = StringBuffer();

    switch (type) {
      case 'student':
        buffer.writeln('Metric,Value');
        buffer.writeln('Total Assessments,${data['totalAssessments']}');
        buffer.writeln('Average Score,${data['averageScore']}');
        buffer.writeln('Total Classes,${data['totalClasses']}');
        buffer.writeln('Attendance Rate,${data['attendanceRate']}%');
        break;

      case 'teacher':
        buffer.writeln('Metric,Value');
        buffer.writeln('Total Classes,${data['totalClasses']}');
        buffer.writeln('Completed Classes,${data['completedClasses']}');
        buffer.writeln('Total Students,${data['totalStudentsReached']}');
        buffer.writeln('Total Assessments,${data['totalAssessments']}');
        break;

      case 'system':
        buffer.writeln('Metric,Value');
        buffer.writeln('Total Users,${data['totalUsers']}');
        buffer.writeln('Students,${data['studentCount']}');
        buffer.writeln('Staff,${data['staffCount']}');
        buffer.writeln('Total Classes,${data['totalClasses']}');
        buffer.writeln('Live Classes,${data['liveClasses']}');
        break;
    }

    return buffer.toString();
  }
}
