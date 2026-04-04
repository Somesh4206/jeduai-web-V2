/// Download Section Widget
/// 
/// Displays download buttons for generated files
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../data/models/media_translation_job.dart';

class DownloadSection extends StatelessWidget {
  final MediaTranslationJob job;
  
  const DownloadSection({
    super.key,
    required this.job,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.download, color: Colors.green[700]),
                const SizedBox(width: 8),
                const Text(
                  'Downloads',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Download buttons
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                // Transcript
                if (job.transcriptText != null)
                  _buildDownloadButton(
                    context,
                    icon: Icons.description,
                    label: 'Transcript TXT',
                    color: Colors.blue,
                    onTap: () => _showDownloadDialog(
                      context,
                      'Transcript',
                      job.transcriptText!,
                      '${job.originalFileName}_transcript.txt',
                    ),
                  ),
                
                // Translation
                if (job.translatedText != null)
                  _buildDownloadButton(
                    context,
                    icon: Icons.translate,
                    label: 'Translation TXT',
                    color: Colors.purple,
                    onTap: () => _showDownloadDialog(
                      context,
                      'Translation',
                      job.translatedText!,
                      '${job.originalFileName}_translation.txt',
                    ),
                  ),
                
                // Subtitle
                if (job.subtitleContent != null && job.mediaType == 'video')
                  _buildDownloadButton(
                    context,
                    icon: Icons.subtitles,
                    label: 'Subtitle SRT',
                    color: Colors.orange,
                    onTap: () => _showDownloadDialog(
                      context,
                      'Subtitles',
                      job.subtitleContent!,
                      '${job.originalFileName}_subtitles.srt',
                    ),
                  ),
                
                // Translated Audio (disabled - not available)
                _buildDownloadButton(
                  context,
                  icon: Icons.audiotrack,
                  label: 'Translated Audio',
                  color: Colors.grey,
                  enabled: false,
                  onTap: () {},
                ),
                
                // Video Package (disabled - not available)
                if (job.mediaType == 'video')
                  _buildDownloadButton(
                    context,
                    icon: Icons.video_library,
                    label: 'Video Package',
                    color: Colors.grey,
                    enabled: false,
                    onTap: () {},
                  ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Info message
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Translated audio and video muxing are not available on current platform. '
                      'Download transcript, translation, and subtitle files separately.',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDownloadButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return ElevatedButton.icon(
      onPressed: enabled ? onTap : null,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: enabled ? color : Colors.grey[300],
        foregroundColor: enabled ? Colors.white : Colors.grey[600],
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
  
  void _showDownloadDialog(
    BuildContext context,
    String title,
    String content,
    String fileName,
  ) {
    Get.dialog(
      AlertDialog(
        title: Text('$title: $fileName'),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: SelectableText(
              content,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: content));
              Get.back();
              Get.snackbar(
                '✅ Copied',
                'Content copied to clipboard',
                snackPosition: SnackPosition.BOTTOM,
                duration: const Duration(seconds: 2),
              );
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copy to Clipboard'),
          ),
        ],
      ),
    );
  }
}
