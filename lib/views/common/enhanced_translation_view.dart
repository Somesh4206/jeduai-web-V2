import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../services/gemini_translation_service.dart';

class EnhancedTranslationView extends StatefulWidget {
  const EnhancedTranslationView({super.key});

  @override
  State<EnhancedTranslationView> createState() =>
      _EnhancedTranslationViewState();
}

class _EnhancedTranslationViewState extends State<EnhancedTranslationView>
    with SingleTickerProviderStateMixin {
  final translationService = Get.put(GeminiTranslationService());
  final sourceController = TextEditingController();
  final targetController = TextEditingController();

  String sourceLang = 'en';
  String targetLang = 'hi';

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    sourceController.dispose();
    targetController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Translation Hub'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.translate), text: 'Translate'),
            Tab(icon: Icon(Icons.history), text: 'History'),
            Tab(icon: Icon(Icons.settings), text: 'Settings'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTranslateTab(),
          _buildHistoryTab(),
          _buildSettingsTab(),
        ],
      ),
    );
  }

  Widget _buildTranslateTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(Icons.translate, size: 50, color: Colors.white),
                const SizedBox(height: 12),
                const Text(
                  'AI-Powered Translation',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Powered by Google Gemini AI',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Language Selection
          Row(
            children: [
              Expanded(
                child: _buildLanguageSelector(
                  'From',
                  sourceLang,
                  (value) => setState(() => sourceLang = value!),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: IconButton(
                  icon: const Icon(Icons.swap_horiz, size: 32),
                  onPressed: _swapLanguages,
                  color: const Color(0xFF6366F1),
                ),
              ),
              Expanded(
                child: _buildLanguageSelector(
                  'To',
                  targetLang,
                  (value) => setState(() => targetLang = value!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Source Text Input
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.edit, color: Color(0xFF6366F1)),
                      const SizedBox(width: 8),
                      const Text(
                        'Enter Text',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${sourceController.text.length} chars',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                TextField(
                  controller: sourceController,
                  maxLines: 10,
                  decoration: const InputDecoration(
                    hintText:
                        'Paste or type your text here...\n\nSupports multiple lines!\nJust paste and translate.',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                  onChanged: (value) => setState(() {}),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          Clipboard.getData('text/plain').then((data) {
                            if (data?.text != null) {
                              sourceController.text = data!.text!;
                              setState(() {});
                            }
                          });
                        },
                        icon: const Icon(Icons.content_paste, size: 18),
                        label: const Text('Paste'),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          sourceController.clear();
                          setState(() {});
                        },
                        icon: const Icon(Icons.clear, size: 18),
                        label: const Text('Clear'),
                      ),
                      const Spacer(),
                      Obx(
                        () => translationService.isTranslating.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const SizedBox(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Translate Button
          Obx(
            () => Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: translationService.isTranslating.value
                    ? null
                    : _translate,
                icon: const Icon(Icons.translate),
                label: Text(
                  translationService.isTranslating.value
                      ? 'Translating...'
                      : 'Translate',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ),
          ),

          // Progress Indicator
          Obx(() {
            if (translationService.isTranslating.value) {
              return Column(
                children: [
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: translationService.translationProgress.value,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF6366F1),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(translationService.translationProgress.value * 100).toStringAsFixed(0)}% Complete',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          }),

          const SizedBox(height: 24),

          // Translated Text Output
          Obx(() {
            if (translationService.translatedText.value.isNotEmpty) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 8),
                          const Text(
                            'Translation',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.copy, size: 20),
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(
                                  text: translationService.translatedText.value,
                                ),
                              );
                              Get.snackbar(
                                '✅ Copied',
                                'Translation copied to clipboard',
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SelectableText(
                        translationService.translatedText.value,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector(
    String label,
    String value,
    Function(String?) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF6366F1).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6366F1),
            ),
          ),
          const SizedBox(height: 4),
          DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            items: translationService.supportedLanguages.map((lang) {
              return DropdownMenuItem(
                value: lang['code'],
                child: Text(
                  '${lang['nativeName']} (${lang['name']})',
                  style: const TextStyle(fontSize: 14),
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return Obx(() {
      if (translationService.translationHistory.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history, size: 80, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No translation history yet',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: translationService.translationHistory.length,
        itemBuilder: (context, index) {
          final item = translationService.translationHistory[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ExpansionTile(
              title: Text(
                '${item['sourceLang']} → ${item['targetLang']}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${item['sourceText'].toString().substring(0, item['sourceText'].toString().length > 50 ? 50 : item['sourceText'].toString().length)}...',
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Original:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(item['sourceText']),
                      const SizedBox(height: 12),
                      const Text(
                        'Translation:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(item['targetText']),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  Widget _buildSettingsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Translation Settings',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Supported Languages'),
            subtitle: Text(
              '${translationService.supportedLanguages.length} languages',
            ),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Clear History'),
            subtitle: const Text('Remove all translation history'),
            onTap: () {
              translationService.clearHistory();
              Get.snackbar(
                '✅ Cleared',
                'Translation history cleared',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Export History'),
            subtitle: const Text('Export translation history as text'),
            onTap: () {
              final export = translationService.exportHistory();
              Clipboard.setData(ClipboardData(text: export));
              Get.snackbar(
                '✅ Exported',
                'History copied to clipboard',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
        ),
      ],
    );
  }

  void _swapLanguages() {
    setState(() {
      final temp = sourceLang;
      sourceLang = targetLang;
      targetLang = temp;

      final tempText = sourceController.text;
      sourceController.text = targetController.text;
      targetController.text = tempText;
    });
  }

  Future<void> _translate() async {
    if (sourceController.text.trim().isEmpty) {
      Get.snackbar(
        '⚠️ Empty Text',
        'Please enter text to translate',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      await translationService.translateText(
        text: sourceController.text,
        sourceLang: sourceLang,
        targetLang: targetLang,
        userId: 'current_user_id', // Replace with actual user ID
      );
    } catch (e) {
      // Error already handled in service
    }
  }
}
