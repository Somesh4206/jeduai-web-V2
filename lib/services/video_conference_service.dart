import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Advanced Video Conference Service
/// Provides Zoom-like functionality for online classes
class VideoConferenceService extends GetxService {
  // Observable states
  var isCameraOn = true.obs;
  var isMicrophoneOn = true.obs;
  var isScreenSharing = false.obs;
  var isRecording = false.obs;
  var participants = <Participant>[].obs;
  var chatMessages = <ChatMessage>[].obs;
  var isHandRaised = false.obs;
  var currentView = ViewMode.gallery.obs;

  // Meeting state
  var meetingId = ''.obs;
  var meetingPassword = ''.obs;
  var isHost = false.obs;
  var meetingDuration = 0.obs;
  var connectionQuality = ConnectionQuality.excellent.obs;

  /// Generate unique meeting link
  String generateMeetingLink() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomId = (timestamp % 1000000).toString().padLeft(6, '0');
    meetingId.value = 'JED-$randomId';
    meetingPassword.value = _generatePassword();

    return 'https://meet.jeduai.com/${meetingId.value}';
  }

  /// Generate random password
  String _generatePassword() {
    final chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(
      6,
      (index) =>
          chars[(DateTime.now().millisecondsSinceEpoch + index) % chars.length],
    ).join();
  }

  /// Start meeting as host
  Future<void> startMeeting({
    required String className,
    required String hostName,
    required String hostId,
  }) async {
    isHost.value = true;
    meetingId.value = generateMeetingLink().split('/').last;

    // Add host as first participant
    participants.add(
      Participant(
        id: hostId,
        name: hostName,
        role: ParticipantRole.host,
        isCameraOn: true,
        isMicrophoneOn: true,
        isHandRaised: false,
        joinedAt: DateTime.now(),
      ),
    );

    // Start meeting timer
    _startMeetingTimer();

    Get.snackbar(
      'Meeting Started',
      'Meeting ID: ${meetingId.value}',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  /// Join meeting as participant
  Future<bool> joinMeeting({
    required String meetingId,
    required String participantName,
    required String participantId,
    String? password,
  }) async {
    // Simulate joining delay
    await Future.delayed(const Duration(seconds: 1));

    // Validate meeting (in production, check with backend)
    if (meetingId.isEmpty) {
      Get.snackbar('Error', 'Invalid meeting ID');
      return false;
    }

    // Add participant
    participants.add(
      Participant(
        id: participantId,
        name: participantName,
        role: ParticipantRole.participant,
        isCameraOn: true,
        isMicrophoneOn: true,
        isHandRaised: false,
        joinedAt: DateTime.now(),
      ),
    );

    this.meetingId.value = meetingId;

    Get.snackbar(
      'Joined Successfully',
      'You are now in the meeting',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );

    return true;
  }

  /// Toggle camera
  void toggleCamera() {
    isCameraOn.value = !isCameraOn.value;
    Get.snackbar(
      isCameraOn.value ? 'Camera On' : 'Camera Off',
      isCameraOn.value
          ? 'Your camera is now visible'
          : 'Your camera is now hidden',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  /// Toggle microphone
  void toggleMicrophone() {
    isMicrophoneOn.value = !isMicrophoneOn.value;
    Get.snackbar(
      isMicrophoneOn.value ? 'Microphone On' : 'Microphone Off',
      isMicrophoneOn.value ? 'You are now unmuted' : 'You are now muted',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  /// Toggle screen sharing
  void toggleScreenShare() {
    isScreenSharing.value = !isScreenSharing.value;
    Get.snackbar(
      isScreenSharing.value
          ? 'Screen Sharing Started'
          : 'Screen Sharing Stopped',
      isScreenSharing.value
          ? 'Your screen is now visible'
          : 'Screen sharing ended',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  /// Toggle recording
  void toggleRecording() {
    isRecording.value = !isRecording.value;
    Get.snackbar(
      isRecording.value ? 'Recording Started' : 'Recording Stopped',
      isRecording.value ? 'This meeting is being recorded' : 'Recording saved',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isRecording.value ? Colors.red : Colors.grey,
      colorText: Colors.white,
    );
  }

  /// Raise/lower hand
  void toggleHandRaise() {
    isHandRaised.value = !isHandRaised.value;
    Get.snackbar(
      isHandRaised.value ? 'Hand Raised' : 'Hand Lowered',
      isHandRaised.value ? 'The host will be notified' : 'Hand lowered',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Send chat message
  void sendChatMessage(String message, String senderId, String senderName) {
    chatMessages.add(
      ChatMessage(
        id: 'MSG${DateTime.now().millisecondsSinceEpoch}',
        senderId: senderId,
        senderName: senderName,
        message: message,
        timestamp: DateTime.now(),
      ),
    );
  }

  /// Change view mode
  void changeViewMode(ViewMode mode) {
    currentView.value = mode;
  }

  /// Mute participant (host only)
  void muteParticipant(String participantId) {
    if (!isHost.value) return;

    final index = participants.indexWhere((p) => p.id == participantId);
    if (index != -1) {
      participants[index].isMicrophoneOn = false;
      participants.refresh();
    }
  }

  /// Remove participant (host only)
  void removeParticipant(String participantId) {
    if (!isHost.value) return;

    participants.removeWhere((p) => p.id == participantId);
    Get.snackbar(
      'Participant Removed',
      'Participant has been removed from the meeting',
    );
  }

  /// End meeting (host only)
  void endMeeting() {
    if (!isHost.value) return;

    participants.clear();
    chatMessages.clear();
    meetingDuration.value = 0;

    Get.snackbar(
      'Meeting Ended',
      'The meeting has been ended by the host',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  /// Leave meeting
  void leaveMeeting(String participantId) {
    participants.removeWhere((p) => p.id == participantId);

    // Reset states
    isCameraOn.value = true;
    isMicrophoneOn.value = true;
    isScreenSharing.value = false;
    isRecording.value = false;
    isHandRaised.value = false;
  }

  /// Start meeting timer
  void _startMeetingTimer() {
    Future.delayed(const Duration(minutes: 1), () {
      if (participants.isNotEmpty) {
        meetingDuration.value++;
        _startMeetingTimer();
      }
    });
  }

  /// Get meeting duration formatted
  String get formattedDuration {
    final hours = meetingDuration.value ~/ 60;
    final minutes = meetingDuration.value % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  /// Simulate connection quality check
  void checkConnectionQuality() {
    // In production, check actual network quality
    final random = DateTime.now().millisecondsSinceEpoch % 3;
    connectionQuality.value = ConnectionQuality.values[random];
  }
}

/// Participant Model
class Participant {
  final String id;
  final String name;
  final ParticipantRole role;
  bool isCameraOn;
  bool isMicrophoneOn;
  bool isHandRaised;
  final DateTime joinedAt;

  Participant({
    required this.id,
    required this.name,
    required this.role,
    required this.isCameraOn,
    required this.isMicrophoneOn,
    required this.isHandRaised,
    required this.joinedAt,
  });
}

/// Chat Message Model
class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String message;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.timestamp,
  });

  String get timeFormatted {
    return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}

/// Enums
enum ParticipantRole { host, coHost, participant }

enum ViewMode { gallery, speaker, grid }

enum ConnectionQuality { excellent, good, poor }

/// Extension for ConnectionQuality
extension ConnectionQualityExtension on ConnectionQuality {
  Color get color {
    switch (this) {
      case ConnectionQuality.excellent:
        return Colors.green;
      case ConnectionQuality.good:
        return Colors.orange;
      case ConnectionQuality.poor:
        return Colors.red;
    }
  }

  IconData get icon {
    switch (this) {
      case ConnectionQuality.excellent:
        return Icons.signal_cellular_alt;
      case ConnectionQuality.good:
        return Icons.signal_cellular_alt_2_bar;
      case ConnectionQuality.poor:
        return Icons.signal_cellular_alt_1_bar;
    }
  }

  String get label {
    switch (this) {
      case ConnectionQuality.excellent:
        return 'Excellent';
      case ConnectionQuality.good:
        return 'Good';
      case ConnectionQuality.poor:
        return 'Poor';
    }
  }
}
