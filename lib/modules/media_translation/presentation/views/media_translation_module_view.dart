/// Media Translation Module View
/// 
/// Main UI for the new Hugging Face-based media translation module
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import '../controllers/media_translation_controller.dart';
import '../widgets/upload_card.dart';
import '../widgets/job_status_card.dart';
import '../widgets/transcript_panel.dart';
import '../widgets/download_section.dart';
import '../../../../utils/media_translation_constants.dart';

class MediaTranslationModuleView extends StatefulWidget {
  const MediaTranslationModuleView({super.key});
  
  @override
  State<MediaTranslationModuleView> createState() => _MediaTranslationModuleViewState();
}

class _MediaTranslationModuleViewState extends State<MediaTranslationModuleView> {
  final MediaTranslationController controller = Get.put(MediaTranslationController());
  
  String sourceLanguage = 'English';
  String targetLanguage = 'Tamil';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio & Video Translation'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF9C27B0), Color(0xFFBA68C8)],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => _showHistory(),
            tooltip: 'View History',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title
            const Text(
              'Upload Media for Translation',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Powered by Hugging Face AI',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            
            // Upload cards
            Row(
              children: [
                Expanded(
                  child: UploadCard(
                    title: 'Upload Audio',
                    subtitle: 'MP3, WAV, M4A, OGG',
                    icon: Icons.audiotrack,
                    color: Colors.purple,
                    onTap: () => _pickFile('audio'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: UploadCard(
                    title: 'Upload Video',
                    subtitle: 'MP4, MOV, MKV, WEBM',
                    icon: Icons.videocam,
                    color: Colors.pink,
                    onTap: () => _pickFile('video'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Language selection
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Translation Languages',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: sourceLanguage,
                            decoration: const InputDecoration(
                              labelText: 'From',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.language),
                            ),
                            items: MediaTranslationConstants.supportedLanguages
                                .map((lang) => DropdownMenuItem(
                                      value: lang,
                                      child: Text(lang),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() => sourceLanguage = value!);
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Icon(Icons.arrow_forward, color: Colors.purple),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: targetLanguage,
                            decoration: const InputDecoration(
                              labelText: 'To',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.translate),
                            ),
                            items: MediaTranslationConstants.supportedLanguages
                                .map((lang) => DropdownMenuItem(
                                      value: lang,
                                      child: Text(lang),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() => targetLanguage = value!);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Current job status
            Obx(() {
              final job = controller.currentJob.value;
              if (job != null) {
                return Column(
                  children: [
                    JobStatusCard(job: job),
                    const SizedBox(height: 24),
                    
                    // Transcript and translation
                    if (job.transcriptText != null) ...[
                      TranscriptPanel(
                        title: 'Original Transcript',
                        content: job.transcriptText!,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    if (job.translatedText != null) ...[
                      TranscriptPanel(
                        title: 'Translated Text',
                        content: job.translatedText!,
                        color: Colors.purple,
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // Downloads
                    if (job.isCompleted) ...[
                      DownloadSection(job: job),
                      const SizedBox(height: 16),
                      
                      // Clear button
                      ElevatedButton.icon(
                        onPressed: () => controller.clearCurrentJob(),
                        icon: const Icon(Icons.clear),
                        label: const Text('Start New Translation'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[700],
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              }
              return const SizedBox.shrink();
            }),
            
            // Instructions
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        const Text(
                          'How It Works',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildStep('1', 'Upload your audio or video file'),
                    _buildStep('2', 'Select source and target languages'),
                    _buildStep('3', 'AI transcribes the audio content'),
                    _buildStep('4', 'AI translates to target language'),
                    _buildStep('5', 'Download transcript, translation, and subtitles'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Colors.purple,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
  
  Future<void> _pickFile(String type) async {
    try {
      FilePickerResult? result;
      
      if (type == 'audio') {
        result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: MediaTranslationConstants.audioExtensions,
          allowMultiple: false,
          withData: true,
        );
      } else {
        result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: MediaTranslationConstants.videoExtensions,
          allowMultiple: false,
          withData: true,
        );
      }
      
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        
        if (file.bytes == null) {
          Get.snackbar(
            '❌ Error',
            'Could not read file data',
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }
        
        // Start translation
        await controller.startTranslation(
          fileName: file.name,
          fileBytes: file.bytes!,
          fileSize: file.size,
          sourceLanguage: sourceLanguage,
          targetLanguage: targetLanguage,
        );
      }
    } catch (e) {
      Get.snackbar(
        '❌ Error',
        'Failed to pick file: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  
  void _showHistory() {
    Get.dialog(
      Dialog(
        child: Container(
          width: 600,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.history, color: Colors.purple),
                  const SizedBox(width: 8),
                  const Text(
                    'Translation History',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Obx(() {
                  if (controller.history.isEmpty) {
                    return const Center(
                      child: Text('No translation history yet'),
                    );
                  }
                  
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: controller.history.length,
                    itemBuilder: (context, index) {
                      final job = controller.history[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Icon(
                            job.mediaType == 'audio'
                                ? Icons.audiotrack
                                : Icons.videocam,
                            color: job.isCompleted
                                ? Colors.green
                                : (job.isFailed ? Colors.red : Colors.grey),
                          ),
                          title: Text(job.originalFileName),
                          subtitle: Text(
                            '${job.sourceLanguage} → ${job.targetLanguage}\n'
                            '${job.statusText}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => controller.deleteJob(job.id),
                          ),
                          onTap: () {
                            Get.back();
                            controller.currentJob.value = job;
                          },
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
