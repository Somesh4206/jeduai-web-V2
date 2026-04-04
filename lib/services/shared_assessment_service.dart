import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AssessmentData {
  final String id;
  final String title;
  final String subject;
  final String type;
  final String difficulty;
  final int totalQuestions;
  final int duration;
  final String classLevel;
  final String createdBy;
  final String createdByName;
  final DateTime createdAt;
  final DateTime dueDate;
  final List<dynamic> questions;
  final bool isAIGenerated;

  // Student-specific fields
  int? score;
  bool isCompleted;
  DateTime? completedAt;

  AssessmentData({
    required this.id,
    required this.title,
    required this.subject,
    required this.type,
    required this.difficulty,
    required this.totalQuestions,
    required this.duration,
    required this.classLevel,
    required this.createdBy,
    required this.createdByName,
    required this.createdAt,
    required this.dueDate,
    required this.questions,
    this.isAIGenerated = false,
    this.score,
    this.isCompleted = false,
    this.completedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'subject': subject,
    'type': type,
    'difficulty': difficulty,
    'totalQuestions': totalQuestions,
    'duration': duration,
    'classLevel': classLevel,
    'createdBy': createdBy,
    'createdByName': createdByName,
    'createdAt': createdAt.toIso8601String(),
    'dueDate': dueDate.toIso8601String(),
    'questions': questions,
    'isAIGenerated': isAIGenerated,
    'score': score,
    'isCompleted': isCompleted,
    'completedAt': completedAt?.toIso8601String(),
  };

  factory AssessmentData.fromJson(Map<String, dynamic> json) => AssessmentData(
    id: json['id'],
    title: json['title'],
    subject: json['subject'],
    type: json['type'],
    difficulty: json['difficulty'],
    totalQuestions: json['totalQuestions'],
    duration: json['duration'],
    classLevel: json['classLevel'],
    createdBy: json['createdBy'],
    createdByName: json['createdByName'],
    createdAt: DateTime.parse(json['createdAt']),
    dueDate: DateTime.parse(json['dueDate']),
    questions: json['questions'],
    isAIGenerated: json['isAIGenerated'] ?? false,
    score: json['score'],
    isCompleted: json['isCompleted'] ?? false,
    completedAt: json['completedAt'] != null
        ? DateTime.parse(json['completedAt'])
        : null,
  );

  AssessmentData copyWith({
    int? score,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return AssessmentData(
      id: id,
      title: title,
      subject: subject,
      type: type,
      difficulty: difficulty,
      totalQuestions: totalQuestions,
      duration: duration,
      classLevel: classLevel,
      createdBy: createdBy,
      createdByName: createdByName,
      createdAt: createdAt,
      dueDate: dueDate,
      questions: questions,
      isAIGenerated: isAIGenerated,
      score: score ?? this.score,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

class SharedAssessmentService extends GetxService {
  static SharedAssessmentService get instance => Get.find();

  final RxList<AssessmentData> allAssessments = <AssessmentData>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadAssessments();
    _initializePredefinedAssessments();
  }

  // Initialize pre-defined assessments for testing (only visible to admin student)
  Future<void> _initializePredefinedAssessments() async {
    // Check if pre-defined assessments already exist
    if (allAssessments.any((a) => a.id.startsWith('PREDEFINED_'))) {
      return; // Already initialized
    }

    // Create pre-defined assessments
    final predefinedAssessments = [
      AssessmentData(
        id: 'PREDEFINED_1',
        title: 'Basic Arithmetic',
        subject: 'Mathematics',
        type: 'Quiz',
        difficulty: 'Easy',
        totalQuestions: 15,
        duration: 20,
        classLevel: 'ALL', // Visible to all classes
        createdBy: 'system',
        createdByName: 'System',
        createdAt: DateTime.now(),
        dueDate: DateTime.now().add(Duration(days: 30)),
        questions: [], // Questions are in take_assessment_view.dart
        isAIGenerated: false,
      ),
      AssessmentData(
        id: 'PREDEFINED_2',
        title: 'Algebra Fundamentals',
        subject: 'Mathematics',
        type: 'Quiz',
        difficulty: 'Medium',
        totalQuestions: 20,
        duration: 30,
        classLevel: 'ALL',
        createdBy: 'system',
        createdByName: 'System',
        createdAt: DateTime.now(),
        dueDate: DateTime.now().add(Duration(days: 30)),
        questions: [],
        isAIGenerated: false,
      ),
      AssessmentData(
        id: 'PREDEFINED_4',
        title: 'Grammar Basics',
        subject: 'English',
        type: 'Quiz',
        difficulty: 'Easy',
        totalQuestions: 15,
        duration: 20,
        classLevel: 'ALL',
        createdBy: 'system',
        createdByName: 'System',
        createdAt: DateTime.now(),
        dueDate: DateTime.now().add(Duration(days: 30)),
        questions: [],
        isAIGenerated: false,
      ),
      AssessmentData(
        id: 'PREDEFINED_10',
        title: 'HTML & CSS Basics',
        subject: 'Programming',
        type: 'Quiz',
        difficulty: 'Easy',
        totalQuestions: 20,
        duration: 30,
        classLevel: 'ALL',
        createdBy: 'system',
        createdByName: 'System',
        createdAt: DateTime.now(),
        dueDate: DateTime.now().add(Duration(days: 30)),
        questions: [],
        isAIGenerated: false,
      ),
      AssessmentData(
        id: 'PREDEFINED_16',
        title: 'Logical Reasoning Basics',
        subject: 'Aptitude',
        type: 'Quiz',
        difficulty: 'Easy',
        totalQuestions: 20,
        duration: 30,
        classLevel: 'ALL',
        createdBy: 'system',
        createdByName: 'System',
        createdAt: DateTime.now(),
        dueDate: DateTime.now().add(Duration(days: 30)),
        questions: [],
        isAIGenerated: false,
      ),
    ];

    allAssessments.addAll(predefinedAssessments);
    await saveAssessments();
    print(
      '✅ Initialized ${predefinedAssessments.length} pre-defined assessments',
    );
  }

  // Load assessments from local storage
  Future<void> loadAssessments() async {
    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final assessmentsJson = prefs.getString('shared_assessments');

      if (assessmentsJson != null) {
        final List<dynamic> decoded = jsonDecode(assessmentsJson);
        allAssessments.value = decoded
            .map((json) => AssessmentData.fromJson(json))
            .toList();
      }
    } catch (e) {
      print('Error loading assessments: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Save assessments to local storage
  Future<void> saveAssessments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final assessmentsJson = jsonEncode(
        allAssessments.map((a) => a.toJson()).toList(),
      );
      await prefs.setString('shared_assessments', assessmentsJson);
    } catch (e) {
      print('Error saving assessments: $e');
    }
  }

  // Create new assessment
  Future<String> createAssessment({
    required String title,
    required String subject,
    required String type,
    required String difficulty,
    required int totalQuestions,
    required int duration,
    required String classLevel,
    required String createdBy,
    required String createdByName,
    required List<dynamic> questions,
    bool isAIGenerated = false,
    DateTime? dueDate,
  }) async {
    final id = 'ASSESS_${DateTime.now().millisecondsSinceEpoch}';

    final assessment = AssessmentData(
      id: id,
      title: title,
      subject: subject,
      type: type,
      difficulty: difficulty,
      totalQuestions: totalQuestions,
      duration: duration,
      classLevel: classLevel,
      createdBy: createdBy,
      createdByName: createdByName,
      createdAt: DateTime.now(),
      dueDate: dueDate ?? DateTime.now().add(Duration(days: 7)),
      questions: questions,
      isAIGenerated: isAIGenerated,
    );

    allAssessments.add(assessment);
    await saveAssessments();

    // Show success notification
    Get.snackbar(
      'Assessment Created',
      '$title has been created and is now available to students',
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 3),
    );

    return id;
  }

  // Update assessment completion
  Future<void> completeAssessment(String assessmentId, int score) async {
    final index = allAssessments.indexWhere((a) => a.id == assessmentId);
    if (index != -1) {
      allAssessments[index] = allAssessments[index].copyWith(
        score: score,
        isCompleted: true,
        completedAt: DateTime.now(),
      );
      await saveAssessments();
    }
  }

  // Map class names to handle different formats
  String _normalizeClassName(String className) {
    final normalized = className.toUpperCase().trim();

    // Map College Year to CSBS format
    if (normalized.contains('YEAR 1') || normalized.contains('I CSBS')) {
      return 'I CSBS';
    }
    if (normalized.contains('YEAR 2') || normalized.contains('II CSBS')) {
      return 'II CSBS';
    }
    if (normalized.contains('YEAR 3') || normalized.contains('III CSBS')) {
      return 'III CSBS';
    }
    if (normalized.contains('YEAR 4') || normalized.contains('IV CSBS')) {
      return 'IV CSBS';
    }

    return className;
  }

  // Get assessments for a specific class
  List<AssessmentData> getAssessmentsForClass(String className) {
    final normalizedClass = _normalizeClassName(className);

    return allAssessments.where((a) {
      final assessmentClass = _normalizeClassName(a.classLevel);
      return assessmentClass == normalizedClass;
    }).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Get assessments created by a specific staff
  List<AssessmentData> getAssessmentsByStaff(String staffEmail) {
    return allAssessments.where((a) => a.createdBy == staffEmail).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Get assessments by subject
  List<AssessmentData> getAssessmentsBySubject(String subject) {
    return allAssessments
        .where((a) => a.subject.toLowerCase().contains(subject.toLowerCase()))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Get upcoming assessments for students
  List<AssessmentData> getUpcomingAssessments(String className) {
    final now = DateTime.now();
    return allAssessments
        .where(
          (a) =>
              a.classLevel == className &&
              !a.isCompleted &&
              a.dueDate.isAfter(now),
        )
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  // Get completed assessments
  List<AssessmentData> getCompletedAssessments() {
    return allAssessments.where((a) => a.isCompleted).toList()
      ..sort((a, b) => b.completedAt!.compareTo(a.completedAt!));
  }

  // Get assessment by ID
  AssessmentData? getAssessmentById(String id) {
    try {
      return allAssessments.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  // Delete assessment
  Future<void> deleteAssessment(String id) async {
    allAssessments.removeWhere((a) => a.id == id);
    await saveAssessments();

    Get.snackbar(
      'Assessment Deleted',
      'The assessment has been removed',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // Get statistics
  Map<String, dynamic> getStatistics(String? staffEmail) {
    final assessments = staffEmail != null
        ? getAssessmentsByStaff(staffEmail)
        : allAssessments;

    final total = assessments.length;
    final aiGenerated = assessments.where((a) => a.isAIGenerated).length;
    final completed = assessments.where((a) => a.isCompleted).length;
    final pending = total - completed;

    final avgScore = completed > 0
        ? assessments
                  .where((a) => a.isCompleted && a.score != null)
                  .map((a) => a.score!)
                  .reduce((a, b) => a + b) /
              completed
        : 0.0;

    return {
      'total': total,
      'aiGenerated': aiGenerated,
      'completed': completed,
      'pending': pending,
      'averageScore': avgScore,
    };
  }

  // Get subject-wise breakdown
  Map<String, int> getSubjectBreakdown(String? staffEmail) {
    final assessments = staffEmail != null
        ? getAssessmentsByStaff(staffEmail)
        : allAssessments;

    final Map<String, int> breakdown = {};
    for (var assessment in assessments) {
      breakdown[assessment.subject] = (breakdown[assessment.subject] ?? 0) + 1;
    }
    return breakdown;
  }

  // Search assessments
  List<AssessmentData> searchAssessments(String query) {
    final lowerQuery = query.toLowerCase();
    return allAssessments
        .where(
          (a) =>
              a.title.toLowerCase().contains(lowerQuery) ||
              a.subject.toLowerCase().contains(lowerQuery) ||
              a.createdByName.toLowerCase().contains(lowerQuery),
        )
        .toList();
  }

  // Get recent assessments
  List<AssessmentData> getRecentAssessments({int limit = 5}) {
    final sorted = List<AssessmentData>.from(allAssessments)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(limit).toList();
  }

  // Clear all assessments (for testing)
  Future<void> clearAllAssessments() async {
    allAssessments.clear();
    await saveAssessments();
  }
}
