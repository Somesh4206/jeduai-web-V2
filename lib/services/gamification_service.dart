import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

/// Gamification Service - Adds game-like elements to learning
class GamificationService extends GetxService {
  final SupabaseClient _client = SupabaseConfig.client;

  // Observable points and badges
  final userPoints = 0.obs;
  final userLevel = 1.obs;
  final userBadges = <Map<String, dynamic>>[].obs;
  final leaderboard = <Map<String, dynamic>>[].obs;

  /// Award points for various activities
  Future<void> awardPoints(String userId, int points, String reason) async {
    try {
      // Update user points
      final currentPoints = await getUserPoints(userId);
      final newPoints = currentPoints + points;

      await _client.from('user_gamification').upsert({
        'user_id': userId,
        'points': newPoints,
        'level': _calculateLevel(newPoints),
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Log the activity
      await _client.from('gamification_logs').insert({
        'user_id': userId,
        'points': points,
        'reason': reason,
        'created_at': DateTime.now().toIso8601String(),
      });

      // Check for new badges
      await _checkAndAwardBadges(userId, newPoints);

      userPoints.value = newPoints;
      userLevel.value = _calculateLevel(newPoints);

      Get.snackbar(
        '🎉 Points Earned!',
        '+$points points for $reason',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print('❌ Error awarding points: $e');
    }
  }

  /// Calculate level based on points
  int _calculateLevel(int points) {
    // Level up every 100 points
    return (points / 100).floor() + 1;
  }

  /// Get user points
  Future<int> getUserPoints(String userId) async {
    try {
      final response = await _client
          .from('user_gamification')
          .select('points')
          .eq('user_id', userId)
          .maybeSingle();

      return response?['points'] ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Check and award badges
  Future<void> _checkAndAwardBadges(String userId, int points) async {
    final badges = [
      {'name': 'First Steps', 'points': 10, 'icon': '🎯'},
      {'name': 'Getting Started', 'points': 50, 'icon': '🌟'},
      {'name': 'Dedicated Learner', 'points': 100, 'icon': '📚'},
      {'name': 'Knowledge Seeker', 'points': 250, 'icon': '🔍'},
      {'name': 'Master Student', 'points': 500, 'icon': '🏆'},
      {'name': 'Legend', 'points': 1000, 'icon': '👑'},
    ];

    for (var badge in badges) {
      final badgePoints = badge['points'];
      if (badgePoints is num && points >= badgePoints) {
        await _awardBadge(userId, badge);
      }
    }
  }

  /// Award badge to user
  Future<void> _awardBadge(String userId, Map<String, dynamic> badge) async {
    try {
      // Check if already has badge
      final existing = await _client
          .from('user_badges')
          .select()
          .eq('user_id', userId)
          .eq('badge_name', badge['name'])
          .maybeSingle();

      if (existing == null) {
        await _client.from('user_badges').insert({
          'user_id': userId,
          'badge_name': badge['name'],
          'badge_icon': badge['icon'],
          'earned_at': DateTime.now().toIso8601String(),
        });

        Get.snackbar(
          '🏅 New Badge Unlocked!',
          '${badge['icon']} ${badge['name']}',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      print('❌ Error awarding badge: $e');
    }
  }

  /// Get user badges
  Future<List<Map<String, dynamic>>> getUserBadges(String userId) async {
    try {
      final response = await _client
          .from('user_badges')
          .select()
          .eq('user_id', userId)
          .order('earned_at', ascending: false);

      return response;
    } catch (e) {
      return [];
    }
  }

  /// Get leaderboard
  Future<List<Map<String, dynamic>>> getLeaderboard({int limit = 10}) async {
    try {
      final response = await _client
          .from('user_gamification')
          .select('*, users(name, email)')
          .order('points', ascending: false)
          .limit(limit);

      return response;
    } catch (e) {
      return [];
    }
  }

  /// Award points for specific activities
  Future<void> onClassAttended(String userId) async {
    await awardPoints(userId, 10, 'Attending class');
  }

  Future<void> onAssessmentCompleted(String userId, int score) async {
    final points = (score / 10).round(); // 1 point per 10% score
    await awardPoints(userId, points, 'Completing assessment');
  }

  Future<void> onPerfectScore(String userId) async {
    await awardPoints(userId, 50, 'Perfect score! 💯');
  }

  Future<void> onStreakMaintained(String userId, int days) async {
    await awardPoints(userId, days * 5, '$days-day streak! 🔥');
  }

  Future<void> onHelpingOther(String userId) async {
    await awardPoints(userId, 15, 'Helping classmate');
  }

  Future<void> onTranslationUsed(String userId) async {
    await awardPoints(userId, 2, 'Using translation');
  }
}
