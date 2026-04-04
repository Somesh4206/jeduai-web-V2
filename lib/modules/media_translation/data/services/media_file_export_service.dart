/// Media File Export Service
/// 
/// Handles exporting and downloading of generated files
/// Supports both web (blob download) and mobile/desktop (file save)
library;

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

class MediaFileExportService {
  /// Export text file (transcript or translation)
  /// 
  /// Returns a data URL or file path depending on platform
  Future<String> exportTextFile(String content, String fileName) async {
    try {
      final bytes = utf8.encode(content);
      
      if (kIsWeb) {
        // For web, create a data URL
        final base64Content = base64Encode(bytes);
        return 'data:text/plain;base64,$base64Content';
      } else {
        // For mobile/desktop, we'll return the content as-is
        // The actual file saving will be handled by the UI layer
        return content;
      }
    } catch (e) {
      throw Exception('Failed to export text file: $e');
    }
  }
  
  /// Export SRT subtitle file
  /// 
  /// Returns a data URL or file path depending on platform
  Future<String> exportSrtFile(String srtContent, String fileName) async {
    try {
      final bytes = utf8.encode(srtContent);
      
      if (kIsWeb) {
        // For web, create a data URL
        final base64Content = base64Encode(bytes);
        return 'data:text/srt;base64,$base64Content';
      } else {
        // For mobile/desktop, return content
        return srtContent;
      }
    } catch (e) {
      throw Exception('Failed to export SRT file: $e');
    }
  }
  
  /// Export binary file (audio/video)
  /// 
  /// Returns a data URL or file path depending on platform
  Future<String> exportBinaryFile(
    Uint8List bytes,
    String fileName,
    String mimeType,
  ) async {
    try {
      if (kIsWeb) {
        // For web, create a blob URL
        final base64Content = base64Encode(bytes);
        return 'data:$mimeType;base64,$base64Content';
      } else {
        // For mobile/desktop, we'll need to save to a file
        // This will be handled by the UI layer with path_provider
        throw Exception('Binary file export not implemented for mobile/desktop');
      }
    } catch (e) {
      throw Exception('Failed to export binary file: $e');
    }
  }
  
  /// Generate SRT subtitle content from transcript and translation
  /// 
  /// Creates subtitle chunks with timestamps
  String generateSrtContent(
    String originalText,
    String translatedText, {
    int wordsPerSubtitle = 10,
    double secondsPerWord = 0.4,
  }) {
    final translatedWords = translatedText.split(' ');
    final subtitles = <String>[];
    
    int index = 1;
    double currentTime = 0.0;
    
    for (int i = 0; i < translatedWords.length; i += wordsPerSubtitle) {
      final endIndex = (i + wordsPerSubtitle < translatedWords.length)
          ? i + wordsPerSubtitle
          : translatedWords.length;
      
      final chunk = translatedWords.sublist(i, endIndex).join(' ');
      final duration = (endIndex - i) * secondsPerWord;
      
      final startTime = _formatSrtTime(currentTime);
      final endTime = _formatSrtTime(currentTime + duration);
      
      subtitles.add('$index\n$startTime --> $endTime\n$chunk\n');
      
      index++;
      currentTime += duration;
    }
    
    return subtitles.join('\n');
  }
  
  /// Format time for SRT format (HH:MM:SS,mmm)
  String _formatSrtTime(double seconds) {
    final hours = (seconds / 3600).floor();
    final minutes = ((seconds % 3600) / 60).floor();
    final secs = (seconds % 60).floor();
    final millis = ((seconds % 1) * 1000).floor();
    
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${secs.toString().padLeft(2, '0')},'
        '${millis.toString().padLeft(3, '0')}';
  }
  
  /// Trigger download in web browser
  /// 
  /// This uses JavaScript to create a download link and click it
  void triggerWebDownload(String dataUrl, String fileName) {
    if (!kIsWeb) {
      throw Exception('Web download only available on web platform');
    }
    
    // This will be handled by the UI layer using html package
    // We'll provide the data URL and filename
  }
  
  /// Get MIME type from file extension
  String getMimeType(String extension) {
    switch (extension.toLowerCase()) {
      case 'mp3':
        return 'audio/mpeg';
      case 'wav':
        return 'audio/wav';
      case 'm4a':
        return 'audio/mp4';
      case 'ogg':
        return 'audio/ogg';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      case 'mkv':
        return 'video/x-matroska';
      case 'webm':
        return 'video/webm';
      case 'txt':
        return 'text/plain';
      case 'srt':
        return 'text/srt';
      default:
        return 'application/octet-stream';
    }
  }
}
