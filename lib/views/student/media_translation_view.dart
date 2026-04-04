import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/media_translation_service.dart';
import '../../services/real_time_translation_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'translated_video_player_view.dart';

class MediaTranslationView extends StatefulWidget {
  const MediaTranslationView({super.key});

  @override
  State<MediaTranslationView> createState() => _MediaTranslationViewState();
}

class _MediaTranslationViewState extends State<MediaTranslationView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MediaTranslationService _mediaService = Get.put(
    MediaTranslationService(),
  );

  // Text-to-Speech for voice-over playback
  final FlutterTts _flutterTts = FlutterTts();
  bool _isPlaying = false;
  String? _currentPlayingId;

  String sourceLanguage = 'English';
  String targetLanguage = 'Tamil';

  // All supported languages
  final List<String> allLanguages = RealTimeTranslationService
      .languageCodes
      .keys
      .toList();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      // setSharedInstance is not supported on web, wrap in try-catch
      await _flutterTts.setSharedInstance(true);
    } catch (e) {
      // Ignore - not supported on web platform
    }
    _flutterTts.setCompletionHandler(() {
      setState(() {
        _isPlaying = false;
        _currentPlayingId = null;
      });
    });
    _flutterTts.setErrorHandler((msg) {
      setState(() {
        _isPlaying = false;
        _currentPlayingId = null;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  // Play voice-over using Text-to-Speech
  Future<void> _playVoiceOver(MediaFile file) async {
    if (_isPlaying && _currentPlayingId == file.id) {
      // Stop if already playing this file
      await _flutterTts.stop();
      setState(() {
        _isPlaying = false;
        _currentPlayingId = null;
      });
      return;
    }

    // Stop any current playback
    await _flutterTts.stop();

    // Set language based on target language
    String languageCode = 'en-US';
    if (file.targetLanguage == 'Tamil') {
      languageCode = 'ta-IN';
    } else if (file.targetLanguage == 'Hindi') {
      languageCode = 'hi-IN';
    } else if (file.targetLanguage == 'Spanish') {
      languageCode = 'es-ES';
    } else if (file.targetLanguage == 'English') {
      languageCode = 'en-US';
    }

    await _flutterTts.setLanguage(languageCode);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    // Get the text to speak
    String textToSpeak = file.translatedText ?? 'No translation available';

    // If it's a video with subtitles, combine subtitle text
    if (file.subtitles != null && file.subtitles!.isNotEmpty) {
      textToSpeak = file.subtitles!.map((s) => s.text).join('. ');
    }

    setState(() {
      _isPlaying = true;
      _currentPlayingId = file.id;
    });

    await _flutterTts.speak(textToSpeak);
  }

  Future<void> _pickFile(String type) async {
    try {
      FilePickerResult? result;

      if (type == 'audio') {
        result = await FilePicker.platform.pickFiles(
          type: FileType.audio,
          allowMultiple: false,
        );
      } else {
        result = await FilePicker.platform.pickFiles(
          type: FileType.video,
          allowMultiple: false,
        );
      }

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        // For web, we can use the bytes directly
        String? filePath;
        if (file.bytes != null) {
          // Create a blob URL for web
          filePath = Uri.dataFromBytes(
            file.bytes!,
            mimeType: 'video/${file.extension}',
          ).toString();
        } else if (file.path != null) {
          // For mobile/desktop, use the file path
          filePath = file.path;
        }

        final mediaFile = MediaFile(
          id: 'MEDIA_${DateTime.now().millisecondsSinceEpoch}',
          name: file.name,
          type: type,
          format: file.extension ?? file.name.split('.').last,
          uploadedAt: DateTime.now(),
          size: file.size,
          filePath: filePath,
          fileBytes: file.bytes,
        );

        await _mediaService.addFile(mediaFile);

        Get.snackbar(
          '✅ Success',
          'File "${file.name}" uploaded successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          icon: const Icon(Icons.check_circle, color: Colors.white),
        );
      }
    } catch (e) {
      Get.snackbar(
        '❌ Error',
        'Failed to upload file. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.error, color: Colors.white),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Media Translation'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF9C27B0), Color(0xFFBA68C8)],
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.upload_file), text: 'Upload'),
            Tab(icon: Icon(Icons.folder), text: 'My Files'),
            Tab(icon: Icon(Icons.download), text: 'Translated'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUploadTab(),
          _buildMyFilesTab(),
          _buildTranslatedTab(),
        ],
      ),
    );
  }

  Widget _buildUploadTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Upload Audio Card
          Card(
            elevation: 4,
            child: InkWell(
              onTap: () => _pickFile('audio'),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple.shade400, Colors.purple.shade600],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(Icons.audiotrack, size: 64, color: Colors.white),
                    const SizedBox(height: 16),
                    const Text(
                      'Upload Audio File',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'MP3, WAV, M4A, OGG files',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Upload Video Card
          Card(
            elevation: 4,
            child: InkWell(
              onTap: () => _pickFile('video'),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.pink.shade400, Colors.pink.shade600],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(Icons.videocam, size: 64, color: Colors.white),
                    const SizedBox(height: 16),
                    const Text(
                      'Upload Video File',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'MP4, AVI, MOV, MKV files',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Instructions
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue),
                      const SizedBox(width: 8),
                      const Text(
                        'How it works',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInstructionStep('1', 'Upload your audio or video file'),
                  _buildInstructionStep('2', 'Go to "My Files" tab'),
                  _buildInstructionStep(
                    '3',
                    'Select source and target language',
                  ),
                  _buildInstructionStep('4', 'Click "Translate" button'),
                  _buildInstructionStep('5', 'Download from "Translated" tab'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
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

  Widget _buildMyFilesTab() {
    return Obx(() {
      if (_mediaService.uploadedFiles.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.folder_open, size: 80, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'No files uploaded yet',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () => _tabController.animateTo(0),
                icon: const Icon(Icons.upload),
                label: const Text('Upload Files'),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _mediaService.uploadedFiles.length,
        itemBuilder: (context, index) {
          final file = _mediaService.uploadedFiles[index];
          return _buildFileCard(file);
        },
      );
    });
  }

  Widget _buildFileCard(MediaFile file) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: file.type == 'audio'
                        ? Colors.purple.shade100
                        : Colors.pink.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    file.type == 'audio' ? Icons.audiotrack : Icons.videocam,
                    color: file.type == 'audio' ? Colors.purple : Colors.pink,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        file.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${file.format.toUpperCase()} • ${file.sizeFormatted}',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                if (file.isTranslated)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Translated',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
              ],
            ),
            if (!file.isTranslated) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: sourceLanguage,
                      decoration: const InputDecoration(
                        labelText: 'From Language',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        prefixIcon: Icon(Icons.language),
                      ),
                      isExpanded: true,
                      items: allLanguages
                          .map(
                            (lang) => DropdownMenuItem(
                              value: lang,
                              child: Text(
                                lang,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() => sourceLanguage = value!);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Colors.purple,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: targetLanguage,
                      decoration: const InputDecoration(
                        labelText: 'To Language',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        prefixIcon: Icon(Icons.translate),
                      ),
                      isExpanded: true,
                      items: allLanguages
                          .map(
                            (lang) => DropdownMenuItem(
                              value: lang,
                              child: Text(
                                lang,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() => targetLanguage = value!);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showTranslateOptions(
                        file,
                        sourceLanguage,
                        targetLanguage,
                      ),
                      icon: const Icon(Icons.translate),
                      label: const Text('Translate'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _showDeleteDialog(file.id),
                    icon: const Icon(Icons.delete, color: Colors.red),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTranslatedTab() {
    return Obx(() {
      print('Translated files count: ${_mediaService.translatedFiles.length}');

      if (_mediaService.translatedFiles.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.download_done, size: 80, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'No translated files yet',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  // Reload files from storage
                  _mediaService.loadFiles();
                  Get.snackbar(
                    'Refreshed',
                    'Files reloaded from storage',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _mediaService.translatedFiles.length,
        itemBuilder: (context, index) {
          final file = _mediaService.translatedFiles[index];
          print(
            'Translated file $index: ${file.name}, hasSubtitles: ${file.hasSubtitles}, type: ${file.type}',
          );
          return _buildTranslatedFileCard(file);
        },
      );
    });
  }

  Widget _buildTranslatedFileCard(MediaFile file) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.check_circle, color: Colors.green),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        file.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${file.sourceLanguage} → ${file.targetLanguage}',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      if (file.hasSubtitles || file.hasVoiceOver) ...[
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 4,
                          children: [
                            if (file.hasSubtitles)
                              Chip(
                                label: const Text(
                                  'Subtitles',
                                  style: TextStyle(fontSize: 10),
                                ),
                                backgroundColor: Colors.blue.shade100,
                                padding: EdgeInsets.zero,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                            if (file.hasVoiceOver)
                              Chip(
                                label: const Text(
                                  'Voice-over',
                                  style: TextStyle(fontSize: 10),
                                ),
                                backgroundColor: Colors.purple.shade100,
                                padding: EdgeInsets.zero,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Translated Text:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    file.translatedText ?? 'No translation available',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Action buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Watch Video Button (for all translated videos)
                if (file.type == 'video')
                  ElevatedButton.icon(
                    onPressed: () {
                      print('Opening video player for: ${file.name}');
                      print('File path: ${file.filePath}');
                      print('Has subtitles: ${file.hasSubtitles}');
                      print('Subtitles count: ${file.subtitles?.length ?? 0}');

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TranslatedVideoPlayerView(file: file),
                        ),
                      );
                    },
                    icon: const Icon(Icons.play_circle_filled, size: 18),
                    label: const Text('Watch Video'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ElevatedButton.icon(
                  onPressed: () => _mediaService.downloadTranslation(file),
                  icon: const Icon(Icons.download, size: 18),
                  label: const Text('Translation'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
                if (file.hasSubtitles)
                  ElevatedButton.icon(
                    onPressed: () => _mediaService.downloadSubtitles(file),
                    icon: const Icon(Icons.subtitles, size: 18),
                    label: const Text('Subtitles'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                if (file.hasVoiceOver) ...[
                  ElevatedButton.icon(
                    onPressed: () => _playVoiceOver(file),
                    icon: Icon(
                      _isPlaying && _currentPlayingId == file.id
                          ? Icons.stop
                          : Icons.play_arrow,
                      size: 18,
                    ),
                    label: Text(
                      _isPlaying && _currentPlayingId == file.id
                          ? 'Stop'
                          : 'Play',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isPlaying && _currentPlayingId == file.id
                          ? Colors.red
                          : Colors.purple,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showVoiceOverInfo(file),
                    icon: const Icon(Icons.info_outline, color: Colors.purple),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Voice-over details',
                  ),
                ],
                IconButton(
                  onPressed: () => _showDeleteDialog(file.id),
                  icon: const Icon(Icons.delete, color: Colors.red),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showVoiceOverInfo(MediaFile file) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.record_voice_over, color: Colors.purple),
              SizedBox(width: 8),
              Text('Voice-over Player'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                file.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text('Language: ${file.targetLanguage}'),
              const SizedBox(height: 16),
              // Play button
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      IconButton(
                        onPressed: () async {
                          await _playVoiceOver(file);
                          setDialogState(() {});
                        },
                        icon: Icon(
                          _isPlaying && _currentPlayingId == file.id
                              ? Icons.stop_circle
                              : Icons.play_circle_fill,
                          size: 64,
                          color: Colors.purple,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isPlaying && _currentPlayingId == file.id
                            ? 'Playing...'
                            : 'Tap to play voice-over',
                        style: TextStyle(
                          color: Colors.purple.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Text being spoken:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      file.translatedText ?? 'No translation available',
                      style: const TextStyle(fontSize: 12),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await _flutterTts.stop();
                setState(() {
                  _isPlaying = false;
                  _currentPlayingId = null;
                });
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  void _showTranslateOptions(
    MediaFile file,
    String sourceLanguage,
    String targetLanguage,
  ) {
    showDialog(
      context: context,
      builder: (context) => _TranslateOptionsDialog(
        file: file,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
        mediaService: _mediaService,
      ),
    );
  }

  void _showDeleteDialog(String fileId) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete File'),
        content: const Text('Are you sure you want to delete this file?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              _mediaService.deleteFile(fileId);
              Get.back();
              Get.snackbar(
                'Deleted',
                'File deleted successfully',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _TranslateOptionsDialog extends StatefulWidget {
  final MediaFile file;
  final String sourceLanguage;
  final String targetLanguage;
  final MediaTranslationService mediaService;

  const _TranslateOptionsDialog({
    required this.file,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.mediaService,
  });

  @override
  State<_TranslateOptionsDialog> createState() =>
      _TranslateOptionsDialogState();
}

class _TranslateOptionsDialogState extends State<_TranslateOptionsDialog> {
  late bool generateSubtitles;
  late bool generateVoiceOver;
  bool useAdvancedAI = false;
  bool usePipeline = false; // Whisper + NLLB pipeline

  @override
  void initState() {
    super.initState();
    generateSubtitles = widget.file.type == 'video';
    generateVoiceOver = false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.settings, color: Colors.purple),
          SizedBox(width: 8),
          Text('Translation Options'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'File: ${widget.file.name}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text('${widget.sourceLanguage} → ${widget.targetLanguage}'),
          const Divider(height: 24),
          // Advanced AI Mode Toggle
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: useAdvancedAI ? Colors.blue.shade50 : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: useAdvancedAI ? Colors.blue : Colors.grey.shade300,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: useAdvancedAI ? Colors.blue : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Advanced AI Translation',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: useAdvancedAI ? Colors.blue : Colors.black,
                            ),
                          ),
                          Text(
                            'Uses Gemini AI for real-time translation',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: useAdvancedAI,
                      onChanged: (value) {
                        setState(() => useAdvancedAI = value);
                      },
                      activeThumbColor: Colors.blue,
                    ),
                  ],
                ),
                if (useAdvancedAI) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Colors.blue.shade700,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'AI will analyze actual audio content and generate accurate translations',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.blue.shade700,
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
          const SizedBox(height: 12),
          if (widget.file.type == 'video') ...[
            CheckboxListTile(
              title: const Text('Generate Subtitles'),
              subtitle: Text(
                useAdvancedAI
                    ? 'AI-powered subtitle generation'
                    : 'Create SRT subtitle file',
              ),
              value: generateSubtitles,
              onChanged: (value) {
                setState(() => generateSubtitles = value ?? false);
              },
              contentPadding: EdgeInsets.zero,
              activeColor: useAdvancedAI ? Colors.blue : Colors.purple,
            ),
          ],
          CheckboxListTile(
            title: const Text('Generate Voice-over'),
            subtitle: Text(
              useAdvancedAI
                  ? 'AI-translated voice narration'
                  : 'Create audio narration',
            ),
            value: generateVoiceOver,
            onChanged: (value) {
              setState(() => generateVoiceOver = value ?? false);
            },
            contentPadding: EdgeInsets.zero,
            activeColor: useAdvancedAI ? Colors.blue : Colors.purple,
          ),
          const Divider(),
          // Pipeline Mode (Whisper + NLLB)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: usePipeline ? Colors.orange.shade50 : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: usePipeline ? Colors.orange : Colors.grey.shade300,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.memory,
                  color: usePipeline ? Colors.orange : Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Full Pipeline (Whisper + NLLB)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: usePipeline
                              ? Colors.orange.shade800
                              : Colors.black,
                        ),
                      ),
                      Text(
                        'Speech-to-Text → Translation → TTS',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: usePipeline,
                  onChanged: (value) {
                    setState(() {
                      usePipeline = value;
                      if (value) useAdvancedAI = false;
                    });
                  },
                  activeThumbColor: Colors.orange,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pop(context);

            if (usePipeline) {
              // Use full pipeline (Whisper + NLLB + TTS)
              widget.mediaService.translateWithPipeline(
                widget.file.id,
                widget.sourceLanguage,
                widget.targetLanguage,
                generateSubtitles: generateSubtitles,
                generateVoiceOver: generateVoiceOver,
              );
            } else if (useAdvancedAI) {
              // Use advanced AI translation with Gemini
              widget.mediaService.translateFileAdvanced(
                widget.file.id,
                widget.sourceLanguage,
                widget.targetLanguage,
                generateSubtitles: generateSubtitles,
                generateVoiceOver: generateVoiceOver,
              );
            } else {
              // Use basic translation
              widget.mediaService.translateFile(
                widget.file.id,
                widget.sourceLanguage,
                widget.targetLanguage,
                generateSubtitles: generateSubtitles,
                generateVoiceOver: generateVoiceOver,
              );
            }
          },
          icon: Icon(
            usePipeline
                ? Icons.memory
                : (useAdvancedAI ? Icons.auto_awesome : Icons.translate),
          ),
          label: Text(
            usePipeline
                ? 'Pipeline Translate'
                : (useAdvancedAI ? 'AI Translate' : 'Translate'),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: usePipeline
                ? Colors.orange
                : (useAdvancedAI ? Colors.blue : Colors.purple),
          ),
        ),
      ],
    );
  }
}
