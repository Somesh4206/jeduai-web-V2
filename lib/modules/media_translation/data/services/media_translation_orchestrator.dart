/// Media Translation Orchestrator Service
/// 
/// Orchestrates the complete media translation workflow:
/// 1. Receive picked file
/// 2. Determine media type
/// 3. Extract audio (if video)
/// 4. Call HF transcription
/// 5. Call HF translation
/// 6. Build subtitles
/// 7. Create downloadable files
/// 8. Persist job history
library;

import 'dart:typed_data';
import '../models/media_translation_job.dart';
import 'hf_media_translation_api.dart';
import 'media_file_export_service.dart';
import '../../../../utils/media_translation_constants.dart';

class MediaTranslationOrchestrator {
  final HfMediaTranslationApi _api;
  final MediaFileExportService _exportService;
  
  MediaTranslationOrchestrator({
    required HfMediaTranslationApi api,
    required MediaFileExportService exportService,
  })  : _api = api,
        _exportService = exportService;

  
  /// Process a media translation job
  /// 
  /// This is the main workflow that handles the entire translation process
  Future<MediaTranslationJob> processJob(
    MediaTranslationJob job,
    Function(MediaTranslationJob) onUpdate,
  ) async {
    MediaTranslationJob currentJob = job;
    
    try {
      // Step 1: Uploading (already done, just update status)
      currentJob = currentJob.copyWith(
        status: JobStatus.uploading,
        progress: 0.1,
        updatedAt: DateTime.now(),
      );
      onUpdate(currentJob);
      
      // Step 2: Extract audio (if video)
      Uint8List audioBytes;
      if (currentJob.mediaType == 'video') {
        currentJob = currentJob.copyWith(
          status: JobStatus.extracting,
          progress: 0.2,
          updatedAt: DateTime.now(),
        );
        onUpdate(currentJob);
        
        // For web platform, we cannot easily extract audio from video
        // We'll attempt to use the video file directly with Whisper
        // Whisper can handle video files directly
        audioBytes = currentJob.fileBytes!;
      } else {
        // Audio file, use directly
        audioBytes = currentJob.fileBytes!;
      }
      
      // Step 3: Transcribe audio
      currentJob = currentJob.copyWith(
        status: JobStatus.transcribing,
        progress: 0.4,
        updatedAt: DateTime.now(),
      );
      onUpdate(currentJob);
      
      final transcriptText = await _api.transcribeAudioBytes(
        audioBytes,
        currentJob.originalFileName,
        currentJob.sourceLanguage,
      );
      
      currentJob = currentJob.copyWith(
        transcriptText: transcriptText,
        progress: 0.6,
        updatedAt: DateTime.now(),
      );
      onUpdate(currentJob);
      
      // Step 4: Translate transcript
      currentJob = currentJob.copyWith(
        status: JobStatus.translating,
        progress: 0.7,
        updatedAt: DateTime.now(),
      );
      onUpdate(currentJob);
      
      final translatedText = await _api.translateText(
        transcriptText,
        currentJob.sourceLanguage,
        currentJob.targetLanguage,
      );
      
      currentJob = currentJob.copyWith(
        translatedText: translatedText,
        progress: 0.8,
        updatedAt: DateTime.now(),
      );
      onUpdate(currentJob);
      
      // Step 5: Generate output files
      currentJob = currentJob.copyWith(
        status: JobStatus.generating,
        progress: 0.9,
        updatedAt: DateTime.now(),
      );
      onUpdate(currentJob);
      
      // Generate transcript file
      final transcriptPath = await _exportService.exportTextFile(
        transcriptText,
        '${currentJob.originalFileName}_transcript.txt',
      );
      
      // Generate translation file
      final translationPath = await _exportService.exportTextFile(
        translatedText,
        '${currentJob.originalFileName}_translation.txt',
      );
      
      // Generate subtitle file (for video)
      String? subtitlePath;
      String? subtitleContent;
      if (currentJob.mediaType == 'video') {
        subtitleContent = _exportService.generateSrtContent(
          transcriptText,
          translatedText,
        );
        subtitlePath = await _exportService.exportSrtFile(
          subtitleContent,
          '${currentJob.originalFileName}_subtitles.srt',
        );
      }
      
      // Step 6: Complete
      currentJob = currentJob.copyWith(
        status: JobStatus.completed,
        progress: 1.0,
        transcriptDownloadPath: transcriptPath,
        translationDownloadPath: translationPath,
        subtitleDownloadPath: subtitlePath,
        subtitleContent: subtitleContent,
        completedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      onUpdate(currentJob);
      
      return currentJob;
    } catch (e) {
      // Handle errors
      currentJob = currentJob.copyWith(
        status: JobStatus.failed,
        errorMessage: e.toString(),
        updatedAt: DateTime.now(),
      );
      onUpdate(currentJob);
      
      rethrow;
    }
  }
  
  /// Validate file before processing
  bool validateFile(String fileName, int fileSize, String mediaType) {
    // Check file size
    if (mediaType == 'audio' && fileSize > MediaTranslationConstants.maxAudioSize) {
      return false;
    }
    if (mediaType == 'video' && fileSize > MediaTranslationConstants.maxVideoSize) {
      return false;
    }
    
    // Check file extension
    final extension = fileName.split('.').last.toLowerCase();
    if (mediaType == 'audio') {
      return MediaTranslationConstants.audioExtensions.contains(extension);
    } else {
      return MediaTranslationConstants.videoExtensions.contains(extension);
    }
  }
  
  /// Get media type from file extension
  String getMediaType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    if (MediaTranslationConstants.audioExtensions.contains(extension)) {
      return 'audio';
    } else if (MediaTranslationConstants.videoExtensions.contains(extension)) {
      return 'video';
    } else {
      throw Exception('Unsupported file type');
    }
  }
}
