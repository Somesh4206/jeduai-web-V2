import 'dart:io';
import 'package:get/get.dart';
import 'huggingface_translation_service.dart';
import 'groq_audio_translation_service.dart';

/// Service for transcribing actual audio/video files
/// Uses real audio content, NOT generated/narrated content
class AudioVideoTranscriptionService extends GetxService {
  static AudioVideoTranscriptionService get instance => Get.find();

  final RxBool isProcessing = false.obs;
  final RxString currentStep = ''.obs;
  final RxDouble progress = 0.0.obs;

  /// Transcribe actual audio from file using Whisper
  /// This extracts REAL speech from the audio, not generated content
  Future<TranscriptionResult> transcribeAudioFile({
    required File audioFile,
    String? sourceLanguage,
  }) async {
    isProcessing.value = true;
    progress.value = 0.0;
    currentStep.value = 'Preparing audio file...';

    try {
      // Verify file exists
      if (!await audioFile.exists()) {
        throw Exception('Audio file not found: ${audioFile.path}');
      }

      currentStep.value = 'Transcribing actual audio content...';
      progress.value = 0.2;

      // Try Hugging Face Whisper first (better for multilingual)
      try {
        final hfService = Get.find<HuggingFaceTranslationService>();
        final result = await hfService.transcribeAudio(
          audioFile: audioFile,
          language: sourceLanguage,
        );

        if (result.success && result.transcription.isNotEmpty) {
          currentStep.value = 'Transcription complete!';
          progress.value = 1.0;
          
          return TranscriptionResult(
            success: true,
            transcription: result.transcription,
            source: 'Hugging Face Whisper',
          );
        }
      } catch (e) {
        print('Hugging Face transcription failed: $e');
        currentStep.value = 'Trying alternative transcription service...';
      }

      // Fallback to Groq Whisper
      try {
        final groqService = Get.find<GroqAudioTranslationService>();
        final result = await groqService.transcribeAudio(
          audioFile: audioFile,
          language: sourceLanguage,
        );

        if (result.success && result.transcription.isNotEmpty) {
          currentStep.value = 'Transcription complete!';
          progress.value = 1.0;
          
          return TranscriptionResult(
            success: true,
            transcription: result.transcription,
            source: 'Groq Whisper',
          );
        }
      } catch (e) {
        print('Groq transcription failed: $e');
      }

      throw Exception('All transcription services failed. Please check audio quality and format.');
      
    } catch (e) {
      currentStep.value = 'Error: $e';
      return TranscriptionResult(
        success: false,
        error: e.toString(),
        transcription: '',
        source: 'None',
      );
    } finally {
      isProcessing.value = false;
    }
  }

  /// Transcribe video file by extracting audio
  /// This uses REAL video audio, not generated content
  Future<TranscriptionResult> transcribeVideoFile({
    required File videoFile,
    String? sourceLanguage,
  }) async {
    isProcessing.value = true;
    progress.value = 0.0;
    currentStep.value = 'Extracting audio from video...';

    try {
      // Verify file exists
      if (!await videoFile.exists()) {
        throw Exception('Video file not found: ${videoFile.path}');
      }

      // Note: For proper video audio extraction, you would need ffmpeg
      // For now, we'll attempt to transcribe the video file directly
      // Many transcription APIs can handle video files directly
      
      currentStep.value = 'Transcribing video audio...';
      progress.value = 0.2;

      // Try transcribing video file directly
      final result = await transcribeAudioFile(
        audioFile: videoFile,
        sourceLanguage: sourceLanguage,
      );

      return result;
      
    } catch (e) {
      currentStep.value = 'Error: $e';
      return TranscriptionResult(
        success: false,
        error: e.toString(),
        transcription: '',
        source: 'None',
      );
    } finally {
      isProcessing.value = false;
    }
  }

  /// Validate audio file format
  bool isValidAudioFormat(String filePath) {
    final validFormats = [
      '.mp3', '.wav', '.m4a', '.flac', '.ogg', 
      '.aac', '.wma', '.opus'
    ];
    
    final extension = filePath.toLowerCase().substring(filePath.lastIndexOf('.'));
    return validFormats.contains(extension);
  }

  /// Validate video file format
  bool isValidVideoFormat(String filePath) {
    final validFormats = [
      '.mp4', '.avi', '.mov', '.mkv', '.webm', 
      '.flv', '.wmv', '.m4v'
    ];
    
    final extension = filePath.toLowerCase().substring(filePath.lastIndexOf('.'));
    return validFormats.contains(extension);
  }

  /// Get file size in MB
  Future<double> getFileSizeMB(File file) async {
    final bytes = await file.length();
    return bytes / (1024 * 1024);
  }

  /// Check if file is too large for transcription
  Future<bool> isFileTooLarge(File file, {double maxSizeMB = 25}) async {
    final sizeMB = await getFileSizeMB(file);
    return sizeMB > maxSizeMB;
  }
}

/// Result of audio/video transcription
class TranscriptionResult {
  final bool success;
  final String? error;
  final String transcription;
  final String source; // Which service was used

  TranscriptionResult({
    required this.success,
    this.error,
    required this.transcription,
    required this.source,
  });
}
