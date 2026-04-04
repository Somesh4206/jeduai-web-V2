import 'package:get/get.dart';

class AdminController extends GetxController {
  // Dashboard Statistics
  var totalStudents = 0.obs;
  var totalStaff = 0.obs;
  var totalCourses = 0.obs;
  var totalClasses = 0.obs;
  var totalAssessments = 0.obs;
  var activeUsers = 0.obs;
  var aiToolEngagement = 0.0.obs;
  var systemHealth = 0.0.obs;

  // Data Lists
  var students = <Map<String, dynamic>>[].obs;
  var staff = <Map<String, dynamic>>[].obs;
  var staffList = <Map<String, dynamic>>[].obs;
  var courses = <Map<String, dynamic>>[].obs;
  var coursesList = <Map<String, dynamic>>[].obs;
  var aiUsageLogs = <Map<String, dynamic>>[].obs;
  var performanceReports = <Map<String, dynamic>>[].obs;
  var classPerformance = <Map<String, dynamic>>[].obs;

  // Loading States
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
    fetchAllData();
  }

  void fetchDashboardData() {
    totalStudents.value = 1250;
    totalStaff.value = 85;
    totalCourses.value = 45;
    totalClasses.value = 120;
    totalAssessments.value = 340;
    activeUsers.value = 1180;
    aiToolEngagement.value = 78.5;
    systemHealth.value = 95.2;
  }

  void fetchAllData() {
    isLoading.value = true;

    // Mock Students Data
    students.value = List.generate(
      10,
      (i) => {
        'id': 'STU${1000 + i}',
        'name': 'Student ${i + 1}',
        'email': 'student${i + 1}@jeduai.com',
        'class': 'Class ${10 + (i % 3)}',
        'status': i % 3 == 0 ? 'Active' : 'Active',
        'joinDate': '2024-01-${(i + 1).toString().padLeft(2, '0')}',
      },
    );

    // Mock Staff Data
    staff.value = List.generate(
      8,
      (i) => {
        'id': 'STF${2000 + i}',
        'name': 'Teacher ${i + 1}',
        'email': 'teacher${i + 1}@jeduai.com',
        'subject': ['Mathematics', 'Physics', 'Chemistry', 'English'][i % 4],
        'classes': 'Class ${10 + (i % 3)}, Class ${11 + (i % 3)}',
        'status': 'Active',
        'joinDate': '2023-0${(i % 9) + 1}-15',
      },
    );
    staffList.assignAll(staff);

    // Mock Courses Data
    courses.value = List.generate(
      6,
      (i) => {
        'id': 'CRS${3000 + i}',
        'name': [
          'Mathematics',
          'Physics',
          'Chemistry',
          'English',
          'Biology',
          'Computer Science',
        ][i],
        'instructor': 'Teacher ${i + 1}',
        'enrolled': 150 + (i * 20),
        'duration': '${12 + i} weeks',
        'staff': 'Teacher ${i + 1}',
        'students': 150 + (i * 20),
        'status': 'Active',
      },
    );
    coursesList.assignAll(courses);

    // Mock Class Performance Data
    classPerformance.value = List.generate(
      5,
      (i) => {
        'class': '${10 + i}',
        'students': 120 - (i * 10),
        'avgScore': 85.0 - (i * 5),
      },
    );

    // Mock AI Usage Logs
    aiUsageLogs.value = List.generate(
      5,
      (i) => {
        'tool': [
          'AI Tutor',
          'Translation',
          'Assessment Gen',
          'Smart Learning',
          'Analytics',
        ][i],
        'usage': (500 - i * 50),
        'date': '2024-11-${15 - i}',
        'trend': i % 2 == 0 ? 'up' : 'down',
      },
    );

    isLoading.value = false;
  }

  void addStudent(Map<String, dynamic> data) {
    students.add(data);
    totalStudents.value++;
    Get.snackbar('Success', 'Student added successfully');
  }

  void updateStudent(String id, Map<String, dynamic> data) {
    final index = students.indexWhere((s) => s['id'] == id);
    if (index != -1) {
      students[index] = data;
      Get.snackbar('Success', 'Student updated successfully');
    }
  }

  void deleteStudent(String id) {
    students.removeWhere((s) => s['id'] == id);
    totalStudents.value--;
    Get.snackbar('Deleted', 'Student removed successfully');
  }

  void addStaff(Map<String, dynamic> data) {
    staff.add(data);
    staffList.add(data);
    totalStaff.value++;
    Get.snackbar('Success', 'Staff member added successfully');
  }

  void updateStaff(String id, Map<String, dynamic> data) {
    final index = staff.indexWhere((s) => s['id'] == id);
    if (index != -1) {
      staff[index] = data;
      staffList[index] = data;
      Get.snackbar('Success', 'Staff updated successfully');
    }
  }

  void deleteStaff(String id) {
    staff.removeWhere((s) => s['id'] == id);
    staffList.removeWhere((s) => s['id'] == id);
    totalStaff.value--;
    Get.snackbar('Deleted', 'Staff member removed successfully');
  }

  void addCourse(Map<String, dynamic> data) {
    courses.add(data);
    coursesList.add(data);
    totalCourses.value++;
    Get.snackbar('Success', 'Course added successfully');
  }

  void updateCourse(String id, Map<String, dynamic> data) {
    final index = courses.indexWhere((c) => c['id'] == id);
    if (index != -1) {
      courses[index] = data;
      coursesList[index] = data;
      Get.snackbar('Success', 'Course updated successfully');
    }
  }

  void deleteCourse(String id) {
    courses.removeWhere((c) => c['id'] == id);
    coursesList.removeWhere((c) => c['id'] == id);
    totalCourses.value--;
    Get.snackbar('Deleted', 'Course removed successfully');
  }

  void refreshData() {
    fetchDashboardData();
    fetchAllData();
  }
}
