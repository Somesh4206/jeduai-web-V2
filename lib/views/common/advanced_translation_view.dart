import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../services/gemini_translation_service.dart';
import '../../services/enhanced_translation_service.dart';
import '../../modules/media_translation/presentation/views/media_translation_module_view.dart';

class AdvancedTranslationView extends StatefulWidget {
  const AdvancedTranslationView({super.key});

  @override
  State<AdvancedTranslationView> createState() =>
      _AdvancedTranslationViewState();
}

class _AdvancedTranslationViewState extends State<AdvancedTranslationView>
    with SingleTickerProviderStateMixin {
  final baseService = Get.put(GeminiTranslationService());
  final enhancedService = Get.put(EnhancedTranslationService());
  final sourceController = TextEditingController();

  String sourceLang = 'en';
  String targetLang = 'hi';
  String translationMode = 'standard';
  String? selectedContext;
  String? selectedTone;
  String? selectedDomain;

  late TabController _tabController;

  final translationModes = [
    {'id': 'standard', 'name': 'Standard', 'icon': Icons.translate},
    {'id': 'context', 'name': 'Contextual', 'icon': Icons.psychology},
    {'id': 'grammar', 'name': 'Grammar', 'icon': Icons.school},
    {'id': 'idiom', 'name': 'Idioms', 'icon': Icons.lightbulb},
    {
      'id': 'pronunciation',
      'name': 'Pronunciation',
      'icon': Icons.record_voice_over,
    },
    {'id': 'technical', 'name': 'Technical', 'icon': Icons.engineering},
    {'id': 'compare', 'name': 'Compare', 'icon': Icons.compare_arrows},
  ];

  final contexts = [
    'Educational',
    'Business',
    'Casual Conversation',
    'Formal Letter',
    'Social Media',
    'Academic',
  ];

  final tones = [
    'Formal',
    'Informal',
    'Casual',
    'Professional',
    'Friendly',
    'Respectful',
  ];

  final domains = [
    'Medical',
    'Legal',
    'Technical',
    'Academic',
    'Business',
    'Scientific',
  ];

  Map<String, dynamic>? translationResult;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    sourceController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Translation'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFEC4899)],
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.normal,
          ),
          tabs: const [
            Tab(icon: Icon(Icons.translate, size: 24), text: 'Text'),
            Tab(icon: Icon(Icons.upload_file, size: 24), text: 'File Upload'),
            Tab(icon: Icon(Icons.auto_awesome, size: 24), text: 'Features'),
            Tab(icon: Icon(Icons.compare, size: 24), text: 'Compare'),
            Tab(icon: Icon(Icons.tips_and_updates, size: 24), text: 'Tips'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTranslateTab(),
          const MediaTranslationModuleView(),
          _buildFeaturesTab(),
          _buildCompareTab(),
          _buildTipsTab(),
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
          // Mode Selection
          _buildModeSelector(),
          const SizedBox(height: 16),

          // Language Selection
          _buildLanguageSelector(),
          const SizedBox(height: 16),

          // Context/Tone/Domain Selection (based on mode)
          if (translationMode == 'context') _buildContextSelector(),
          if (translationMode == 'technical') _buildDomainSelector(),
          const SizedBox(height: 16),

          // Input Text
          _buildInputField(),
          const SizedBox(height: 16),

          // Translate Button
          _buildTranslateButton(),
          const SizedBox(height: 24),

          // Results
          if (translationResult != null) _buildResults(),
        ],
      ),
    );
  }

  Widget _buildModeSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Translation Mode',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: translationModes.map((mode) {
              final isSelected = translationMode == mode['id'];
              return ChoiceChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      mode['icon'] as IconData,
                      size: 16,
                      color: isSelected ? Colors.white : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(mode['name'] as String),
                  ],
                ),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    translationMode = mode['id'] as String;
                    translationResult = null;
                  });
                },
                selectedColor: const Color(0xFFEC4899),
                backgroundColor: Colors.white,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Row(
      children: [
        Expanded(
          child: _buildLanguageDropdown('From', sourceLang, (value) {
            setState(() => sourceLang = value!);
          }),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: IconButton(
            icon: const Icon(Icons.swap_horiz, size: 32),
            onPressed: () {
              setState(() {
                final temp = sourceLang;
                sourceLang = targetLang;
                targetLang = temp;
              });
            },
            color: const Color(0xFF6366F1),
          ),
        ),
        Expanded(
          child: _buildLanguageDropdown('To', targetLang, (value) {
            setState(() => targetLang = value!);
          }),
        ),
      ],
    );
  }

  Widget _buildLanguageDropdown(
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
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
          ),
        ],
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
            items: baseService.supportedLanguages.map((lang) {
              return DropdownMenuItem(
                value: lang['code'],
                child: Text(
                  '${lang['nativeName']} (${lang['name']})',
                  style: const TextStyle(fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildContextSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Context & Tone',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Context',
                  border: OutlineInputBorder(),
                ),
                initialValue: selectedContext,
                items: contexts.map((context) {
                  return DropdownMenuItem(value: context, child: Text(context));
                }).toList(),
                onChanged: (value) => setState(() => selectedContext = value),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Tone',
                  border: OutlineInputBorder(),
                ),
                initialValue: selectedTone,
                items: tones.map((tone) {
                  return DropdownMenuItem(value: tone, child: Text(tone));
                }).toList(),
                onChanged: (value) => setState(() => selectedTone = value),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDomainSelector() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Technical Domain',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.engineering),
      ),
      initialValue: selectedDomain,
      items: domains.map((domain) {
        return DropdownMenuItem(value: domain, child: Text(domain));
      }).toList(),
      onChanged: (value) => setState(() => selectedDomain = value),
    );
  }

  Widget _buildInputField() {
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
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.edit, color: Color(0xFF6366F1)),
                const SizedBox(width: 8),
                const Text(
                  'Enter Text',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                Text(
                  '${sourceController.text.length} chars',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          TextField(
            controller: sourceController,
            maxLines: 8,
            decoration: const InputDecoration(
              hintText: 'Type or paste your text here...',
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
            onChanged: (value) => setState(() {}),
          ),
        ],
      ),
    );
  }

  Widget _buildTranslateButton() {
    return Obx(() {
      final isLoading =
          baseService.isTranslating.value || enhancedService.isProcessing.value;

      return Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFEC4899)],
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
          onPressed: isLoading ? null : _performTranslation,
          icon: isLoading
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
            isLoading ? 'Translating...' : 'Translate',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 16),
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
      );
    });
  }

  Widget _buildResults() {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 28),
              const SizedBox(width: 12),
              const Text(
                'Translation Results',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () {
                  final mainText =
                      translationResult!['main'] ??
                      translationResult!['translation'] ??
                      '';
                  Clipboard.setData(ClipboardData(text: mainText));
                  Get.snackbar('✅ Copied', 'Translation copied to clipboard');
                },
              ),
            ],
          ),
          const Divider(height: 24),
          _buildResultContent(),
        ],
      ),
    );
  }

  Widget _buildResultContent() {
    switch (translationMode) {
      case 'context':
        return _buildContextualResult();
      case 'grammar':
        return _buildGrammarResult();
      case 'idiom':
        return _buildIdiomResult();
      case 'pronunciation':
        return _buildPronunciationResult();
      case 'technical':
        return _buildTechnicalResult();
      case 'compare':
        return _buildCompareResult();
      default:
        return _buildStandardResult();
    }
  }

  Widget _buildStandardResult() {
    return SelectableText(
      translationResult!['main'] ?? translationResult!['translation'] ?? '',
      style: const TextStyle(fontSize: 16),
    );
  }

  Widget _buildContextualResult() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildResultSection('Main Translation', translationResult!['main']),
        if (translationResult!['alternative']?.isNotEmpty ?? false)
          _buildResultSection('Alternative', translationResult!['alternative']),
        if (translationResult!['literal']?.isNotEmpty ?? false)
          _buildResultSection('Literal', translationResult!['literal']),
        if (translationResult!['notes']?.isNotEmpty ?? false)
          _buildResultSection('Notes', translationResult!['notes']),
      ],
    );
  }

  Widget _buildGrammarResult() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildResultSection('Translation', translationResult!['translation']),
        if (translationResult!['breakdown']?.isNotEmpty ?? false)
          _buildResultSection('Breakdown', translationResult!['breakdown']),
        if (translationResult!['structure']?.isNotEmpty ?? false)
          _buildResultSection('Structure', translationResult!['structure']),
        if (translationResult!['keyPoints'] != null)
          _buildListSection('Key Points', translationResult!['keyPoints']),
      ],
    );
  }

  Widget _buildIdiomResult() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildResultSection('Equivalent', translationResult!['equivalent']),
        if (translationResult!['literal']?.isNotEmpty ?? false)
          _buildResultSection('Literal', translationResult!['literal']),
        if (translationResult!['meaning']?.isNotEmpty ?? false)
          _buildResultSection('Meaning', translationResult!['meaning']),
        if (translationResult!['example']?.isNotEmpty ?? false)
          _buildResultSection('Example', translationResult!['example']),
      ],
    );
  }

  Widget _buildPronunciationResult() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildResultSection('Translation', translationResult!['translation']),
        if (translationResult!['romanization']?.isNotEmpty ?? false)
          _buildResultSection(
            'Romanization',
            translationResult!['romanization'],
          ),
        if (translationResult!['pronunciation']?.isNotEmpty ?? false)
          _buildResultSection(
            'Pronunciation',
            translationResult!['pronunciation'],
          ),
        if (translationResult!['audioTips']?.isNotEmpty ?? false)
          _buildResultSection('Audio Tips', translationResult!['audioTips']),
      ],
    );
  }

  Widget _buildTechnicalResult() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildResultSection('Translation', translationResult!['translation']),
        if (translationResult!['technicalTerms'] != null)
          _buildMapSection(
            'Technical Terms',
            translationResult!['technicalTerms'],
          ),
        if (translationResult!['alternatives'] != null)
          _buildListSection('Alternatives', translationResult!['alternatives']),
      ],
    );
  }

  Widget _buildCompareResult() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (translationResult!['literal']?.isNotEmpty ?? false)
          _buildResultSection('Literal', translationResult!['literal']),
        if (translationResult!['natural']?.isNotEmpty ?? false)
          _buildResultSection('Natural', translationResult!['natural']),
        if (translationResult!['formal']?.isNotEmpty ?? false)
          _buildResultSection('Formal', translationResult!['formal']),
        if (translationResult!['casual']?.isNotEmpty ?? false)
          _buildResultSection('Casual', translationResult!['casual']),
      ],
    );
  }

  Widget _buildResultSection(String title, dynamic content) {
    if (content == null || content.toString().isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF6366F1),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          SelectableText(
            content.toString(),
            style: const TextStyle(fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildListSection(String title, dynamic list) {
    if (list == null || (list as List).isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF6366F1),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          ...list.map(
            (item) => Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontSize: 15)),
                  Expanded(
                    child: SelectableText(
                      item.toString(),
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection(String title, dynamic map) {
    if (map == null || (map as Map).isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF6366F1),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          ...map.entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.key,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  SelectableText(
                    entry.value.toString(),
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildFeatureCard(
          'Contextual Translation',
          'Get translations that consider context and tone',
          Icons.psychology,
          Colors.blue,
        ),
        _buildFeatureCard(
          'Grammar Explanation',
          'Understand the grammar structure of translations',
          Icons.school,
          Colors.green,
        ),
        _buildFeatureCard(
          'Idiom Translation',
          'Translate idioms with cultural context',
          Icons.lightbulb,
          Colors.orange,
        ),
        _buildFeatureCard(
          'Pronunciation Guide',
          'Learn how to pronounce translated text',
          Icons.record_voice_over,
          Colors.purple,
        ),
        _buildFeatureCard(
          'Technical Translation',
          'Specialized translation for technical domains',
          Icons.engineering,
          Colors.red,
        ),
        _buildFeatureCard(
          'Compare Translations',
          'See multiple translation approaches side-by-side',
          Icons.compare_arrows,
          Colors.teal,
        ),
      ],
    );
  }

  Widget _buildFeatureCard(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
      ),
    );
  }

  Widget _buildCompareTab() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.compare_arrows, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Translation Comparison',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Select "Compare" mode in the Translate tab to see multiple translation approaches',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildTipCard(
          '💡 Use Context',
          'For better translations, select the appropriate context and tone',
        ),
        _buildTipCard(
          '📚 Learn Grammar',
          'Use Grammar mode to understand sentence structure',
        ),
        _buildTipCard(
          '🗣️ Practice Pronunciation',
          'Use Pronunciation mode to learn how to speak',
        ),
        _buildTipCard(
          '🔧 Technical Terms',
          'For specialized content, use Technical mode with the right domain',
        ),
        _buildTipCard(
          '🔄 Compare Styles',
          'Use Compare mode to see formal vs casual translations',
        ),
        _buildTipCard(
          '💬 Idioms',
          'Idiom mode helps you understand cultural expressions',
        ),
      ],
    );
  }

  Widget _buildTipCard(String title, String description) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(description, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Future<void> _performTranslation() async {
    if (sourceController.text.trim().isEmpty) {
      Get.snackbar('⚠️ Empty Text', 'Please enter text to translate');
      return;
    }

    try {
      setState(() => translationResult = null);

      switch (translationMode) {
        case 'context':
          final result = await enhancedService.translateWithContext(
            text: sourceController.text,
            sourceLang: sourceLang,
            targetLang: targetLang,
            context: selectedContext,
            tone: selectedTone,
          );
          setState(() => translationResult = result);
          break;

        case 'grammar':
          final result = await enhancedService.translateWithGrammar(
            text: sourceController.text,
            sourceLang: sourceLang,
            targetLang: targetLang,
          );
          setState(() => translationResult = result);
          break;

        case 'idiom':
          final result = await enhancedService.translateIdiom(
            idiom: sourceController.text,
            sourceLang: sourceLang,
            targetLang: targetLang,
          );
          setState(() => translationResult = result);
          break;

        case 'pronunciation':
          final result = await enhancedService.translateWithPronunciation(
            text: sourceController.text,
            sourceLang: sourceLang,
            targetLang: targetLang,
          );
          setState(() => translationResult = result);
          break;

        case 'technical':
          if (selectedDomain == null) {
            Get.snackbar(
              '⚠️ Select Domain',
              'Please select a technical domain',
            );
            return;
          }
          final result = await enhancedService.translateTechnical(
            text: sourceController.text,
            sourceLang: sourceLang,
            targetLang: targetLang,
            domain: selectedDomain!,
          );
          setState(() => translationResult = result);
          break;

        case 'compare':
          final result = await enhancedService.compareTranslations(
            text: sourceController.text,
            sourceLang: sourceLang,
            targetLang: targetLang,
          );
          setState(() => translationResult = result);
          break;

        default:
          final result = await baseService.translateText(
            text: sourceController.text,
            sourceLang: sourceLang,
            targetLang: targetLang,
            userId: 'current_user_id',
          );
          setState(() => translationResult = {'main': result});
      }
    } catch (e) {
      Get.snackbar('❌ Error', 'Translation failed: $e');
    }
  }
}
