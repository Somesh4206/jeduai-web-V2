import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../config/gemini_config.dart';

/// Enhanced AI Tutor Service - Advanced AI tutoring with context awareness
class EnhancedAITutorService extends GetxService {
  final SupabaseClient _client = SupabaseConfig.client;

  final chatHistory = <Map<String, dynamic>>[].obs;
  final isTyping = false.obs;

  /// Get AI response with context awareness
  Future<String> getAIResponse(
    String userId,
    String message,
    String subject,
  ) async {
    try {
      isTyping.value = true;

      // Get user's performance context
      final context = await _getUserContext(userId, subject);

      // Generate contextual response
      final response = await _generateResponse(message, subject, context);

      // Save conversation
      await _saveConversation(userId, message, response, subject);

      // Add to chat history
      chatHistory.add({
        'role': 'user',
        'message': message,
        'timestamp': DateTime.now(),
      });
      chatHistory.add({
        'role': 'assistant',
        'message': response,
        'timestamp': DateTime.now(),
      });

      isTyping.value = false;
      return response;
    } catch (e) {
      isTyping.value = false;
      return 'I apologize, but I encountered an error. Please try again.';
    }
  }

  /// Get user context for personalized responses
  Future<Map<String, dynamic>> _getUserContext(
    String userId,
    String subject,
  ) async {
    try {
      // Get recent performance in subject
      final submissions = await _client
          .from(DatabaseTables.assessmentSubmissions)
          .select('*, assessments(*)')
          .eq('student_id', userId)
          .eq('assessments.subject', subject)
          .order('submitted_at', ascending: false)
          .limit(5);

      final averageScore = submissions.isEmpty
          ? 0.0
          : submissions.map((s) => s['score'] ?? 0).reduce((a, b) => a + b) /
                submissions.length;

      // Get recent topics studied
      final recentClasses = await _client
          .from(DatabaseTables.classEnrollments)
          .select('*, online_classes(*)')
          .eq('student_id', userId)
          .eq('online_classes.subject', subject)
          .order('enrolled_at', ascending: false)
          .limit(3);

      return {
        'averageScore': averageScore,
        'performanceLevel': averageScore >= 80
            ? 'advanced'
            : averageScore >= 60
            ? 'intermediate'
            : 'beginner',
        'recentTopics': recentClasses
            .map((c) => c['online_classes']['title'])
            .toList(),
      };
    } catch (e) {
      return {};
    }
  }

  /// Generate AI response using Gemini API
  Future<String> _generateResponse(
    String message,
    String subject,
    Map<String, dynamic> context,
  ) async {
    try {
      final performanceLevel = context['performanceLevel'] ?? 'intermediate';
      final recentTopics = context['recentTopics'] ?? [];
      final averageScore = context['averageScore'] ?? 0.0;

      // Build context-aware prompt
      final prompt =
          '''You are an expert AI tutor helping a student with $subject.

Student Context:
- Performance Level: $performanceLevel
- Average Score: ${averageScore.toStringAsFixed(1)}%
- Recent Topics: ${recentTopics.join(', ')}

Student Question: $message

Provide a helpful, educational response that:
1. Addresses their question directly
2. Matches their performance level ($performanceLevel)
3. Uses clear explanations with examples
4. Encourages learning and understanding
5. Includes step-by-step guidance when appropriate

Response:''';

      // Call Gemini API
      final response = await http.post(
        Uri.parse(GeminiConfig.aiTutorUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 2048,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiResponse = data['candidates'][0]['content']['parts'][0]['text'];
        return aiResponse.trim();
      } else {
        return _generateFallbackResponse(message, subject, performanceLevel);
      }
    } catch (e) {
      return _generateFallbackResponse(
        message,
        subject,
        context['performanceLevel'] ?? 'intermediate',
      );
    }
  }

  /// Fallback response if API fails
  String _generateFallbackResponse(
    String message,
    String subject,
    String level,
  ) {
    return '''I'm here to help you with $subject!

Your question: "$message"

While I process your question, here's what I can help you with:

📚 **Explanations**: Ask me to explain any concept
🔍 **Examples**: Request examples to understand better
✍️ **Practice**: Get practice problems to improve
💡 **Solutions**: Step-by-step problem solving

Please try asking your question again, or let me know how else I can assist you!
''';
  }

  /// Save conversation
  Future<void> _saveConversation(
    String userId,
    String userMessage,
    String aiResponse,
    String subject,
  ) async {
    try {
      await _client.from('ai_tutor_conversations').insert({
        'user_id': userId,
        'user_message': userMessage,
        'ai_response': aiResponse,
        'subject': subject,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('❌ Error saving conversation: $e');
    }
  }

  /// Get conversation history
  Future<List<Map<String, dynamic>>> getConversationHistory(
    String userId, {
    String? subject,
  }) async {
    try {
      var query = _client
          .from('ai_tutor_conversations')
          .select()
          .eq('user_id', userId);

      if (subject != null) {
        query = query.eq('subject', subject);
      }

      final response = await query
          .order('created_at', ascending: false)
          .limit(50);

      return response;
    } catch (e) {
      return [];
    }
  }

  /// Get suggested topics
  Future<List<String>> getSuggestedTopics(String userId, String subject) async {
    try {
      // Get weak areas
      await _client
          .from(DatabaseTables.assessmentSubmissions)
          .select('*, assessments(*)')
          .eq('student_id', userId)
          .eq('assessments.subject', subject);

      // Analyze and suggest topics based on performance
      final suggestions = <String>[
        'Review fundamentals',
        'Practice problem-solving',
        'Explore advanced concepts',
        'Work on weak areas',
        'Prepare for upcoming assessments',
      ];

      return suggestions;
    } catch (e) {
      return [];
    }
  }

  /// Clear chat history
  void clearChatHistory() {
    chatHistory.clear();
  }
}
