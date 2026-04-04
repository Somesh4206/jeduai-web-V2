import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../config/gemini_config.dart';
import 'gemini_translation_service.dart';

/// Enhanced Translation Service with Advanced Features
class EnhancedTranslationService extends GetxService {
  final baseService = Get.find<GeminiTranslationService>();

  // Observable states
  final isProcessing = false.obs;
  final suggestions = <String>[].obs;
  final contextualTranslations = <Map<String, dynamic>>[].obs;

  /// Translate with context awareness
  Future<Map<String, dynamic>> translateWithContext({
    required String text,
    required String sourceLang,
    required String targetLang,
    String? context,
    String? tone,
  }) async {
    try {
      isProcessing.value = true;

      final prompt =
          '''
Translate the following text from ${_getLanguageName(sourceLang)} to ${_getLanguageName(targetLang)}.

${context != null ? 'Context: $context\n' : ''}
${tone != null ? 'Tone: $tone (formal/informal/casual/professional)\n' : ''}

Provide:
1. Main translation
2. Alternative translation
3. Literal translation
4. Cultural notes (if applicable)

Format as JSON:
{
  "main": "main translation",
  "alternative": "alternative translation",
  "literal": "literal translation",
  "notes": "cultural or contextual notes"
}

Text: $text
''';

      final response = await _callGeminiAPI(prompt);

      // Parse JSON response
      try {
        final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(response);
        if (jsonMatch != null) {
          final jsonStr = jsonMatch.group(0)!;
          return jsonDecode(jsonStr);
        }
      } catch (e) {
        // Fallback to simple translation
      }

      return {'main': response, 'alternative': '', 'literal': '', 'notes': ''};
    } finally {
      isProcessing.value = false;
    }
  }

  /// Get multiple translation suggestions
  Future<List<String>> getMultipleSuggestions({
    required String text,
    required String sourceLang,
    required String targetLang,
    int count = 5,
  }) async {
    try {
      isProcessing.value = true;

      final prompt =
          '''
Provide $count different translation variations of the following text from ${_getLanguageName(sourceLang)} to ${_getLanguageName(targetLang)}.

Each variation should have a different style or formality level:
1. Formal/Professional
2. Casual/Conversational
3. Literary/Poetic
4. Simple/Direct
5. Detailed/Explanatory

Format: One translation per line, numbered.

Text: $text

Translations:
''';

      final response = await _callGeminiAPI(prompt);

      // Parse numbered list
      final lines = response
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .map((line) => line.replaceAll(RegExp(r'^\d+\.\s*'), '').trim())
          .where((line) => line.isNotEmpty)
          .toList();

      suggestions.value = lines;
      return lines;
    } finally {
      isProcessing.value = false;
    }
  }

  /// Translate with grammar explanation
  Future<Map<String, dynamic>> translateWithGrammar({
    required String text,
    required String sourceLang,
    required String targetLang,
  }) async {
    try {
      isProcessing.value = true;

      final prompt =
          '''
Translate the following text from ${_getLanguageName(sourceLang)} to ${_getLanguageName(targetLang)} and provide grammar explanation.

Provide:
1. Translation
2. Word-by-word breakdown
3. Grammar structure explanation
4. Key grammar points

Format as JSON:
{
  "translation": "translated text",
  "breakdown": "word-by-word explanation",
  "structure": "grammar structure",
  "keyPoints": ["point 1", "point 2"]
}

Text: $text
''';

      final response = await _callGeminiAPI(prompt);

      try {
        final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(response);
        if (jsonMatch != null) {
          return jsonDecode(jsonMatch.group(0)!);
        }
      } catch (e) {
        // Fallback
      }

      return {
        'translation': response,
        'breakdown': '',
        'structure': '',
        'keyPoints': [],
      };
    } finally {
      isProcessing.value = false;
    }
  }

  /// Translate idioms and phrases
  Future<Map<String, dynamic>> translateIdiom({
    required String idiom,
    required String sourceLang,
    required String targetLang,
  }) async {
    try {
      isProcessing.value = true;

      final prompt =
          '''
Translate the following idiom/phrase from ${_getLanguageName(sourceLang)} to ${_getLanguageName(targetLang)}.

Provide:
1. Equivalent idiom in target language (if exists)
2. Literal translation
3. Meaning explanation
4. Usage example in target language

Format as JSON:
{
  "equivalent": "equivalent idiom",
  "literal": "literal translation",
  "meaning": "explanation",
  "example": "usage example"
}

Idiom: $idiom
''';

      final response = await _callGeminiAPI(prompt);

      try {
        final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(response);
        if (jsonMatch != null) {
          return jsonDecode(jsonMatch.group(0)!);
        }
      } catch (e) {
        // Fallback
      }

      return {
        'equivalent': response,
        'literal': '',
        'meaning': '',
        'example': '',
      };
    } finally {
      isProcessing.value = false;
    }
  }

  /// Translate with pronunciation guide
  Future<Map<String, dynamic>> translateWithPronunciation({
    required String text,
    required String sourceLang,
    required String targetLang,
  }) async {
    try {
      isProcessing.value = true;

      final prompt =
          '''
Translate the following text from ${_getLanguageName(sourceLang)} to ${_getLanguageName(targetLang)} and provide pronunciation guide.

Provide:
1. Translation
2. Romanization/Transliteration
3. Pronunciation guide (IPA if applicable)
4. Audio description

Format as JSON:
{
  "translation": "translated text",
  "romanization": "romanized text",
  "pronunciation": "pronunciation guide",
  "audioTips": "how to pronounce"
}

Text: $text
''';

      final response = await _callGeminiAPI(prompt);

      try {
        final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(response);
        if (jsonMatch != null) {
          return jsonDecode(jsonMatch.group(0)!);
        }
      } catch (e) {
        // Fallback
      }

      return {
        'translation': response,
        'romanization': '',
        'pronunciation': '',
        'audioTips': '',
      };
    } finally {
      isProcessing.value = false;
    }
  }

  /// Translate conversation/dialogue
  Future<List<Map<String, String>>> translateConversation({
    required List<String> messages,
    required String sourceLang,
    required String targetLang,
    bool maintainContext = true,
  }) async {
    try {
      isProcessing.value = true;

      final results = <Map<String, String>>[];
      String conversationContext = '';

      for (int i = 0; i < messages.length; i++) {
        final message = messages[i];

        final prompt =
            '''
Translate the following message from ${_getLanguageName(sourceLang)} to ${_getLanguageName(targetLang)}.

${maintainContext && conversationContext.isNotEmpty ? 'Previous conversation context:\n$conversationContext\n' : ''}

Message: $message

Translation:
''';

        final translation = await _callGeminiAPI(prompt);

        results.add({'original': message, 'translated': translation.trim()});

        // Update context
        if (maintainContext) {
          conversationContext +=
              'Original: $message\nTranslated: ${translation.trim()}\n';
        }

        // Small delay to avoid rate limiting
        if (i < messages.length - 1) {
          await Future.delayed(const Duration(milliseconds: 300));
        }
      }

      return results;
    } finally {
      isProcessing.value = false;
    }
  }

  /// Translate technical/specialized text
  Future<Map<String, dynamic>> translateTechnical({
    required String text,
    required String sourceLang,
    required String targetLang,
    required String domain, // e.g., 'medical', 'legal', 'technical', 'academic'
  }) async {
    try {
      isProcessing.value = true;

      final prompt =
          '''
Translate the following $domain text from ${_getLanguageName(sourceLang)} to ${_getLanguageName(targetLang)}.

Use appropriate $domain terminology and maintain technical accuracy.

Provide:
1. Translation
2. Key technical terms with explanations
3. Alternative technical terms (if applicable)

Format as JSON:
{
  "translation": "translated text",
  "technicalTerms": {"term1": "explanation1", "term2": "explanation2"},
  "alternatives": ["alternative 1", "alternative 2"]
}

Text: $text
''';

      final response = await _callGeminiAPI(prompt);

      try {
        final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(response);
        if (jsonMatch != null) {
          return jsonDecode(jsonMatch.group(0)!);
        }
      } catch (e) {
        // Fallback
      }

      return {
        'translation': response,
        'technicalTerms': {},
        'alternatives': [],
      };
    } finally {
      isProcessing.value = false;
    }
  }

  /// Translate and summarize long text
  Future<Map<String, dynamic>> translateAndSummarize({
    required String text,
    required String sourceLang,
    required String targetLang,
    int summaryLength = 100, // words
  }) async {
    try {
      isProcessing.value = true;

      final prompt =
          '''
Translate the following text from ${_getLanguageName(sourceLang)} to ${_getLanguageName(targetLang)}.

Then provide:
1. Full translation
2. Summary (approximately $summaryLength words)
3. Key points (bullet points)

Format as JSON:
{
  "fullTranslation": "complete translation",
  "summary": "concise summary",
  "keyPoints": ["point 1", "point 2", "point 3"]
}

Text: $text
''';

      final response = await _callGeminiAPI(prompt);

      try {
        final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(response);
        if (jsonMatch != null) {
          return jsonDecode(jsonMatch.group(0)!);
        }
      } catch (e) {
        // Fallback
      }

      return {'fullTranslation': response, 'summary': '', 'keyPoints': []};
    } finally {
      isProcessing.value = false;
    }
  }

  /// Compare translations from multiple approaches
  Future<Map<String, String>> compareTranslations({
    required String text,
    required String sourceLang,
    required String targetLang,
  }) async {
    try {
      isProcessing.value = true;

      final prompt =
          '''
Translate the following text from ${_getLanguageName(sourceLang)} to ${_getLanguageName(targetLang)} using different approaches:

1. Literal translation (word-for-word)
2. Natural translation (idiomatic)
3. Formal translation (professional)
4. Casual translation (conversational)

Format as JSON:
{
  "literal": "literal translation",
  "natural": "natural translation",
  "formal": "formal translation",
  "casual": "casual translation"
}

Text: $text
''';

      final response = await _callGeminiAPI(prompt);

      try {
        final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(response);
        if (jsonMatch != null) {
          final Map<String, dynamic> parsed = jsonDecode(jsonMatch.group(0)!);
          return parsed.map((key, value) => MapEntry(key, value.toString()));
        }
      } catch (e) {
        // Fallback
      }

      return {'literal': response, 'natural': '', 'formal': '', 'casual': ''};
    } finally {
      isProcessing.value = false;
    }
  }

  /// Helper: Call Gemini API
  Future<String> _callGeminiAPI(String prompt) async {
    final response = await http.post(
      Uri.parse(GeminiConfig.translateUrl),
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
          'temperature': 0.4,
          'topK': 40,
          'topP': 0.95,
          'maxOutputTokens': 2048,
        },
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'].trim();
    } else {
      throw Exception('API request failed: ${response.statusCode}');
    }
  }

  /// Helper: Get language name
  String _getLanguageName(String code) {
    final lang = baseService.supportedLanguages.firstWhere(
      (l) => l['code'] == code,
      orElse: () => {'name': code},
    );
    return lang['name'] as String;
  }
}
