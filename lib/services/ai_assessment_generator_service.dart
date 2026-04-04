import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/gemini_config.dart';

class AIAssessmentGeneratorService {
  static final AIAssessmentGeneratorService _instance =
      AIAssessmentGeneratorService._internal();
  factory AIAssessmentGeneratorService() => _instance;
  AIAssessmentGeneratorService._internal();

  Future<Map<String, dynamic>> generateAssessment({
    required String subject,
    required String classLevel,
    required String type,
    required String difficulty,
    required int numberOfQuestions,
    required int duration,
    required bool includeAnswers,
  }) async {
    try {
      final prompt = _buildPrompt(
        subject: subject,
        classLevel: classLevel,
        type: type,
        difficulty: difficulty,
        numberOfQuestions: numberOfQuestions,
        includeAnswers: includeAnswers,
      );

      final response = await http.post(
        Uri.parse(
          '${GeminiConfig.baseUrl}/models/${GeminiConfig.modelName}:generateContent?key=${GeminiConfig.apiKey}',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 8192,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Gemini API Response received');

        try {
          final generatedText =
              data['candidates'][0]['content']['parts'][0]['text'];
          print('📝 Generated text length: ${generatedText.length}');

          return _parseGeneratedAssessment(
            generatedText,
            subject,
            classLevel,
            type,
            difficulty,
            numberOfQuestions,
            duration,
          );
        } catch (parseError) {
          print('❌ Error parsing response: $parseError');
          print('Response data: $data');
          rethrow;
        }
      } else {
        print('❌ API Error: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception(
          'Failed to generate assessment: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Error generating assessment: $e');
      print('Stack trace: ${StackTrace.current}');
      // Return a fallback assessment
      return _generateFallbackAssessment(
        subject,
        classLevel,
        type,
        difficulty,
        numberOfQuestions,
        duration,
      );
    }
  }

  String _buildPrompt({
    required String subject,
    required String classLevel,
    required String type,
    required String difficulty,
    required int numberOfQuestions,
    required bool includeAnswers,
  }) {
    return '''
You are an expert educator creating a $difficulty level $type assessment for $classLevel students.

Subject: $subject
Number of Questions: $numberOfQuestions
Difficulty Level: $difficulty
Class Level: $classLevel

IMPORTANT: Respond ONLY with a valid JSON array. Do not include any explanatory text before or after the JSON.

Create exactly $numberOfQuestions multiple-choice questions following this EXACT JSON format:

[
  {
    "id": "1",
    "question": "What is the primary purpose of data normalization in databases?",
    "options": [
      "To increase data redundancy",
      "To reduce data redundancy and improve data integrity",
      "To make queries slower",
      "To increase storage space"
    ],
    "correctAnswer": 1,
    "explanation": "Data normalization reduces redundancy and improves data integrity by organizing data efficiently."
  }
]

Requirements for each question:
1. "id": Sequential number as string ("1", "2", "3"...)
2. "question": Clear, specific question text appropriate for $classLevel
3. "options": Array of exactly 4 answer choices
4. "correctAnswer": Index (0-3) of the correct option
5. "explanation": Brief explanation of why the answer is correct

Question Guidelines:
- Make questions relevant to $subject
- Ensure $difficulty difficulty level
- Cover different topics within the subject
- Make all options plausible
- Avoid ambiguous wording
- Use proper grammar and spelling

Generate ONLY the JSON array now (no other text):
''';
  }

  Map<String, dynamic> _parseGeneratedAssessment(
    String generatedText,
    String subject,
    String classLevel,
    String type,
    String difficulty,
    int numberOfQuestions,
    int duration,
  ) {
    try {
      // Extract JSON from the response
      final jsonStart = generatedText.indexOf('[');
      final jsonEnd = generatedText.lastIndexOf(']') + 1;

      if (jsonStart != -1 && jsonEnd > jsonStart) {
        final jsonString = generatedText.substring(jsonStart, jsonEnd);
        final questions = jsonDecode(jsonString) as List;

        return {
          'success': true,
          'assessment': {
            'title': '$subject $type - $classLevel',
            'subject': subject,
            'classLevel': classLevel,
            'type': type,
            'difficulty': difficulty,
            'totalQuestions': questions.length,
            'duration': duration,
            'questions': questions,
            'generatedAt': DateTime.now().toIso8601String(),
          },
        };
      } else {
        throw Exception('No valid JSON found in response');
      }
    } catch (e) {
      print('Error parsing assessment: $e');
      return _generateFallbackAssessment(
        subject,
        classLevel,
        type,
        difficulty,
        numberOfQuestions,
        duration,
      );
    }
  }

  Map<String, dynamic> _generateFallbackAssessment(
    String subject,
    String classLevel,
    String type,
    String difficulty,
    int numberOfQuestions,
    int duration,
  ) {
    // Generate more realistic sample questions based on subject
    final questions = _generateRealisticQuestions(
      subject,
      difficulty,
      numberOfQuestions,
    );

    return {
      'success': true,
      'assessment': {
        'title': '$subject $type - $classLevel',
        'subject': subject,
        'classLevel': classLevel,
        'type': type,
        'difficulty': difficulty,
        'totalQuestions': numberOfQuestions,
        'duration': duration,
        'questions': questions,
        'generatedAt': DateTime.now().toIso8601String(),
        'isFallback': true,
      },
    };
  }

  List<Map<String, dynamic>> _generateRealisticQuestions(
    String subject,
    String difficulty,
    int count,
  ) {
    // Sample question templates based on common subjects
    final questionTemplates = {
      'Big Data Analytics': [
        {
          'question': 'What is the primary characteristic of Big Data?',
          'options': [
            'Volume, Velocity, Variety',
            'Speed only',
            'Size only',
            'Structure only',
          ],
          'correctAnswer': 0,
          'explanation':
              'Big Data is characterized by the 3 Vs: Volume, Velocity, and Variety.',
        },
        {
          'question':
              'Which tool is commonly used for distributed data processing?',
          'options': ['Hadoop', 'MS Excel', 'Notepad', 'Paint'],
          'correctAnswer': 0,
          'explanation':
              'Hadoop is a framework for distributed storage and processing of big data.',
        },
        {
          'question': 'What does HDFS stand for?',
          'options': [
            'Hadoop Distributed File System',
            'High Data File System',
            'Hybrid Data Format System',
            'Hard Disk File System',
          ],
          'correctAnswer': 0,
          'explanation':
              'HDFS is the primary storage system used by Hadoop applications.',
        },
        {
          'question': 'Which programming model is used in Hadoop?',
          'options': [
            'MapReduce',
            'Object-Oriented',
            'Functional',
            'Procedural',
          ],
          'correctAnswer': 0,
          'explanation':
              'MapReduce is a programming model for processing large data sets with parallel algorithms.',
        },
        {
          'question': 'What is Apache Spark primarily used for?',
          'options': [
            'Fast data processing',
            'Web browsing',
            'Email management',
            'Video editing',
          ],
          'correctAnswer': 0,
          'explanation':
              'Apache Spark is an open-source unified analytics engine for large-scale data processing.',
        },
      ],
      'Data Science': [
        {
          'question': 'What is the first step in the data science process?',
          'options': [
            'Data Collection',
            'Model Deployment',
            'Visualization',
            'Testing',
          ],
          'correctAnswer': 0,
          'explanation':
              'Data collection is the first crucial step in any data science project.',
        },
        {
          'question':
              'Which Python library is most commonly used for data manipulation?',
          'options': ['Pandas', 'Flask', 'Django', 'Tkinter'],
          'correctAnswer': 0,
          'explanation':
              'Pandas is the go-to library for data manipulation and analysis in Python.',
        },
      ],
      'Computer Science': [
        {
          'question': 'What does CPU stand for?',
          'options': [
            'Central Processing Unit',
            'Computer Personal Unit',
            'Central Program Utility',
            'Computer Processing Unit',
          ],
          'correctAnswer': 0,
          'explanation':
              'CPU is the Central Processing Unit, the brain of the computer.',
        },
        {
          'question': 'Which data structure uses LIFO principle?',
          'options': ['Stack', 'Queue', 'Array', 'Tree'],
          'correctAnswer': 0,
          'explanation': 'Stack follows Last In First Out (LIFO) principle.',
        },
      ],
      'Cloud Computing': [
        {
          'question':
              'What are the three main service models of cloud computing?',
          'options': [
            'IaaS, PaaS, SaaS',
            'Hardware, Software, Network',
            'Public, Private, Hybrid',
            'Storage, Compute, Database',
          ],
          'correctAnswer': 0,
          'explanation':
              'The three service models are Infrastructure as a Service (IaaS), Platform as a Service (PaaS), and Software as a Service (SaaS).',
        },
        {
          'question': 'Which company provides AWS cloud services?',
          'options': ['Amazon', 'Google', 'Microsoft', 'IBM'],
          'correctAnswer': 0,
          'explanation': 'Amazon Web Services (AWS) is provided by Amazon.',
        },
      ],
    };

    // Find matching template or use generic
    List<Map<String, dynamic>>? templates;
    for (var key in questionTemplates.keys) {
      if (subject.toLowerCase().contains(key.toLowerCase())) {
        templates = questionTemplates[key];
        break;
      }
    }

    // If no specific template found, create generic questions
    if (templates == null) {
      return List.generate(
        count,
        (index) => {
          'question':
              'Question ${index + 1}: What is an important concept in $subject?',
          'options': [
            'Correct answer for $subject',
            'Incorrect option 1',
            'Incorrect option 2',
            'Incorrect option 3',
          ],
          'correctAnswer': 0,
          'explanation':
              'This is a sample question. Configure Gemini API for AI-generated questions.',
        },
      );
    }

    // Repeat and mix templates to reach desired count
    final questions = <Map<String, dynamic>>[];
    while (questions.length < count) {
      for (var template in templates) {
        if (questions.length >= count) break;
        questions.add(Map<String, dynamic>.from(template));
      }
    }

    return questions.take(count).toList();
  }

  // Quick generation for common subjects
  Future<Map<String, dynamic>> generateQuickAssessment(String subject) async {
    return generateAssessment(
      subject: subject,
      classLevel: 'Class 10',
      type: 'Quiz',
      difficulty: 'Medium',
      numberOfQuestions: 10,
      duration: 15,
      includeAnswers: true,
    );
  }
}
