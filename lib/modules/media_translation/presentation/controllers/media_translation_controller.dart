/// Media Translation Controller
/// 
/// GetX controller for managing media translation state and operations
/// Uses backend server for all Hugging Face API calls
library;

import 'dart:convert';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/media_translation_job.dart';
import '../../data/services/media_translation_api_client.dart';
import '../../data/services/backend_media_orchestrator.dart';

class MediaTranslationController extends GetxController {
  // Services
  late final MediaTranslationApiClient _apiClient;
  late final BackendMediaOrchestrator _orchestrator;
  
  // State
  final RxBool isLoading = false.obs;
  final RxString currentStep = ''.obs;
  final RxDouble progress = 0.0.obs;
  final Rx<MediaTranslationJob?> currentJob = Rx<MediaTranslationJob?>(null);
  final RxList<MediaTranslationJob> history = <MediaTranslationJob>[].obs;
  final RxString errorMessage = ''.obs;
  final RxBool backendAvailable = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    _initializeServices();
    _loadHistory();
    _checkBackendHealth();
  }
  
  void _initializeServices() {
    _apiClient = MediaTranslationApiClient();
    _orchestrator = BackendMediaOrchestrator(
      apiClient: _apiClient,
    );
  }
  
  /// Check if backend server is available
  Future<void> _checkBackendHealth() async {
    try {
      backendAvailable.value = await _orchestrator.checkBackendHealth();
      if (!backendAvailable.value) {
        Get.snackbar(
          '⚠️ Backend Unavailable',
          'Media translation backend is not running. Please start the backend server.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 5),
        );
      }
    } catch (e) {
      backendAvailable.value = false;
    }
  }

  
  /// Load job history from local storage
  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString('media_translation_history');
      
      if (historyJson != null && historyJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(historyJson);
        history.value = decoded
            .map((json) => MediaTranslationJob.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      print('Error loading history: $e');
    }
  }
  
  /// Save job history to local storage
  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = jsonEncode(
        history.map((job) => job.toJson()).toList(),
      );
      await prefs.setString('media_translation_history', historyJson);
    } catch (e) {
      print('Error saving history: $e');
    }
  }
  
  /// Start a new translation job
  Future<void> startTranslation({
    required String fileName,
    required Uint8List fileBytes,
    required int fileSize,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      // Determine media type
      final mediaType = _orchestrator.getMediaType(fileName);
      final extension = fileName.split('.').last;
      
      // Validate file
      if (!_orchestrator.validateFile(fileName, fileSize, mediaType)) {
        throw Exception('Invalid file: size exceeds limit or unsupported format');
      }
      
      // Create new job
      final job = MediaTranslationJob(
        id: 'JOB_${DateTime.now().millisecondsSinceEpoch}',
        originalFileName: fileName,
        mediaType: mediaType,
        extension: extension,
        fileBytes: fileBytes,
        fileSize: fileSize,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
        createdAt: DateTime.now(),
      );
      
      currentJob.value = job;
      
      // Process the job
      final completedJob = await _orchestrator.processJob(
        job,
        (updatedJob) {
          currentJob.value = updatedJob;
          currentStep.value = updatedJob.statusText;
          progress.value = updatedJob.progress;
        },
      );
      
      // Add to history
      history.insert(0, completedJob);
      await _saveHistory();
      
      Get.snackbar(
        '✅ Success',
        'Translation completed successfully!',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        '❌ Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Clear current job
  void clearCurrentJob() {
    currentJob.value = null;
    currentStep.value = '';
    progress.value = 0.0;
    errorMessage.value = '';
  }
  
  /// Delete a job from history
  Future<void> deleteJob(String jobId) async {
    history.removeWhere((job) => job.id == jobId);
    await _saveHistory();
  }
  
  /// Clear all history
  Future<void> clearHistory() async {
    history.clear();
    await _saveHistory();
  }
  
  /// Get job by ID
  MediaTranslationJob? getJobById(String jobId) {
    try {
      return history.firstWhere((job) => job.id == jobId);
    } catch (e) {
      return null;
    }
  }
}
