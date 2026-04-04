/// Media Translation API Client
/// 
/// Handles all communication with JeduAI backend server
/// NO DIRECT HUGGING FACE CALLS - All HF operations are proxied through backend
library;

import 'dart:async';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../config/backend_config.dart';
import '../models/media_translation_job.dart';

class MediaTranslationApiClient {
  /// Process media file through backend
  /// 
  /// Sends file to backend which handles:
  /// - Hugging Face Whisper transcription
  /// - Hugging Face NLLB translation
  /// - Subtitle generation
  /// - File storage
  /// 
  /// Returns job result with transcript, translation, and download links
  Future<Map<String, dynamic>> processMedia({
    required Uint8List fileBytes,
    required String fileName,
    required String sourceLanguage,
    required String targetLanguage,
    required String mediaType,
  }) async {
    try {
      print('📤 Sending file to backend: $fileName (${fileBytes.length} bytes)');
      print('   Languages: $sourceLanguage → $targetLanguage');
      
      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(BackendConfig.mediaProcessUrl),
      );
      
      // Add file
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: fileName,
        ),
      );
      
      // Add form fields
      request.fields['sourceLanguage'] = sourceLanguage;
      request.fields['targetLanguage'] = targetLanguage;
      request.fields['mediaType'] = mediaType;
      
      // Send request with timeout
      final streamedResponse = await request.send().timeout(
        Duration(seconds: BackendConfig.apiTimeout),
      );
      
      // Get response
      final response = await http.Response.fromStream(streamedResponse);
      
      print('   Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body) as Map<String, dynamic>;
        print('✅ Backend processing successful');
        return result;
      } else {
        final error = response.body;
        print('❌ Backend error: ${response.statusCode}');
        print('   Error: $error');
        throw Exception('Backend processing failed: ${response.statusCode} - $error');
      }
    } on TimeoutException {
      print('⏱️ Request timeout');
      throw Exception('Request timeout - processing took too long');
    } catch (e) {
      print('❌ API client error: $e');
      rethrow;
    }
  }
  
  /// Download file from backend
  /// 
  /// Downloads generated files (transcript, translation, subtitle)
  Future<String> downloadFile(String jobId, String filename) async {
    try {
      final url = BackendConfig.getDownloadUrl(jobId, filename);
      print('📥 Downloading: $url');
      
      final response = await http.get(Uri.parse(url)).timeout(
        Duration(seconds: BackendConfig.downloadTimeout),
      );
      
      if (response.statusCode == 200) {
        print('✅ Download successful');
        return response.body;
      } else {
        throw Exception('Download failed: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Download error: $e');
      rethrow;
    }
  }
  
  /// Check backend health
  /// 
  /// Verifies backend is running and configured
  Future<bool> checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse(BackendConfig.healthUrl),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return result['status'] == 'healthy';
      }
      return false;
    } catch (e) {
      print('❌ Health check failed: $e');
      return false;
    }
  }
}
