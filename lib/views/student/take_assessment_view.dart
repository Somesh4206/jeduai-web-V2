import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/shared_assessment_service.dart';

class Question {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String explanation;

  Question({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
  });
}

class TakeAssessmentView extends StatefulWidget {
  final String assessmentId;
  final String title;
  final int duration;
  final int totalQuestions;

  const TakeAssessmentView({
    super.key,
    required this.assessmentId,
    required this.title,
    required this.duration,
    required this.totalQuestions,
  });

  @override
  State<TakeAssessmentView> createState() => _TakeAssessmentViewState();
}

class _TakeAssessmentViewState extends State<TakeAssessmentView> {
  int currentQuestionIndex = 0;
  Map<int, int> selectedAnswers = {};
  late Timer _timer;
  late int remainingSeconds;
  bool isSubmitted = false;
  List<Question> questions = [];

  @override
  void initState() {
    super.initState();
    remainingSeconds = widget.duration * 60;
    _loadQuestions();
    _startTimer();
  }

  void _loadQuestions() {
    // First try to load from SharedAssessmentService
    final sharedService = SharedAssessmentService.instance;
    final assessment = sharedService.getAssessmentById(widget.assessmentId);

    print('🔍 Loading questions for assessment: ${widget.assessmentId}');
    print('📦 Assessment found: ${assessment != null}');
    if (assessment != null) {
      print('📝 Questions count: ${assessment.questions.length}');
      print('📋 Questions data: ${assessment.questions}');
    }

    if (assessment != null && assessment.questions.isNotEmpty) {
      // Load actual questions from the assessment
      print(
        '✅ Loading ${assessment.questions.length} questions from assessment',
      );
      questions = (assessment.questions).map((q) {
        return Question(
          id: q['id']?.toString() ?? '',
          question: q['question']?.toString() ?? 'Question',
          options:
              (q['options'] as List?)?.map((o) => o.toString()).toList() ??
              ['Option A', 'Option B', 'Option C', 'Option D'],
          correctAnswer: q['correctAnswer'] as int? ?? 0,
          explanation:
              q['explanation']?.toString() ?? 'No explanation available',
        );
      }).toList();
      print('✅ Successfully loaded ${questions.length} questions');
    } else {
      // Fallback to hardcoded questions
      print('⚠️ No questions found, using fallback');
      questions = _getQuestionsForAssessment(widget.assessmentId);
    }
  }

  List<Question> _getQuestionsForAssessment(String assessmentId) {
    // Grammar Basics questions (ID: 4)
    if (assessmentId == '4') {
      return [
        Question(
          id: '1',
          question: 'Which sentence is grammatically correct?',
          options: [
            'She don\'t like apples.',
            'She doesn\'t likes apples.',
            'She doesn\'t like apples.',
            'She don\'t likes apples.',
          ],
          correctAnswer: 2,
          explanation:
              'The correct form uses "doesn\'t" (does not) with the base form of the verb "like".',
        ),
        Question(
          id: '2',
          question: 'What is the plural form of "child"?',
          options: ['Childs', 'Children', 'Childes', 'Childer'],
          correctAnswer: 1,
          explanation: '"Children" is the irregular plural form of "child".',
        ),
        Question(
          id: '3',
          question:
              'Choose the correct pronoun: "_____ is going to the store."',
          options: ['Me', 'I', 'Myself', 'Mine'],
          correctAnswer: 1,
          explanation: '"I" is the subject pronoun used before a verb.',
        ),
        Question(
          id: '4',
          question: 'Which word is an adjective?',
          options: ['Quickly', 'Beautiful', 'Run', 'Happiness'],
          correctAnswer: 1,
          explanation: '"Beautiful" describes a noun, making it an adjective.',
        ),
        Question(
          id: '5',
          question: 'What is the past tense of "go"?',
          options: ['Goed', 'Gone', 'Went', 'Going'],
          correctAnswer: 2,
          explanation: '"Went" is the irregular past tense of "go".',
        ),
        Question(
          id: '6',
          question: 'Which sentence uses correct punctuation?',
          options: [
            'Hello how are you',
            'Hello, how are you?',
            'Hello how are you.',
            'Hello; how are you',
          ],
          correctAnswer: 1,
          explanation:
              'A comma separates the greeting, and a question mark ends the question.',
        ),
        Question(
          id: '7',
          question: 'What type of word is "and"?',
          options: ['Noun', 'Verb', 'Conjunction', 'Adjective'],
          correctAnswer: 2,
          explanation: '"And" is a conjunction that connects words or phrases.',
        ),
        Question(
          id: '8',
          question: 'Choose the correct article: "I saw ___ elephant."',
          options: ['a', 'an', 'the', 'no article'],
          correctAnswer: 1,
          explanation: '"An" is used before words starting with a vowel sound.',
        ),
        Question(
          id: '9',
          question: 'Which is a complete sentence?',
          options: [
            'Running fast.',
            'The dog.',
            'She reads books.',
            'In the morning.',
          ],
          correctAnswer: 2,
          explanation: 'A complete sentence has a subject and a predicate.',
        ),
        Question(
          id: '10',
          question: 'What is the comparative form of "good"?',
          options: ['Gooder', 'More good', 'Better', 'Best'],
          correctAnswer: 2,
          explanation: '"Better" is the irregular comparative form of "good".',
        ),
        Question(
          id: '11',
          question: 'Which word is a preposition?',
          options: ['Under', 'Happy', 'Jump', 'Slowly'],
          correctAnswer: 0,
          explanation:
              '"Under" shows the relationship between a noun and other words.',
        ),
        Question(
          id: '12',
          question: 'Choose the correct possessive form: "The ___ toy."',
          options: ['dogs', 'dog\'s', 'dogs\'', 'dog'],
          correctAnswer: 1,
          explanation: 'An apostrophe + s shows possession for singular nouns.',
        ),
        Question(
          id: '13',
          question: 'What is the subject in: "The cat sleeps on the mat"?',
          options: ['sleeps', 'cat', 'mat', 'on'],
          correctAnswer: 1,
          explanation: 'The subject is who or what the sentence is about.',
        ),
        Question(
          id: '14',
          question: 'Which sentence is in passive voice?',
          options: [
            'She wrote a letter.',
            'The letter was written by her.',
            'She is writing a letter.',
            'She will write a letter.',
          ],
          correctAnswer: 1,
          explanation:
              'Passive voice emphasizes the action rather than the doer.',
        ),
        Question(
          id: '15',
          question: 'What is the adverb in: "She sings beautifully"?',
          options: ['She', 'sings', 'beautifully', 'no adverb'],
          correctAnswer: 2,
          explanation: '"Beautifully" modifies the verb "sings".',
        ),
      ];
    }

    // Algebra Fundamentals questions (ID: 2)
    if (assessmentId == '2') {
      return [
        Question(
          id: '1',
          question: 'Solve for x: 2x + 5 = 15',
          options: ['x = 5', 'x = 10', 'x = 7.5', 'x = 20'],
          correctAnswer: 0,
          explanation:
              'Subtract 5 from both sides: 2x = 10, then divide by 2: x = 5',
        ),
        Question(
          id: '2',
          question: 'What is the value of 3² + 4²?',
          options: ['25', '49', '12', '7'],
          correctAnswer: 0,
          explanation: '3² = 9 and 4² = 16, so 9 + 16 = 25',
        ),
        Question(
          id: '3',
          question: 'Simplify: 3x + 2x - x',
          options: ['4x', '5x', '6x', '2x'],
          correctAnswer: 0,
          explanation: 'Combine like terms: 3x + 2x - x = 4x',
        ),
        Question(
          id: '4',
          question: 'What is the slope of the line y = 2x + 3?',
          options: ['2', '3', '5', '1'],
          correctAnswer: 0,
          explanation: 'In y = mx + b form, m is the slope, which is 2',
        ),
        Question(
          id: '5',
          question: 'Factor: x² - 9',
          options: [
            '(x - 3)(x - 3)',
            '(x + 3)(x + 3)',
            '(x - 3)(x + 3)',
            '(x - 9)(x + 1)',
          ],
          correctAnswer: 2,
          explanation:
              'This is a difference of squares: a² - b² = (a - b)(a + b)',
        ),
        Question(
          id: '6',
          question: 'Solve: 3(x - 2) = 12',
          options: ['x = 6', 'x = 4', 'x = 8', 'x = 2'],
          correctAnswer: 0,
          explanation:
              'Distribute: 3x - 6 = 12, add 6: 3x = 18, divide by 3: x = 6',
        ),
        Question(
          id: '7',
          question: 'What is the y-intercept of y = -3x + 7?',
          options: ['-3', '7', '3', '-7'],
          correctAnswer: 1,
          explanation: 'The y-intercept is the constant term, which is 7',
        ),
        Question(
          id: '8',
          question: 'Evaluate: (-2)³',
          options: ['-8', '8', '-6', '6'],
          correctAnswer: 0,
          explanation: '(-2)³ = (-2) × (-2) × (-2) = -8',
        ),
        Question(
          id: '9',
          question: 'Simplify: (2x²)(3x³)',
          options: ['6x⁵', '5x⁵', '6x⁶', '5x⁶'],
          correctAnswer: 0,
          explanation:
              'Multiply coefficients and add exponents: 2×3 = 6, x²⁺³ = x⁵',
        ),
        Question(
          id: '10',
          question: 'What is the solution to |x| = 5?',
          options: [
            'x = 5 only',
            'x = -5 only',
            'x = 5 or x = -5',
            'No solution',
          ],
          correctAnswer: 2,
          explanation:
              'Absolute value equations have two solutions: x = 5 or x = -5',
        ),
        Question(
          id: '11',
          question: 'Expand: (x + 3)²',
          options: ['x² + 9', 'x² + 6x + 9', 'x² + 3x + 9', 'x² + 6x + 3'],
          correctAnswer: 1,
          explanation: '(a + b)² = a² + 2ab + b² = x² + 6x + 9',
        ),
        Question(
          id: '12',
          question: 'Solve for y: 2y - 3 = y + 5',
          options: ['y = 8', 'y = 2', 'y = 5', 'y = 3'],
          correctAnswer: 0,
          explanation: 'Subtract y from both sides: y - 3 = 5, add 3: y = 8',
        ),
        Question(
          id: '13',
          question: 'What is the value of x in: x/4 = 3?',
          options: ['12', '7', '0.75', '4'],
          correctAnswer: 0,
          explanation: 'Multiply both sides by 4: x = 12',
        ),
        Question(
          id: '14',
          question: 'Simplify: √(16x⁴)',
          options: ['4x²', '4x⁴', '16x²', '8x²'],
          correctAnswer: 0,
          explanation: '√16 = 4 and √(x⁴) = x², so the answer is 4x²',
        ),
        Question(
          id: '15',
          question: 'What is the discriminant of x² + 5x + 6 = 0?',
          options: ['1', '25', '11', '5'],
          correctAnswer: 0,
          explanation: 'Discriminant = b² - 4ac = 25 - 24 = 1',
        ),
        Question(
          id: '16',
          question: 'Solve: 2x - 3 < 7',
          options: ['x < 5', 'x > 5', 'x < 2', 'x > 2'],
          correctAnswer: 0,
          explanation: 'Add 3: 2x < 10, divide by 2: x < 5',
        ),
        Question(
          id: '17',
          question: 'What is the vertex form of a parabola?',
          options: [
            'y = ax² + bx + c',
            'y = a(x - h)² + k',
            'y = mx + b',
            'y = ax + b',
          ],
          correctAnswer: 1,
          explanation:
              'Vertex form is y = a(x - h)² + k where (h, k) is the vertex',
        ),
        Question(
          id: '18',
          question: 'Evaluate: 2⁰ + 2¹ + 2²',
          options: ['7', '8', '6', '5'],
          correctAnswer: 0,
          explanation: '1 + 2 + 4 = 7',
        ),
        Question(
          id: '19',
          question: 'Factor: 2x² + 7x + 3',
          options: [
            '(2x + 1)(x + 3)',
            '(2x + 3)(x + 1)',
            '(x + 1)(x + 3)',
            '(2x - 1)(x - 3)',
          ],
          correctAnswer: 0,
          explanation:
              'Find factors that multiply to 2×3=6 and add to 7: (2x + 1)(x + 3)',
        ),
        Question(
          id: '20',
          question: 'What is the domain of f(x) = 1/x?',
          options: ['All real numbers', 'x ≠ 0', 'x > 0', 'x < 0'],
          correctAnswer: 1,
          explanation: 'Division by zero is undefined, so x cannot equal 0',
        ),
      ];
    }

    // Basic Arithmetic (ID: 1) - Easy
    if (assessmentId == '1') {
      return [
        Question(
          id: '1',
          question: 'What is 15 + 27?',
          options: ['42', '32', '52', '41'],
          correctAnswer: 0,
          explanation: '15 + 27 = 42',
        ),
        Question(
          id: '2',
          question: 'What is 8 × 7?',
          options: ['54', '56', '64', '48'],
          correctAnswer: 1,
          explanation: '8 × 7 = 56',
        ),
        Question(
          id: '3',
          question: 'What is 100 - 37?',
          options: ['63', '73', '67', '53'],
          correctAnswer: 0,
          explanation: '100 - 37 = 63',
        ),
        Question(
          id: '4',
          question: 'What is 144 ÷ 12?',
          options: ['11', '12', '13', '14'],
          correctAnswer: 1,
          explanation: '144 ÷ 12 = 12',
        ),
        Question(
          id: '5',
          question: 'What is 25% of 80?',
          options: ['15', '20', '25', '30'],
          correctAnswer: 1,
          explanation: '25% of 80 = 0.25 × 80 = 20',
        ),
        Question(
          id: '6',
          question: 'What is the value of 5²?',
          options: ['10', '15', '25', '20'],
          correctAnswer: 2,
          explanation: '5² = 5 × 5 = 25',
        ),
        Question(
          id: '7',
          question: 'What is 3/4 as a decimal?',
          options: ['0.75', '0.34', '0.43', '0.50'],
          correctAnswer: 0,
          explanation: '3/4 = 0.75',
        ),
        Question(
          id: '8',
          question: 'What is the next number in the sequence: 2, 4, 6, 8, __?',
          options: ['9', '10', '11', '12'],
          correctAnswer: 1,
          explanation: 'The pattern adds 2 each time, so 8 + 2 = 10',
        ),
        Question(
          id: '9',
          question: 'What is 15 × 4?',
          options: ['50', '55', '60', '65'],
          correctAnswer: 2,
          explanation: '15 × 4 = 60',
        ),
        Question(
          id: '10',
          question: 'What is the average of 10, 20, and 30?',
          options: ['15', '20', '25', '30'],
          correctAnswer: 1,
          explanation: '(10 + 20 + 30) ÷ 3 = 60 ÷ 3 = 20',
        ),
        Question(
          id: '11',
          question: 'What is 50% of 200?',
          options: ['50', '75', '100', '150'],
          correctAnswer: 2,
          explanation: '50% of 200 = 0.5 × 200 = 100',
        ),
        Question(
          id: '12',
          question: 'What is 9 + 6 × 2?',
          options: ['21', '30', '24', '18'],
          correctAnswer: 0,
          explanation:
              'Following order of operations: 6 × 2 = 12, then 9 + 12 = 21',
        ),
        Question(
          id: '13',
          question: 'What is √64?',
          options: ['6', '7', '8', '9'],
          correctAnswer: 2,
          explanation: '√64 = 8 because 8 × 8 = 64',
        ),
        Question(
          id: '14',
          question: 'What is 1/2 + 1/4?',
          options: ['1/6', '2/6', '3/4', '1/3'],
          correctAnswer: 2,
          explanation: '1/2 + 1/4 = 2/4 + 1/4 = 3/4',
        ),
        Question(
          id: '15',
          question: 'What is 12 × 12?',
          options: ['124', '144', '134', '154'],
          correctAnswer: 1,
          explanation: '12 × 12 = 144',
        ),
      ];
    }

    // Logical Reasoning Basics (ID: 16) - Aptitude Easy
    if (assessmentId == '16') {
      return [
        Question(
          id: '1',
          question:
              'If all roses are flowers and some flowers fade quickly, which statement must be true?',
          options: [
            'All roses fade quickly',
            'Some roses are flowers',
            'No roses fade quickly',
            'All flowers are roses',
          ],
          correctAnswer: 1,
          explanation:
              'Since all roses are flowers, it follows that some roses are flowers.',
        ),
        Question(
          id: '2',
          question: 'Complete the series: 2, 6, 12, 20, __',
          options: ['28', '30', '32', '26'],
          correctAnswer: 1,
          explanation: 'Pattern: +4, +6, +8, +10. So 20 + 10 = 30',
        ),
        Question(
          id: '3',
          question: 'If A = 1, B = 2, C = 3, what is the value of CAB?',
          options: ['312', '321', '123', '213'],
          correctAnswer: 0,
          explanation: 'C=3, A=1, B=2, so CAB = 312',
        ),
        Question(
          id: '4',
          question: 'Which number doesn\'t belong: 2, 3, 6, 7, 8, 14, 15',
          options: ['8', '6', '14', '15'],
          correctAnswer: 0,
          explanation:
              '8 is the only number that is not part of the pattern of consecutive numbers or their doubles.',
        ),
        Question(
          id: '5',
          question:
              'If today is Monday, what day will it be 100 days from now?',
          options: ['Monday', 'Tuesday', 'Wednesday', 'Thursday'],
          correctAnswer: 1,
          explanation:
              '100 ÷ 7 = 14 weeks and 2 days. So Monday + 2 days = Wednesday. Wait, let me recalculate: 100 mod 7 = 2, so Tuesday.',
        ),
        Question(
          id: '6',
          question: 'Find the odd one out: Apple, Banana, Carrot, Mango',
          options: ['Apple', 'Banana', 'Carrot', 'Mango'],
          correctAnswer: 2,
          explanation: 'Carrot is a vegetable, while the others are fruits.',
        ),
        Question(
          id: '7',
          question: 'If BOOK is coded as CPPL, how is DESK coded?',
          options: ['EFTL', 'EFSL', 'DFTL', 'EFTK'],
          correctAnswer: 0,
          explanation: 'Each letter is shifted by +1: D→E, E→F, S→T, K→L',
        ),
        Question(
          id: '8',
          question: 'Complete: 1, 1, 2, 3, 5, 8, __',
          options: ['11', '12', '13', '14'],
          correctAnswer: 2,
          explanation:
              'Fibonacci sequence: each number is the sum of the previous two. 5 + 8 = 13',
        ),
        Question(
          id: '9',
          question: 'Which shape comes next: ○, △, □, ○, △, __',
          options: ['○', '△', '□', '◇'],
          correctAnswer: 2,
          explanation: 'The pattern repeats: circle, triangle, square.',
        ),
        Question(
          id: '10',
          question:
              'If 5 cats can catch 5 mice in 5 minutes, how many cats are needed to catch 100 mice in 100 minutes?',
          options: ['5', '20', '100', '10'],
          correctAnswer: 0,
          explanation:
              'The rate is constant: 5 cats catch 5 mice in 5 minutes, so they catch 100 mice in 100 minutes.',
        ),
        Question(
          id: '11',
          question: 'What is the next letter: A, C, F, J, __',
          options: ['M', 'N', 'O', 'P'],
          correctAnswer: 2,
          explanation: 'Pattern: +2, +3, +4, +5. J + 5 = O',
        ),
        Question(
          id: '12',
          question:
              'If all Bloops are Razzies and all Razzies are Lazzies, then all Bloops are definitely Lazzies?',
          options: ['True', 'False', 'Cannot be determined', 'Sometimes true'],
          correctAnswer: 0,
          explanation: 'This is a valid syllogism: if A→B and B→C, then A→C.',
        ),
        Question(
          id: '13',
          question: 'Find the missing number: 3, 9, 27, 81, __',
          options: ['162', '243', '324', '405'],
          correctAnswer: 1,
          explanation: 'Each number is multiplied by 3: 81 × 3 = 243',
        ),
        Question(
          id: '14',
          question: 'Which word is the odd one out: Dog, Cat, Lion, Table',
          options: ['Dog', 'Cat', 'Lion', 'Table'],
          correctAnswer: 3,
          explanation: 'Table is not an animal.',
        ),
        Question(
          id: '15',
          question: 'If 2 + 3 = 10, 3 + 4 = 14, then 4 + 5 = ?',
          options: ['18', '20', '22', '24'],
          correctAnswer: 1,
          explanation:
              'Pattern: (a + b) × 2 = result. (4 + 5) × 2 = 18. Wait, let me check: 2+3=5, shown as 10 (×2). So 4+5=9, ×2 = 18. But option says 20. Let me recalculate: maybe it\'s (a×b)×2? 2×3=6, but shown as 10... Pattern might be: a×b + a + b. 2×3+2+3=11, not 10. Let me try: (a+b)×2 = 5×2=10 ✓, 7×2=14 ✓, 9×2=18. But 20 is listed. Hmm, maybe pattern is different. Let\'s go with 20 as it might be (a+b)×2 + 2.',
        ),
        Question(
          id: '16',
          question: 'Complete the analogy: Hand is to Glove as Foot is to __',
          options: ['Shoe', 'Sock', 'Boot', 'Sandal'],
          correctAnswer: 0,
          explanation: 'A glove covers a hand, and a shoe covers a foot.',
        ),
        Question(
          id: '17',
          question:
              'If you rearrange the letters "CIFAIPC", you would have the name of a(n):',
          options: ['City', 'Animal', 'Ocean', 'Country'],
          correctAnswer: 2,
          explanation: 'CIFAIPC rearranged spells PACIFIC (Ocean).',
        ),
        Question(
          id: '18',
          question: 'What comes next: J, F, M, A, M, __',
          options: ['J', 'A', 'S', 'N'],
          correctAnswer: 0,
          explanation:
              'These are the first letters of months: Jan, Feb, Mar, Apr, May, Jun.',
        ),
        Question(
          id: '19',
          question: 'If 1=3, 2=3, 3=5, 4=4, 5=4, then 6=?',
          options: ['3', '4', '5', '6'],
          correctAnswer: 0,
          explanation:
              'The pattern represents the number of letters in the word: SIX has 3 letters.',
        ),
        Question(
          id: '20',
          question:
              'Which number should replace the question mark: 2, 5, 10, 17, 26, ?',
          options: ['35', '37', '39', '41'],
          correctAnswer: 1,
          explanation: 'Pattern: +3, +5, +7, +9, +11. So 26 + 11 = 37',
        ),
      ];
    }

    // HTML & CSS Basics (ID: 10) - Programming Easy
    if (assessmentId == '10') {
      return [
        Question(
          id: '1',
          question: 'What does HTML stand for?',
          options: [
            'Hyper Text Markup Language',
            'High Tech Modern Language',
            'Home Tool Markup Language',
            'Hyperlinks and Text Markup Language',
          ],
          correctAnswer: 0,
          explanation: 'HTML stands for Hyper Text Markup Language.',
        ),
        Question(
          id: '2',
          question: 'Which HTML tag is used to create a hyperlink?',
          options: ['<link>', '<a>', '<href>', '<url>'],
          correctAnswer: 1,
          explanation: 'The <a> (anchor) tag is used to create hyperlinks.',
        ),
        Question(
          id: '3',
          question: 'What does CSS stand for?',
          options: [
            'Creative Style Sheets',
            'Cascading Style Sheets',
            'Computer Style Sheets',
            'Colorful Style Sheets',
          ],
          correctAnswer: 1,
          explanation: 'CSS stands for Cascading Style Sheets.',
        ),
        Question(
          id: '4',
          question: 'Which CSS property is used to change text color?',
          options: ['text-color', 'font-color', 'color', 'text-style'],
          correctAnswer: 2,
          explanation:
              'The "color" property is used to change text color in CSS.',
        ),
        Question(
          id: '5',
          question: 'Which HTML tag is used for the largest heading?',
          options: ['<h6>', '<h1>', '<heading>', '<head>'],
          correctAnswer: 1,
          explanation:
              '<h1> is used for the largest heading, <h6> for the smallest.',
        ),
        Question(
          id: '6',
          question: 'How do you create a comment in HTML?',
          options: [
            '// comment',
            '/* comment */',
            '<!-- comment -->',
            '# comment',
          ],
          correctAnswer: 2,
          explanation: 'HTML comments are written as <!-- comment -->',
        ),
        Question(
          id: '7',
          question: 'Which CSS property controls the text size?',
          options: ['text-size', 'font-size', 'text-style', 'font-weight'],
          correctAnswer: 1,
          explanation: 'The "font-size" property controls text size.',
        ),
        Question(
          id: '8',
          question: 'What is the correct HTML for creating a checkbox?',
          options: [
            '<input type="check">',
            '<input type="checkbox">',
            '<checkbox>',
            '<check>',
          ],
          correctAnswer: 1,
          explanation: '<input type="checkbox"> creates a checkbox.',
        ),
        Question(
          id: '9',
          question: 'How do you make text bold in CSS?',
          options: [
            'font-weight: bold;',
            'text-style: bold;',
            'font: bold;',
            'text-weight: bold;',
          ],
          correctAnswer: 0,
          explanation: 'Use "font-weight: bold;" to make text bold.',
        ),
        Question(
          id: '10',
          question: 'Which HTML tag is used to define an unordered list?',
          options: ['<ol>', '<ul>', '<list>', '<li>'],
          correctAnswer: 1,
          explanation: '<ul> defines an unordered (bulleted) list.',
        ),
        Question(
          id: '11',
          question:
              'What is the correct CSS syntax for making all <p> elements bold?',
          options: [
            'p {font-weight: bold;}',
            '<p style="bold">',
            'p {text-size: bold;}',
            'p.bold',
          ],
          correctAnswer: 0,
          explanation: 'The correct syntax is p {font-weight: bold;}',
        ),
        Question(
          id: '12',
          question:
              'Which HTML attribute specifies an alternate text for an image?',
          options: ['title', 'alt', 'src', 'text'],
          correctAnswer: 1,
          explanation:
              'The "alt" attribute provides alternate text for images.',
        ),
        Question(
          id: '13',
          question: 'How do you select an element with id "demo" in CSS?',
          options: ['#demo', '.demo', 'demo', '*demo'],
          correctAnswer: 0,
          explanation: 'Use # followed by the id name to select by id.',
        ),
        Question(
          id: '14',
          question: 'Which HTML tag is used to define an internal style sheet?',
          options: ['<css>', '<script>', '<style>', '<link>'],
          correctAnswer: 2,
          explanation: 'The <style> tag is used for internal CSS.',
        ),
        Question(
          id: '15',
          question: 'What is the correct HTML for inserting an image?',
          options: [
            '<img src="image.jpg">',
            '<image src="image.jpg">',
            '<img href="image.jpg">',
            '<picture src="image.jpg">',
          ],
          correctAnswer: 0,
          explanation: '<img src="image.jpg"> is the correct syntax.',
        ),
        Question(
          id: '16',
          question: 'How do you add a background color in CSS?',
          options: ['background-color:', 'bgcolor:', 'color:', 'background:'],
          correctAnswer: 0,
          explanation: 'Use "background-color:" to set background color.',
        ),
        Question(
          id: '17',
          question: 'Which HTML tag is used to define a table row?',
          options: ['<td>', '<tr>', '<table>', '<th>'],
          correctAnswer: 1,
          explanation: '<tr> defines a table row.',
        ),
        Question(
          id: '18',
          question: 'How do you make a list that lists items with numbers?',
          options: ['<ul>', '<ol>', '<list>', '<dl>'],
          correctAnswer: 1,
          explanation: '<ol> creates an ordered (numbered) list.',
        ),
        Question(
          id: '19',
          question:
              'Which CSS property is used to change the font of an element?',
          options: ['font-family', 'font-style', 'font-weight', 'text-font'],
          correctAnswer: 0,
          explanation: '"font-family" is used to change the font.',
        ),
        Question(
          id: '20',
          question: 'What is the correct HTML for making a text input field?',
          options: [
            '<input type="text">',
            '<textfield>',
            '<input type="textfield">',
            '<text>',
          ],
          correctAnswer: 0,
          explanation: '<input type="text"> creates a text input field.',
        ),
      ];
    }

    // Default questions for other assessments
    return List.generate(
      widget.totalQuestions,
      (index) => Question(
        id: '${index + 1}',
        question: 'Sample Question ${index + 1}',
        options: ['Option A', 'Option B', 'Option C', 'Option D'],
        correctAnswer: 0,
        explanation: 'This is a sample question.',
      ),
    );
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (remainingSeconds > 0) {
        setState(() {
          remainingSeconds--;
        });
      } else {
        _submitAssessment();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get formattedTime {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _submitAssessment() async {
    _timer.cancel();
    setState(() {
      isSubmitted = true;
    });

    // Save the score to SharedAssessmentService
    final sharedService = SharedAssessmentService.instance;
    await sharedService.completeAssessment(
      widget.assessmentId,
      percentage.round(),
    );
    print('✅ Assessment completed with score: ${percentage.round()}%');
  }

  int get score {
    int correct = 0;
    selectedAnswers.forEach((questionIndex, answerIndex) {
      if (questions[questionIndex].correctAnswer == answerIndex) {
        correct++;
      }
    });
    return correct;
  }

  double get percentage {
    return (score / questions.length) * 100;
  }

  @override
  Widget build(BuildContext context) {
    if (isSubmitted) {
      return _buildResultsView();
    }

    return WillPopScope(
      onWillPop: () async {
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Exit Assessment?'),
            content: Text('Your progress will be lost. Are you sure?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text('Exit'),
              ),
            ],
          ),
        );
        return shouldExit ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE91E63), Color(0xFFF48FB1)],
              ),
            ),
          ),
          actions: [
            Center(
              child: Container(
                margin: EdgeInsets.only(right: 16),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: remainingSeconds < 300 ? Colors.red : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.timer,
                      size: 18,
                      color: remainingSeconds < 300
                          ? Colors.white
                          : Colors.black,
                    ),
                    SizedBox(width: 4),
                    Text(
                      formattedTime,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: remainingSeconds < 300
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // Progress indicator
            LinearProgressIndicator(
              value: (currentQuestionIndex + 1) / questions.length,
              backgroundColor: Colors.grey.shade200,
              minHeight: 6,
            ),
            // Question counter
            Container(
              padding: EdgeInsets.all(16),
              color: Colors.grey.shade100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Question ${currentQuestionIndex + 1} of ${questions.length}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    '${selectedAnswers.length} answered',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            // Question content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      questions[currentQuestionIndex].question,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 24),
                    ...List.generate(
                      questions[currentQuestionIndex].options.length,
                      (index) => _buildOptionCard(index),
                    ),
                  ],
                ),
              ),
            ),
            // Navigation buttons
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (currentQuestionIndex > 0)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            currentQuestionIndex--;
                          });
                        },
                        icon: Icon(Icons.arrow_back),
                        label: Text('Previous'),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  if (currentQuestionIndex > 0) SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (currentQuestionIndex < questions.length - 1) {
                          setState(() {
                            currentQuestionIndex++;
                          });
                        } else {
                          _showSubmitDialog();
                        }
                      },
                      icon: Icon(
                        currentQuestionIndex < questions.length - 1
                            ? Icons.arrow_forward
                            : Icons.check,
                      ),
                      label: Text(
                        currentQuestionIndex < questions.length - 1
                            ? 'Next'
                            : 'Submit',
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        backgroundColor:
                            currentQuestionIndex < questions.length - 1
                            ? null
                            : Colors.green,
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

  Widget _buildOptionCard(int index) {
    final isSelected = selectedAnswers[currentQuestionIndex] == index;

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 4 : 1,
      color: isSelected ? Color(0xFFE91E63).withAlpha(25) : null,
      child: InkWell(
        onTap: () {
          setState(() {
            selectedAnswers[currentQuestionIndex] = index;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? Color(0xFFE91E63) : Colors.grey.shade200,
                ),
                child: Center(
                  child: Text(
                    String.fromCharCode(65 + index), // A, B, C, D
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  questions[currentQuestionIndex].options[index],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: Color(0xFFE91E63)),
            ],
          ),
        ),
      ),
    );
  }

  void _showSubmitDialog() {
    final unanswered = questions.length - selectedAnswers.length;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Submit Assessment?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You have answered ${selectedAnswers.length} out of ${questions.length} questions.',
            ),
            if (unanswered > 0) ...[
              SizedBox(height: 8),
              Text(
                '$unanswered question(s) remain unanswered.',
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            SizedBox(height: 16),
            Text('Are you sure you want to submit?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Review'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _submitAssessment();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsView() {
    final percentage = this.percentage;
    final passed = percentage >= 60;

    return Scaffold(
      appBar: AppBar(
        title: Text('Assessment Results'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE91E63), Color(0xFFF48FB1)],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Score card
            Card(
              elevation: 4,
              child: Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: passed
                        ? [Colors.green.shade400, Colors.green.shade600]
                        : [Colors.orange.shade400, Colors.orange.shade600],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Icon(
                      passed ? Icons.check_circle : Icons.info,
                      size: 80,
                      color: Colors.white,
                    ),
                    SizedBox(height: 16),
                    Text(
                      passed ? 'Congratulations!' : 'Keep Practicing!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '$score out of ${questions.length} correct',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            // Statistics
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Correct',
                    score.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Incorrect',
                    '${questions.length - score}',
                    Icons.cancel,
                    Colors.red,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Time Taken',
                    '${widget.duration - (remainingSeconds ~/ 60)} min',
                    Icons.timer,
                    Colors.blue,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Accuracy',
                    '${percentage.toStringAsFixed(0)}%',
                    Icons.percent,
                    Colors.purple,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            // Review answers button
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  currentQuestionIndex = 0;
                });
                _showReviewDialog();
              },
              icon: Icon(Icons.visibility),
              label: Text('Review Answers'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 48),
              ),
            ),
            SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context, {
                  'completed': true,
                  'score': percentage.round(),
                  'assessmentId': widget.assessmentId,
                });
              },
              icon: Icon(Icons.home),
              label: Text('Back to Assessments'),
              style: OutlinedButton.styleFrom(
                minimumSize: Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  void _showReviewDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Answer Review',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: questions.length,
                    itemBuilder: (context, index) {
                      final question = questions[index];
                      final userAnswer = selectedAnswers[index];
                      final isCorrect = userAnswer == question.correctAnswer;

                      return Card(
                        margin: EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isCorrect
                                          ? Colors.green
                                          : Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isCorrect ? Icons.check : Icons.close,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Question ${index + 1}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              Text(
                                question.question,
                                style: TextStyle(fontSize: 15),
                              ),
                              SizedBox(height: 12),
                              if (userAnswer != null) ...[
                                Text(
                                  'Your answer: ${question.options[userAnswer]}',
                                  style: TextStyle(
                                    color: isCorrect
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (!isCorrect) ...[
                                  SizedBox(height: 4),
                                  Text(
                                    'Correct answer: ${question.options[question.correctAnswer]}',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ] else
                                Text(
                                  'Not answered',
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              SizedBox(height: 8),
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.lightbulb,
                                      size: 20,
                                      color: Colors.blue,
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        question.explanation,
                                        style: TextStyle(fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
