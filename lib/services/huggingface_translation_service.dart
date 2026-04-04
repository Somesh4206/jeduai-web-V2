import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../config/huggingface_config.dart';
import 'media_translation_service.dart';

/// Hugging Face Translation Service
/// Uses Seamless M4T V2 Large for multilingual audio/video translation
class HuggingFaceTranslationService extends GetxService {
  static HuggingFaceTranslationService get instance => Get.find();

  // Processing state
  final RxBool isProcessing = false.obs;
  final RxString currentStep = ''.obs;
  final RxDouble progress = 0.0.obs;
  final RxString lastError = ''.obs;

  // Cache for model loading
  bool _modelLoaded = false;

  /// Warm up the model (first request takes longer)
  Future<void> warmUpModel() async {
    if (_modelLoaded) return;

    try {
      currentStep.value = 'Loading translation model...';
      await translateText(
        text: 'Hello',
        sourceLanguage: 'English',
        targetLanguage: 'Hindi',
      );
      _modelLoaded = true;
    } catch (e) {
      print('Model warmup failed: $e');
    }
  }

  /// Translate text using Seamless M4T
  Future<TextTranslationResult> translateText({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    try {
      final sourceLangCode = HuggingFaceConfig.getLanguageCode(sourceLanguage);
      final targetLangCode = HuggingFaceConfig.getLanguageCode(targetLanguage);

      final response = await http.post(
        Uri.parse(HuggingFaceConfig.seamlessM4TUrl),
        headers: HuggingFaceConfig.headers,
        body: jsonEncode({
          'inputs': text,
          'parameters': {
            'src_lang': sourceLangCode,
            'tgt_lang': targetLangCode,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Handle different response formats
        String translatedText = '';
        if (data is List && data.isNotEmpty) {
          translatedText = data[0]['translation_text'] ?? 
                          data[0]['generated_text'] ?? 
                          text;
        } else if (data is Map) {
          translatedText = data['translation_text'] ?? 
                          data['generated_text'] ?? 
                          text;
        }

        return TextTranslationResult(
          success: true,
          originalText: text,
          translatedText: translatedText,
        );
      } else if (response.statusCode == 503) {
        // Model is loading
        lastError.value = 'Model is loading, please wait...';
        await Future.delayed(Duration(seconds: 20));
        return translateText(
          text: text,
          sourceLanguage: sourceLanguage,
          targetLanguage: targetLanguage,
        );
      } else {
        throw Exception('Translation failed: ${response.body}');
      }
    } catch (e) {
      lastError.value = e.toString();
      return TextTranslationResult(
        success: false,
        error: e.toString(),
        originalText: text,
        translatedText: text,
      );
    }
  }

  /// Transcribe audio using Whisper
  Future<AudioTranscriptionResult> transcribeAudio({
    required File audioFile,
    String? language,
  }) async {
    isProcessing.value = true;
    progress.value = 0.0;
    currentStep.value = 'Reading audio file...';

    try {
      // Read audio file as bytes
      final audioBytes = await audioFile.readAsBytes();
      
      currentStep.value = 'Uploading to Whisper...';
      progress.value = 0.2;

      final response = await http.post(
        Uri.parse(HuggingFaceConfig.whisperUrl),
        headers: HuggingFaceConfig.audioHeaders,
        body: audioBytes,
      );

      progress.value = 0.7;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final transcription = data['text'] ?? '';

        currentStep.value = 'Transcription complete!';
        progress.value = 1.0;

        return AudioTranscriptionResult(
          success: true,
          transcription: transcription,
        );
      } else if (response.statusCode == 503) {
        currentStep.value = 'Model loading, retrying...';
        await Future.delayed(Duration(seconds: 20));
        return transcribeAudio(audioFile: audioFile, language: language);
      } else {
        throw Exception('Transcription failed: ${response.body}');
      }
    } catch (e) {
      currentStep.value = 'Error: $e';
      lastError.value = e.toString();
      return AudioTranscriptionResult(
        success: false,
        error: e.toString(),
        transcription: '',
      );
    } finally {
      isProcessing.value = false;
    }
  }

  /// Translate audio: transcribe then translate
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
      final translationResult = await translateText(
        text: transcriptionResult.transcription,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
      );

      if (!translationResult.success) {
        throw Exception(translationResult.error);
      }

      currentStep.value = 'Translation complete!';
      progress.value = 1.0;

      return AudioTranslationResult(
        success: true,
        originalText: transcriptionResult.transcription,
        translatedText: translationResult.translatedText,
      );
    } catch (e) {
      currentStep.value = 'Error: $e';
      lastError.value = e.toString();
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

  /// Translate video content (audio extraction + translation)
  Future<VideoTranslationResult> translateVideo({
    required File videoFile,
    required String sourceLanguage,
    required String targetLanguage,
    Duration? videoDuration,
  }) async {
    isProcessing.value = true;
    progress.value = 0.0;

    try {
      currentStep.value = 'Processing video...';
      
      // Note: In a real implementation, you would extract audio from video
      // For now, we'll work with the assumption that audio is provided separately
      // or use a video processing library
      
      currentStep.value = 'Extracting audio from video...';
      progress.value = 0.1;

      // TODO: Extract audio from video file
      // For now, treat video file as audio
      
      currentStep.value = 'Transcribing audio...';
      progress.value = 0.2;

      final transcriptionResult = await transcribeAudio(
        audioFile: videoFile,
        language: sourceLanguage,
      );

      if (!transcriptionResult.success) {
        throw Exception(transcriptionResult.error);
      }

      progress.value = 0.6;

      currentStep.value = 'Translating content...';
      final translationResult = await translateText(
        text: transcriptionResult.transcription,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
      );

      if (!translationResult.success) {
        throw Exception(translationResult.error);
      }

      progress.value = 0.9;

      // Generate subtitles
      currentStep.value = 'Generating subtitles...';
      final subtitles = _generateSubtitles(
        translationResult.translatedText,
        videoDuration ?? Duration(minutes: 5),
      );

      currentStep.value = 'Video translation complete!';
      progress.value = 1.0;

      return VideoTranslationResult(
        success: true,
        originalText: transcriptionResult.transcription,
        translatedText: translationResult.translatedText,
        subtitles: subtitles,
      );
    } catch (e) {
      currentStep.value = 'Error: $e';
      lastError.value = e.toString();
      return VideoTranslationResult(
        success: false,
        error: e.toString(),
        originalText: '',
        translatedText: '',
        subtitles: [],
      );
    } finally {
      isProcessing.value = false;
    }
  }

  /// Generate subtitles from translated text
  List<SubtitleSegment> _generateSubtitles(
    String translatedText,
    Duration videoDuration,
  ) {
    final subtitles = <SubtitleSegment>[];
    
    // Split text into sentences
    final sentences = translatedText
        .split(RegExp(r'[।.!?]+'))
        .where((s) => s.trim().isNotEmpty)
        .toList();

    if (sentences.isEmpty) return subtitles;

    final totalSeconds = videoDuration.inSeconds;
    final secondsPerSubtitle = (totalSeconds / sentences.length).ceil();
    int currentTime = 0;

    for (int i = 0; i < sentences.length && currentTime < totalSeconds; i++) {
      final endTime = (currentTime + secondsPerSubtitle) > totalSeconds
          ? totalSeconds
          : currentTime + secondsPerSubtitle;

      subtitles.add(
        SubtitleSegment(
          index: i + 1,
          startTime: Duration(seconds: currentTime),
          endTime: Duration(seconds: endTime),
          text: sentences[i].trim(),
        ),
      );

      currentTime = endTime;
    }

    return subtitles;
  }

  /// Batch translate multiple texts
  Future<List<TextTranslationResult>> batchTranslate({
    required List<String> texts,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    final results = <TextTranslationResult>[];
    
    for (int i = 0; i < texts.length; i++) {
      progress.value = (i + 1) / texts.length;
      currentStep.value = 'Translating ${i + 1}/${texts.length}...';
      
      final result = await translateText(
        text: texts[i],
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
      );
      
      results.add(result);
      
      // Small delay to avoid rate limiting
      await Future.delayed(Duration(milliseconds: 500));
    }
    
    return results;
  }
}

/// Text translation result
class TextTranslationResult {
  final bool success;
  final String? error;
  final String originalText;
  final String translatedText;

  TextTranslationResult({
    required this.success,
    this.error,
    required this.originalText,
    required this.translatedText,
  });
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

/// Video translation result
class VideoTranslationResult {
  final bool success;
  final String? error;
  final String originalText;
  final String translatedText;
  final List<SubtitleSegment> subtitles;

  VideoTranslationResult({
    required this.success,
    this.error,
    required this.originalText,
    required this.translatedText,
    required this.subtitles,
  });
}
