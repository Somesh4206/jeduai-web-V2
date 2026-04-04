import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../config/groq_config.dart';

/// Groq Audio Translation Service
/// Uses Groq's Whisper API for audio transcription and translation
class GroqAudioTranslationService extends GetxService {
  static GroqAudioTranslationService get instance => Get.find();

  // Processing state
  final RxBool isProcessing = false.obs;
  final RxString currentStep = ''.obs;
  final RxDouble progress = 0.0.obs;

  /// Transcribe audio file using Groq Whisper
  Future<AudioTranscriptionResult> transcribeAudio({
    required File audioFile,
    String? language,
  }) async {
    isProcessing.value = true;
    progress.value = 0.0;
    currentStep.value = 'Uploading audio...';

    try {
      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(GroqConfig.transcriptionUrl),
      );

      // Add headers
      request.headers.addAll(GroqConfig.multipartHeaders);

      // Add audio file
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          audioFile.path,
        ),
      );

      // Add model
      request.fields['model'] = GroqConfig.whisperModel;

      // Add language if specified
      if (language != null) {
        request.fields['language'] = _getLanguageCode(language);
      }

      // Add response format
      request.fields['response_format'] = 'json';

      currentStep.value = 'Transcribing audio...';
      progress.value = 0.3;

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      progress.value = 0.8;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final transcription = data['text'] ?? '';

        currentStep.value = 'Transcription complete!';
        progress.value = 1.0;

        return AudioTranscriptionResult(
          success: true,
          transcription: transcription,
        );
      } else {
        throw Exception('Transcription failed: ${response.body}');
      }
    } catch (e) {
      currentStep.value = 'Error: $e';
      return AudioTranscriptionResult(
        success: false,
        error: e.toString(),
        transcription: '',
      );
    } finally {
      isProcessing.value = false;
    }
  }

  /// Translate audio: transcribe then translate text
  Future<AudioTranslationResult> translateAudio({
    required File audioFile,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    isProcessing.value = true;
    progress.value = 0.0;

    try {
      // Step 1: Transcribe audio
      currentStep.value = 'Transcribing audio...';
      final transcriptionResult = await transcribeAudio(
        audioFile: audioFile,
        language: sourceLanguage,
      );

      if (!transcriptionResult.success) {
        throw Exception(transcriptionResult.error);
      }

      progress.value = 0.5;

      // Step 2: Translate transcription
      currentStep.value = 'Translating to $targetLanguage...';
      final translatedText = await _translateText(
        text: transcriptionResult.transcription,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
      );

      currentStep.value = 'Translation complete!';
      progress.value = 1.0;

      return AudioTranslationResult(
        success: true,
        originalText: transcriptionResult.transcription,
        translatedText: translatedText,
      );
    } catch (e) {
      currentStep.value = 'Error: $e';
      return AudioTranslationResult(
        success: false,
        error: e.toString(),
        originalText: '',
        translatedText: '',
      );
    } finally {
      isProcessing.value = false;
    }
  }

  /// Translate text using Groq chat API
  Future<String> _translateText({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(GroqConfig.chatUrl),
        headers: GroqConfig.headers,
        body: jsonEncode({
          'model': GroqConfig.translationModel,
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are a professional translator. Translate accurately while maintaining natural flow. Provide ONLY the translated text.'
            },
            {
              'role': 'user',
              'content':
                  'Translate from $sourceLanguage to $targetLanguage:\n\n$text'
            }
          ],
          'temperature': 0.3,
          'max_tokens': 2048,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final translatedText =
            data['choices']?[0]?['message']?['content'] ?? '';
        return translatedText.isNotEmpty ? translatedText : text;
      }
    } catch (e) {
      // Return original if translation fails
    }

    return text;
  }

  /// Convert language name to ISO code
  String _getLanguageCode(String language) {
    final languageMap = {
      'English': 'en',
      'Hindi': 'hi',
      'Tamil': 'ta',
      'Telugu': 'te',
      'Malayalam': 'ml',
      'Bengali': 'bn',
      'Kannada': 'kn',
      'Marathi': 'mr',
      'Gujarati': 'gu',
      'Punjabi': 'pa',
      'Urdu': 'ur',
      'Spanish': 'es',
      'French': 'fr',
      'German': 'de',
      'Chinese': 'zh',
      'Japanese': 'ja',
      'Korean': 'ko',
      'Arabic': 'ar',
      'Russian': 'ru',
      'Portuguese': 'pt',
      'Italian': 'it',
    };

    return languageMap[language] ?? 'en';
  }
}

/// Audio transcription result
class AudioTranscriptionResult {
  final bool success;
  final String? error;
  final String transcription;

  AudioTranscriptionResult({
    required this.success,
    this.error,
    required this.transcription,
  });
}

/// Audio translation result
class AudioTranslationResult {
  final bool success;
  final String? error;
  final String originalText;
  final String translatedText;

  AudioTranslationResult({
    required this.success,
    this.error,
    required this.originalText,
    required this.translatedText,
  });
}
