import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/staff_controller.dart';
import '../../services/ai_assessment_generator_service.dart';
import '../../services/shared_assessment_service.dart';
import '../../services/user_data_service.dart';

class StaffAssessmentCreationView extends StatefulWidget {
  const StaffAssessmentCreationView({super.key});

  @override
  State<StaffAssessmentCreationView> createState() =>
      _StaffAssessmentCreationViewState();
}

class _StaffAssessmentCreationViewState
    extends State<StaffAssessmentCreationView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final StaffController staffController = Get.find<StaffController>();

  final titleController = TextEditingController();
  final subjectController = TextEditingController();
  final descriptionController = TextEditingController();

  String selectedType = 'Quiz';
  String selectedDifficulty = 'Medium';
  String selectedClass = 'III CSBS';
  int numberOfQuestions = 20;
  int duration = 30;
  bool includeAnswers = true;
  bool isGenerating = false;

  final List<String> assessmentTypes = ['Quiz', 'Test', 'Exam', 'Assignment'];
  final List<String> difficulties = ['Easy', 'Medium', 'Hard'];
  final List<String> classes = [
    'Class 6',
    'Class 7',
    'Class 8',
    'Class 9',
    'Class 10',
    'Class 11',
    'Class 12',
    'I CSBS',
    'II CSBS',
    'III CSBS',
    'IV CSBS',
    'College - Year 1',
    'College - Year 2',
    'College - Year 3',
    'College - Year 4',
    'College - Postgraduate',
    'Professional/Others',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    titleController.dispose();
    subjectController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assessment Creation'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE91E63), Color(0xFFF48FB1)],
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.auto_awesome), text: 'AI Generate'),
            Tab(icon: Icon(Icons.edit), text: 'Manual'),
            Tab(icon: Icon(Icons.list), text: 'My Assessments'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAIGenerateTab(),
          _buildManualTab(),
          _buildMyAssessmentsTab(),
        ],
      ),
    );
  }

  Widget _buildAIGenerateTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE91E63), Color(0xFFF48FB1)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(Icons.auto_awesome, size: 50, color: Colors.white),
                const SizedBox(height: 12),
                const Text(
                  'AI-Powered Assessment Generator',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Generate custom assessments using AI in seconds',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildInputField(
            'Subject',
            'e.g., Computer Science',
            subjectController,
            Icons.subject,
          ),
          const SizedBox(height: 16),
          _buildDropdownField(
            'Select Class',
            selectedClass,
            classes,
            Icons.school,
            (value) => setState(() => selectedClass = value!),
          ),
          const SizedBox(height: 16),
          _buildDropdownField(
            'Assessment Type',
            selectedType,
            assessmentTypes,
            Icons.assignment,
            (value) => setState(() => selectedType = value!),
          ),
          const SizedBox(height: 16),
          _buildDropdownField(
            'Difficulty Level',
            selectedDifficulty,
            difficulties,
            Icons.speed,
            (value) => setState(() => selectedDifficulty = value!),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE91E63).withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.quiz, color: Color(0xFFE91E63)),
                    SizedBox(width: 8),
                    Text(
                      'Number of Questions',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Slider(
                  value: numberOfQuestions.toDouble(),
                  min: 5,
                  max: 50,
                  divisions: 9,
                  activeColor: const Color(0xFFE91E63),
                  label: numberOfQuestions.toString(),
                  onChanged: (value) =>
                      setState(() => numberOfQuestions = value.toInt()),
                ),
                Text(
                  '$numberOfQuestions questions',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE91E63).withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.timer, color: Color(0xFFE91E63)),
                    SizedBox(width: 8),
                    Text(
                      'Duration',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Slider(
                  value: duration.toDouble(),
                  min: 15,
                  max: 180,
                  divisions: 11,
                  activeColor: const Color(0xFFE91E63),
                  label: '$duration min',
                  onChanged: (value) =>
                      setState(() => duration = value.toInt()),
                ),
                Text(
                  '$duration minutes',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE91E63).withValues(alpha: 0.3),
              ),
            ),
            child: SwitchListTile(
              title: const Text('Include Answer Key'),
              subtitle: const Text('Generate answers along with questions'),
              value: includeAnswers,
              activeThumbColor: const Color(0xFFE91E63),
              onChanged: (value) => setState(() => includeAnswers = value),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(height: 24),
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
                    Icon(Icons.lightbulb, color: Colors.orange, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'AI Prompt Preview',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Generate a $numberOfQuestions-question ${selectedType.toUpperCase()} assessment for $selectedClass ${subjectController.text.isEmpty ? "[Subject]" : subjectController.text}, difficulty $selectedDifficulty${includeAnswers ? ", include answers" : ""}.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE91E63), Color(0xFFF48FB1)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ElevatedButton.icon(
              onPressed: isGenerating ? null : _generateAssessment,
              icon: isGenerating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(
                isGenerating ? 'Generating...' : 'Generate Assessment with AI',
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
        ],
      ),
    );
  }

  Widget _buildManualTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Create Assessment Manually',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildInputField(
            'Title',
            'Assessment Title',
            titleController,
            Icons.title,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            'Subject',
            'Subject Name',
            subjectController,
            Icons.subject,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            'Description',
            'Assessment Description',
            descriptionController,
            Icons.description,
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          _buildDropdownField(
            'Type',
            selectedType,
            assessmentTypes,
            Icons.category,
            (value) => setState(() => selectedType = value!),
          ),
          const SizedBox(height: 16),
          _buildDropdownField(
            'Class',
            selectedClass,
            classes,
            Icons.school,
            (value) => setState(() => selectedClass = value!),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _createManualAssessment,
            icon: const Icon(Icons.add),
            label: const Text('Create Assessment'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE91E63),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyAssessmentsTab() {
    final sharedService = SharedAssessmentService.instance;

    return Obx(() {
      if (sharedService.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      // Get current user's assessments
      final userService = UserDataService();
      final currentUserEmail =
          userService.getUserByEmail('vijayakumar@vsb.edu')?.email ?? '';
      final myAssessments = sharedService.getAssessmentsByStaff(
        currentUserEmail,
      );

      if (myAssessments.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.assignment, size: 80, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No assessments created yet',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              SizedBox(height: 8),
              Text(
                'Create your first assessment using AI or manually',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: myAssessments.length,
        itemBuilder: (context, index) {
          final assessment = myAssessments[index];
          final completedCount = sharedService.allAssessments
              .where((a) => a.id == assessment.id && a.isCompleted)
              .length;
          final totalStudents = 45; // III CSBS class size
          final completionRate = ((completedCount / totalStudents) * 100)
              .toInt();

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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE91E63),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          assessment.type,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (assessment.isAIGenerated)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.purple,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                size: 12,
                                color: Colors.white,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'AI',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const Spacer(),
                      PopupMenuButton(
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'view',
                            child: Text('View Details'),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text(
                              'Delete',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                        onSelected: (value) async {
                          if (value == 'delete') {
                            await sharedService.deleteAssessment(assessment.id);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    assessment.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${assessment.subject} • ${assessment.totalQuestions} questions • ${assessment.difficulty}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Class: ${assessment.classLevel}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Completion Rate',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              '$completionRate%',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFE91E63),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Students',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              '$completedCount/$totalStudents',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Created',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              '${assessment.createdAt.day}/${assessment.createdAt.month}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildInputField(
    String label,
    String hint,
    TextEditingController controller,
    IconData icon, {
    int maxLines = 1,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE91E63).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFFE91E63), size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE91E63),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
              isDense: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    String value,
    List<String> items,
    IconData icon,
    Function(String?) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE91E63).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFFE91E63), size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE91E63),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            items: items
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  void _generateAssessment() async {
    if (subjectController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a subject',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => isGenerating = true);

    try {
      final aiService = AIAssessmentGeneratorService();
      final result = await aiService.generateAssessment(
        subject: subjectController.text,
        classLevel: selectedClass,
        type: selectedType,
        difficulty: selectedDifficulty,
        numberOfQuestions: numberOfQuestions,
        duration: duration,
        includeAnswers: includeAnswers,
      );

      setState(() => isGenerating = false);

      if (result['success'] == true) {
        final assessment = result['assessment'];
        final isFallback = assessment['isFallback'] ?? false;

        // Show the generated assessment in a dialog
        _showGeneratedAssessmentDialog(assessment);

        Get.snackbar(
          'Success',
          isFallback
              ? 'Sample assessment generated! (AI service unavailable)'
              : 'AI Assessment generated successfully with ${assessment['totalQuestions']} questions!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        // Save to shared assessment service
        final userService = UserDataService();
        final currentUser = await userService.getCurrentUser();

        final sharedService = SharedAssessmentService.instance;
        await sharedService.createAssessment(
          title: assessment['title'],
          subject: assessment['subject'],
          type: assessment['type'],
          difficulty: assessment['difficulty'],
          totalQuestions: assessment['totalQuestions'],
          duration: assessment['duration'],
          classLevel: assessment['classLevel'],
          createdBy: currentUser?.email ?? 'unknown',
          createdByName: currentUser?.name ?? 'Unknown',
          questions: assessment['questions'],
          isAIGenerated: !isFallback,
        );

        // Also save to staff controller for backward compatibility
        staffController.createAssessment({
          'title': assessment['title'],
          'subject': assessment['subject'],
          'type': assessment['type'],
          'difficulty': assessment['difficulty'],
          'totalQuestions': assessment['totalQuestions'],
          'duration': assessment['duration'],
          'questions': assessment['questions'],
          'classLevel': assessment['classLevel'],
        });
      } else {
        throw Exception('Generation failed');
      }
    } catch (e) {
      setState(() => isGenerating = false);
      Get.snackbar(
        'Error',
        'Failed to generate assessment: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    }
  }

  void _showGeneratedAssessmentDialog(Map<String, dynamic> assessment) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFE91E63), Color(0xFFF48FB1)],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Generated Assessment',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        assessment['title'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          Chip(
                            label: Text(assessment['classLevel']),
                            backgroundColor: Colors.blue.shade100,
                          ),
                          Chip(
                            label: Text(assessment['difficulty']),
                            backgroundColor: Colors.orange.shade100,
                          ),
                          Chip(
                            label: Text(
                              '${assessment['totalQuestions']} questions',
                            ),
                            backgroundColor: Colors.green.shade100,
                          ),
                          Chip(
                            label: Text('${assessment['duration']} min'),
                            backgroundColor: Colors.purple.shade100,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Questions Preview:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...List.generate(
                        (assessment['questions'] as List).length > 5
                            ? 5
                            : (assessment['questions'] as List).length,
                        (index) {
                          final question = assessment['questions'][index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Q${index + 1}. ${question['question']}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ...List.generate(
                                    (question['options'] as List).length,
                                    (optIndex) => Padding(
                                      padding: const EdgeInsets.only(
                                        left: 16,
                                        top: 4,
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 24,
                                            height: 24,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color:
                                                  question['correctAnswer'] ==
                                                      optIndex
                                                  ? Colors.green.shade100
                                                  : Colors.grey.shade200,
                                            ),
                                            child: Center(
                                              child: Text(
                                                String.fromCharCode(
                                                  65 + optIndex,
                                                ),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      question['correctAnswer'] ==
                                                          optIndex
                                                      ? Colors.green.shade700
                                                      : Colors.grey.shade700,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              question['options'][optIndex],
                                              style: TextStyle(
                                                color:
                                                    question['correctAnswer'] ==
                                                        optIndex
                                                    ? Colors.green.shade700
                                                    : Colors.black87,
                                                fontWeight:
                                                    question['correctAnswer'] ==
                                                        optIndex
                                                    ? FontWeight.w600
                                                    : FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (question['explanation'] != null) ...[
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.lightbulb,
                                            size: 16,
                                            color: Colors.blue.shade700,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              question['explanation'],
                                              style: TextStyle(
                                                fontSize: 12,
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
                          );
                        },
                      ),
                      if ((assessment['questions'] as List).length > 5)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            '... and ${(assessment['questions'] as List).length - 5} more questions',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  border: Border(top: BorderSide(color: Colors.grey.shade300)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          // Export functionality can be added here
                        },
                        icon: const Icon(Icons.download),
                        label: const Text('Export'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _tabController.animateTo(2);
                        },
                        icon: const Icon(Icons.check),
                        label: const Text('Save & View'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE91E63),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _createManualAssessment() async {
    if (titleController.text.isEmpty || subjectController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill all required fields',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Get current user
    final userService = UserDataService();
    final currentUser = await userService.getCurrentUser();

    // Create sample questions for manual assessment
    final sampleQuestions = List.generate(
      10,
      (index) => {
        'question': 'Question ${index + 1} for ${subjectController.text}',
        'options': ['Option A', 'Option B', 'Option C', 'Option D'],
        'correctAnswer': 0,
        'explanation': 'This is a manually created question.',
      },
    );

    // Save to shared assessment service
    final sharedService = SharedAssessmentService.instance;
    await sharedService.createAssessment(
      title: titleController.text,
      subject: subjectController.text,
      type: selectedType,
      difficulty: selectedDifficulty,
      totalQuestions: 10,
      duration: 30,
      classLevel: selectedClass,
      createdBy: currentUser?.email ?? 'unknown',
      createdByName: currentUser?.name ?? 'Unknown',
      questions: sampleQuestions,
      isAIGenerated: false,
    );

    // Also save to staff controller
    staffController.createAssessment({
      'title': titleController.text,
      'subject': subjectController.text,
    });

    titleController.clear();
    subjectController.clear();
    descriptionController.clear();
    _tabController.animateTo(2);
  }
}
