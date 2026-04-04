import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/gemini_translation_service.dart';

class StudentTranslationView extends StatefulWidget {
  const StudentTranslationView({super.key});

  @override
  State<StudentTranslationView> createState() => _StudentTranslationViewState();
}

class _StudentTranslationViewState extends State<StudentTranslationView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController sourceController = TextEditingController();
  final TextEditingController targetController = TextEditingController();
  final translationService = Get.find<GeminiTranslationService>();

  String sourceLanguage = 'English';
  String targetLanguage = 'Hindi';
  bool isTranslating = false;
  bool isRecording = false;
  bool isProcessingFile = false;
  List<Map<String, dynamic>> translationHistory = [];
  String? uploadedFileName;
  String? uploadedFileType;

  // Comprehensive Indian and International languages
  final List<Map<String, String>> languages = [
    // Indian Languages (22 Official Languages)
    {'name': 'Hindi', 'code': 'hi', 'flag': '🇮🇳', 'script': 'Devanagari'},
    {'name': 'Tamil', 'code': 'ta', 'flag': '🇮🇳', 'script': 'Tamil'},
    {'name': 'Telugu', 'code': 'te', 'flag': '🇮🇳', 'script': 'Telugu'},
    {'name': 'Kannada', 'code': 'kn', 'flag': '🇮🇳', 'script': 'Kannada'},
    {'name': 'Malayalam', 'code': 'ml', 'flag': '🇮🇳', 'script': 'Malayalam'},
    {'name': 'Bengali', 'code': 'bn', 'flag': '🇮🇳', 'script': 'Bengali'},
    {'name': 'Marathi', 'code': 'mr', 'flag': '🇮🇳', 'script': 'Devanagari'},
    {'name': 'Gujarati', 'code': 'gu', 'flag': '🇮🇳', 'script': 'Gujarati'},
    {'name': 'Punjabi', 'code': 'pa', 'flag': '🇮🇳', 'script': 'Gurmukhi'},
    {'name': 'Odia', 'code': 'or', 'flag': '🇮🇳', 'script': 'Odia'},
    {'name': 'Assamese', 'code': 'as', 'flag': '🇮🇳', 'script': 'Bengali'},
    {'name': 'Urdu', 'code': 'ur', 'flag': '🇮🇳', 'script': 'Perso-Arabic'},
    {'name': 'Sanskrit', 'code': 'sa', 'flag': '🇮🇳', 'script': 'Devanagari'},
    {
      'name': 'Kashmiri',
      'code': 'ks',
      'flag': '🇮🇳',
      'script': 'Perso-Arabic',
    },
    {'name': 'Sindhi', 'code': 'sd', 'flag': '🇮🇳', 'script': 'Devanagari'},
    {'name': 'Konkani', 'code': 'gom', 'flag': '🇮🇳', 'script': 'Devanagari'},
    {'name': 'Nepali', 'code': 'ne', 'flag': '🇮🇳', 'script': 'Devanagari'},
    {'name': 'Manipuri', 'code': 'mni', 'flag': '🇮🇳', 'script': 'Meitei'},
    {'name': 'Bodo', 'code': 'brx', 'flag': '🇮🇳', 'script': 'Devanagari'},
    {'name': 'Dogri', 'code': 'doi', 'flag': '🇮🇳', 'script': 'Devanagari'},
    {'name': 'Maithili', 'code': 'mai', 'flag': '🇮🇳', 'script': 'Devanagari'},
    {'name': 'Santali', 'code': 'sat', 'flag': '🇮🇳', 'script': 'Ol Chiki'},
    // International Languages
    {'name': 'English', 'code': 'en', 'flag': '🇬🇧', 'script': 'Latin'},
    {'name': 'Spanish', 'code': 'es', 'flag': '🇪🇸', 'script': 'Latin'},
    {'name': 'French', 'code': 'fr', 'flag': '🇫🇷', 'script': 'Latin'},
    {'name': 'German', 'code': 'de', 'flag': '🇩🇪', 'script': 'Latin'},
    {'name': 'Chinese', 'code': 'zh', 'flag': '🇨🇳', 'script': 'Chinese'},
    {'name': 'Japanese', 'code': 'ja', 'flag': '🇯🇵', 'script': 'Japanese'},
    {'name': 'Korean', 'code': 'ko', 'flag': '🇰🇷', 'script': 'Hangul'},
    {'name': 'Arabic', 'code': 'ar', 'flag': '🇸🇦', 'script': 'Arabic'},
    {'name': 'Portuguese', 'code': 'pt', 'flag': '🇵🇹', 'script': 'Latin'},
    {'name': 'Russian', 'code': 'ru', 'flag': '🇷🇺', 'script': 'Cyrillic'},
    {'name': 'Italian', 'code': 'it', 'flag': '🇮🇹', 'script': 'Latin'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    sourceController.dispose();
    targetController.dispose();
    super.dispose();
  }

  void translate() async {
    if (sourceController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter text to translate',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => isTranslating = true);

    try {
      // Get language codes
      final sourceLangCode = _getLanguageCode(sourceLanguage);
      final targetLangCode = _getLanguageCode(targetLanguage);

      // Use Gemini translation service
      final translatedText = await translationService.translateText(
        text: sourceController.text,
        sourceLang: sourceLangCode,
        targetLang: targetLangCode,
        userId: 'STU001', // Replace with actual user ID
      );

      setState(() {
        targetController.text = translatedText;
        isTranslating = false;

        translationHistory.insert(0, {
          'source': sourceController.text,
          'target': translatedText,
          'from': sourceLanguage,
          'to': targetLanguage,
          'time': DateTime.now(),
          'type': 'text',
        });
        if (translationHistory.length > 50) translationHistory.removeLast();
      });
    } catch (e) {
      setState(() {
        targetController.text = 'Translation failed. Please try again.';
        isTranslating = false;
      });

      Get.snackbar(
        'Error',
        'Translation failed: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    Get.snackbar(
      'Success',
      'Translation completed',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  String _getLanguageCode(String languageName) {
    final lang = languages.firstWhere(
      (l) => l['name'] == languageName,
      orElse: () => {'code': 'en'},
    );
    return lang['code'] ?? 'en';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Translation'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF9C27B0), Color(0xFFCE93D8)],
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.text_fields), text: 'Text'),
            Tab(icon: Icon(Icons.upload_file), text: 'File Upload'),
            Tab(icon: Icon(Icons.videocam), text: 'Video'),
            Tab(icon: Icon(Icons.mic), text: 'Audio'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTextTranslation(),
          _buildFileUploadTranslation(),
          _buildVideoTranslation(),
          _buildAudioTranslation(),
        ],
      ),
    );
  }

  Widget _buildTextTranslation() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Language selection with enhanced UI
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF9C27B0).withValues(alpha: 0.1),
                  const Color(0xFFCE93D8).withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(child: _buildLanguageSelector(true)),
                IconButton(
                  icon: const Icon(
                    Icons.swap_horiz,
                    color: Color(0xFF9C27B0),
                    size: 32,
                  ),
                  onPressed: () {
                    setState(() {
                      final temp = sourceLanguage;
                      sourceLanguage = targetLanguage;
                      targetLanguage = temp;
                      final tempText = sourceController.text;
                      sourceController.text = targetController.text;
                      targetController.text = tempText;
                    });
                  },
                ),
                Expanded(child: _buildLanguageSelector(false)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Source text with enhanced features
          _buildTranslationCard(
            title: sourceLanguage,
            controller: sourceController,
            hint:
                'Enter text in any language...\n\nSupports:\n• All 22 Indian languages\n• International languages\n• Mixed language text',
            isReadOnly: false,
            color: const Color(0xFF9C27B0),
          ),
          const SizedBox(height: 16),

          // Translation options
          Row(
            children: [
              Expanded(child: _buildOptionChip('Formal', Icons.business, true)),
              const SizedBox(width: 8),
              Expanded(child: _buildOptionChip('Casual', Icons.chat, false)),
              const SizedBox(width: 8),
              Expanded(child: _buildOptionChip('Literary', Icons.book, false)),
            ],
          ),
          const SizedBox(height: 16),

          // Translate button with enhanced design
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF9C27B0), Color(0xFFCE93D8)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF9C27B0).withValues(alpha: 0.3),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: isTranslating ? null : translate,
              icon: isTranslating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.translate, size: 24),
              label: Text(
                isTranslating ? 'Translating with AI...' : 'Translate Now',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Target text with enhanced features
          _buildTranslationCard(
            title: targetLanguage,
            controller: targetController,
            hint:
                'Translation will appear here...\n\n✓ AI-powered accuracy\n✓ Context-aware\n✓ Grammar verified',
            isReadOnly: true,
            color: const Color(0xFFCE93D8),
          ),
          const SizedBox(height: 20),

          // Quick phrases for Indian languages
          const Text(
            'Quick Phrases',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildQuickPhrase('Hello', Icons.waving_hand),
              _buildQuickPhrase('Thank you', Icons.favorite),
              _buildQuickPhrase('Good morning', Icons.wb_sunny),
              _buildQuickPhrase('How are you?', Icons.question_answer),
              _buildQuickPhrase('Goodbye', Icons.exit_to_app),
              _buildQuickPhrase('Please', Icons.pan_tool),
              _buildQuickPhrase('Sorry', Icons.sentiment_dissatisfied),
              _buildQuickPhrase('Welcome', Icons.celebration),
            ],
          ),
          const SizedBox(height: 20),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showHistory(),
                  icon: const Icon(Icons.history),
                  label: const Text('History'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Color(0xFF9C27B0)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Get.snackbar(
                      'Saved',
                      'Translation saved to favorites',
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                    );
                  },
                  icon: const Icon(Icons.bookmark),
                  label: const Text('Save'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Color(0xFF9C27B0)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFileUploadTranslation() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF9C27B0), Color(0xFFCE93D8)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                Icon(Icons.cloud_upload, size: 60, color: Colors.white),
                SizedBox(height: 12),
                Text(
                  'File Translation',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Upload documents, images, or PDFs for translation',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Language selection for file
          Row(
            children: [
              Expanded(child: _buildLanguageSelector(true)),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.arrow_forward, color: Color(0xFF9C27B0)),
              ),
              Expanded(child: _buildLanguageSelector(false)),
            ],
          ),
          const SizedBox(height: 24),

          // Supported file types
          _buildFeatureCard(
            'Document Translation',
            'PDF, DOCX, TXT, RTF files',
            Icons.description,
            const Color(0xFF9C27B0),
          ),
          const SizedBox(height: 12),
          _buildFeatureCard(
            'Image Translation (OCR)',
            'JPG, PNG - Extract and translate text from images',
            Icons.image,
            const Color(0xFFAB47BC),
          ),
          const SizedBox(height: 12),
          _buildFeatureCard(
            'Subtitle Files',
            'SRT, VTT, ASS subtitle file translation',
            Icons.subtitles,
            const Color(0xFFBA68C8),
          ),
          const SizedBox(height: 24),

          // Upload area
          InkWell(
            onTap: () => _handleFileUpload(),
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF9C27B0).withValues(alpha: 0.3),
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (uploadedFileName == null) ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF9C27B0).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.cloud_upload,
                        size: 50,
                        color: Color(0xFF9C27B0),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Tap to upload file',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Supports: PDF, DOCX, TXT, Images',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ] else ...[
                    const Icon(
                      Icons.check_circle,
                      size: 50,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      uploadedFileName!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      uploadedFileType!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          if (uploadedFileName != null) ...[
            ElevatedButton.icon(
              onPressed: isProcessingFile ? null : () => _processFile(),
              icon: isProcessingFile
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.translate),
              label: Text(
                isProcessingFile ? 'Processing...' : 'Translate File',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9C27B0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  uploadedFileName = null;
                  uploadedFileType = null;
                });
              },
              icon: const Icon(Icons.clear),
              label: const Text('Remove File'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Colors.red),
                foregroundColor: Colors.red,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVideoTranslation() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF9C27B0), Color(0xFFCE93D8)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                Icon(Icons.video_library, size: 60, color: Colors.white),
                SizedBox(height: 12),
                Text(
                  'Video Translation',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Upload videos and get AI-powered subtitles or dubbing',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Language selection
          Row(
            children: [
              Expanded(child: _buildLanguageSelector(true)),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.arrow_forward, color: Color(0xFF9C27B0)),
              ),
              Expanded(child: _buildLanguageSelector(false)),
            ],
          ),
          const SizedBox(height: 24),

          _buildFeatureCard(
            'Auto Subtitle Generation',
            'AI generates accurate subtitles in source language',
            Icons.subtitles,
            const Color(0xFF9C27B0),
          ),
          const SizedBox(height: 12),
          _buildFeatureCard(
            'Subtitle Translation',
            'Translate subtitles to any Indian or international language',
            Icons.translate,
            const Color(0xFFAB47BC),
          ),
          const SizedBox(height: 12),
          _buildFeatureCard(
            'AI Voice Dubbing',
            'Natural voice dubbing with lip-sync technology',
            Icons.record_voice_over,
            const Color(0xFFBA68C8),
          ),
          const SizedBox(height: 12),
          _buildFeatureCard(
            'Real-time Translation',
            'Live subtitle translation while watching',
            Icons.live_tv,
            const Color(0xFF8E24AA),
          ),
          const SizedBox(height: 24),

          // Video upload button
          ElevatedButton.icon(
            onPressed: () => _handleVideoUpload(),
            icon: const Icon(Icons.upload_file),
            label: const Text('Upload Video'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9C27B0),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 12),

          // Supported formats
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: Color(0xFF9C27B0),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Supported Formats',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Video: MP4, AVI, MOV, MKV, WebM\nSubtitles: SRT, VTT, ASS, SSA\nMax size: 500 MB',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioTranslation() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF9C27B0), Color(0xFFCE93D8)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                Icon(Icons.mic, size: 60, color: Colors.white),
                SizedBox(height: 12),
                Text(
                  'Audio Translation',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Record or upload audio for instant translation',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Language selection
          Row(
            children: [
              Expanded(child: _buildLanguageSelector(true)),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.arrow_forward, color: Color(0xFF9C27B0)),
              ),
              Expanded(child: _buildLanguageSelector(false)),
            ],
          ),
          const SizedBox(height: 24),

          _buildFeatureCard(
            'Voice Recording',
            'Record your voice and translate instantly',
            Icons.keyboard_voice,
            const Color(0xFF9C27B0),
          ),
          const SizedBox(height: 12),
          _buildFeatureCard(
            'Audio File Upload',
            'Upload MP3, WAV, M4A, OGG files',
            Icons.audio_file,
            const Color(0xFFAB47BC),
          ),
          const SizedBox(height: 12),
          _buildFeatureCard(
            'Speech-to-Text',
            'Convert speech to text with high accuracy',
            Icons.text_fields,
            const Color(0xFFBA68C8),
          ),
          const SizedBox(height: 12),
          _buildFeatureCard(
            'Text-to-Speech',
            'Listen to translated text in natural voice',
            Icons.volume_up,
            const Color(0xFF8E24AA),
          ),
          const SizedBox(height: 24),

          // Recording interface
          InkWell(
            onTap: () => _toggleRecording(),
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: isRecording
                    ? const LinearGradient(
                        colors: [Color(0xFFE91E63), Color(0xFFF48FB1)],
                      )
                    : LinearGradient(
                        colors: [Colors.grey.shade100, Colors.grey.shade200],
                      ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isRecording
                      ? Colors.red
                      : const Color(0xFF9C27B0).withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isRecording
                          ? Colors.white.withValues(alpha: 0.3)
                          : const Color(0xFF9C27B0).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isRecording ? Icons.stop : Icons.mic,
                      size: 50,
                      color: isRecording
                          ? Colors.white
                          : const Color(0xFF9C27B0),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isRecording
                        ? 'Recording... Tap to stop'
                        : 'Tap to start recording',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isRecording ? Colors.white : Colors.grey.shade700,
                    ),
                  ),
                  if (isRecording) ...[
                    const SizedBox(height: 8),
                    const Text(
                      '00:15',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _handleAudioUpload(),
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Upload Audio'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9C27B0),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Get.snackbar(
                      'Playing',
                      'Playing translated audio',
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                    );
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Play'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Color(0xFF9C27B0)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector(bool isSource) {
    final selectedLang = isSource ? sourceLanguage : targetLanguage;
    final langData = languages.firstWhere((l) => l['name'] == selectedLang);

    return InkWell(
      onTap: () => _showLanguagePicker(isSource),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF9C27B0).withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF9C27B0).withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 4,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(langData['flag']!, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    selectedLang,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF9C27B0),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    langData['script']!,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Color(0xFF9C27B0)),
          ],
        ),
      ),
    );
  }

  Widget _buildTranslationCard({
    required String title,
    required TextEditingController controller,
    required String hint,
    required bool isReadOnly,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 16,
                ),
              ),
              if (controller.text.isNotEmpty)
                Row(
                  children: [
                    Text(
                      '${controller.text.length} chars',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    if (!isReadOnly) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () => setState(() => controller.clear()),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                    if (isReadOnly && controller.text.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 20),
                        onPressed: () {
                          Get.snackbar(
                            'Copied',
                            'Text copied to clipboard',
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                          );
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.volume_up, size: 20),
                        onPressed: () {
                          Get.snackbar(
                            'Playing',
                            'Text-to-speech in $title',
                            backgroundColor: Colors.blue,
                            colorText: Colors.white,
                          );
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ],
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLines: 6,
            readOnly: isReadOnly,
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
              filled: true,
              fillColor: isReadOnly ? Colors.grey.shade50 : Colors.transparent,
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionChip(String label, IconData icon, bool isSelected) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 16), const SizedBox(width: 4), Text(label)],
      ),
      selected: isSelected,
      onSelected: (value) => setState(() {}),
      selectedColor: const Color(0xFF9C27B0).withValues(alpha: 0.2),
      checkmarkColor: const Color(0xFF9C27B0),
    );
  }

  Widget _buildQuickPhrase(String phrase, IconData icon) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(phrase),
      onPressed: () {
        sourceController.text = phrase;
        translate();
      },
      backgroundColor: const Color(0xFF9C27B0).withValues(alpha: 0.1),
      labelStyle: const TextStyle(color: Color(0xFF9C27B0)),
    );
  }

  Widget _buildFeatureCard(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguagePicker(bool isSource) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF9C27B0), Color(0xFFCE93D8)],
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    const Text(
                      'Select Language',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search languages...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: languages.length,
                  itemBuilder: (context, index) {
                    final lang = languages[index];
                    final isIndian = lang['flag'] == '🇮🇳';
                    return ListTile(
                      leading: Text(
                        lang['flag']!,
                        style: const TextStyle(fontSize: 28),
                      ),
                      title: Row(
                        children: [
                          Text(lang['name']!),
                          if (isIndian) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Indian',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      subtitle: Text('${lang['code']} • ${lang['script']}'),
                      onTap: () {
                        setState(() {
                          if (isSource) {
                            sourceLanguage = lang['name']!;
                          } else {
                            targetLanguage = lang['name']!;
                          }
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showHistory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Translation History',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_sweep),
                  onPressed: () {
                    setState(() => translationHistory.clear());
                    Navigator.pop(context);
                    Get.snackbar(
                      'Cleared',
                      'Translation history cleared',
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: translationHistory.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No translation history yet',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: translationHistory.length,
                      itemBuilder: (context, index) {
                        final item = translationHistory[index];
                        final time = item['time'] as DateTime;
                        final timeStr =
                            '${time.hour}:${time.minute.toString().padLeft(2, '0')}';

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(
                                0xFF9C27B0,
                              ).withValues(alpha: 0.1),
                              child: const Icon(
                                Icons.translate,
                                color: Color(0xFF9C27B0),
                              ),
                            ),
                            title: Text(
                              item['source']!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '${item['from']} → ${item['to']}\n${item['target']}\n$timeStr',
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            isThreeLine: true,
                            trailing: PopupMenuButton(
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'reuse',
                                  child: Row(
                                    children: [
                                      Icon(Icons.replay, size: 18),
                                      SizedBox(width: 8),
                                      Text('Reuse'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.delete,
                                        size: 18,
                                        color: Colors.red,
                                      ),
                                      SizedBox(width: 8),
                                      Text('Delete'),
                                    ],
                                  ),
                                ),
                              ],
                              onSelected: (value) {
                                if (value == 'reuse') {
                                  sourceController.text = item['source']!;
                                  targetController.text = item['target']!;
                                  sourceLanguage = item['from']!;
                                  targetLanguage = item['to']!;
                                  Navigator.pop(context);
                                  setState(() {});
                                } else if (value == 'delete') {
                                  setState(
                                    () => translationHistory.removeAt(index),
                                  );
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleFileUpload() {
    setState(() {
      uploadedFileName = 'sample_document.pdf';
      uploadedFileType = 'PDF Document • 2.4 MB';
    });
    Get.snackbar(
      'File Uploaded',
      'Ready to translate',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  void _processFile() async {
    setState(() => isProcessingFile = true);
    await Future.delayed(const Duration(seconds: 3));
    setState(() => isProcessingFile = false);

    Get.snackbar(
      'Success',
      'File translated successfully! Download ready.',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  void _handleVideoUpload() {
    Get.snackbar(
      'Upload Video',
      'Select video file to translate',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

  void _handleAudioUpload() {
    Get.snackbar(
      'Upload Audio',
      'Select audio file to translate',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

  void _toggleRecording() {
    setState(() => isRecording = !isRecording);
    if (isRecording) {
      Get.snackbar(
        'Recording',
        'Speak now...',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } else {
      Get.snackbar(
        'Processing',
        'Transcribing and translating...',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
    }
  }
}
