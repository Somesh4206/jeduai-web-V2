import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'take_assessment_view.dart';
import '../../services/shared_assessment_service.dart';
import '../../services/user_data_service.dart';

class StudentAssessmentView extends StatefulWidget {
  const StudentAssessmentView({super.key});

  @override
  State<StudentAssessmentView> createState() => _StudentAssessmentViewState();
}

class _StudentAssessmentViewState extends State<StudentAssessmentView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String selectedSubject = 'All';
  final SharedAssessmentService sharedService =
      SharedAssessmentService.instance;
  String currentUserClass = 'III CSBS'; // Will be loaded from user data
  bool isAdminStudent = false;

  final List<String> subjects = [
    'All',
    'Data and Information Science',
    'Embedded Systems and IoT',
    'Big Data Analytics',
    'Cloud Computing',
    'Fundamentals of Management',
    'Mathematics',
    'Science',
    'English',
    'History',
    'Programming',
    'Aptitude',
  ];

  // Old static assessments list removed - now using SharedAssessmentService
  /*
  List<Assessment> assessments = [
    // Mathematics - Easy
    Assessment(
      id: '1',
      title: 'Basic Arithmetic',
      subject: 'Mathematics',
      type: 'Quiz',
      totalQuestions: 15,
      duration: 20,
      dueDate: DateTime.now().add(Duration(days: 1)),
      isCompleted: false,
      difficulty: 'Easy',
    ),
    // Mathematics - Medium
    Assessment(
      id: '2',
      title: 'Algebra Fundamentals',
      subject: 'Mathematics',
      type: 'Quiz',
      totalQuestions: 20,
      duration: 30,
      dueDate: DateTime.now().add(Duration(days: 2)),
      isCompleted: false,
      difficulty: 'Medium',
    ),
    // Mathematics - Hard
    Assessment(
      id: '3',
      title: 'Calculus Advanced',
      subject: 'Mathematics',
      type: 'Exam',
      totalQuestions: 50,
      duration: 120,
      dueDate: DateTime.now().add(Duration(days: 10)),
      isCompleted: false,
      difficulty: 'Hard',
    ),

    // English - Easy
    Assessment(
      id: '4',
      title: 'Grammar Basics',
      subject: 'English',
      type: 'Quiz',
      totalQuestions: 15,
      duration: 20,
      dueDate: DateTime.now().add(Duration(days: 1)),
      isCompleted: false,
      difficulty: 'Easy',
    ),
    // English - Medium
    Assessment(
      id: '5',
      title: 'Vocabulary Builder',
      subject: 'English',
      type: 'Quiz',
      totalQuestions: 25,
      duration: 30,
      dueDate: DateTime.now().add(Duration(days: 3)),
      isCompleted: false,
      difficulty: 'Medium',
    ),
    // English - Hard
    Assessment(
      id: '6',
      title: 'Advanced Comprehension',
      subject: 'English',
      type: 'Test',
      totalQuestions: 35,
      duration: 60,
      dueDate: DateTime.now().add(Duration(days: 7)),
      isCompleted: false,
      difficulty: 'Hard',
    ),

    // Science - Easy
    Assessment(
      id: '7',
      title: 'Basic Physics',
      subject: 'Science',
      type: 'Quiz',
      totalQuestions: 15,
      duration: 25,
      dueDate: DateTime.now().add(Duration(days: 2)),
      isCompleted: false,
      difficulty: 'Easy',
    ),
    // Science - Medium
    Assessment(
      id: '8',
      title: 'Chemistry Fundamentals',
      subject: 'Science',
      type: 'Test',
      totalQuestions: 30,
      duration: 45,
      dueDate: DateTime.now().add(Duration(days: 4)),
      isCompleted: false,
      difficulty: 'Medium',
    ),
    // Science - Hard
    Assessment(
      id: '9',
      title: 'Physics Mid-term',
      subject: 'Science',
      type: 'Exam',
      totalQuestions: 40,
      duration: 90,
      dueDate: DateTime.now().add(Duration(days: 5)),
      isCompleted: false,
      difficulty: 'Hard',
    ),

    // Programming - Easy
    Assessment(
      id: '10',
      title: 'HTML & CSS Basics',
      subject: 'Programming',
      type: 'Quiz',
      totalQuestions: 20,
      duration: 25,
      dueDate: DateTime.now().add(Duration(days: 2)),
      isCompleted: false,
      difficulty: 'Easy',
    ),
    // Programming - Medium
    Assessment(
      id: '11',
      title: 'Python Fundamentals',
      subject: 'Programming',
      type: 'Quiz',
      totalQuestions: 25,
      duration: 40,
      dueDate: DateTime.now().add(Duration(days: 3)),
      isCompleted: false,
      difficulty: 'Medium',
    ),
    // Programming - Hard
    Assessment(
      id: '12',
      title: 'Data Structures & Algorithms',
      subject: 'Programming',
      type: 'Test',
      totalQuestions: 35,
      duration: 75,
      dueDate: DateTime.now().add(Duration(days: 8)),
      isCompleted: false,
      difficulty: 'Hard',
    ),

    // History - Easy
    Assessment(
      id: '13',
      title: 'Ancient Civilizations',
      subject: 'History',
      type: 'Quiz',
      totalQuestions: 15,
      duration: 20,
      dueDate: DateTime.now().add(Duration(days: 3)),
      isCompleted: false,
      difficulty: 'Easy',
    ),
    // History - Medium
    Assessment(
      id: '14',
      title: 'World War II',
      subject: 'History',
      type: 'Test',
      totalQuestions: 30,
      duration: 50,
      dueDate: DateTime.now().add(Duration(days: 6)),
      isCompleted: false,
      difficulty: 'Medium',
    ),
    // History - Hard
    Assessment(
      id: '15',
      title: 'Modern History Analysis',
      subject: 'History',
      type: 'Exam',
      totalQuestions: 40,
      duration: 90,
      dueDate: DateTime.now().add(Duration(days: 12)),
      isCompleted: false,
      difficulty: 'Hard',
    ),

    // Aptitude - Easy
    Assessment(
      id: '16',
      title: 'Logical Reasoning Basics',
      subject: 'Aptitude',
      type: 'Quiz',
      totalQuestions: 20,
      duration: 30,
      dueDate: DateTime.now().add(Duration(days: 2)),
      isCompleted: false,
      difficulty: 'Easy',
    ),
    // Aptitude - Medium
    Assessment(
      id: '17',
      title: 'Quantitative Aptitude',
      subject: 'Aptitude',
      type: 'Test',
      totalQuestions: 30,
      duration: 45,
      dueDate: DateTime.now().add(Duration(days: 4)),
      isCompleted: false,
      difficulty: 'Medium',
    ),
    // Aptitude - Hard
    Assessment(
      id: '18',
      title: 'Advanced Problem Solving',
      subject: 'Aptitude',
      type: 'Test',
      totalQuestions: 40,
      duration: 60,
      dueDate: DateTime.now().add(Duration(days: 9)),
      isCompleted: false,
      difficulty: 'Hard',
    ),

    // Completed Assessments
    Assessment(
      id: '19',
      title: 'Basic Programming',
      subject: 'Programming',
      type: 'Quiz',
      totalQuestions: 20,
      duration: 30,
      dueDate: DateTime.now().subtract(Duration(days: 2)),
      score: 92,
      isCompleted: true,
      difficulty: 'Easy',
    ),
    Assessment(
      id: '20',
      title: 'English Grammar Test',
      subject: 'English',
      type: 'Test',
      totalQuestions: 25,
      duration: 40,
      dueDate: DateTime.now().subtract(Duration(days: 5)),
      score: 88,
      isCompleted: true,
      difficulty: 'Medium',
    ),
    Assessment(
      id: '21',
      title: 'Mathematics Quiz',
      subject: 'Mathematics',
      type: 'Quiz',
      totalQuestions: 15,
      duration: 20,
      dueDate: DateTime.now().subtract(Duration(days: 3)),
      score: 95,
      isCompleted: true,
      difficulty: 'Easy',
    ),
  ];
  */

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userService = UserDataService();
    final currentUser = await userService.getCurrentUser();
    if (currentUser != null) {
      setState(() {
        currentUserClass = currentUser.className ?? 'III CSBS';
        isAdminStudent = currentUser.className == 'ALL';
        print('👤 Current User: ${currentUser.email}');
        print('📚 Class: $currentUserClass');
        print('🔑 Is Admin Student: $isAdminStudent');
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<AssessmentData> get allAvailableAssessments {
    // If admin student, show all assessments (including pre-defined ones)
    if (isAdminStudent) {
      print(
        '✅ Admin Student: Showing ALL ${sharedService.allAssessments.length} assessments',
      );
      return sharedService.allAssessments;
    }
    // Otherwise, show only assessments for student's class (excluding pre-defined system assessments)
    final classAssessments = sharedService
        .getAssessmentsForClass(currentUserClass)
        .where(
          (a) => !a.id.startsWith('PREDEFINED_'),
        ) // Hide pre-defined assessments from regular students
        .toList();
    print(
      '📋 Regular Student: Showing ${classAssessments.length} assessments for $currentUserClass (excluding pre-defined)',
    );
    return classAssessments;
  }

  List<AssessmentData> get filteredAssessments {
    var filtered = allAvailableAssessments;
    if (selectedSubject != 'All') {
      filtered = filtered
          .where(
            (a) =>
                a.subject.toLowerCase().contains(selectedSubject.toLowerCase()),
          )
          .toList();
    }
    return filtered;
  }

  List<AssessmentData> get upcomingAssessments =>
      filteredAssessments
          .where((a) => !a.isCompleted && a.dueDate.isAfter(DateTime.now()))
          .toList()
        ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

  List<AssessmentData> get completedAssessments =>
      filteredAssessments.where((a) => a.isCompleted).toList()
        ..sort((a, b) => b.completedAt!.compareTo(a.completedAt!));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Smart Assessments'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE91E63), Color(0xFFF48FB1)],
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Upcoming', icon: Icon(Icons.schedule)),
            Tab(text: 'Completed', icon: Icon(Icons.check_circle)),
            Tab(text: 'Statistics', icon: Icon(Icons.bar_chart)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Subject filter with gradient
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFE91E63).withOpacity(0.1),
                  Color(0xFFF48FB1).withOpacity(0.1),
                ],
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: subjects.map((subject) {
                  return Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(subject),
                      selected: selectedSubject == subject,
                      onSelected: (selected) {
                        setState(() {
                          selectedSubject = subject;
                        });
                      },
                      selectedColor: Colors.blue,
                      labelStyle: TextStyle(
                        color: selectedSubject == subject
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildUpcomingTab(),
                _buildCompletedTab(),
                _buildStatisticsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingTab() {
    return Obx(() {
      final upcoming = upcomingAssessments;

      if (upcoming.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_outline, size: 80, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No upcoming assessments',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              SizedBox(height: 8),
              Text(
                isAdminStudent
                    ? 'No assessments available'
                    : 'No assessments for $currentUserClass',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: upcoming.length,
        itemBuilder: (context, index) {
          return _buildAssessmentCard(upcoming[index]);
        },
      );
    });
  }

  Widget _buildCompletedTab() {
    return Obx(() {
      final completed = completedAssessments;

      if (completed.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.assignment_outlined, size: 80, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No completed assessments',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: completed.length,
        itemBuilder: (context, index) {
          return _buildAssessmentCard(completed[index]);
        },
      );
    });
  }

  Widget _buildStatisticsTab() {
    final completed = completedAssessments;
    final avgScore = completed.isEmpty
        ? 0.0
        : completed.map((a) => a.score ?? 0).reduce((a, b) => a + b) /
              completed.length;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overall Performance',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Completed',
                  completed.length.toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Pending',
                  upcomingAssessments.length.toString(),
                  Icons.pending,
                  Colors.orange,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Average Score',
                  '${avgScore.toStringAsFixed(1)}%',
                  Icons.star,
                  Colors.blue,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Total',
                  allAvailableAssessments.length.toString(),
                  Icons.assignment,
                  Colors.purple,
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          Text(
            'Subject Breakdown',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          ...subjects.where((s) => s != 'All').map((subject) {
            final subjectAssessments = allAvailableAssessments
                .where(
                  (a) =>
                      a.subject.toLowerCase().contains(subject.toLowerCase()),
                )
                .toList();
            final subjectCompleted = subjectAssessments
                .where((a) => a.isCompleted)
                .length;
            return _buildSubjectProgress(
              subject,
              subjectCompleted,
              subjectAssessments.length,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAssessmentCard(AssessmentData assessment) {
    final isOverdue =
        !assessment.isCompleted && assessment.dueDate.isBefore(DateTime.now());
    final daysUntilDue = assessment.dueDate.difference(DateTime.now()).inDays;

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _showAssessmentDetails(assessment),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getTypeColor(assessment.type),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      assessment.type,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(assessment.difficulty),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      assessment.difficulty,
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  SizedBox(width: 8),
                  if (assessment.isAIGenerated)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.purple,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            size: 10,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'AI',
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  Spacer(),
                  if (assessment.isCompleted)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${assessment.score}%',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                assessment.title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.subject, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    assessment.subject,
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(width: 16),
                  Icon(Icons.quiz, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    '${assessment.totalQuestions} questions',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    'By ${assessment.createdByName}',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  SizedBox(width: 16),
                  Icon(Icons.class_, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    assessment.classLevel,
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.timer, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    '${assessment.duration} minutes',
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(width: 16),
                  Icon(
                    isOverdue ? Icons.warning : Icons.calendar_today,
                    size: 16,
                    color: isOverdue ? Colors.red : Colors.grey,
                  ),
                  SizedBox(width: 4),
                  Text(
                    assessment.isCompleted
                        ? 'Completed'
                        : isOverdue
                        ? 'Overdue'
                        : daysUntilDue == 0
                        ? 'Due today'
                        : 'Due in $daysUntilDue days',
                    style: TextStyle(
                      color: isOverdue ? Colors.red : Colors.grey,
                      fontWeight: isOverdue
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              if (!assessment.isCompleted) ...[
                SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => _startAssessment(assessment),
                  icon: Icon(Icons.play_arrow),
                  label: Text('Start Assessment'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 40),
                  ),
                ),
              ],
            ],
          ),
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
            Icon(icon, size: 40, color: color),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(label, style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectProgress(String subject, int completed, int total) {
    final progress = total == 0 ? 0.0 : completed / total;
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(subject, style: TextStyle(fontWeight: FontWeight.w500)),
              Text('$completed/$total'),
            ],
          ),
          SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade200,
            minHeight: 8,
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Quiz':
        return Colors.blue;
      case 'Test':
        return Colors.orange;
      case 'Exam':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Easy':
        return Colors.green;
      case 'Medium':
        return Colors.orange;
      case 'Hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _startAssessment(AssessmentData assessment) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Start Assessment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(assessment.title),
            SizedBox(height: 16),
            Text('• ${assessment.totalQuestions} questions'),
            Text('• ${assessment.duration} minutes'),
            Text('• ${assessment.difficulty} difficulty'),
            SizedBox(height: 16),
            Text(
              'Are you ready to begin?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TakeAssessmentView(
                    assessmentId: assessment.id,
                    title: assessment.title,
                    duration: assessment.duration,
                    totalQuestions: assessment.totalQuestions,
                  ),
                ),
              );

              // Update assessment if completed
              if (result != null && result['completed'] == true) {
                await sharedService.completeAssessment(
                  assessment.id,
                  result['score'],
                );

                Get.snackbar(
                  'Assessment Completed!',
                  'You scored ${result['score']}% on ${assessment.title}',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                  duration: Duration(seconds: 3),
                );
              }
            },
            child: Text('Start Now'),
          ),
        ],
      ),
    );
  }

  void _showAssessmentDetails(AssessmentData assessment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: EdgeInsets.all(20),
            child: ListView(
              controller: scrollController,
              children: [
                Text(
                  assessment.title,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                _buildDetailRow('Subject', assessment.subject),
                _buildDetailRow('Type', assessment.type),
                _buildDetailRow('Questions', '${assessment.totalQuestions}'),
                _buildDetailRow('Duration', '${assessment.duration} minutes'),
                _buildDetailRow('Difficulty', assessment.difficulty),
                _buildDetailRow('Class', assessment.classLevel),
                _buildDetailRow('Created By', assessment.createdByName),
                _buildDetailRow(
                  'Due Date',
                  '${assessment.dueDate.day}/${assessment.dueDate.month}/${assessment.dueDate.year}',
                ),
                if (assessment.isAIGenerated)
                  _buildDetailRow('Generated', 'AI-Powered'),
                if (assessment.isCompleted)
                  _buildDetailRow('Score', '${assessment.score}%'),
                SizedBox(height: 20),
                if (!assessment.isCompleted)
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _startAssessment(assessment);
                    },
                    icon: Icon(Icons.play_arrow),
                    label: Text('Start Assessment'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
