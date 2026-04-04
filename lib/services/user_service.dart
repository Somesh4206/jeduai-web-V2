import 'package:get/get.dart';

/// User Service - Manages user data across all portals
class UserService extends GetxService {
  // Current logged-in user
  var currentUser = Rxn<User>();

  // Mock users database
  final Map<String, User> users = {
    // Admin User - Kathirvel P
    'mpkathir@gmail.com': User(
      id: 'USR001',
      name: 'Kathirvel P',
      email: 'mpkathir@gmail.com',
      role: UserRole.admin,
      phone: '+91 9876543210',
      department: 'Administration',
      joinDate: DateTime(2024, 1, 1),
      profileImage: null,
    ),

    // Staff User - Kathirvel P (same person, staff role)
    'kathirvel.staff@jeduai.com': User(
      id: 'STF001',
      name: 'Kathirvel P',
      email: 'kathirvel.staff@jeduai.com',
      role: UserRole.staff,
      phone: '+91 9876543210',
      department: 'Computer Science',
      subjects: ['Artificial Intelligence', 'Data Structures', 'Algorithms'],
      joinDate: DateTime(2024, 1, 1),
      profileImage: null,
    ),

    // Student User - Kathirvel P (same person, student role)
    'kathirvel.student@jeduai.com': User(
      id: 'STU001',
      name: 'Kathirvel P',
      email: 'kathirvel.student@jeduai.com',
      role: UserRole.student,
      phone: '+91 9876543210',
      department: 'Computer Science',
      className: 'Class 12',
      rollNumber: 'CS12001',
      joinDate: DateTime(2024, 1, 1),
      profileImage: null,
    ),

    // Additional sample users
    'student2@jeduai.com': User(
      id: 'STU002',
      name: 'Priya Sharma',
      email: 'student2@jeduai.com',
      role: UserRole.student,
      className: 'Class 12',
      rollNumber: 'CS12002',
      joinDate: DateTime(2024, 1, 15),
    ),

    'teacher1@jeduai.com': User(
      id: 'STF002',
      name: 'Dr. Rajesh Kumar',
      email: 'teacher1@jeduai.com',
      role: UserRole.staff,
      department: 'Mathematics',
      subjects: ['Calculus', 'Algebra', 'Statistics'],
      joinDate: DateTime(2023, 8, 1),
    ),
  };

  /// Login user
  User? login(String email, String password, UserRole role) {
    final user = users[email];

    if (user == null) {
      return null;
    }

    if (user.role != role) {
      return null;
    }

    currentUser.value = user;
    return user;
  }

  /// Logout
  void logout() {
    currentUser.value = null;
  }

  /// Get user by ID
  User? getUserById(String userId) {
    try {
      return users.values.firstWhere((u) => u.id == userId);
    } catch (e) {
      return null;
    }
  }

  /// Get user by email
  User? getUserByEmail(String email) {
    return users[email];
  }

  /// Get all users by role
  List<User> getUsersByRole(UserRole role) {
    return users.values.where((u) => u.role == role).toList();
  }

  /// Update user profile
  void updateUser(User user) {
    users[user.email] = user;
    if (currentUser.value?.id == user.id) {
      currentUser.value = user;
    }
  }
}

/// User Model
class User {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? phone;
  final String? department;
  final List<String>? subjects; // For staff
  final String? className; // For students
  final String? rollNumber; // For students
  final DateTime joinDate;
  final String? profileImage;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.department,
    this.subjects,
    this.className,
    this.rollNumber,
    required this.joinDate,
    this.profileImage,
  });

  String get displayRole {
    switch (role) {
      case UserRole.admin:
        return 'Administrator';
      case UserRole.staff:
        return 'Staff/Teacher';
      case UserRole.student:
        return 'Student';
    }
  }

  String get initials {
    final names = name.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  }
}

/// User Role Enum
enum UserRole { admin, staff, student }
