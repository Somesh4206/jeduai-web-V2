import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/enhanced_ai_tutor_service.dart';

class Message {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? subject;

  Message({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.subject,
  });
}

class StudentAiTutorView extends StatefulWidget {
  const StudentAiTutorView({super.key});

  @override
  State<StudentAiTutorView> createState() => _StudentAiTutorViewState();
}

class _StudentAiTutorViewState extends State<StudentAiTutorView> {
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final List<Message> messages = [];
  final aiTutorService = Get.find<EnhancedAITutorService>();
  bool isTyping = false;
  String selectedSubject = 'General';
  final List<String> subjects = [
    'General',
    'Mathematics',
    'Science',
    'English',
    'History',
    'Programming',
    'Physics',
    'Chemistry',
    'Biology',
  ];

  @override
  void initState() {
    super.initState();
    // Welcome message
    messages.add(
      Message(
        text: 'Hello! I\'m your AI Tutor. How can I help you today?',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  void sendMessage() async {
    if (messageController.text.trim().isEmpty) return;

    final userMessage = messageController.text.trim();
    setState(() {
      messages.add(
        Message(
          text: userMessage,
          isUser: true,
          timestamp: DateTime.now(),
          subject: selectedSubject,
        ),
      );
      isTyping = true;
    });

    messageController.clear();
    scrollToBottom();

    // Get AI response from Gemini
    try {
      final aiResponse = await aiTutorService.getAIResponse(
        'STU001', // Replace with actual user ID
        userMessage,
        selectedSubject,
      );

      setState(() {
        messages.add(
          Message(
            text: aiResponse,
            isUser: false,
            timestamp: DateTime.now(),
            subject: selectedSubject,
          ),
        );
        isTyping = false;
      });
      scrollToBottom();
    } catch (e) {
      setState(() {
        messages.add(
          Message(
            text: 'Sorry, I encountered an error. Please try again.',
            isUser: false,
            timestamp: DateTime.now(),
            subject: selectedSubject,
          ),
        );
        isTyping = false;
      });
      scrollToBottom();
    }
  }

  void scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Tutor'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.subject),
            onSelected: (value) {
              setState(() {
                selectedSubject = value;
              });
              Get.snackbar(
                'Subject Changed',
                'Now tutoring: $value',
                snackPosition: SnackPosition.BOTTOM,
                duration: Duration(seconds: 2),
              );
            },
            itemBuilder: (context) => subjects
                .map(
                  (subject) =>
                      PopupMenuItem(value: subject, child: Text(subject)),
                )
                .toList(),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline),
            onPressed: () {
              setState(() {
                messages.clear();
                messages.add(
                  Message(
                    text: 'Chat cleared. How can I help you?',
                    isUser: false,
                    timestamp: DateTime.now(),
                  ),
                );
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Subject indicator with gradient
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF4CAF50).withOpacity(0.1),
                  Color(0xFF81C784).withOpacity(0.1),
                ],
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xFF4CAF50),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.school, size: 20, color: Colors.white),
                ),
                SizedBox(width: 12),
                Text(
                  'Current Subject: $selectedSubject',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4CAF50),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          // Messages
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: EdgeInsets.all(16),
              itemCount: messages.length + (isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == messages.length && isTyping) {
                  return _buildTypingIndicator();
                }
                return _buildMessageBubble(messages[index]);
              },
            ),
          ),
          // Input area
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: 'Ask me anything about $selectedSubject...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => sendMessage(),
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: message.isUser ? Colors.blue : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: message.isUser ? Colors.white : Colors.black87,
                fontSize: 15,
              ),
            ),
            SizedBox(height: 4),
            Text(
              '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                color: message.isUser
                    ? Colors.white.withOpacity(0.7)
                    : Colors.grey,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDot(0),
            SizedBox(width: 4),
            _buildDot(1),
            SizedBox(width: 4),
            _buildDot(2),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 600),
      builder: (context, double value, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(value),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }
}
