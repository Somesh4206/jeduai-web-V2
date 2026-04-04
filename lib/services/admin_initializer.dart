import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Admin Initializer - Creates default admin account on first run
class AdminInitializer {
  static const String _usersKey = 'local_users';
  static const String _adminInitializedKey = 'admin_initialized';

  /// Initialize default admin account if not exists
  static Future<void> initializeDefaultAdmin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Check if admin already initialized
      final isInitialized = prefs.getBool(_adminInitializedKey) ?? false;
      if (isInitialized) {
        print('✅ Admin already initialized');
        return;
      }

      // Get existing users
      final usersJson = prefs.getString(_usersKey) ?? '[]';
      final List<dynamic> users = jsonDecode(usersJson);

      // Check if admin already exists
      final adminExists = users.any((user) => 
        user['role'] == 'admin' && user['email'] == 'admin@vsb.edu'
      );

      if (adminExists) {
        print('✅ Default admin already exists');
        await prefs.setBool(_adminInitializedKey, true);
        return;
      }

      // Create default admin account
      final Map<String, dynamic> defaultAdmin = {
        'uid': 'admin_${DateTime.now().millisecondsSinceEpoch}',
        'name': 'System Administrator',
        'email': 'admin@vsb.edu',
        'password': 'admin123', // Change this in production!
        'role': 'admin',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'permissions': ['all'],
        'managedDepartments': ['All Departments'],
        'lastLogin': DateTime.now().toIso8601String(),
      };

      // Add admin to users list
      users.add(defaultAdmin);

      // Save to SharedPreferences
      await prefs.setString(_usersKey, jsonEncode(users));
      await prefs.setBool(_adminInitializedKey, true);

      print('✅ Default admin account created successfully');
      print('📧 Email: admin@vsb.edu');
      print('🔑 Password: admin123');
      print('⚠️  Please change the password after first login!');
    } catch (e) {
      print('❌ Error initializing admin: $e');
    }
  }

  /// Create additional admin account (only callable by existing admin)
  static Future<Map<String, dynamic>?> createAdminAccount({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
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
      
      // Create new admin
      final Map<String, dynamic> newAdmin = {
        'uid': 'admin_${DateTime.now().millisecondsSinceEpoch}',
        'name': name,
        'email': email,
        'password': password,
        'role': 'admin',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'permissions': ['all'],
        'managedDepartments': [],
        'lastLogin': DateTime.now().toIso8601String(),
      };
      
      // Add admin to list
      users.add(newAdmin);
      
      // Save to SharedPreferences
      await prefs.setString(_usersKey, jsonEncode(users));
      
      print('✅ New admin account created: $email');
      return newAdmin;
    } catch (e) {
      print('❌ Error creating admin account: $e');
      return {'error': e.toString()};
    }
  }

  /// Reset admin password (emergency use only)
  static Future<bool> resetAdminPassword({
    required String email,
    required String newPassword,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get existing users
      final usersJson = prefs.getString(_usersKey) ?? '[]';
      final List<dynamic> users = jsonDecode(usersJson);
      
      // Find admin
      final adminIndex = users.indexWhere(
        (user) => user['email'] == email && user['role'] == 'admin',
      );
      
      if (adminIndex == -1) {
        print('❌ Admin not found: $email');
        return false;
      }
      
      // Update password
      users[adminIndex]['password'] = newPassword;
      users[adminIndex]['updatedAt'] = DateTime.now().toIso8601String();
      
      // Save to SharedPreferences
      await prefs.setString(_usersKey, jsonEncode(users));
      
      print('✅ Admin password reset successfully: $email');
      return true;
    } catch (e) {
      print('❌ Error resetting admin password: $e');
      return false;
    }
  }
}
