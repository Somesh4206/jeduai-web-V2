import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

/// User Session Service - Manages current logged-in user and their data
class UserSessionService extends GetxService {
  static UserSessionService get instance => Get.find();

  // Observable current user
  final Rx<Map<String, dynamic>?> currentUser = Rx<Map<String, dynamic>?>(null);

  // User analytics
  final RxInt assessmentsCompleted = 0.obs;
  final RxInt videosWatched = 0.obs;
  final RxInt translationsUsed = 0.obs;
  final RxDouble averageScore = 0.0.obs;
  final RxInt totalScore = 0.obs;
  final RxInt loginCount = 0.obs;
  final RxString lastLoginDate = ''.obs;

  static const String _currentUserKey = 'current_user';
  static const String _userAnalyticsPrefix = 'user_analytics_';

  @override
  void onInit() {
    super.onInit();
    loadCurrentUser();
  }

  /// Load current logged-in user from storage
  Future<void> loadCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_currentUserKey);

      if (userJson != null) {
        currentUser.value = jsonDecode(userJson);
        await loadUserAnalytics();
        print('✅ User session loaded: ${currentUser.value?['email']}');
      }
    } catch (e) {
      print('❌ Error loading user session: $e');
    }
  }

  /// Set current user after login
  Future<void> setCurrentUser(Map<String, dynamic> user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Convert Firestore Timestamps to ISO strings before storing
      final Map<String, dynamic> userToStore = {};
      
      user.forEach((key, value) {
        if (value is Timestamp) {
          // Convert Firestore Timestamp to ISO string
          userToStore[key] = value.toDate().toIso8601String();
        } else {
          userToStore[key] = value;
        }
      });
      
      currentUser.value = userToStore;
      await prefs.setString(_currentUserKey, jsonEncode(userToStore));

      // Update login count and date
      await incrementLoginCount();
      await updateLastLoginDate();

      // Load user analytics
      await loadUserAnalytics();

      print('✅ User session set: ${userToStore['email']}');
    } catch (e) {
      print('❌ Error setting user session: $e');
    }
  }

  /// Clear current user on logout
  Future<void> clearCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_currentUserKey);
      currentUser.value = null;

      // Reset analytics
      assessmentsCompleted.value = 0;
      videosWatched.value = 0;
      translationsUsed.value = 0;
      averageScore.value = 0.0;
      totalScore.value = 0;
      loginCount.value = 0;
      lastLoginDate.value = '';

      print('✅ User session cleared');
    } catch (e) {
      print('❌ Error clearing user session: $e');
    }
  }

  /// Load user analytics from storage
  Future<void> loadUserAnalytics() async {
    if (currentUser.value == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = currentUser.value!['uid'];
      final analyticsKey = '$_userAnalyticsPrefix$userId';
      final analyticsJson = prefs.getString(analyticsKey);

      if (analyticsJson != null) {
        final analytics = jsonDecode(analyticsJson);
        assessmentsCompleted.value = analytics['assessmentsCompleted'] ?? 0;
        videosWatched.value = analytics['videosWatched'] ?? 0;
        translationsUsed.value = analytics['translationsUsed'] ?? 0;
        averageScore.value = (analytics['averageScore'] ?? 0.0).toDouble();
        totalScore.value = analytics['totalScore'] ?? 0;
        loginCount.value = analytics['loginCount'] ?? 0;
        lastLoginDate.value = analytics['lastLoginDate'] ?? '';
      }
    } catch (e) {
      print('❌ Error loading user analytics: $e');
    }
  }

  /// Save user analytics to storage
  Future<void> saveUserAnalytics() async {
    if (currentUser.value == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = currentUser.value!['uid'];
      final analyticsKey = '$_userAnalyticsPrefix$userId';

      final analytics = {
        'assessmentsCompleted': assessmentsCompleted.value,
        'videosWatched': videosWatched.value,
        'translationsUsed': translationsUsed.value,
        'averageScore': averageScore.value,
        'totalScore': totalScore.value,
        'loginCount': loginCount.value,
        'lastLoginDate': lastLoginDate.value,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      await prefs.setString(analyticsKey, jsonEncode(analytics));
      print('✅ User analytics saved');
    } catch (e) {
      print('❌ Error saving user analytics: $e');
    }
  }

  /// Track assessment completion
  Future<void> trackAssessmentCompleted(int score) async {
    assessmentsCompleted.value++;
    totalScore.value += score;

    // Calculate average score
    if (assessmentsCompleted.value > 0) {
      averageScore.value = totalScore.value / assessmentsCompleted.value;
    }

    await saveUserAnalytics();
    print('✅ Assessment tracked: Score $score');
  }

  /// Track video watched
  Future<void> trackVideoWatched() async {
    videosWatched.value++;
    await saveUserAnalytics();
    print('✅ Video watched tracked');
  }

  /// Track translation used
  Future<void> trackTranslationUsed() async {
    translationsUsed.value++;
    await saveUserAnalytics();
    print('✅ Translation tracked');
  }

  /// Increment login count
  Future<void> incrementLoginCount() async {
    loginCount.value++;
    await saveUserAnalytics();
  }

  /// Update last login date
  Future<void> updateLastLoginDate() async {
    lastLoginDate.value = DateTime.now().toIso8601String();
    await saveUserAnalytics();
  }

  /// Get user display name
  String get userName => currentUser.value?['name'] ?? 'User';

  /// Get user email
  String get userEmail => currentUser.value?['email'] ?? '';

  /// Get user role
  String get userRole => currentUser.value?['role'] ?? '';

  /// Check if user is logged in
  bool get isLoggedIn => currentUser.value != null;

  /// Get user ID
  String get userId => currentUser.value?['uid'] ?? '';

  /// Get user profile data
  /// Get user profile data
  Map<String, dynamic> get userProfile {
    if (currentUser.value == null) return {};

    return {
      'name': userName,
      'email': userEmail,
      'role': userRole,
      'uid': userId,
      'createdAt': _convertTimestampToString(currentUser.value?['createdAt']),
      'department': currentUser.value?['department'] ?? '',
      'year': currentUser.value?['year'] ?? '',
      'section': currentUser.value?['section'] ?? '',
      'designation': currentUser.value?['designation'] ?? '',
      'subjects': currentUser.value?['subjects'] ?? [],
      'permissions': currentUser.value?['permissions'] ?? [],
    };
  }

  /// Helper to convert Timestamp to String
  String _convertTimestampToString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is Timestamp) return value.toDate().toIso8601String();
    return '';
  }

  /// Get user statistics
  Map<String, dynamic> get userStatistics {
    return {
      'assessmentsCompleted': assessmentsCompleted.value,
      'videosWatched': videosWatched.value,
      'translationsUsed': translationsUsed.value,
      'averageScore': averageScore.value,
      'totalScore': totalScore.value,
      'loginCount': loginCount.value,
      'lastLoginDate': lastLoginDate.value,
    };
  }

  /// Update user profile
  Future<void> updateUserProfile(Map<String, dynamic> updates) async {
    if (currentUser.value == null) return;

    try {
      final updatedUser = Map<String, dynamic>.from(currentUser.value!);
      updatedUser.addAll(updates);
      updatedUser['updatedAt'] = DateTime.now().toIso8601String();

      await setCurrentUser(updatedUser);

      // Also update in local auth storage
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString('local_users') ?? '[]';
      final List<dynamic> users = jsonDecode(usersJson);

      final userIndex = users.indexWhere((u) => u['uid'] == userId);
      if (userIndex != -1) {
        users[userIndex] = updatedUser;
        await prefs.setString('local_users', jsonEncode(users));
      }

      print('✅ User profile updated');
    } catch (e) {
      print('❌ Error updating user profile: $e');
    }
  }
}
