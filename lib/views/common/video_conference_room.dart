import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/video_conference_service.dart';

class VideoConferenceRoom extends StatefulWidget {
  final String meetingId;
  final String userName;
  final String userId;
  final bool isHost;

  const VideoConferenceRoom({
    super.key,
    required this.meetingId,
    required this.userName,
    required this.userId,
    this.isHost = false,
  });

  @override
  State<VideoConferenceRoom> createState() => _VideoConferenceRoomState();
}

class _VideoConferenceRoomState extends State<VideoConferenceRoom> {
  final VideoConferenceService service = Get.put(VideoConferenceService());
  final TextEditingController chatController = TextEditingController();
  bool showChat = false;
  bool showParticipants = false;

  @override
  void initState() {
    super.initState();
    _initializeMeeting();
  }

  void _initializeMeeting() async {
    if (widget.isHost) {
      await service.startMeeting(
        className: 'Online Class',
        hostName: widget.userName,
        hostId: widget.userId,
      );
    } else {
      await service.joinMeeting(
        meetingId: widget.meetingId,
        participantName: widget.userName,
        participantId: widget.userId,
      );
    }
  }

  @override
  void dispose() {
    service.leaveMeeting(widget.userId);
    chatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Main video grid
            _buildVideoGrid(),

            // Top bar
            _buildTopBar(),

            // Bottom controls
            _buildBottomControls(),

            // Side panels
            if (showChat) _buildChatPanel(),
            if (showParticipants) _buildParticipantsPanel(),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoGrid() {
    return Obx(() {
      final participants = service.participants;

      if (participants.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(color: Colors.white),
        );
      }

      return GridView.builder(
        padding: const EdgeInsets.only(top: 60, bottom: 100),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: participants.length == 1 ? 1 : 2,
          childAspectRatio: 16 / 9,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: participants.length,
        itemBuilder: (context, index) {
          return _buildVideoTile(participants[index]);
        },
      );
    });
  }

  Widget _buildVideoTile(Participant participant) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          // Video placeholder (in production, show actual video stream)
          if (participant.isCameraOn)
            Center(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade900, Colors.purple.shade900],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.person,
                  size: 80,
                  color: Colors.white54,
                ),
              ),
            )
          else
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.blue,
                child: Text(
                  participant.name[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

          // Participant info
          Positioned(
            bottom: 8,
            left: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!participant.isMicrophoneOn)
                    const Icon(Icons.mic_off, size: 16, color: Colors.red),
                  if (!participant.isMicrophoneOn) const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      participant.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (participant.role == ParticipantRole.host) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(2),
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
                  ],
                  if (participant.isHandRaised) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.pan_tool, size: 16, color: Colors.yellow),
                  ],
                ],
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black.withValues(alpha: 0.7), Colors.transparent],
          ),
        ),
        child: Row(
          children: [
            // Meeting info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(
                    () => Text(
                      'Meeting ID: ${service.meetingId.value}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Obx(
                    () => Text(
                      'Duration: ${service.formattedDuration}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Connection quality
            Obx(
              () => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: service.connectionQuality.value.color.withValues(
                    alpha: 0.3,
                  ),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: service.connectionQuality.value.color,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      service.connectionQuality.value.icon,
                      size: 16,
                      color: service.connectionQuality.value.color,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      service.connectionQuality.value.label,
                      style: TextStyle(
                        color: service.connectionQuality.value.color,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Recording indicator
            Obx(
              () => service.isRecording.value
                  ? Container(
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
                          Icon(
                            Icons.fiber_manual_record,
                            size: 12,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'REC',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox(),
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
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
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
            Obx(
              () => _buildControlButton(
                icon: service.isMicrophoneOn.value ? Icons.mic : Icons.mic_off,
                label: 'Mic',
                onPressed: service.toggleMicrophone,
                isActive: service.isMicrophoneOn.value,
              ),
            ),

            // Camera
            Obx(
              () => _buildControlButton(
                icon: service.isCameraOn.value
                    ? Icons.videocam
                    : Icons.videocam_off,
                label: 'Camera',
                onPressed: service.toggleCamera,
                isActive: service.isCameraOn.value,
              ),
            ),

            // Screen Share
            Obx(
              () => _buildControlButton(
                icon: Icons.screen_share,
                label: 'Share',
                onPressed: service.toggleScreenShare,
                isActive: service.isScreenSharing.value,
              ),
            ),

            // Participants
            _buildControlButton(
              icon: Icons.people,
              label: 'People',
              onPressed: () =>
                  setState(() => showParticipants = !showParticipants),
              badge: service.participants.length.toString(),
            ),

            // Chat
            _buildControlButton(
              icon: Icons.chat,
              label: 'Chat',
              onPressed: () => setState(() => showChat = !showChat),
            ),

            // Raise Hand
            Obx(
              () => _buildControlButton(
                icon: Icons.pan_tool,
                label: 'Hand',
                onPressed: service.toggleHandRaise,
                isActive: service.isHandRaised.value,
              ),
            ),

            // More options
            _buildControlButton(
              icon: Icons.more_horiz,
              label: 'More',
              onPressed: _showMoreOptions,
            ),

            // Leave/End
            _buildControlButton(
              icon: Icons.call_end,
              label: widget.isHost ? 'End' : 'Leave',
              onPressed: _leaveMeeting,
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isActive = true,
    Color? color,
    String? badge,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color:
                    color ??
                    (isActive
                        ? Colors.white24
                        : Colors.red.withValues(alpha: 0.3)),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(icon),
                color: color != null
                    ? Colors.white
                    : (isActive ? Colors.white : Colors.red),
                onPressed: onPressed,
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
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
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

  Widget _buildChatPanel() {
    return Positioned(
      right: 0,
      top: 60,
      bottom: 100,
      width: 300,
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Chat header
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(
                children: [
                  const Text(
                    'Chat',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => showChat = false),
                  ),
                ],
              ),
            ),

            // Chat messages
            Expanded(
              child: Obx(
                () => ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: service.chatMessages.length,
                  itemBuilder: (context, index) {
                    final message = service.chatMessages[index];
                    return _buildChatMessage(message);
                  },
                ),
              ),
            ),

            // Chat input
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: chatController,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send),
                    color: Colors.blue,
                    onPressed: _sendMessage,
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                message.senderName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                message.timeFormatted,
                style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(message.message),
        ],
      ),
    );
  }

  Widget _buildParticipantsPanel() {
    return Positioned(
      right: 0,
      top: 60,
      bottom: 100,
      width: 300,
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Participants header
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(
                children: [
                  Obx(
                    () => Text(
                      'Participants (${service.participants.length})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => showParticipants = false),
                  ),
                ],
              ),
            ),

            // Participants list
            Expanded(
              child: Obx(
                () => ListView.builder(
                  itemCount: service.participants.length,
                  itemBuilder: (context, index) {
                    final participant = service.participants[index];
                    return _buildParticipantTile(participant);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantTile(Participant participant) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue,
        child: Text(
          participant.name[0].toUpperCase(),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      title: Text(participant.name),
      subtitle: Text(
        participant.role == ParticipantRole.host ? 'Host' : 'Participant',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            participant.isMicrophoneOn ? Icons.mic : Icons.mic_off,
            size: 20,
            color: participant.isMicrophoneOn ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 8),
          Icon(
            participant.isCameraOn ? Icons.videocam : Icons.videocam_off,
            size: 20,
            color: participant.isCameraOn ? Colors.green : Colors.red,
          ),
          if (widget.isHost && participant.id != widget.userId)
            PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'mute', child: Text('Mute')),
                const PopupMenuItem(value: 'remove', child: Text('Remove')),
              ],
              onSelected: (value) {
                if (value == 'mute') {
                  service.muteParticipant(participant.id);
                } else if (value == 'remove') {
                  service.removeParticipant(participant.id);
                }
              },
            ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (chatController.text.trim().isEmpty) return;

    service.sendChatMessage(
      chatController.text,
      widget.userId,
      widget.userName,
    );
    chatController.clear();
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.fiber_manual_record),
              title: const Text('Record Meeting'),
              onTap: () {
                Navigator.pop(context);
                service.toggleRecording();
              },
            ),
            ListTile(
              leading: const Icon(Icons.view_module),
              title: const Text('Change View'),
              onTap: () {
                Navigator.pop(context);
                _showViewOptions();
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Get.snackbar('Settings', 'Settings coming soon');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showViewOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select View'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Gallery View'),
              onTap: () {
                service.changeViewMode(ViewMode.gallery);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Speaker View'),
              onTap: () {
                service.changeViewMode(ViewMode.speaker);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Grid View'),
              onTap: () {
                service.changeViewMode(ViewMode.grid);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _leaveMeeting() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.isHost ? 'End Meeting' : 'Leave Meeting'),
        content: Text(
          widget.isHost
              ? 'Are you sure you want to end this meeting for everyone?'
              : 'Are you sure you want to leave this meeting?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (widget.isHost) {
                service.endMeeting();
              } else {
                service.leaveMeeting(widget.userId);
              }
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close meeting room
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(widget.isHost ? 'End' : 'Leave'),
          ),
        ],
      ),
    );
  }
}
