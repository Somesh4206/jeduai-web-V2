import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/online_class_model.dart';

/// Enhanced Video Meeting Room View
/// Provides in-app video conferencing experience
class VideoMeetingRoomView extends StatefulWidget {
  final OnlineClass classData;
  final String userName;
  final String userId;
  final bool isHost;

  const VideoMeetingRoomView({
    super.key,
    required this.classData,
    required this.userName,
    required this.userId,
    this.isHost = false,
  });

  @override
  State<VideoMeetingRoomView> createState() => _VideoMeetingRoomViewState();
}

class _VideoMeetingRoomViewState extends State<VideoMeetingRoomView> {
  bool isMicMuted = false;
  bool isVideoOff = false;
  bool isScreenSharing = false;
  bool showParticipants = false;
  bool showChat = false;
  bool isHandRaised = false;

  final TextEditingController _chatController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final List<Participant> _participants = [];

  @override
  void initState() {
    super.initState();
    _initializeMeeting();
  }

  void _initializeMeeting() {
    // Add current user as participant
    _participants.add(
      Participant(
        id: widget.userId,
        name: widget.userName,
        isHost: widget.isHost,
        isMuted: isMicMuted,
        isVideoOff: isVideoOff,
        isHandRaised: false,
      ),
    );

    // Add mock participants for demo
    _participants.addAll([
      Participant(
        id: 'P001',
        name: 'Student 1',
        isHost: false,
        isMuted: true,
        isVideoOff: false,
        isHandRaised: false,
      ),
      Participant(
        id: 'P002',
        name: 'Student 2',
        isHost: false,
        isMuted: false,
        isVideoOff: false,
        isHandRaised: false,
      ),
    ]);

    // Add welcome message
    _messages.add(
      ChatMessage(
        id: 'M001',
        senderId: 'SYSTEM',
        senderName: 'System',
        message: 'Welcome to ${widget.classData.title}!',
        timestamp: DateTime.now(),
        isSystem: true,
      ),
    );
  }

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Main video area
            _buildMainVideoArea(),

            // Top bar with class info
            _buildTopBar(),

            // Bottom control bar
            _buildBottomControls(),

            // Side panels
            if (showParticipants) _buildParticipantsPanel(),
            if (showChat) _buildChatPanel(),
          ],
        ),
      ),
    );
  }

  Widget _buildMainVideoArea() {
    return Column(
      children: [
        // Main video (teacher/presenter)
        Expanded(
          flex: 3,
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                // Video placeholder
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: const Color(0xFF00BCD4),
                        child: Text(
                          widget.classData.teacherName[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 40,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.classData.teacherName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.mic, color: Colors.white, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'Speaking',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Screen sharing indicator
                if (isScreenSharing)
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.screen_share,
                            color: Colors.white,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Screen Sharing',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Participant thumbnails
        Container(
          height: 120,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _participants.length,
            itemBuilder: (context, index) {
              return _buildParticipantThumbnail(_participants[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildParticipantThumbnail(Participant participant) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: participant.isHandRaised ? Colors.yellow : Colors.transparent,
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: participant.isHost
                      ? const Color(0xFFFF6B6B)
                      : const Color(0xFF00BCD4),
                  child: Text(
                    participant.name[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  participant.name,
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Muted indicator
          if (participant.isMuted)
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mic_off, color: Colors.white, size: 12),
              ),
            ),
          // Hand raised indicator
          if (participant.isHandRaised)
            const Positioned(
              top: 4,
              right: 4,
              child: Text('✋', style: TextStyle(fontSize: 20)),
            ),
          // Host badge
          if (participant.isHost)
            Positioned(
              top: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B6B),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'HOST',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black.withValues(alpha: 0.7), Colors.transparent],
          ),
        ),
        child: Row(
          children: [
            // Class info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.classData.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.circle, color: Colors.white, size: 8),
                            SizedBox(width: 4),
                            Text(
                              'LIVE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_participants.length} participants',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Recording indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.red),
              ),
              child: const Row(
                children: [
                  Icon(Icons.fiber_manual_record, color: Colors.red, size: 12),
                  SizedBox(width: 4),
                  Text('Recording', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withValues(alpha: 0.9), Colors.transparent],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Microphone
            _buildControlButton(
              icon: isMicMuted ? Icons.mic_off : Icons.mic,
              label: isMicMuted ? 'Unmute' : 'Mute',
              color: isMicMuted ? Colors.red : Colors.white,
              onPressed: () {
                setState(() {
                  isMicMuted = !isMicMuted;
                });
              },
            ),

            // Video
            _buildControlButton(
              icon: isVideoOff ? Icons.videocam_off : Icons.videocam,
              label: isVideoOff ? 'Start Video' : 'Stop Video',
              color: isVideoOff ? Colors.red : Colors.white,
              onPressed: () {
                setState(() {
                  isVideoOff = !isVideoOff;
                });
              },
            ),

            // Screen Share (host only)
            if (widget.isHost)
              _buildControlButton(
                icon: isScreenSharing
                    ? Icons.stop_screen_share
                    : Icons.screen_share,
                label: isScreenSharing ? 'Stop Share' : 'Share',
                color: isScreenSharing ? Colors.green : Colors.white,
                onPressed: () {
                  setState(() {
                    isScreenSharing = !isScreenSharing;
                  });
                },
              ),

            // Participants
            _buildControlButton(
              icon: Icons.people,
              label: 'Participants',
              badge: _participants.length.toString(),
              onPressed: () {
                setState(() {
                  showParticipants = !showParticipants;
                  if (showParticipants) showChat = false;
                });
              },
            ),

            // Chat
            _buildControlButton(
              icon: Icons.chat,
              label: 'Chat',
              badge: _messages.length > 1 ? '${_messages.length}' : null,
              onPressed: () {
                setState(() {
                  showChat = !showChat;
                  if (showChat) showParticipants = false;
                });
              },
            ),

            // Raise Hand
            _buildControlButton(
              icon: isHandRaised ? Icons.pan_tool : Icons.pan_tool_outlined,
              label: isHandRaised ? 'Lower Hand' : 'Raise Hand',
              color: isHandRaised ? Colors.yellow : Colors.white,
              onPressed: () {
                setState(() {
                  isHandRaised = !isHandRaised;
                });
              },
            ),

            // Leave
            _buildControlButton(
              icon: Icons.call_end,
              label: 'Leave',
              color: Colors.red,
              onPressed: _showLeaveDialog,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    Color color = Colors.white,
    String? badge,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(icon, color: color),
                onPressed: onPressed,
                iconSize: 28,
              ),
            ),
            if (badge != null)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 10)),
      ],
    );
  }

  Widget _buildParticipantsPanel() {
    return Positioned(
      right: 0,
      top: 80,
      bottom: 100,
      child: Container(
        width: 300,
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            bottomLeft: Radius.circular(16),
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Text(
                    'Participants',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_participants.length}',
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        showParticipants = false;
                      });
                    },
                  ),
                ],
              ),
            ),
            // Participants list
            Expanded(
              child: ListView.builder(
                itemCount: _participants.length,
                itemBuilder: (context, index) {
                  final participant = _participants[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: participant.isHost
                          ? const Color(0xFFFF6B6B)
                          : const Color(0xFF00BCD4),
                      child: Text(
                        participant.name[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            participant.name,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        if (participant.isHost)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B6B),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'HOST',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (participant.isHandRaised)
                          const Text('✋', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Icon(
                          participant.isMuted ? Icons.mic_off : Icons.mic,
                          color: participant.isMuted
                              ? Colors.red
                              : Colors.green,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          participant.isVideoOff
                              ? Icons.videocam_off
                              : Icons.videocam,
                          color: participant.isVideoOff
                              ? Colors.red
                              : Colors.green,
                          size: 20,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatPanel() {
    return Positioned(
      right: 0,
      top: 80,
      bottom: 100,
      child: Container(
        width: 350,
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            bottomLeft: Radius.circular(16),
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Text(
                    'Chat',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        showChat = false;
                      });
                    },
                  ),
                ],
              ),
            ),
            // Messages
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _buildChatMessage(_messages[index]);
                },
              ),
            ),
            // Input
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                border: Border(top: BorderSide(color: Colors.grey.shade700)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _chatController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: Colors.grey.shade700,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF00BCD4),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatMessage(ChatMessage message) {
    if (message.isSystem) {
      return Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.shade800,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            message.message,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ),
      );
    }

    final isMe = message.senderId == widget.userId;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 250),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF00BCD4) : Colors.grey.shade800,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Text(
                message.senderName,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (!isMe) const SizedBox(height: 4),
            Text(message.message, style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() {
    if (_chatController.text.trim().isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(
          id: 'M${DateTime.now().millisecondsSinceEpoch}',
          senderId: widget.userId,
          senderName: widget.userName,
          message: _chatController.text.trim(),
          timestamp: DateTime.now(),
          isSystem: false,
        ),
      );
    });

    _chatController.clear();
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _showLeaveDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Meeting?'),
        content: const Text('Are you sure you want to leave this meeting?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close meeting room
              Get.snackbar(
                'Left Meeting',
                'You have left ${widget.classData.title}',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.orange,
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }
}

// Models
class Participant {
  final String id;
  final String name;
  final bool isHost;
  bool isMuted;
  bool isVideoOff;
  bool isHandRaised;

  Participant({
    required this.id,
    required this.name,
    required this.isHost,
    required this.isMuted,
    required this.isVideoOff,
    required this.isHandRaised,
  });
}

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String message;
  final DateTime timestamp;
  final bool isSystem;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.timestamp,
    this.isSystem = false,
  });
}
