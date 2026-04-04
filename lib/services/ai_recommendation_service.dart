import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

/// AI-Powered Recommendation Service
/// Provides personalized recommendations for students and teachers
class AIRecommendationService extends GetxService {
  final SupabaseClient _client = SupabaseConfig.client;

  /// Get personalized class recommendations for students
  Future<List<Map<String, dynamic>>> getClassRecommendations(
    String studentId,
  ) async {
    try {
      // Get student's enrolled classes and subjects
      final enrollments = await _client
          .from(DatabaseTables.classEnrollments)
          .select('*, online_classes(*)')
          .eq('student_id', studentId);

      // Extract subjects student is interested in
      final interestedSubjects = enrollments
          .map((e) => e['online_classes']['subject'] as String)
          .toSet()
          .toList();

      // Get student's performance by subject
      final submissions = await _client
          .from(DatabaseTables.assessmentSubmissions)
          .select('*, assessments(*)')
          .eq('student_id', studentId);

      // Calculate weak subjects (performance < 60%)
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

      final weakSubjects = <String>[];
      subjectScores.forEach((subject, scores) {
        final avg = scores.reduce((a, b) => a + b) / scores.length;
        if (avg < 60) {
          weakSubjects.add(subject);
        }
      });

      // Get recommended classes
      // Priority: 1. Weak subjects, 2. Interested subjects, 3. Popular classes
      final recommendations = <Map<String, dynamic>>[];

      // Classes for weak subjects
      if (weakSubjects.isNotEmpty) {
        final weakSubjectClasses = await _client
            .from(DatabaseTables.onlineClasses)
            .select('*, class_enrollments(*)')
            .inFilter('subject', weakSubjects)
            .eq('status', 'scheduled')
            .limit(5);

        for (var classData in weakSubjectClasses) {
          recommendations.add({
            ...classData,
            'recommendationReason': 'Improve in ${classData['subject']}',
            'priority': 'high',
          });
        }
      }

      // Classes in interested subjects
      if (interestedSubjects.isNotEmpty) {
        final interestedClasses = await _client
            .from(DatabaseTables.onlineClasses)
            .select('*, class_enrollments(*)')
            .inFilter('subject', interestedSubjects)
            .eq('status', 'scheduled')
            .limit(5);

        for (var classData in interestedClasses) {
          if (!recommendations.any((r) => r['id'] == classData['id'])) {
            recommendations.add({
              ...classData,
              'recommendationReason': 'Based on your interests',
              'priority': 'medium',
            });
          }
        }
      }

      // Popular classes (high enrollment)
      final popularClasses = await _client
          .from(DatabaseTables.onlineClasses)
          .select('*, class_enrollments(*)')
          .eq('status', 'scheduled')
          .limit(10);

      popularClasses.sort((a, b) {
        final aEnrollments = (a['class_enrollments'] as List).length;
        final bEnrollments = (b['class_enrollments'] as List).length;
        return bEnrollments.compareTo(aEnrollments);
      });

      for (var classData in popularClasses.take(3)) {
        if (!recommendations.any((r) => r['id'] == classData['id'])) {
          recommendations.add({
            ...classData,
            'recommendationReason': 'Popular among students',
            'priority': 'low',
          });
        }
      }

      return recommendations;
    } catch (e) {
      print('❌ Error getting class recommendations: $e');
      return [];
    }
  }

  /// Get study recommendations based on performance
  Future<List<Map<String, dynamic>>> getStudyRecommendations(
    String studentId,
  ) async {
    try {
      final submissions = await _client
          .from(DatabaseTables.assessmentSubmissions)
          .select('*, assessments(*)')
          .eq('student_id', studentId)
          .order('submitted_at', ascending: false)
          .limit(20);

      final recommendations = <Map<String, dynamic>>[];

      // Analyze recent performance
      final subjectPerformance = <String, List<double>>{};
      for (var submission in submissions) {
        final subject = submission['assessments']['subject'] as String;
        final score = submission['score'] ?? 0;
        final maxScore = submission['assessments']['total_marks'];
        final percentage = maxScore == 0 ? 0.0 : (score / maxScore) * 100;

        if (!subjectPerformance.containsKey(subject)) {
          subjectPerformance[subject] = [];
        }
        subjectPerformance[subject]!.add(percentage);
      }

      // Generate recommendations
      subjectPerformance.forEach((subject, scores) {
        final avg = scores.reduce((a, b) => a + b) / scores.length;
        final trend = scores.length > 1 ? scores.last - scores.first : 0.0;

        if (avg < 50) {
          recommendations.add({
            'subject': subject,
            'type': 'urgent',
            'message': 'Focus on $subject fundamentals',
            'averageScore': avg,
            'trend': trend,
            'actions': [
              'Review basic concepts',
              'Practice more problems',
              'Attend extra classes',
              'Seek teacher help',
            ],
          });
        } else if (avg < 70) {
          recommendations.add({
            'subject': subject,
            'type': 'improvement',
            'message': 'Strengthen your $subject skills',
            'averageScore': avg,
            'trend': trend,
            'actions': [
              'Practice advanced problems',
              'Review weak topics',
              'Join study groups',
            ],
          });
        } else if (trend < -10) {
          recommendations.add({
            'subject': subject,
            'type': 'warning',
            'message': 'Your $subject performance is declining',
            'averageScore': avg,
            'trend': trend,
            'actions': [
              'Identify problem areas',
              'Increase study time',
              'Review recent topics',
            ],
          });
        }
      });

      // Sort by priority
      recommendations.sort((a, b) {
        final priority = {'urgent': 0, 'warning': 1, 'improvement': 2};
        return priority[a['type']]!.compareTo(priority[b['type']]!);
      });

      return recommendations;
    } catch (e) {
      print('❌ Error getting study recommendations: $e');
      return [];
    }
  }

  /// Get teacher recommendations for improving engagement
  Future<List<Map<String, dynamic>>> getTeacherRecommendations(
    String teacherId,
  ) async {
    try {
      final recommendations = <Map<String, dynamic>>[];

      // Get teacher's classes
      final classes = await _client
          .from(DatabaseTables.onlineClasses)
          .select('*, class_enrollments(*)')
          .eq('teacher_id', teacherId);

      // Analyze enrollment rates
      final totalClasses = classes.length;
      if (totalClasses > 0) {
        final avgEnrollment =
            classes.fold<int>(
              0,
              (sum, c) => sum + (c['class_enrollments'] as List).length,
            ) /
            totalClasses;

        if (avgEnrollment < 10) {
          recommendations.add({
            'type': 'engagement',
            'priority': 'high',
            'message': 'Low class enrollment detected',
            'suggestions': [
              'Add more detailed class descriptions',
              'Schedule classes at popular times',
              'Promote classes through announcements',
              'Offer interactive sessions',
            ],
          });
        }
      }

      // Get assessments
      final assessments = await _client
          .from(DatabaseTables.assessments)
          .select('*, assessment_submissions(*)')
          .eq('teacher_id', teacherId);

      // Analyze submission rates
      for (var assessment in assessments) {
        final submissions = assessment['assessment_submissions'] as List;
        final submissionRate = submissions.length;

        if (submissionRate < 5) {
          recommendations.add({
            'type': 'assessment',
            'priority': 'medium',
            'message': 'Low assessment submission rate',
            'assessmentTitle': assessment['title'],
            'suggestions': [
              'Send reminders to students',
              'Extend deadline if needed',
              'Simplify assessment instructions',
              'Provide sample questions',
            ],
          });
        }
      }

      // Check class timing patterns
      final scheduledClasses = classes
          .where((c) => c['status'] == 'scheduled')
          .toList();

      if (scheduledClasses.isEmpty) {
        recommendations.add({
          'type': 'scheduling',
          'priority': 'high',
          'message': 'No upcoming classes scheduled',
          'suggestions': [
            'Schedule regular classes',
            'Plan ahead for better student preparation',
            'Consider student availability',
          ],
        });
      }

      return recommendations;
    } catch (e) {
      print('❌ Error getting teacher recommendations: $e');
      return [];
    }
  }

  /// Get personalized learning path
  Future<Map<String, dynamic>> getPersonalizedLearningPath(
    String studentId,
  ) async {
    try {
      // Get student's current level in each subject
      final submissions = await _client
          .from(DatabaseTables.assessmentSubmissions)
          .select('*, assessments(*)')
          .eq('student_id', studentId);

      final subjectLevels = <String, String>{};
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

      // Determine level for each subject
      subjectScores.forEach((subject, scores) {
        final avg = scores.reduce((a, b) => a + b) / scores.length;
        if (avg >= 80) {
          subjectLevels[subject] = 'Advanced';
        } else if (avg >= 60) {
          subjectLevels[subject] = 'Intermediate';
        } else {
          subjectLevels[subject] = 'Beginner';
        }
      });

      // Create learning path
      final learningPath = <String, dynamic>{};
      subjectLevels.forEach((subject, level) {
        learningPath[subject] = {
          'currentLevel': level,
          'nextSteps': _getNextSteps(subject, level),
          'recommendedClasses': [],
          'estimatedTime': _getEstimatedTime(level),
        };
      });

      return {
        'studentId': studentId,
        'learningPath': learningPath,
        'overallProgress': _calculateOverallProgress(subjectScores),
      };
    } catch (e) {
      print('❌ Error getting learning path: $e');
      return {};
    }
  }

  List<String> _getNextSteps(String subject, String level) {
    switch (level) {
      case 'Beginner':
        return [
          'Master fundamental concepts',
          'Complete basic exercises',
          'Attend introductory classes',
          'Practice regularly',
        ];
      case 'Intermediate':
        return [
          'Tackle advanced problems',
          'Apply concepts to real scenarios',
          'Join advanced classes',
          'Participate in discussions',
        ];
      case 'Advanced':
        return [
          'Explore specialized topics',
          'Mentor other students',
          'Work on projects',
          'Prepare for competitions',
        ];
      default:
        return [];
    }
  }

  String _getEstimatedTime(String level) {
    switch (level) {
      case 'Beginner':
        return '3-6 months';
      case 'Intermediate':
        return '2-4 months';
      case 'Advanced':
        return '1-2 months';
      default:
        return 'Unknown';
    }
  }

  double _calculateOverallProgress(Map<String, List<double>> subjectScores) {
    if (subjectScores.isEmpty) return 0.0;

    final allScores = <double>[];
    for (var scores in subjectScores.values) {
      allScores.addAll(scores);
    }

    return allScores.reduce((a, b) => a + b) / allScores.length;
  }

  /// Get smart scheduling recommendations
  Future<List<Map<String, dynamic>>> getSchedulingRecommendations(
    String teacherId,
  ) async {
    try {
      // Analyze past class timings and enrollment
      final pastClasses = await _client
          .from(DatabaseTables.onlineClasses)
          .select('*, class_enrollments(*)')
          .eq('teacher_id', teacherId)
          .eq('status', 'completed');

      // Find best time slots based on enrollment
      final timeSlotEnrollment = <String, List<int>>{};

      for (var classData in pastClasses) {
        final scheduledTime = DateTime.parse(
          classData['scheduled_time'] as String,
        );
        final hour = scheduledTime.hour;
        final dayOfWeek = scheduledTime.weekday;
        final timeSlot = '$dayOfWeek-$hour';

        if (!timeSlotEnrollment.containsKey(timeSlot)) {
          timeSlotEnrollment[timeSlot] = [];
        }
        timeSlotEnrollment[timeSlot]!.add(
          (classData['class_enrollments'] as List).length,
        );
      }

      // Calculate average enrollment per time slot
      final recommendations = <Map<String, dynamic>>[];
      timeSlotEnrollment.forEach((timeSlot, enrollments) {
        final avg = enrollments.reduce((a, b) => a + b) / enrollments.length;
        final parts = timeSlot.split('-');
        final dayOfWeek = int.parse(parts[0]);
        final hour = int.parse(parts[1]);

        recommendations.add({
          'dayOfWeek': _getDayName(dayOfWeek),
          'hour': hour,
          'averageEnrollment': avg,
          'recommendation': avg > 20 ? 'Highly recommended' : 'Good time',
        });
      });

      // Sort by average enrollment
      recommendations.sort(
        (a, b) => (b['averageEnrollment'] as double).compareTo(
          a['averageEnrollment'] as double,
        ),
      );

      return recommendations.take(5).toList();
    } catch (e) {
      print('❌ Error getting scheduling recommendations: $e');
      return [];
    }
  }

  String _getDayName(int dayOfWeek) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[dayOfWeek - 1];
  }
}
