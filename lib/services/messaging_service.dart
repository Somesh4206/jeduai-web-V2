import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Advanced Messaging Service for Staff-Student Communication
class MessagingService extends GetxService {
  // Observable lists
  var conversations = <Conversation>[].obs;
  var unreadCount = 0.obs;
  var messageTemplates = <MessageTemplate>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadConversations();
    _initializeTemplates();
  }

  /// Initialize message templates
  void _initializeTemplates() {
    messageTemplates.value = [
      MessageTemplate(
        id: 'T1',
        title: 'Assignment Reminder',
        content:
            'Hi {name}, this is a reminder that your assignment for {subject} is due on {date}. Please submit it on time.',
        category: 'Academic',
      ),
      MessageTemplate(
        id: 'T2',
        title: 'Attendance Alert',
        content:
            'Dear {name}, your attendance is currently at {percentage}%. Please ensure regular attendance to meet the minimum requirement.',
        category: 'Attendance',
      ),
      MessageTemplate(
        id: 'T3',
        title: 'Performance Appreciation',
        content:
            'Congratulations {name}! Your performance in {subject} has been excellent. Keep up the great work!',
        category: 'Appreciation',
      ),
      MessageTemplate(
        id: 'T4',
        title: 'Meeting Request',
        content:
            'Hi {name}, I would like to schedule a meeting with you to discuss your progress. Please let me know your available time.',
        category: 'Meeting',
      ),
      MessageTemplate(
        id: 'T5',
        title: 'Class Cancellation',
        content:
            'Dear students, the class scheduled for {date} at {time} has been cancelled. We will reschedule it soon.',
        category: 'Announcement',
      ),
    ];
  }

  /// Send message to student
  Future<void> sendMessage({
    required String recipientId,
    required String recipientName,
    required String subject,
    required String message,
    String? senderId,
    String? senderName,
  }) async {
    final newMessage = Message(
      id: 'MSG${DateTime.now().millisecondsSinceEpoch}',
      senderId: senderId ?? 'STAFF001',
      senderName: senderName ?? 'Staff',
      recipientId: recipientId,
      recipientName: recipientName,
      subject: subject,
      message: message,
      timestamp: DateTime.now(),
      isRead: false,
    );

    // Find or create conversation
    final convIndex = conversations.indexWhere(
      (c) => c.participantId == recipientId,
    );

    if (convIndex != -1) {
      conversations[convIndex].messages.add(newMessage);
      conversations[convIndex].lastMessage = message;
      conversations[convIndex].lastMessageTime = DateTime.now();
      conversations[convIndex].unreadCount++;
    } else {
      conversations.add(
        Conversation(
          id: 'CONV${DateTime.now().millisecondsSinceEpoch}',
          participantId: recipientId,
          participantName: recipientName,
          messages: [newMessage],
          lastMessage: message,
          lastMessageTime: DateTime.now(),
          unreadCount: 1,
        ),
      );
    }

    await _saveConversations();
    _updateUnreadCount();

    Get.snackbar(
      'Message Sent',
      'Your message has been sent to $recipientName',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  /// Broadcast message to multiple students
  Future<void> broadcastMessage({
    required List<String> recipientIds,
    required List<String> recipientNames,
    required String subject,
    required String message,
  }) async {
    for (int i = 0; i < recipientIds.length; i++) {
      await sendMessage(
        recipientId: recipientIds[i],
        recipientName: recipientNames[i],
        subject: subject,
        message: message,
      );
    }

    Get.snackbar(
      'Broadcast Sent',
      'Message sent to ${recipientIds.length} students',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  /// Mark message as read
  void markAsRead(String conversationId, String messageId) {
    final convIndex = conversations.indexWhere((c) => c.id == conversationId);
    if (convIndex != -1) {
      final msgIndex = conversations[convIndex].messages.indexWhere(
        (m) => m.id == messageId,
      );
      if (msgIndex != -1) {
        conversations[convIndex].messages[msgIndex].isRead = true;
        conversations[convIndex].unreadCount--;
        _saveConversations();
        _updateUnreadCount();
      }
    }
  }

  /// Get conversation by participant ID
  Conversation? getConversation(String participantId) {
    try {
      return conversations.firstWhere((c) => c.participantId == participantId);
    } catch (e) {
      return null;
    }
  }

  /// Update unread count
  void _updateUnreadCount() {
    unreadCount.value = conversations.fold(
      0,
      (sum, conv) => sum + conv.unreadCount,
    );
  }

  /// Save conversations to storage
  Future<void> _saveConversations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final convsJson = conversations.map((c) => c.toJson()).toList();
      await prefs.setString('conversations', jsonEncode(convsJson));
    } catch (e) {
      print('Error saving conversations: $e');
    }
  }

  /// Load conversations from storage
  Future<void> _loadConversations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final convsString = prefs.getString('conversations');
      if (convsString != null) {
        final List<dynamic> convsJson = jsonDecode(convsString);
        conversations.value = convsJson
            .map((json) => Conversation.fromJson(json))
            .toList();
        _updateUnreadCount();
      }
    } catch (e) {
      print('Error loading conversations: $e');
    }
  }
}

/// Conversation Model
class Conversation {
  final String id;
  final String participantId;
  final String participantName;
  List<Message> messages;
  String lastMessage;
  DateTime lastMessageTime;
  int unreadCount;

  Conversation({
    required this.id,
    required this.participantId,
    required this.participantName,
    required this.messages,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'participantId': participantId,
    'participantName': participantName,
    'messages': messages.map((m) => m.toJson()).toList(),
    'lastMessage': lastMessage,
    'lastMessageTime': lastMessageTime.toIso8601String(),
    'unreadCount': unreadCount,
  };

  factory Conversation.fromJson(Map<String, dynamic> json) => Conversation(
    id: json['id'],
    participantId: json['participantId'],
    participantName: json['participantName'],
    messages: (json['messages'] as List)
        .map((m) => Message.fromJson(m))
        .toList(),
    lastMessage: json['lastMessage'],
    lastMessageTime: DateTime.parse(json['lastMessageTime']),
    unreadCount: json['unreadCount'] ?? 0,
  );
}

/// Message Model
class Message {
  final String id;
  final String senderId;
  final String senderName;
  final String recipientId;
  final String recipientName;
  final String subject;
  final String message;
  final DateTime timestamp;
  bool isRead;

  Message({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.recipientId,
    required this.recipientName,
    required this.subject,
    required this.message,
    required this.timestamp,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'senderId': senderId,
    'senderName': senderName,
    'recipientId': recipientId,
    'recipientName': recipientName,
    'subject': subject,
    'message': message,
    'timestamp': timestamp.toIso8601String(),
    'isRead': isRead,
  };

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id: json['id'],
    senderId: json['senderId'],
    senderName: json['senderName'],
    recipientId: json['recipientId'],
    recipientName: json['recipientName'],
    subject: json['subject'],
    message: json['message'],
    timestamp: DateTime.parse(json['timestamp']),
    isRead: json['isRead'] ?? false,
  );
}

/// Message Template Model
class MessageTemplate {
  final String id;
  final String title;
  final String content;
  final String category;

  MessageTemplate({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
  });
}
