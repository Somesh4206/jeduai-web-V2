/// Hugging Face Media Translation API Service
/// 
/// Handles all API calls to Hugging Face Inference API for:
/// - Speech-to-Text (Whisper)
/// - Text Translation (NLLB-200)
/// - Text-to-Speech (Optional)
library;

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../../../../utils/media_translation_constants.dart';

class HfMediaTranslationApi {
  // Hugging Face API endpoints
  static const String whisperModel = 'openai/whisper-large-v3';
  static const String nllbModel = 'facebook/nllb-200-distilled-600M';
  static const String baseUrl = 'https://api-inference.huggingface.co/models';
  
  final String _token;
  
  HfMediaTranslationApi({required String token}) : _token = token;
  
  /// Transcribe audio bytes using Whisper model
  /// 
  /// [audioBytes] - Raw audio file bytes
  /// [fileName] - Original file name for debugging
  /// [sourceLanguage] - Source language for transcription
  /// 
  /// Returns the transcribed text
  Future<String> transcribeAudioBytes(
    Uint8List audioBytes,
    String fileName,
    String sourceLanguage,
  ) async {
    if (_token.isEmpty) {
      throw Exception(MediaTranslationConstants.errorNoToken);
    }
    
    final languageCode = MediaTranslationConstants.getWhisperCode(sourceLanguage);
    final url = '$baseUrl/$whisperModel';
    
    print('🎤 Transcribing audio: $fileName (${audioBytes.length} bytes)');
    print('   Language: $sourceLanguage ($languageCode)');
    
    int retries = 0;
    while (retries < MediaTranslationConstants.maxRetries) {
      try {
        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $_token',
            'Content-Type': 'application/octet-stream',
          },
          body: audioBytes,
        ).timeout(
          Duration(seconds: MediaTranslationConstants.apiTimeout),
        );
        
        print('   Response status: ${response.statusCode}');
        
        if (response.statusCode == 200) {
          final result = jsonDecode(response.body);
          
          // Whisper returns {"text": "transcribed text"}
          if (result is Map && result.containsKey('text')) {
            final transcriptText = result['text'] as String;
            print('✅ Transcription successful: ${transcriptText.length} characters');
            return transcriptText.trim();
          } else {
            throw Exception('Unexpected response format from Whisper API');
          }
        } else if (response.statusCode == 503) {
          // Model is loading, retry after delay
          print('⏳ Model loading, retrying in ${MediaTranslationConstants.retryDelay}s...');
          await Future.delayed(Duration(seconds: MediaTranslationConstants.retryDelay));
          retries++;
          continue;
        } else if (response.statusCode == 429) {
          // Rate limit, retry with exponential backoff
          final delay = MediaTranslationConstants.retryDelay * (retries + 1);
          print('⏳ Rate limited, retrying in ${delay}s...');
          await Future.delayed(Duration(seconds: delay));
          retries++;
          continue;
        } else {
          final errorBody = response.body;
          print('❌ Transcription failed: ${response.statusCode}');
          print('   Error: $errorBody');
          throw Exception('Transcription failed: ${response.statusCode} - $errorBody');
        }
      } on TimeoutException {
        print('⏱️ Request timeout, retrying...');
        retries++;
        if (retries >= MediaTranslationConstants.maxRetries) {
          throw Exception(MediaTranslationConstants.errorTimeout);
        }
        await Future.delayed(Duration(seconds: MediaTranslationConstants.retryDelay));
      } catch (e) {
        print('❌ Transcription error: $e');
        if (retries >= MediaTranslationConstants.maxRetries - 1) {
          rethrow;
        }
        retries++;
        await Future.delayed(Duration(seconds: MediaTranslationConstants.retryDelay));
      }
    }
    
    throw Exception(MediaTranslationConstants.errorTranscriptionFailed);
  }
  
  /// Translate text using NLLB-200 model
  /// 
  /// [text] - Text to translate
  /// [sourceLanguage] - Source language
  /// [targetLanguage] - Target language
  /// 
  /// Returns the translated text
  Future<String> translateText(
    String text,
    String sourceLanguage,
    String targetLanguage,
  ) async {
    if (_token.isEmpty) {
      throw Exception(MediaTranslationConstants.errorNoToken);
    }
    
    if (text.trim().isEmpty) {
      throw Exception('Cannot translate empty text');
    }
    
    final srcCode = MediaTranslationConstants.getNllbCode(sourceLanguage);
    final tgtCode = MediaTranslationConstants.getNllbCode(targetLanguage);
    final url = '$baseUrl/$nllbModel';
    
    print('🌐 Translating text: ${text.length} characters');
    print('   $sourceLanguage ($srcCode) → $targetLanguage ($tgtCode)');
    
    int retries = 0;
    while (retries < MediaTranslationConstants.maxRetries) {
      try {
        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $_token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'inputs': text,
            'parameters': {
              'src_lang': srcCode,
              'tgt_lang': tgtCode,
            },
          }),
        ).timeout(
          Duration(seconds: MediaTranslationConstants.apiTimeout),
        );
        
        print('   Response status: ${response.statusCode}');
        
        if (response.statusCode == 200) {
          final result = jsonDecode(response.body);
          
          // NLLB returns [{"translation_text": "translated text"}]
          if (result is List && result.isNotEmpty) {
            final translatedText = result[0]['translation_text'] as String;
            print('✅ Translation successful: ${translatedText.length} characters');
            return translatedText.trim();
          } else if (result is Map && result.containsKey('translation_text')) {
            final translatedText = result['translation_text'] as String;
            print('✅ Translation successful: ${translatedText.length} characters');
            return translatedText.trim();
          } else {
            throw Exception('Unexpected response format from NLLB API');
          }
        } else if (response.statusCode == 503) {
          // Model is loading, retry after delay
          print('⏳ Model loading, retrying in ${MediaTranslationConstants.retryDelay}s...');
          await Future.delayed(Duration(seconds: MediaTranslationConstants.retryDelay));
          retries++;
          continue;
        } else if (response.statusCode == 429) {
          // Rate limit, retry with exponential backoff
          final delay = MediaTranslationConstants.retryDelay * (retries + 1);
          print('⏳ Rate limited, retrying in ${delay}s...');
          await Future.delayed(Duration(seconds: delay));
          retries++;
          continue;
        } else {
          final errorBody = response.body;
          print('❌ Translation failed: ${response.statusCode}');
          print('   Error: $errorBody');
          throw Exception('Translation failed: ${response.statusCode} - $errorBody');
        }
      } on TimeoutException {
        print('⏱️ Request timeout, retrying...');
        retries++;
        if (retries >= MediaTranslationConstants.maxRetries) {
          throw Exception(MediaTranslationConstants.errorTimeout);
        }
        await Future.delayed(Duration(seconds: MediaTranslationConstants.retryDelay));
      } catch (e) {
        print('❌ Translation error: $e');
        if (retries >= MediaTranslationConstants.maxRetries - 1) {
          rethrow;
        }
        retries++;
        await Future.delayed(Duration(seconds: MediaTranslationConstants.retryDelay));
      }
    }
    
    throw Exception(MediaTranslationConstants.errorTranslationFailed);
  }
  
  /// Synthesize translated audio (Optional - TTS)
  /// 
  /// Note: This is optional and may not be available on all platforms
  /// Returns null if TTS is not supported or fails
  Future<Uint8List?> synthesizeTranslatedAudio(
    String text,
    String targetLanguage,
  ) async {
    // TTS via Hugging Face is complex and may not work well for all languages
    // For now, we'll return null and mark this as "not available"
    // Future implementation can use models like:
    // - facebook/mms-tts-eng for English
    // - facebook/mms-tts-hin for Hindi
    // etc.
    
    print('ℹ️ TTS synthesis not implemented yet');
    return null;
  }
  
  /// Check if the API token is valid
  Future<bool> validateToken() async {
    try {
      final response = await http.get(
        Uri.parse('https://huggingface.co/api/whoami-v2'),
        headers: {
          'Authorization': 'Bearer $_token',
        },
      ).timeout(const Duration(seconds: 10));
      
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Token validation failed: $e');
      return false;
    }
  }
}
