import 'dart:async';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

/// Real-time Collaboration Service
/// Enables real-time features like live chat, whiteboard, polls, etc.
class RealtimeCollaborationService extends GetxService {
  final SupabaseClient _client = SupabaseConfig.client;
  final _activeUsers = <String, Map<String, dynamic>>{}.obs;
  final _chatMessages = <Map<String, dynamic>>[].obs;
  final _whiteboardStrokes = <Map<String, dynamic>>[].obs;
  final _polls = <Map<String, dynamic>>[].obs;

  RealtimeChannel? _classChannel;
  String? _currentMeetingId;

  /// Get observable lists
  List<Map<String, dynamic>> get activeUsers => _activeUsers.values.toList();
  List<Map<String, dynamic>> get chatMessages => _chatMessages;
  List<Map<String, dynamic>> get whiteboardStrokes => _whiteboardStrokes;
  List<Map<String, dynamic>> get polls => _polls;

  /// Join a class meeting room
  Future<void> joinMeeting(
    String meetingId,
    String userId,
    String userName,
    String role,
  ) async {
    try {
      _currentMeetingId = meetingId;

      // Subscribe to real-time channel
      _classChannel = _client.channel('class:$meetingId');

      // Listen for presence changes
      // Note: Presence tracking simplified for compatibility
      // In production, implement proper presence tracking based on Supabase version

      // Listen for chat messages
      _classChannel!.onBroadcast(
        event: 'chat',
        callback: (payload) {
          _chatMessages.add(payload);
        },
      );

      // Listen for whiteboard strokes
      _classChannel!.onBroadcast(
        event: 'whiteboard',
        callback: (payload) {
          _whiteboardStrokes.add(payload);
        },
      );

      // Listen for polls
      _classChannel!.onBroadcast(
        event: 'poll',
        callback: (payload) {
          _polls.add(payload);
        },
      );

      // Listen for hand raises
      _classChannel!.onBroadcast(
        event: 'hand_raise',
        callback: (payload) {
          Get.snackbar(
            'Hand Raised',
            '${payload['user_name']} raised their hand',
            snackPosition: SnackPosition.TOP,
          );
        },
      );

      // Subscribe to channel
      _classChannel!.subscribe((status, error) {
        if (status == RealtimeSubscribeStatus.subscribed) {
          // Track presence
          _classChannel!.track({
            'user_id': userId,
            'user_name': userName,
            'role': role,
            'joined_at': DateTime.now().toIso8601String(),
          });

          print('✅ Joined meeting: $meetingId');
        }
      });

      // Save to database
      await _client.from(DatabaseTables.meetingParticipants).insert({
        'id': '${userId}_$meetingId',
        'meeting_id': meetingId,
        'user_id': userId,
        'user_name': userName,
        'role': role,
        'joined_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('❌ Error joining meeting: $e');
    }
  }

  /// Leave meeting
  Future<void> leaveMeeting(String userId) async {
    try {
      if (_classChannel != null) {
        await _classChannel!.untrack();
        await _classChannel!.unsubscribe();
        _classChannel = null;
      }

      // Update database
      if (_currentMeetingId != null) {
        await _client
            .from(DatabaseTables.meetingParticipants)
            .update({'left_at': DateTime.now().toIso8601String()})
            .eq('meeting_id', _currentMeetingId!)
            .eq('user_id', userId);
      }

      _activeUsers.clear();
      _chatMessages.clear();
      _whiteboardStrokes.clear();
      _polls.clear();
      _currentMeetingId = null;

      print('✅ Left meeting');
    } catch (e) {
      print('❌ Error leaving meeting: $e');
    }
  }

  /// Send chat message
  Future<void> sendChatMessage(
    String userId,
    String userName,
    String message,
  ) async {
    try {
      final messageData = {
        'user_id': userId,
        'user_name': userName,
        'message': message,
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Broadcast to all participants
      await _classChannel?.sendBroadcastMessage(
        event: 'chat',
        payload: messageData,
      );

      // Save to database
      if (_currentMeetingId != null) {
        await _client.from(DatabaseTables.chatMessages).insert({
          'id': '${DateTime.now().millisecondsSinceEpoch}',
          'meeting_id': _currentMeetingId!,
          'sender_id': userId,
          'sender_name': userName,
          'message': message,
          'created_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      print('❌ Error sending chat message: $e');
    }
  }

  /// Draw on whiteboard
  Future<void> drawOnWhiteboard(
    String userId,
    Map<String, dynamic> strokeData,
  ) async {
    try {
      final data = {
        'user_id': userId,
        'stroke': strokeData,
        'timestamp': DateTime.now().toIso8601String(),
      };

      await _classChannel?.sendBroadcastMessage(
        event: 'whiteboard',
        payload: data,
      );
    } catch (e) {
      print('❌ Error drawing on whiteboard: $e');
    }
  }

  /// Clear whiteboard
  Future<void> clearWhiteboard() async {
    try {
      _whiteboardStrokes.clear();

      await _classChannel?.sendBroadcastMessage(
        event: 'whiteboard',
        payload: {'action': 'clear'},
      );
    } catch (e) {
      print('❌ Error clearing whiteboard: $e');
    }
  }

  /// Create poll
  Future<void> createPoll(
    String question,
    List<String> options,
    String creatorId,
    String creatorName,
  ) async {
    try {
      final pollData = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'question': question,
        'options': options,
        'creator_id': creatorId,
        'creator_name': creatorName,
        'votes': <String, int>{},
        'created_at': DateTime.now().toIso8601String(),
      };

      await _classChannel?.sendBroadcastMessage(
        event: 'poll',
        payload: pollData,
      );
    } catch (e) {
      print('❌ Error creating poll: $e');
    }
  }

  /// Vote on poll
  Future<void> voteOnPoll(String pollId, String userId, int optionIndex) async {
    try {
      await _classChannel?.sendBroadcastMessage(
        event: 'poll_vote',
        payload: {
          'poll_id': pollId,
          'user_id': userId,
          'option_index': optionIndex,
        },
      );
    } catch (e) {
      print('❌ Error voting on poll: $e');
    }
  }

  /// Raise hand
  Future<void> raiseHand(String userId, String userName) async {
    try {
      await _classChannel?.sendBroadcastMessage(
        event: 'hand_raise',
        payload: {
          'user_id': userId,
          'user_name': userName,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      print('❌ Error raising hand: $e');
    }
  }

  /// Share screen (notify others)
  Future<void> startScreenShare(String userId, String userName) async {
    try {
      await _classChannel?.sendBroadcastMessage(
        event: 'screen_share',
        payload: {'user_id': userId, 'user_name': userName, 'action': 'start'},
      );
    } catch (e) {
      print('❌ Error starting screen share: $e');
    }
  }

  /// Stop screen share
  Future<void> stopScreenShare(String userId) async {
    try {
      await _classChannel?.sendBroadcastMessage(
        event: 'screen_share',
        payload: {'user_id': userId, 'action': 'stop'},
      );
    } catch (e) {
      print('❌ Error stopping screen share: $e');
    }
  }

  /// Send reaction/emoji
  Future<void> sendReaction(
    String userId,
    String userName,
    String emoji,
  ) async {
    try {
      await _classChannel?.sendBroadcastMessage(
        event: 'reaction',
        payload: {
          'user_id': userId,
          'user_name': userName,
          'emoji': emoji,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      print('❌ Error sending reaction: $e');
    }
  }

  /// Mute/unmute participant (host only)
  Future<void> muteParticipant(String participantId, bool mute) async {
    try {
      await _classChannel?.sendBroadcastMessage(
        event: 'mute_control',
        payload: {'participant_id': participantId, 'mute': mute},
      );
    } catch (e) {
      print('❌ Error controlling mute: $e');
    }
  }

  /// End class (host only)
  Future<void> endClass() async {
    try {
      await _classChannel?.sendBroadcastMessage(
        event: 'class_end',
        payload: {'timestamp': DateTime.now().toIso8601String()},
      );

      // Update class status in database
      if (_currentMeetingId != null) {
        await _client
            .from(DatabaseTables.onlineClasses)
            .update({'status': 'completed'})
            .eq('meeting_id', _currentMeetingId!);
      }
    } catch (e) {
      print('❌ Error ending class: $e');
    }
  }

  /// Get chat history from database
  Future<List<Map<String, dynamic>>> getChatHistory(String meetingId) async {
    try {
      final messages = await _client
          .from(DatabaseTables.chatMessages)
          .select()
          .eq('meeting_id', meetingId)
          .order('created_at', ascending: true);

      return messages;
    } catch (e) {
      print('❌ Error fetching chat history: $e');
      return [];
    }
  }

  /// Get meeting statistics
  Future<Map<String, dynamic>> getMeetingStatistics(String meetingId) async {
    try {
      final participants = await _client
          .from(DatabaseTables.meetingParticipants)
          .select()
          .eq('meeting_id', meetingId);

      final totalParticipants = participants.length;
      final currentlyActive = participants
          .where((p) => p['left_at'] == null)
          .length;

      // Calculate average duration
      final durations = <int>[];
      for (var participant in participants) {
        if (participant['left_at'] != null) {
          final joined = DateTime.parse(participant['joined_at']);
          final left = DateTime.parse(participant['left_at']);
          durations.add(left.difference(joined).inMinutes);
        }
      }

      final avgDuration = durations.isEmpty
          ? 0
          : durations.reduce((a, b) => a + b) / durations.length;

      // Get chat message count
      final chatCount = await _client
          .from(DatabaseTables.chatMessages)
          .select('id')
          .eq('meeting_id', meetingId)
          .count(CountOption.exact);

      return {
        'meetingId': meetingId,
        'totalParticipants': totalParticipants,
        'currentlyActive': currentlyActive,
        'averageDuration': avgDuration,
        'chatMessageCount': chatCount.count,
      };
    } catch (e) {
      print('❌ Error fetching meeting statistics: $e');
      return {};
    }
  }

  @override
  void onClose() {
    _classChannel?.unsubscribe();
    super.onClose();
  }
}
