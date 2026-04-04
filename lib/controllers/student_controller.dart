import 'package:get/get.dart';

class Course {
  final String id;
  final String title;
  final String description;
  final double progress;
  final String instructor;
  final int totalLessons;
  final int completedLessons;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.progress,
    required this.instructor,
    required this.totalLessons,
    required this.completedLessons,
  });
}

class Quiz {
  final String id;
  final String title;
  final String subject;
  final DateTime dueDate;
  final int totalQuestions;
  final int duration; // in minutes

  Quiz({
    required this.id,
    required this.title,
    required this.subject,
    required this.dueDate,
    required this.totalQuestions,
    required this.duration,
  });
}

class OnlineClass {
  final String id;
  final String title;
  final String instructor;
  final DateTime scheduledTime;
  final int duration; // in minutes
  final String meetingLink;
  final String subject;

  OnlineClass({
    required this.id,
    required this.title,
    required this.instructor,
    required this.scheduledTime,
    required this.duration,
    required this.meetingLink,
    required this.subject,
  });
}

class StudentController extends GetxController {
  // Dashboard stats
  var completedCourses = 0.obs;
  var pendingQuizzes = 0.obs;
  var aiTutorUsage = 0.obs;
  var totalPoints = 0.obs;
  var currentStreak = 0.obs;

  // Data lists
  var courses = <Course>[].obs;
  var quizzes = <Quiz>[].obs;
  var upcomingClasses = <OnlineClass>[].obs;
  var recentActivities = <String>[].obs;

  // Loading states
  var isLoadingCourses = false.obs;
  var isLoadingQuizzes = false.obs;
  var isLoadingClasses = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
    fetchCourses();
    fetchQuizzes();
    fetchUpcomingClasses();
  }

  void fetchDashboardData() {
    // Simulate fetching dashboard stats
    completedCourses.value = 5;
    pendingQuizzes.value = 3;
    aiTutorUsage.value = 10;
    totalPoints.value = 850;
    currentStreak.value = 7;

    recentActivities.value = [
      'Completed "Introduction to AI" lesson',
      'Scored 95% on Mathematics Quiz',
      'Attended Online Class: Physics',
      'Used AI Tutor for 30 minutes',
      'Submitted Assignment: English Essay',
    ];
  }

  void fetchCourses() {
    isLoadingCourses.value = true;

    // Simulate API call with delay
    Future.delayed(Duration(seconds: 1), () {
      courses.value = [
        Course(
          id: '1',
          title: 'Introduction to Artificial Intelligence',
          description: 'Learn the basics of AI and machine learning',
          progress: 0.75,
          instructor: 'Dr. Sarah Johnson',
          totalLessons: 20,
          completedLessons: 15,
        ),
        Course(
          id: '2',
          title: 'Advanced Mathematics',
          description: 'Calculus, Linear Algebra, and Statistics',
          progress: 0.60,
          instructor: 'Prof. Michael Chen',
          totalLessons: 25,
          completedLessons: 15,
        ),
        Course(
          id: '3',
          title: 'English Literature',
          description: 'Classic and modern literature analysis',
          progress: 0.85,
          instructor: 'Ms. Emily Brown',
          totalLessons: 15,
          completedLessons: 13,
        ),
        Course(
          id: '4',
          title: 'Physics Fundamentals',
          description: 'Mechanics, Thermodynamics, and Electromagnetism',
          progress: 0.40,
          instructor: 'Dr. James Wilson',
          totalLessons: 30,
          completedLessons: 12,
        ),
      ];
      isLoadingCourses.value = false;
    });
  }

  void fetchQuizzes() {
    isLoadingQuizzes.value = true;

    Future.delayed(Duration(seconds: 1), () {
      quizzes.value = [
        Quiz(
          id: '1',
          title: 'AI Basics Quiz',
          subject: 'Artificial Intelligence',
          dueDate: DateTime.now().add(Duration(days: 2)),
          totalQuestions: 20,
          duration: 30,
        ),
        Quiz(
          id: '2',
          title: 'Calculus Mid-term',
          subject: 'Mathematics',
          dueDate: DateTime.now().add(Duration(days: 5)),
          totalQuestions: 30,
          duration: 60,
        ),
        Quiz(
          id: '3',
          title: 'Shakespeare Analysis',
          subject: 'English Literature',
          dueDate: DateTime.now().add(Duration(days: 1)),
          totalQuestions: 15,
          duration: 45,
        ),
      ];
      isLoadingQuizzes.value = false;
    });
  }

  void fetchUpcomingClasses() {
    isLoadingClasses.value = true;

    Future.delayed(Duration(seconds: 1), () {
      upcomingClasses.value = [
        OnlineClass(
          id: '1',
          title: 'AI Neural Networks',
          instructor: 'Dr. Sarah Johnson',
          scheduledTime: DateTime.now().add(Duration(hours: 2)),
          duration: 60,
          meetingLink: 'https://meet.jeduai.com/ai-class-001',
          subject: 'Artificial Intelligence',
        ),
        OnlineClass(
          id: '2',
          title: 'Calculus Problem Solving',
          instructor: 'Prof. Michael Chen',
          scheduledTime: DateTime.now().add(Duration(days: 1, hours: 10)),
          duration: 90,
          meetingLink: 'https://meet.jeduai.com/math-class-002',
          subject: 'Mathematics',
        ),
        OnlineClass(
          id: '3',
          title: 'Poetry Workshop',
          instructor: 'Ms. Emily Brown',
          scheduledTime: DateTime.now().add(Duration(days: 2, hours: 14)),
          duration: 60,
          meetingLink: 'https://meet.jeduai.com/english-class-003',
          subject: 'English Literature',
        ),
      ];
      isLoadingClasses.value = false;
    });
  }

  void enrollInCourse(String courseId) {
    Get.snackbar(
      'Success',
      'Successfully enrolled in course!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void startQuiz(String quizId) {
    Get.snackbar(
      'Quiz Started',
      'Good luck with your quiz!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void joinClass(String classId) {
    final classData = upcomingClasses.firstWhere((c) => c.id == classId);
    Get.snackbar(
      'Joining Class',
      'Opening ${classData.title}...',
      snackPosition: SnackPosition.BOTTOM,
    );
    // In real app, would open meeting link
  }

  void refreshData() {
    fetchDashboardData();
    fetchCourses();
    fetchQuizzes();
    fetchUpcomingClasses();
  }
}
