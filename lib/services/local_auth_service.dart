import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Local Authentication Service - Works without Firebase
/// Stores user data locally for immediate app functionality
class LocalAuthService {
  static const String _usersKey = 'local_users';
  static const String _currentUserKey = 'current_user';

  /// Sign up a new user locally
  Future<Map<String, dynamic>?> signupUser({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      // SECURITY: Prevent admin signup via API
      if (role.toLowerCase() == 'admin') {
        return {'error': 'Admin accounts cannot be created through signup. Contact system administrator.'};
      }
      
      final prefs = await SharedPreferences.getInstance();
      
      // Get existing users
      final usersJson = prefs.getString(_usersKey) ?? '[]';
      final List<dynamic> users = jsonDecode(usersJson);
      
      // Check if email already exists
      final existingUser = users.firstWhere(
        (user) => user['email'] == email,
        orElse: () => null,
      );
      
      if (existingUser != null) {
        return {'error': 'Email already in use'};
      }
      
      // Create new user
      final Map<String, dynamic> newUser = {
        'uid': DateTime.now().millisecondsSinceEpoch.toString(),
        'name': name,
        'email': email,
        'password': password, // In production, this should be hashed
        'role': role,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };
      
      // Add role-specific data
      if (role == 'student') {
        newUser['enrolledCourses'] = [];
        newUser['completedAssessments'] = [];
        newUser['totalScore'] = 0;
        newUser['averageScore'] = 0.0;
        newUser['department'] = '';
        newUser['year'] = '';
        newUser['section'] = '';
      } else if (role == 'staff') {
        newUser['department'] = '';
        newUser['designation'] = '';
        newUser['subjects'] = [];
        newUser['classesAssigned'] = [];
        newUser['totalStudents'] = 0;
      } else if (role == 'admin') {
        newUser['permissions'] = ['all'];
        newUser['managedDepartments'] = [];
        newUser['lastLogin'] = DateTime.now().toIso8601String();
      }
      
      // Add user to list
      users.add(newUser);
      
      // Save to SharedPreferences
      await prefs.setString(_usersKey, jsonEncode(users));
      
      print('✅ User created locally: ${newUser['email']}');
      return newUser;
    } catch (e) {
      print('❌ Local signup error: $e');
      return {'error': e.toString()};
    }
  }

  /// Login user locally
  Future<Map<String, dynamic>?> loginUser({
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get existing users
      final usersJson = prefs.getString(_usersKey) ?? '[]';
      final List<dynamic> users = jsonDecode(usersJson);
      
      // Find user
      final user = users.firstWhere(
        (user) => user['email'] == email && user['password'] == password,
        orElse: () => null,
      );
      
      if (user == null) {
        return {'error': 'Invalid email or password'};
      }
      
      // Check role
      if (user['role'] != role) {
        return {'error': 'Invalid role selected'};
      }
      
      // Save current user
      await prefs.setString(_currentUserKey, jsonEncode(user));
      
      // Update last login for admins
      if (role == 'admin') {
        user['lastLogin'] = DateTime.now().toIso8601String();
        final userIndex = users.indexWhere((u) => u['email'] == email);
        users[userIndex] = user;
        await prefs.setString(_usersKey, jsonEncode(users));
      }
      
      print('✅ User logged in locally: ${user['email']}');
      return user;
    } catch (e) {
      print('❌ Local login error: $e');
      return {'error': e.toString()};
    }
  }

  /// Get current logged in user
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_currentUserKey);
      
      if (userJson == null) return null;
      
      return jsonDecode(userJson);
    } catch (e) {
      print('❌ Get current user error: $e');
      return null;
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_currentUserKey);
      print('✅ User logged out locally');
    } catch (e) {
      print('❌ Local logout error: $e');
    }
  }

  /// Get all users (for debugging)
  Future<List<dynamic>> getAllUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_usersKey) ?? '[]';
      return jsonDecode(usersJson);
    } catch (e) {
      print('❌ Get all users error: $e');
      return [];
    }
  }
}
