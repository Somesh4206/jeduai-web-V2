import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../config/gemini_config.dart';
import '../config/groq_config.dart';
import '../config/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Gemini Translation Service - Advanced AI-powered translation
class GeminiTranslationService extends GetxService {
  final SupabaseClient _client = SupabaseConfig.client;

  // Observable states
  final isTranslating = false.obs;
  final translationProgress = 0.0.obs;
  final translatedText = ''.obs;
  final translationHistory = <Map<String, dynamic>>[].obs;

  // Supported languages
  final supportedLanguages = [
    // Indian Languages
    {'code': 'hi', 'name': 'Hindi', 'nativeName': 'हिंदी'},
    {'code': 'ta', 'name': 'Tamil', 'nativeName': 'தமிழ்'},
    {'code': 'te', 'name': 'Telugu', 'nativeName': 'తెలుగు'},
    {'code': 'ml', 'name': 'Malayalam', 'nativeName': 'മലയാളം'},
    {'code': 'bn', 'name': 'Bengali', 'nativeName': 'বাংলা'},
    {'code': 'kn', 'name': 'Kannada', 'nativeName': 'ಕನ್ನಡ'},
    {'code': 'mr', 'name': 'Marathi', 'nativeName': 'मराठी'},
    {'code': 'gu', 'name': 'Gujarati', 'nativeName': 'ગુજરાતી'},
    {'code': 'pa', 'name': 'Punjabi', 'nativeName': 'ਪੰਜਾਬੀ'},
    {'code': 'ur', 'name': 'Urdu', 'nativeName': 'اردو'},
    {'code': 'or', 'name': 'Odia', 'nativeName': 'ଓଡ଼ିଆ'},
    {'code': 'as', 'name': 'Assamese', 'nativeName': 'অসমীয়া'},
    
    // International Languages
    {'code': 'en', 'name': 'English', 'nativeName': 'English'},
    {'code': 'es', 'name': 'Spanish', 'nativeName': 'Español'},
    {'code': 'fr', 'name': 'French', 'nativeName': 'Français'},
    {'code': 'de', 'name': 'German', 'nativeName': 'Deutsch'},
    {'code': 'zh', 'name': 'Chinese', 'nativeName': '中文'},
    {'code': 'ja', 'name': 'Japanese', 'nativeName': '日本語'},
    {'code': 'ko', 'name': 'Korean', 'nativeName': '한국어'},
    {'code': 'ar', 'name': 'Arabic', 'nativeName': 'العربية'},
    {'code': 'ru', 'name': 'Russian', 'nativeName': 'Русский'},
    {'code': 'pt', 'name': 'Portuguese', 'nativeName': 'Português'},
    {'code': 'it', 'name': 'Italian', 'nativeName': 'Italiano'},
    {'code': 'nl', 'name': 'Dutch', 'nativeName': 'Nederlands'},
    {'code': 'tr', 'name': 'Turkish', 'nativeName': 'Türkçe'},
    {'code': 'pl', 'name': 'Polish', 'nativeName': 'Polski'},
    {'code': 'vi', 'name': 'Vietnamese', 'nativeName': 'Tiếng Việt'},
    {'code': 'th', 'name': 'Thai', 'nativeName': 'ไทย'},
    {'code': 'id', 'name': 'Indonesian', 'nativeName': 'Bahasa Indonesia'},
    {'code': 'ms', 'name': 'Malay', 'nativeName': 'Bahasa Melayu'},
  ];

  /// Translate text using Gemini API (supports multi-line)
  Future<String> translateText({
    required String text,
    required String sourceLang,
    required String targetLang,
    String? userId,
  }) async {
    try {
      isTranslating.value = true;
      translationProgress.value = 0.0;

      // Validate input
      if (text.trim().isEmpty) {
        throw Exception('Text cannot be empty');
      }

      // Split into lines for better handling
      final lines = text.split('\n');
      final totalLines = lines.length;

      print('🔄 Translating $totalLines lines from $sourceLang to $targetLang');

      // For single line or short text, translate directly
      if (totalLines <= 3 || text.length < 500) {
        final result = await _translateWithGemini(text, sourceLang, targetLang);
        translationProgress.value = 1.0;
        translatedText.value = result;

        // Save to history
        if (userId != null) {
          await _saveToHistory(userId, text, result, sourceLang, targetLang);
        }

        isTranslating.value = false;
        return result;
      }

      // For multi-line text, translate in batches
      final translatedLines = <String>[];
      final batchSize = 5; // Translate 5 lines at a time

      for (int i = 0; i < lines.length; i += batchSize) {
        final end = (i + batchSize < lines.length) ? i + batchSize : lines.length;
        final batch = lines.sublist(i, end);
        final batchText = batch.join('\n');

        // Translate batch
        final translatedBatch = await _translateWithGemini(
          batchText,
          sourceLang,
          targetLang,
        );

        translatedLines.add(translatedBatch);

        // Update progress
        translationProgress.value = (end / totalLines);

        // Small delay to avoid rate limiting
        await Future.delayed(const Duration(milliseconds: 500));
      }

      final finalResult = translatedLines.join('\n');
      translatedText.value = finalResult;

      // Save to history
      if (userId != null) {
        await _saveToHistory(userId, text, finalResult, sourceLang, targetLang);
      }

      isTranslating.value = false;
      translationProgress.value = 1.0;

      Get.snackbar(
        '✅ Translation Complete',
        'Translated $totalLines lines successfully',
        snackPosition: SnackPosition.BOTTOM,
      );

      return finalResult;
    } catch (e) {
      isTranslating.value = false;
      print('❌ Translation error: $e');
      
      Get.snackbar(
        '❌ Translation Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );

      throw Exception('Translation failed: $e');
    }
  }

  /// Translate using Gemini API
  Future<String> _translateWithGemini(
    String text,
    String sourceLang,
    String targetLang,
  ) async {
    try {
      final sourceLanguage = _getLanguageName(sourceLang);
      final targetLanguage = _getLanguageName(targetLang);

      // Create prompt for Gemini
      final prompt = '''
Translate the following text from $sourceLanguage to $targetLanguage.
Preserve the original formatting, line breaks, and structure.
Only provide the translation, no explanations or additional text.

Text to translate:
$text

Translation:''';

      // Make API request
      final response = await http.post(
        Uri.parse(GeminiConfig.translateUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.3,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 2048,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final translation = data['candidates'][0]['content']['parts'][0]['text'];
        
        // Clean up the translation
        return translation.trim();
      } else {
        print('❌ API Error: ${response.statusCode} - ${response.body}');
        throw Exception('API request failed: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Gemini API error: $e');
      throw Exception('Translation API error: $e');
    }
  }

  /// Get language name from code
  String _getLanguageName(String code) {
    final lang = supportedLanguages.firstWhere(
      (l) => l['code'] == code,
      orElse: () => {'name': code},
    );
    return lang['name'] as String;
  }

  /// Save translation to history
  Future<void> _saveToHistory(
    String userId,
    String sourceText,
    String targetText,
    String sourceLang,
    String targetLang,
  ) async {
    try {
      await _client.from(DatabaseTables.translations).insert({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'user_id': userId,
        'source_text': sourceText,
        'target_text': targetText,
        'source_language': sourceLang,
        'target_language': targetLang,
        'created_at': DateTime.now().toIso8601String(),
      });

      // Add to local history
      translationHistory.insert(0, {
        'sourceText': sourceText,
        'targetText': targetText,
        'sourceLang': sourceLang,
        'targetLang': targetLang,
        'timestamp': DateTime.now(),
      });
    } catch (e) {
      print('❌ Error saving to history: $e');
    }
  }

  /// Get translation history
  Future<List<Map<String, dynamic>>> getHistory(String userId) async {
    try {
      final response = await _client
          .from(DatabaseTables.translations)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(50);

      return response;
    } catch (e) {
      print('❌ Error fetching history: $e');
      return [];
    }
  }

  /// Detect language using Gemini
  Future<String> detectLanguage(String text) async {
    try {
      final prompt = '''
Detect the language of the following text and respond with ONLY the language code (e.g., 'en' for English, 'hi' for Hindi, 'ta' for Tamil).
Do not provide any explanation, just the two-letter language code.

Text: $text

Language code:''';

      final response = await http.post(
        Uri.parse(GeminiConfig.translateUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final detectedLang = data['candidates'][0]['content']['parts'][0]['text'].trim();
        return detectedLang;
      }

      return 'en'; // Default to English
    } catch (e) {
      print('❌ Language detection error: $e');
      return 'en';
    }
  }

  /// Translate document (file content)
  Future<String> translateDocument({
    required String content,
    required String sourceLang,
    required String targetLang,
    required String fileName,
    String? userId,
  }) async {
    try {
      Get.snackbar(
        '📄 Translating Document',
        'Processing $fileName...',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );

      final result = await translateText(
        text: content,
        sourceLang: sourceLang,
        targetLang: targetLang,
        userId: userId,
      );

      return result;
    } catch (e) {
      throw Exception('Document translation failed: $e');
    }
  }

  /// Batch translate multiple texts
  Future<List<String>> batchTranslate({
    required List<String> texts,
    required String sourceLang,
    required String targetLang,
  }) async {
    final results = <String>[];

    for (int i = 0; i < texts.length; i++) {
      try {
        final result = await _translateWithGemini(
          texts[i],
          sourceLang,
          targetLang,
        );
        results.add(result);

        // Update progress
        translationProgress.value = (i + 1) / texts.length;

        // Small delay
        await Future.delayed(const Duration(milliseconds: 300));
      } catch (e) {
        results.add('Translation failed');
      }
    }

    return results;
  }

  /// Get translation suggestions
  Future<List<String>> getTranslationSuggestions(
    String text,
    String targetLang,
  ) async {
    try {
      final prompt = '''
Provide 3 different translation variations of the following text to $targetLang.
Format: One translation per line, numbered 1-3.

Text: $text

Translations:''';

      final response = await http.post(
        Uri.parse(GeminiConfig.translateUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final suggestions = data['candidates'][0]['content']['parts'][0]['text'];
        
        // Parse suggestions
        return suggestions
            .split('\n')
            .where((s) => s.trim().isNotEmpty)
            .map((s) => s.replaceAll(RegExp(r'^\d+\.\s*'), '').trim())
            .toList();
      }

      return [];
    } catch (e) {
      print('❌ Error getting suggestions: $e');
      return [];
    }
  }

  /// Clear translation history
  void clearHistory() {
    translationHistory.clear();
    translatedText.value = '';
  }

  /// Export translation history
  String exportHistory() {
    final buffer = StringBuffer();
    buffer.writeln('Translation History Export');
    buffer.writeln('Generated: ${DateTime.now()}');
    buffer.writeln('=' * 50);
    buffer.writeln();

    for (var item in translationHistory) {
      buffer.writeln('Source (${item['sourceLang']}):');
      buffer.writeln(item['sourceText']);
      buffer.writeln();
      buffer.writeln('Translation (${item['targetLang']}):');
      buffer.writeln(item['targetText']);
      buffer.writeln();
      buffer.writeln('Timestamp: ${item['timestamp']}');
      buffer.writeln('-' * 50);
      buffer.writeln();
    }

    return buffer.toString();
  }
}
