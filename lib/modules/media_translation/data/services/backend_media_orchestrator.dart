/// Backend Media Translation Orchestrator
/// 
/// Orchestrates media translation through backend server
/// Replaces direct Hugging Face API calls
library;

import 'dart:typed_data';
import '../models/media_translation_job.dart';
import 'media_translation_api_client.dart';
import '../../../../utils/media_translation_constants.dart';

class BackendMediaOrchestrator {
  final MediaTranslationApiClient _apiClient;
  
  BackendMediaOrchestrator({
    required MediaTranslationApiClient apiClient,
  }) : _apiClient = apiClient;
  
  /// Process a media translation job through backend
  /// 
  /// This sends the file to the backend server which handles:
  /// - Hugging Face Whisper transcription
  /// - Hugging Face NLLB translation
  /// - Subtitle generation
  /// - File storage
  Future<MediaTranslationJob> processJob(
    MediaTranslationJob job,
    Function(MediaTranslationJob) onUpdate,
  ) async {
    MediaTranslationJob currentJob = job;
    
    try {
      // Step 1: Uploading
      currentJob = currentJob.copyWith(
        status: JobStatus.uploading,
        progress: 0.1,
        updatedAt: DateTime.now(),
      );
      onUpdate(currentJob);
      
      // Step 2: Send to backend for processing
      currentJob = currentJob.copyWith(
        status: JobStatus.transcribing,
        progress: 0.3,
        updatedAt: DateTime.now(),
      );
      onUpdate(currentJob);
      
      print('🚀 Sending to backend for processing...');
      
      // Call backend API
      final result = await _apiClient.processMedia(
        fileBytes: currentJob.fileBytes!,
        fileName: currentJob.originalFileName,
        sourceLanguage: currentJob.sourceLanguage,
        targetLanguage: currentJob.targetLanguage,
        mediaType: currentJob.mediaType,
      );
      
      // Check if successful
      if (result['success'] != true) {
        throw Exception(result['error'] ?? 'Processing failed');
      }
      
      // Extract results
      final transcript = result['transcript'] as String?;
      final translation = result['translation'] as String?;
      final subtitleContent = result['subtitleContent'] as String?;
      final downloads = result['downloads'] as Map<String, dynamic>?;
      final jobId = result['jobId'] as String?;
      
      // Update progress
      currentJob = currentJob.copyWith(
        status: JobStatus.generating,
        progress: 0.9,
        transcriptText: transcript,
        translatedText: translation,
        subtitleContent: subtitleContent,
        updatedAt: DateTime.now(),
      );
      onUpdate(currentJob);
      
      // Set download paths
      String? transcriptPath;
      String? translationPath;
      String? subtitlePath;
      
      if (downloads != null && jobId != null) {
        transcriptPath = downloads['transcriptTxt'] as String?;
        translationPath = downloads['translationTxt'] as String?;
        subtitlePath = downloads['subtitleSrt'] as String?;
      }
      
      // Complete
      currentJob = currentJob.copyWith(
        status: JobStatus.completed,
        progress: 1.0,
        transcriptDownloadPath: transcriptPath,
        translationDownloadPath: translationPath,
        subtitleDownloadPath: subtitlePath,
        completedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      onUpdate(currentJob);
      
      print('✅ Backend processing completed successfully');
      
      return currentJob;
    } catch (e) {
      print('❌ Backend processing failed: $e');
      
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
  
  /// Check if backend is available
  Future<bool> checkBackendHealth() async {
    return await _apiClient.checkHealth();
  }
}
