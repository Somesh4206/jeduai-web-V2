import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

/// Smart Study Planner Service - AI-powered study scheduling
class SmartStudyPlannerService extends GetxService {
  final SupabaseClient _client = SupabaseConfig.client;

  /// Generate personalized study plan
  Future<Map<String, dynamic>> generateStudyPlan(String studentId) async {
    try {
      // Get student's schedule
      final classes = await _getStudentClasses(studentId);
      final assessments = await _getUpcomingAssessments(studentId);
      final performance = await _getPerformanceData(studentId);

      // Analyze and create plan
      final plan = _createOptimalPlan(classes, assessments, performance);

      // Save plan
      await _savePlan(studentId, plan);

      return plan;
    } catch (e) {
      print('❌ Error generating study plan: $e');
      return {};
    }
  }

  /// Get student's classes
  Future<List<Map<String, dynamic>>> _getStudentClasses(
    String studentId,
  ) async {
    try {
      final enrollments = await _client
          .from(DatabaseTables.classEnrollments)
          .select('*, online_classes(*)')
          .eq('student_id', studentId);

      return enrollments;
    } catch (e) {
      return [];
    }
  }

  /// Get upcoming assessments
  Future<List<Map<String, dynamic>>> _getUpcomingAssessments(
    String studentId,
  ) async {
    try {
      final assessments = await _client
          .from(DatabaseTables.assessments)
          .select()
          .gte('due_date', DateTime.now().toIso8601String())
          .order('due_date', ascending: true);

      return assessments;
    } catch (e) {
      return [];
    }
  }

  /// Get performance data
  Future<Map<String, dynamic>> _getPerformanceData(String studentId) async {
    try {
      final submissions = await _client
          .from(DatabaseTables.assessmentSubmissions)
          .select('*, assessments(*)')
          .eq('student_id', studentId)
          .order('submitted_at', ascending: false)
          .limit(20);

      // Calculate subject-wise performance
      final subjectScores = <String, List<double>>{};
      for (var submission in submissions) {
        final subject = submission['assessments']['subject'] as String;
        final score = submission['score'] ?? 0;
        final maxScore = submission['assessments']['total_marks'];
        final percentage = maxScore == 0 ? 0.0 : (score / maxScore) * 100;

        if (!subjectScores.containsKey(subject)) {
          subjectScores[subject] = [];
        }
        subjectScores[subject]!.add(percentage);
      }

      return {'subjectScores': subjectScores};
    } catch (e) {
      return {};
    }
  }

  /// Create optimal study plan
  Map<String, dynamic> _createOptimalPlan(
    List<Map<String, dynamic>> classes,
    List<Map<String, dynamic>> assessments,
    Map<String, dynamic> performance,
  ) {
    final plan = <String, dynamic>{};
    final dailySchedule = <String, List<Map<String, dynamic>>>{};

    // Prioritize subjects based on performance
    final subjectScores =
        performance['subjectScores'] as Map<String, List<double>>? ?? {};
    final weakSubjects = <String>[];

    subjectScores.forEach((subject, scores) {
      final avg = scores.reduce((a, b) => a + b) / scores.length;
      if (avg < 60) {
        weakSubjects.add(subject);
      }
    });

    // Create daily schedule for next 7 days
    for (int i = 0; i < 7; i++) {
      final date = DateTime.now().add(Duration(days: i));
      final dateKey =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      dailySchedule[dateKey] = [];

      // Morning session (9 AM - 11 AM)
      if (weakSubjects.isNotEmpty) {
        dailySchedule[dateKey]!.add({
          'time': '09:00',
          'duration': 60,
          'activity': 'Study ${weakSubjects[i % weakSubjects.length]}',
          'type': 'study',
          'priority': 'high',
        });
      }

      // Afternoon session (2 PM - 4 PM)
      dailySchedule[dateKey]!.add({
        'time': '14:00',
        'duration': 90,
        'activity': 'Practice problems',
        'type': 'practice',
        'priority': 'medium',
      });

      // Evening session (6 PM - 7 PM)
      dailySchedule[dateKey]!.add({
        'time': '18:00',
        'duration': 60,
        'activity': 'Review and revision',
        'type': 'review',
        'priority': 'medium',
      });

      // Add assessment preparation if due soon
      for (var assessment in assessments) {
        final dueDate = DateTime.parse(assessment['due_date']);
        final daysUntilDue = dueDate.difference(date).inDays;

        if (daysUntilDue >= 0 && daysUntilDue <= 3) {
          dailySchedule[dateKey]!.add({
            'time': '20:00',
            'duration': 60,
            'activity': 'Prepare for ${assessment['title']}',
            'type': 'assessment_prep',
            'priority': 'high',
            'assessmentId': assessment['id'],
          });
        }
      }
    }

    plan['dailySchedule'] = dailySchedule;
    plan['weakSubjects'] = weakSubjects;
    plan['totalStudyHours'] = _calculateTotalHours(dailySchedule);
    plan['recommendations'] = _generateRecommendations(
      weakSubjects,
      assessments,
    );

    return plan;
  }

  /// Calculate total study hours
  int _calculateTotalHours(Map<String, List<Map<String, dynamic>>> schedule) {
    int total = 0;
    schedule.forEach((date, activities) {
      for (var activity in activities) {
        total += activity['duration'] as int;
      }
    });
    return (total / 60).round();
  }

  /// Generate recommendations
  List<String> _generateRecommendations(
    List<String> weakSubjects,
    List<Map<String, dynamic>> assessments,
  ) {
    final recommendations = <String>[];

    if (weakSubjects.isNotEmpty) {
      recommendations.add(
        'Focus on ${weakSubjects.join(", ")} - these need improvement',
      );
    }

    if (assessments.isNotEmpty) {
      recommendations.add(
        '${assessments.length} upcoming assessments - start preparing early',
      );
    }

    recommendations.addAll([
      'Take regular breaks every 45 minutes',
      'Study in a quiet, well-lit environment',
      'Use active recall and spaced repetition',
      'Join study groups for difficult topics',
      'Ask teachers for help when needed',
    ]);

    return recommendations;
  }

  /// Save study plan
  Future<void> _savePlan(String studentId, Map<String, dynamic> plan) async {
    try {
      await _client.from('study_plans').upsert({
        'student_id': studentId,
        'plan_data': plan,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('❌ Error saving plan: $e');
    }
  }

  /// Get saved study plan
  Future<Map<String, dynamic>?> getStudyPlan(String studentId) async {
    try {
      final response = await _client
          .from('study_plans')
          .select()
          .eq('student_id', studentId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      return response?['plan_data'];
    } catch (e) {
      return null;
    }
  }

  /// Mark activity as completed
  Future<void> markActivityCompleted(
    String studentId,
    String date,
    String activity,
  ) async {
    try {
      await _client.from('study_plan_progress').insert({
        'student_id': studentId,
        'date': date,
        'activity': activity,
        'completed_at': DateTime.now().toIso8601String(),
      });

      Get.snackbar(
        '✅ Activity Completed',
        'Great job! Keep up the good work!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('❌ Error marking activity: $e');
    }
  }

  /// Get study statistics
  Future<Map<String, dynamic>> getStudyStatistics(String studentId) async {
    try {
      final progress = await _client
          .from('study_plan_progress')
          .select()
          .eq('student_id', studentId)
          .gte(
            'completed_at',
            DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
          );

      final totalActivities = progress.length;
      final studyHours = totalActivities * 1.5; // Approximate
      final streak = await _calculateStreak(studentId);

      return {
        'totalActivities': totalActivities,
        'studyHours': studyHours,
        'currentStreak': streak,
        'lastStudied': progress.isNotEmpty
            ? progress.last['completed_at']
            : null,
      };
    } catch (e) {
      return {};
    }
  }

  /// Calculate study streak
  Future<int> _calculateStreak(String studentId) async {
    try {
      final progress = await _client
          .from('study_plan_progress')
          .select('date')
          .eq('student_id', studentId)
          .order('date', ascending: false);

      if (progress.isEmpty) return 0;

      int streak = 1;
      DateTime lastDate = DateTime.parse(progress.first['date']);

      for (int i = 1; i < progress.length; i++) {
        final currentDate = DateTime.parse(progress[i]['date']);
        final diff = lastDate.difference(currentDate).inDays;

        if (diff == 1) {
          streak++;
          lastDate = currentDate;
        } else {
          break;
        }
      }

      return streak;
    } catch (e) {
      return 0;
    }
  }
}
