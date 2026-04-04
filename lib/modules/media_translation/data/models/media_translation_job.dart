/// Media Translation Job Model
/// 
/// Represents a single media translation job with all its data and state
library;

import 'dart:typed_data';

enum JobStatus {
  pending,
  uploading,
  extracting,
  transcribing,
  translating,
  generating,
  completed,
  failed,
}

class MediaTranslationJob {
  final String id;
  final String originalFileName;
  final String mediaType; // 'audio' or 'video'
  final String extension;
  final Uint8List? fileBytes;
  final int fileSize;
  final String sourceLanguage;
  final String targetLanguage;
  
  String? transcriptText;
  String? translatedText;
  String? subtitleContent;
  
  // Download paths/blobs
  String? transcriptDownloadPath;
  String? translationDownloadPath;
  String? subtitleDownloadPath;
  String? translatedAudioPath;
  String? processedVideoPath;
  
  JobStatus status;
  double progress; // 0.0 to 1.0
  String? errorMessage;
  
  final DateTime createdAt;
  DateTime? updatedAt;
  DateTime? completedAt;
  
  MediaTranslationJob({
    required this.id,
    required this.originalFileName,
    required this.mediaType,
    required this.extension,
    this.fileBytes,
    required this.fileSize,
    required this.sourceLanguage,
    required this.targetLanguage,
    this.transcriptText,
    this.translatedText,
    this.subtitleContent,
    this.transcriptDownloadPath,
    this.translationDownloadPath,
    this.subtitleDownloadPath,
    this.translatedAudioPath,
    this.processedVideoPath,
    this.status = JobStatus.pending,
    this.progress = 0.0,
    this.errorMessage,
    required this.createdAt,
    this.updatedAt,
    this.completedAt,
  });
  
  // Create a copy with updated fields
  MediaTranslationJob copyWith({
    String? id,
    String? originalFileName,
    String? mediaType,
    String? extension,
    Uint8List? fileBytes,
    int? fileSize,
    String? sourceLanguage,
    String? targetLanguage,
    String? transcriptText,
    String? translatedText,
    String? subtitleContent,
    String? transcriptDownloadPath,
    String? translationDownloadPath,
    String? subtitleDownloadPath,
    String? translatedAudioPath,
    String? processedVideoPath,
    JobStatus? status,
    double? progress,
    String? errorMessage,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
  }) {
    return MediaTranslationJob(
      id: id ?? this.id,
      originalFileName: originalFileName ?? this.originalFileName,
      mediaType: mediaType ?? this.mediaType,
      extension: extension ?? this.extension,
      fileBytes: fileBytes ?? this.fileBytes,
      fileSize: fileSize ?? this.fileSize,
      sourceLanguage: sourceLanguage ?? this.sourceLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      transcriptText: transcriptText ?? this.transcriptText,
      translatedText: translatedText ?? this.translatedText,
      subtitleContent: subtitleContent ?? this.subtitleContent,
      transcriptDownloadPath: transcriptDownloadPath ?? this.transcriptDownloadPath,
      translationDownloadPath: translationDownloadPath ?? this.translationDownloadPath,
      subtitleDownloadPath: subtitleDownloadPath ?? this.subtitleDownloadPath,
      translatedAudioPath: translatedAudioPath ?? this.translatedAudioPath,
      processedVideoPath: processedVideoPath ?? this.processedVideoPath,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
  
  // Convert to JSON for persistence
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'originalFileName': originalFileName,
      'mediaType': mediaType,
      'extension': extension,
      'fileSize': fileSize,
      'sourceLanguage': sourceLanguage,
      'targetLanguage': targetLanguage,
      'transcriptText': transcriptText,
      'translatedText': translatedText,
      'subtitleContent': subtitleContent,
      'transcriptDownloadPath': transcriptDownloadPath,
      'translationDownloadPath': translationDownloadPath,
      'subtitleDownloadPath': subtitleDownloadPath,
      'translatedAudioPath': translatedAudioPath,
      'processedVideoPath': processedVideoPath,
      'status': status.name,
      'progress': progress,
      'errorMessage': errorMessage,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }
  
  // Create from JSON
  factory MediaTranslationJob.fromJson(Map<String, dynamic> json) {
    return MediaTranslationJob(
      id: json['id'] as String,
      originalFileName: json['originalFileName'] as String,
      mediaType: json['mediaType'] as String,
      extension: json['extension'] as String,
      fileSize: json['fileSize'] as int,
      sourceLanguage: json['sourceLanguage'] as String,
      targetLanguage: json['targetLanguage'] as String,
      transcriptText: json['transcriptText'] as String?,
      translatedText: json['translatedText'] as String?,
      subtitleContent: json['subtitleContent'] as String?,
      transcriptDownloadPath: json['transcriptDownloadPath'] as String?,
      translationDownloadPath: json['translationDownloadPath'] as String?,
      subtitleDownloadPath: json['subtitleDownloadPath'] as String?,
      translatedAudioPath: json['translatedAudioPath'] as String?,
      processedVideoPath: json['processedVideoPath'] as String?,
      status: JobStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => JobStatus.pending,
      ),
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      errorMessage: json['errorMessage'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }
  
  // Get formatted file size
  String get formattedFileSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  
  // Check if job is in progress
  bool get isInProgress {
    return status == JobStatus.uploading ||
        status == JobStatus.extracting ||
        status == JobStatus.transcribing ||
        status == JobStatus.translating ||
        status == JobStatus.generating;
  }
  
  // Check if job is completed successfully
  bool get isCompleted => status == JobStatus.completed;
  
  // Check if job has failed
  bool get isFailed => status == JobStatus.failed;
  
  // Get status display text
  String get statusText {
    switch (status) {
      case JobStatus.pending:
        return 'Pending';
      case JobStatus.uploading:
        return 'Uploading...';
      case JobStatus.extracting:
        return 'Extracting Audio...';
      case JobStatus.transcribing:
        return 'Transcribing...';
      case JobStatus.translating:
        return 'Translating...';
      case JobStatus.generating:
        return 'Generating Files...';
      case JobStatus.completed:
        return 'Completed';
      case JobStatus.failed:
        return 'Failed';
    }
  }
}
