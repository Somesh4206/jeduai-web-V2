/// Job Status Card Widget
/// 
/// Displays the current translation job status with progress
library;

import 'package:flutter/material.dart';
import '../../data/models/media_translation_job.dart';

class JobStatusCard extends StatelessWidget {
  final MediaTranslationJob job;
  
  const JobStatusCard({
    super.key,
    required this.job,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // File info
            Row(
              children: [
                Icon(
                  job.mediaType == 'audio' ? Icons.audiotrack : Icons.videocam,
                  color: job.mediaType == 'audio' ? Colors.purple : Colors.pink,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.originalFileName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${job.formattedFileSize} • ${job.sourceLanguage} → ${job.targetLanguage}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Status
            Row(
              children: [
                _buildStatusIcon(job.status),
                const SizedBox(width: 8),
                Text(
                  job.statusText,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(job.status),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Progress bar
            if (job.isInProgress) ...[
              LinearProgressIndicator(
                value: job.progress,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getStatusColor(job.status),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${(job.progress * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
            
            // Error message
            if (job.isFailed && job.errorMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        job.errorMessage!,
                        style: TextStyle(
                          color: Colors.red[700],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatusIcon(JobStatus status) {
    IconData icon;
    Color color;
    
    switch (status) {
      case JobStatus.pending:
        icon = Icons.schedule;
        color = Colors.grey;
        break;
      case JobStatus.uploading:
      case JobStatus.extracting:
      case JobStatus.transcribing:
      case JobStatus.translating:
      case JobStatus.generating:
        icon = Icons.sync;
        color = Colors.blue;
        break;
      case JobStatus.completed:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case JobStatus.failed:
        icon = Icons.error;
        color = Colors.red;
        break;
    }
    
    return Icon(icon, color: color, size: 20);
  }
  
  Color _getStatusColor(JobStatus status) {
    switch (status) {
      case JobStatus.pending:
        return Colors.grey;
      case JobStatus.uploading:
      case JobStatus.extracting:
      case JobStatus.transcribing:
      case JobStatus.translating:
      case JobStatus.generating:
        return Colors.blue;
      case JobStatus.completed:
        return Colors.green;
      case JobStatus.failed:
        return Colors.red;
    }
  }
}
