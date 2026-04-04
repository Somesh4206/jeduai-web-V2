import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InteractiveLessonView extends StatefulWidget {
  final String title;
  final String courseTitle;
  final String description;
  final int duration;

  const InteractiveLessonView({
    super.key,
    required this.title,
    required this.courseTitle,
    required this.description,
    required this.duration,
  });

  @override
  State<InteractiveLessonView> createState() => _InteractiveLessonViewState();
}

class _InteractiveLessonViewState extends State<InteractiveLessonView> {
  int currentStep = 0;
  Map<int, String> answers = {};
  bool showResults = false;
  int score = 0;

  final List<Map<String, dynamic>> steps = [
    {
      'title': 'Introduction',
      'content':
          'Welcome to this interactive lesson! You\'ll learn through hands-on exercises and quizzes.',
      'type': 'info',
    },
    {
      'title': 'Concept Explanation',
      'content':
          'Let\'s start with the basics. This lesson will guide you through key concepts step by step.',
      'type': 'info',
    },
    {
      'title': 'Quiz Question 1',
      'question': 'What is the main purpose of this data structure?',
      'options': [
        'Store data efficiently',
        'Display data',
        'Delete data',
        'None of the above',
      ],
      'correct': 0,
      'type': 'quiz',
    },
    {
      'title': 'Practice Exercise',
      'content':
          'Now try this exercise:\n\nCreate a simple example using what you\'ve learned.',
      'type': 'exercise',
    },
    {
      'title': 'Quiz Question 2',
      'question': 'Which operation is most efficient?',
      'options': [
        'Linear search',
        'Binary search',
        'Random access',
        'Sequential',
      ],
      'correct': 1,
      'type': 'quiz',
    },
    {
      'title': 'Summary',
      'content':
          'Great job! You\'ve completed the interactive lesson. Review your results below.',
      'type': 'summary',
    },
  ];

  void _nextStep() {
    if (currentStep < steps.length - 1) {
      setState(() {
        currentStep++;
      });
    } else {
      _calculateScore();
      setState(() {
        showResults = true;
      });
    }
  }

  void _previousStep() {
    if (currentStep > 0) {
      setState(() {
        currentStep--;
      });
    }
  }

  void _calculateScore() {
    int correct = 0;
    int total = 0;

    for (int i = 0; i < steps.length; i++) {
      if (steps[i]['type'] == 'quiz') {
        total++;
        if (answers[i] != null &&
            int.parse(answers[i]!) == steps[i]['correct']) {
          correct++;
        }
      }
    }

    score = total > 0 ? ((correct / total) * 100).round() : 0;
  }

  @override
  Widget build(BuildContext context) {
    final step = steps[currentStep];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade600, Colors.teal.shade400],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Progress Indicator
          LinearProgressIndicator(
            value: (currentStep + 1) / steps.length,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade600),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Step ${currentStep + 1} of ${steps.length}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${((currentStep + 1) / steps.length * 100).toStringAsFixed(0)}% Complete',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: showResults ? _buildResults() : _buildStepContent(step),
            ),
          ),

          // Navigation Buttons
          if (!showResults)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.2),
                    spreadRadius: 1,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (currentStep > 0)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _previousStep,
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Previous'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  if (currentStep > 0) const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _nextStep,
                      icon: Icon(
                        currentStep == steps.length - 1
                            ? Icons.check_circle
                            : Icons.arrow_forward,
                      ),
                      label: Text(
                        currentStep == steps.length - 1 ? 'Finish' : 'Next',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStepContent(Map<String, dynamic> step) {
    switch (step['type']) {
      case 'quiz':
        return _buildQuiz(step);
      case 'exercise':
        return _buildExercise(step);
      default:
        return _buildInfo(step);
    }
  }

  Widget _buildInfo(Map<String, dynamic> step) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700, size: 30),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  step['title'],
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          step['content'],
          style: const TextStyle(fontSize: 18, height: 1.6),
        ),
      ],
    );
  }

  Widget _buildQuiz(Map<String, dynamic> step) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.quiz, color: Colors.orange.shade700, size: 30),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  step['title'],
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          step['question'],
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),
        ...List.generate(
          step['options'].length,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () {
                setState(() {
                  answers[currentStep] = index.toString();
                });
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: answers[currentStep] == index.toString()
                      ? Colors.green.shade50
                      : Colors.grey.shade100,
                  border: Border.all(
                    color: answers[currentStep] == index.toString()
                        ? Colors.green.shade600
                        : Colors.grey.shade300,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: answers[currentStep] == index.toString()
                            ? Colors.green.shade600
                            : Colors.white,
                        border: Border.all(
                          color: answers[currentStep] == index.toString()
                              ? Colors.green.shade600
                              : Colors.grey.shade400,
                          width: 2,
                        ),
                      ),
                      child: answers[currentStep] == index.toString()
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 20,
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        step['options'][index],
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExercise(Map<String, dynamic> step) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.purple.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.code, color: Colors.purple.shade700, size: 30),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  step['title'],
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          step['content'],
          style: const TextStyle(fontSize: 18, height: 1.6),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            '# Your code here\ndata = [1, 2, 3, 4, 5]\nprint(data)',
            style: TextStyle(
              fontFamily: 'monospace',
              color: Colors.greenAccent,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResults() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: score >= 70
                  ? [Colors.green.shade400, Colors.teal.shade300]
                  : [Colors.orange.shade400, Colors.deepOrange.shade300],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Icon(
                score >= 70 ? Icons.emoji_events : Icons.thumb_up,
                size: 80,
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              const Text(
                'Lesson Complete!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your Score: $score%',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                score >= 70 ? 'Excellent Work!' : 'Good Effort!',
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          onPressed: () {
            Get.back();
            Get.snackbar(
              'Success',
              'Lesson marked as completed',
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
          },
          icon: const Icon(Icons.check_circle),
          label: const Text('Complete Lesson'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade600,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            textStyle: const TextStyle(fontSize: 18),
          ),
        ),
      ],
    );
  }
}
