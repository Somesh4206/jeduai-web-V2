import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserData {
  final String id;
  final String name;
  final String email;
  final String role; // student, staff, admin
  final String? department;
  final String? className;
  final String? year;
  final String? college;
  final String? subject;
  final String? phone;
  final String? rollNumber;

  UserData({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.department,
    this.className,
    this.year,
    this.college,
    this.subject,
    this.phone,
    this.rollNumber,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'role': role,
    'department': department,
    'className': className,
    'year': year,
    'college': college,
    'subject': subject,
    'phone': phone,
    'rollNumber': rollNumber,
  };

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    role: json['role'],
    department: json['department'],
    className: json['className'],
    year: json['year'],
    college: json['college'],
    subject: json['subject'],
    phone: json['phone'],
    rollNumber: json['rollNumber'],
  );
}

class UserDataService {
  static final UserDataService _instance = UserDataService._internal();
  factory UserDataService() => _instance;
  UserDataService._internal();

  // Dynamic users map (can be modified at runtime)
  static final Map<String, UserData> _predefinedUsers = {
    // Students
    'kathirvel@gmail.com': UserData(
      id: 'STU001',
      name: 'Kathirvel P',
      email: 'kathirvel@gmail.com',
      role: 'student',
      department: 'Computer Science and Business Systems',
      className: 'III CSBS',
      year: '3rd Year B.Tech',
      college: 'VSB Engineering College',
      rollNumber: 'CSBS2022001',
      phone: '+91 9876543210',
    ),

    // Super Admin Student - Full Access
    'student@jeduai.com': UserData(
      id: 'STU_ADMIN',
      name: 'Admin Student',
      email: 'student@jeduai.com',
      role: 'student',
      department: 'All Departments',
      className: 'ALL',
      year: 'Admin Access',
      college: 'VSB Engineering College',
      rollNumber: 'ADMIN_STU',
      phone: '+91 9999999999',
    ),

    // Staff Members
    'vijayakumar@vsb.edu': UserData(
      id: 'STAFF001',
      name: 'Vijayakumar',
      email: 'vijayakumar@vsb.edu',
      role: 'staff',
      department: 'Computer Science and Business Systems',
      college: 'VSB Engineering College',
      subject: 'Data and Information Science',
      phone: '+91 9876543211',
    ),

    'shyamaladevi@vsb.edu': UserData(
      id: 'STAFF002',
      name: 'Shyamala Devi',
      email: 'shyamaladevi@vsb.edu',
      role: 'staff',
      department: 'Computer Science and Business Systems',
      college: 'VSB Engineering College',
      subject: 'Embedded Systems and IoT',
      phone: '+91 9876543212',
    ),

    'balasubramani@vsb.edu': UserData(
      id: 'STAFF003',
      name: 'Balasubramani',
      email: 'balasubramani@vsb.edu',
      role: 'staff',
      department: 'Computer Science and Business Systems',
      college: 'VSB Engineering College',
      subject: 'Big Data Analytics',
      phone: '+91 9876543213',
    ),

    'arunjunaikarthick@vsb.edu': UserData(
      id: 'STAFF004',
      name: 'Arunjunai Karthick',
      email: 'arunjunaikarthick@vsb.edu',
      role: 'staff',
      department: 'Computer Science and Business Systems',
      college: 'VSB Engineering College',
      subject: 'Cloud Computing',
      phone: '+91 9876543214',
    ),

    'manonmani@vsb.edu': UserData(
      id: 'STAFF005',
      name: 'Manonmani',
      email: 'manonmani@vsb.edu',
      role: 'staff',
      department: 'Computer Science and Business Systems',
      college: 'VSB Engineering College',
      subject: 'Fundamentals of Management',
      phone: '+91 9876543215',
    ),

    // Admin
    'admin@vsb.edu': UserData(
      id: 'ADMIN001',
      name: 'Admin',
      email: 'admin@vsb.edu',
      role: 'admin',
      college: 'VSB Engineering College',
      department: 'Administration',
    ),
  };

  // Get user by email
  UserData? getUserByEmail(String email) {
    return _predefinedUsers[email.toLowerCase()];
  }

  // Validate login
  Future<UserData?> validateLogin(String email, String password) async {
    // For demo purposes, accept any password for predefined users
    // In production, implement proper authentication
    final user = getUserByEmail(email);
    if (user != null) {
      await saveCurrentUser(user);
      return user;
    }
    return null;
  }

  // Save current user to local storage
  Future<void> saveCurrentUser(UserData user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user', jsonEncode(user.toJson()));
    await prefs.setString('user_role', user.role);
    await prefs.setString('user_email', user.email);
    await prefs.setString('user_name', user.name);
  }

  // Get current user from local storage
  Future<UserData?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('current_user');
    if (userJson != null) {
      return UserData.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user');
    await prefs.remove('user_role');
    await prefs.remove('user_email');
    await prefs.remove('user_name');
  }

  // Get all staff members
  List<UserData> getAllStaff() {
    return _predefinedUsers.values
        .where((user) => user.role == 'staff')
        .toList();
  }

  // Get all students
  List<UserData> getAllStudents() {
    return _predefinedUsers.values
        .where((user) => user.role == 'student')
        .toList();
  }

  // Get staff by subject
  UserData? getStaffBySubject(String subject) {
    return _predefinedUsers.values.firstWhere(
      (user) => user.role == 'staff' && user.subject == subject,
      orElse: () => UserData(id: '', name: '', email: '', role: 'staff'),
    );
  }

  // Get class subjects for III CSBS
  List<Map<String, String>> getClassSubjects() {
    return [
      {
        'subject': 'Data and Information Science',
        'staff': 'Vijayakumar',
        'email': 'vijayakumar@vsb.edu',
      },
      {
        'subject': 'Embedded Systems and IoT',
        'staff': 'Shyamala Devi',
        'email': 'shyamaladevi@vsb.edu',
      },
      {
        'subject': 'Big Data Analytics',
        'staff': 'Balasubramani',
        'email': 'balasubramani@vsb.edu',
      },
      {
        'subject': 'Cloud Computing',
        'staff': 'Arunjunai Karthick',
        'email': 'arunjunaikarthick@vsb.edu',
      },
      {
        'subject': 'Fundamentals of Management',
        'staff': 'Manonmani',
        'email': 'manonmani@vsb.edu',
      },
    ];
  }

  // Check if email exists
  bool emailExists(String email) {
    return _predefinedUsers.containsKey(email.toLowerCase());
  }

  // Get user role
  String? getUserRole(String email) {
    return _predefinedUsers[email.toLowerCase()]?.role;
  }

  // Update user profile
  Future<bool> updateUserProfile(UserData updatedUser) async {
    try {
      // Update in predefined users map
      _predefinedUsers[updatedUser.email.toLowerCase()] = updatedUser;

      // Update current user in local storage
      await saveCurrentUser(updatedUser);

      return true;
    } catch (e) {
      print('Error updating profile: $e');
      return false;
    }
  }

  // Update specific fields
  Future<bool> updateUserFields({
    required String email,
    String? name,
    String? phone,
    String? department,
    String? className,
    String? year,
    String? subject,
    String? rollNumber,
  }) async {
    final user = getUserByEmail(email);
    if (user == null) return false;

    final updatedUser = UserData(
      id: user.id,
      name: name ?? user.name,
      email: user.email,
      role: user.role,
      department: department ?? user.department,
      className: className ?? user.className,
      year: year ?? user.year,
      college: user.college,
      subject: subject ?? user.subject,
      phone: phone ?? user.phone,
      rollNumber: rollNumber ?? user.rollNumber,
    );

    return await updateUserProfile(updatedUser);
  }

  // Add new student
  Future<bool> addStudent({
    required String name,
    required String email,
    required String department,
    required String className,
    required String year,
    String? phone,
    String? rollNumber,
  }) async {
    try {
      // Check if email already exists
      if (emailExists(email)) {
        return false;
      }

      // Generate unique ID
      final id = 'STU${DateTime.now().millisecondsSinceEpoch % 10000}';

      // Create new student
      final newStudent = UserData(
        id: id,
        name: name,
        email: email.toLowerCase(),
        role: 'student',
        department: department,
        className: className,
        year: year,
        college: 'VSB Engineering College',
        phone: phone,
        rollNumber: rollNumber ?? 'ROLL$id',
      );

      // Add to map
      _predefinedUsers[email.toLowerCase()] = newStudent;

      // Save to storage
      await _saveUsersToStorage();

      return true;
    } catch (e) {
      print('Error adding student: $e');
      return false;
    }
  }

  // Add new staff
  Future<bool> addStaff({
    required String name,
    required String email,
    required String department,
    required String subject,
    String? phone,
  }) async {
    try {
      // Check if email already exists
      if (emailExists(email)) {
        return false;
      }

      // Generate unique ID
      final id = 'STAFF${DateTime.now().millisecondsSinceEpoch % 10000}';

      // Create new staff
      final newStaff = UserData(
        id: id,
        name: name,
        email: email.toLowerCase(),
        role: 'staff',
        department: department,
        college: 'VSB Engineering College',
        subject: subject,
        phone: phone,
      );

      // Add to map
      _predefinedUsers[email.toLowerCase()] = newStaff;

      // Save to storage
      await _saveUsersToStorage();

      return true;
    } catch (e) {
      print('Error adding staff: $e');
      return false;
    }
  }

  // Delete user
  Future<bool> deleteUser(String email) async {
    try {
      _predefinedUsers.remove(email.toLowerCase());
      await _saveUsersToStorage();
      return true;
    } catch (e) {
      print('Error deleting user: $e');
      return false;
    }
  }

  // Save users to storage
  Future<void> _saveUsersToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = _predefinedUsers.values
          .map((user) => user.toJson())
          .toList();
      await prefs.setString('app_users', jsonEncode(usersJson));
      print('💾 Saved ${_predefinedUsers.length} users to storage');
    } catch (e) {
      print('Error saving users: $e');
    }
  }

  // Load users from storage
  Future<void> loadUsersFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersString = prefs.getString('app_users');
      if (usersString != null && usersString.isNotEmpty) {
        final List<dynamic> usersJson = jsonDecode(usersString);
        for (var json in usersJson) {
          final user = UserData.fromJson(json);
          _predefinedUsers[user.email.toLowerCase()] = user;
        }
        print('📂 Loaded ${_predefinedUsers.length} users from storage');
      }
    } catch (e) {
      print('Error loading users: $e');
    }
  }
}
