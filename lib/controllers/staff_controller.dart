import 'package:get/get.dart';

class Student {
  final String id;
  final String name;
  final String email;
  final String grade;
  final double attendance;
  final double averageScore;
  final String status; // Active, Inactive, At Risk
  final List<String> courses;
  final String profileImage;

  Student({
    required this.id,
    required this.name,
    required this.email,
    required this.grade,
    required this.attendance,
    required this.averageScore,
    required this.status,
    required this.courses,
    required this.profileImage,
  });
}

class Assessment {
  final String id;
  final String title;
  final String subject;
  final String type;
  final int totalQuestions;
  final int duration;
  final DateTime createdDate;
  final int studentsAssigned;
  final int studentsCompleted;
  final String difficulty;

  Assessment({
    required this.id,
    required this.title,
    required this.subject,
    required this.type,
    required this.totalQuestions,
    required this.duration,
    required this.createdDate,
    required this.studentsAssigned,
    required this.studentsCompleted,
    required this.difficulty,
  });
}

class StaffController extends GetxController {
  // Dashboard stats
  var totalStudents = 0.obs;
  var activeStudents = 0.obs;
  var totalAssessments = 0.obs;
  var upcomingClasses = 0.obs;
  var averageAttendance = 0.0.obs;
  var averagePerformance = 0.0.obs;

  // Data lists
  var students = <Student>[].obs;
  var assessments = <Assessment>[].obs;
  var recentActivities = <String>[].obs;

  // Loading states
  var isLoadingStudents = false.obs;
  var isLoadingAssessments = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
    fetchStudents();
    fetchAssessments();
  }

  void fetchDashboardData() {
    totalStudents.value = 156;
    activeStudents.value = 142;
    totalAssessments.value = 24;
    upcomingClasses.value = 8;
    averageAttendance.value = 87.5;
    averagePerformance.value = 78.3;

    recentActivities.value = [
      'New assessment created: Mathematics Quiz',
      'Student John Doe submitted assignment',
      'Class scheduled for tomorrow at 10 AM',
      '5 students completed Physics test',
      'New student enrolled: Jane Smith',
    ];
  }

  void fetchStudents() {
    isLoadingStudents.value = true;

    Future.delayed(Duration(seconds: 1), () {
      students.value = [
        Student(
          id: '1',
          name: 'Rahul Kumar',
          email: 'rahul@student.com',
          grade: 'A',
          attendance: 95.0,
          averageScore: 88.5,
          status: 'Active',
          courses: ['Mathematics', 'Physics', 'Chemistry'],
          profileImage: '',
        ),
        Student(
          id: '2',
          name: 'Priya Sharma',
          email: 'priya@student.com',
          grade: 'A+',
          attendance: 98.0,
          averageScore: 92.0,
          status: 'Active',
          courses: ['Mathematics', 'English', 'Biology'],
          profileImage: '',
        ),
        Student(
          id: '3',
          name: 'Amit Patel',
          email: 'amit@student.com',
          grade: 'B',
          attendance: 75.0,
          averageScore: 72.5,
          status: 'At Risk',
          courses: ['Physics', 'Chemistry'],
          profileImage: '',
        ),
        Student(
          id: '4',
          name: 'Sneha Reddy',
          email: 'sneha@student.com',
          grade: 'A',
          attendance: 90.0,
          averageScore: 85.0,
          status: 'Active',
          courses: ['English', 'History', 'Geography'],
          profileImage: '',
        ),
        Student(
          id: '5',
          name: 'Vikram Singh',
          email: 'vikram@student.com',
          grade: 'B+',
          attendance: 82.0,
          averageScore: 78.0,
          status: 'Active',
          courses: ['Mathematics', 'Computer Science'],
          profileImage: '',
        ),
      ];
      isLoadingStudents.value = false;
    });
  }

  void fetchAssessments() {
    isLoadingAssessments.value = true;

    Future.delayed(Duration(seconds: 1), () {
      assessments.value = [
        Assessment(
          id: '1',
          title: 'Mathematics Mid-term',
          subject: 'Mathematics',
          type: 'Test',
          totalQuestions: 30,
          duration: 60,
          createdDate: DateTime.now().subtract(Duration(days: 5)),
          studentsAssigned: 45,
          studentsCompleted: 38,
          difficulty: 'Medium',
        ),
        Assessment(
          id: '2',
          title: 'Physics Quiz',
          subject: 'Physics',
          type: 'Quiz',
          totalQuestions: 20,
          duration: 30,
          createdDate: DateTime.now().subtract(Duration(days: 2)),
          studentsAssigned: 40,
          studentsCompleted: 35,
          difficulty: 'Easy',
        ),
        Assessment(
          id: '3',
          title: 'Chemistry Final',
          subject: 'Chemistry',
          type: 'Exam',
          totalQuestions: 50,
          duration: 120,
          createdDate: DateTime.now().subtract(Duration(days: 10)),
          studentsAssigned: 50,
          studentsCompleted: 48,
          difficulty: 'Hard',
        ),
      ];
      isLoadingAssessments.value = false;
    });
  }

  void createAssessment(Map<String, dynamic> data) {
    Get.snackbar(
      'Success',
      'Assessment "${data['title']}" created successfully!',
      snackPosition: SnackPosition.BOTTOM,
    );
    fetchAssessments();
  }

  void updateStudent(String studentId, Map<String, dynamic> data) {
    Get.snackbar(
      'Success',
      'Student information updated successfully!',
      snackPosition: SnackPosition.BOTTOM,
    );
    fetchStudents();
  }

  void deleteAssessment(String assessmentId) {
    assessments.removeWhere((a) => a.id == assessmentId);
    Get.snackbar(
      'Deleted',
      'Assessment deleted successfully',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void refreshData() {
    fetchDashboardData();
    fetchStudents();
    fetchAssessments();
  }
}
