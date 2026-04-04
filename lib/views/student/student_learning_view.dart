import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'video_player_view.dart';
import 'content_reader_view.dart';
import 'interactive_lesson_view.dart';

class Lesson {
  final String id;
  final String title;
  final String courseTitle;
  final String description;
  final int duration; // minutes
  final bool isCompleted;
  final String type; // Video, Reading, Interactive
  final String difficulty;
  final List<String> topics;

  Lesson({
    required this.id,
    required this.title,
    required this.courseTitle,
    required this.description,
    required this.duration,
    required this.isCompleted,
    required this.type,
    required this.difficulty,
    required this.topics,
  });
}

class StudentLearningView extends StatefulWidget {
  const StudentLearningView({super.key});

  @override
  State<StudentLearningView> createState() => _StudentLearningViewState();
}

class _StudentLearningViewState extends State<StudentLearningView> {
  String selectedFilter = 'All';
  final List<String> filters = [
    'All',
    'In Progress',
    'Completed',
    'Not Started',
  ];

  final List<Lesson> lessons = [
    // AI & Machine Learning
    Lesson(
      id: '1',
      title: 'Introduction to Neural Networks',
      courseTitle: 'Artificial Intelligence',
      description: 'Learn the basics of neural networks and how they work',
      duration: 45,
      isCompleted: true,
      type: 'Video',
      difficulty: 'Medium',
      topics: ['AI', 'Machine Learning', 'Neural Networks'],
    ),
    Lesson(
      id: '2',
      title: 'Deep Learning Fundamentals',
      courseTitle: 'Artificial Intelligence',
      description: 'Understanding deep learning architectures and applications',
      duration: 55,
      isCompleted: false,
      type: 'Video',
      difficulty: 'Hard',
      topics: ['Deep Learning', 'CNN', 'RNN'],
    ),
    Lesson(
      id: '3',
      title: 'AI Ethics and Society',
      courseTitle: 'Artificial Intelligence',
      description: 'Exploring ethical implications of AI technology',
      duration: 35,
      isCompleted: false,
      type: 'Reading',
      difficulty: 'Easy',
      topics: ['Ethics', 'AI', 'Society'],
    ),

    // Mathematics
    Lesson(
      id: '4',
      title: 'Calculus Fundamentals',
      courseTitle: 'Advanced Mathematics',
      description: 'Understanding derivatives and integrals',
      duration: 60,
      isCompleted: false,
      type: 'Interactive',
      difficulty: 'Hard',
      topics: ['Calculus', 'Derivatives', 'Integrals'],
    ),
    Lesson(
      id: '5',
      title: 'Linear Algebra Essentials',
      courseTitle: 'Advanced Mathematics',
      description: 'Matrices, vectors, and linear transformations',
      duration: 50,
      isCompleted: false,
      type: 'Video',
      difficulty: 'Medium',
      topics: ['Linear Algebra', 'Matrices', 'Vectors'],
    ),
    Lesson(
      id: '6',
      title: 'Probability and Statistics',
      courseTitle: 'Mathematics',
      description:
          'Understanding probability distributions and statistical analysis',
      duration: 45,
      isCompleted: false,
      type: 'Interactive',
      difficulty: 'Medium',
      topics: ['Probability', 'Statistics', 'Data Analysis'],
    ),

    // Literature
    Lesson(
      id: '7',
      title: 'Shakespeare\'s Sonnets',
      courseTitle: 'English Literature',
      description: 'Analysis of Shakespeare\'s most famous sonnets',
      duration: 30,
      isCompleted: true,
      type: 'Reading',
      difficulty: 'Medium',
      topics: ['Literature', 'Poetry', 'Shakespeare'],
    ),
    Lesson(
      id: '8',
      title: 'Modern Poetry Analysis',
      courseTitle: 'English Literature',
      description: 'Exploring 20th century poetry and literary techniques',
      duration: 40,
      isCompleted: false,
      type: 'Reading',
      difficulty: 'Medium',
      topics: ['Poetry', 'Modern Literature', 'Analysis'],
    ),

    // Physics
    Lesson(
      id: '9',
      title: 'Quantum Mechanics Basics',
      courseTitle: 'Physics',
      description: 'Introduction to quantum physics principles',
      duration: 50,
      isCompleted: false,
      type: 'Video',
      difficulty: 'Hard',
      topics: ['Physics', 'Quantum', 'Mechanics'],
    ),
    Lesson(
      id: '10',
      title: 'Thermodynamics Laws',
      courseTitle: 'Physics',
      description: 'Understanding the four laws of thermodynamics',
      duration: 45,
      isCompleted: false,
      type: 'Reading',
      difficulty: 'Medium',
      topics: ['Thermodynamics', 'Energy', 'Heat'],
    ),
    Lesson(
      id: '11',
      title: 'Electromagnetism Quiz',
      courseTitle: 'Physics',
      description: 'Test your knowledge of electromagnetic principles',
      duration: 30,
      isCompleted: false,
      type: 'Interactive',
      difficulty: 'Medium',
      topics: ['Electromagnetism', 'Electricity', 'Magnetism'],
    ),

    // Programming
    Lesson(
      id: '12',
      title: 'Python Data Structures',
      courseTitle: 'Programming',
      description: 'Lists, dictionaries, sets, and tuples in Python',
      duration: 40,
      isCompleted: false,
      type: 'Interactive',
      difficulty: 'Easy',
      topics: ['Python', 'Programming', 'Data Structures'],
    ),
    Lesson(
      id: '13',
      title: 'Object-Oriented Programming',
      courseTitle: 'Programming',
      description: 'Classes, objects, inheritance, and polymorphism',
      duration: 55,
      isCompleted: false,
      type: 'Video',
      difficulty: 'Medium',
      topics: ['OOP', 'Classes', 'Inheritance'],
    ),
    Lesson(
      id: '14',
      title: 'Algorithms and Complexity',
      courseTitle: 'Computer Science',
      description: 'Big O notation, sorting, and searching algorithms',
      duration: 50,
      isCompleted: false,
      type: 'Reading',
      difficulty: 'Hard',
      topics: ['Algorithms', 'Complexity', 'Big O'],
    ),

    // Chemistry
    Lesson(
      id: '15',
      title: 'Organic Chemistry Basics',
      courseTitle: 'Chemistry',
      description: 'Introduction to organic compounds and reactions',
      duration: 45,
      isCompleted: false,
      type: 'Video',
      difficulty: 'Medium',
      topics: ['Organic Chemistry', 'Compounds', 'Reactions'],
    ),
    Lesson(
      id: '16',
      title: 'Chemical Bonding',
      courseTitle: 'Chemistry',
      description: 'Ionic, covalent, and metallic bonds explained',
      duration: 35,
      isCompleted: false,
      type: 'Reading',
      difficulty: 'Easy',
      topics: ['Bonding', 'Ionic', 'Covalent'],
    ),

    // Data Science & Analytics
    Lesson(
      id: '17',
      title: 'Big Data Analytics',
      courseTitle: 'Data Science',
      description: 'Processing and analyzing large-scale datasets',
      duration: 60,
      isCompleted: false,
      type: 'Video',
      difficulty: 'Hard',
      topics: ['Big Data', 'Analytics', 'Hadoop', 'Spark'],
    ),
    Lesson(
      id: '18',
      title: 'Machine Learning Algorithms',
      courseTitle: 'Data Science',
      description: 'Supervised and unsupervised learning techniques',
      duration: 70,
      isCompleted: false,
      type: 'Reading',
      difficulty: 'Hard',
      topics: ['ML', 'Algorithms', 'Classification', 'Clustering'],
    ),
    Lesson(
      id: '19',
      title: 'Data Visualization Mastery',
      courseTitle: 'Data Science',
      description: 'Creating impactful visualizations with Python and R',
      duration: 45,
      isCompleted: false,
      type: 'Interactive',
      difficulty: 'Medium',
      topics: ['Visualization', 'Python', 'R', 'Tableau'],
    ),

    // Blockchain & Cryptocurrency
    Lesson(
      id: '20',
      title: 'Blockchain Fundamentals',
      courseTitle: 'Blockchain Technology',
      description: 'Understanding distributed ledger technology',
      duration: 55,
      isCompleted: false,
      type: 'Video',
      difficulty: 'Medium',
      topics: ['Blockchain', 'DLT', 'Consensus', 'Mining'],
    ),
    Lesson(
      id: '21',
      title: 'Smart Contracts Development',
      courseTitle: 'Blockchain Technology',
      description: 'Building smart contracts with Solidity',
      duration: 65,
      isCompleted: false,
      type: 'Reading',
      difficulty: 'Hard',
      topics: ['Smart Contracts', 'Solidity', 'Ethereum', 'Web3'],
    ),
    Lesson(
      id: '22',
      title: 'Cryptocurrency Economics',
      courseTitle: 'Blockchain Technology',
      description: 'Economic principles behind digital currencies',
      duration: 50,
      isCompleted: false,
      type: 'Interactive',
      difficulty: 'Medium',
      topics: ['Crypto', 'Economics', 'Bitcoin', 'DeFi'],
    ),

    // Cybersecurity
    Lesson(
      id: '23',
      title: 'Network Security Essentials',
      courseTitle: 'Cybersecurity',
      description: 'Protecting networks from cyber threats',
      duration: 60,
      isCompleted: false,
      type: 'Video',
      difficulty: 'Hard',
      topics: ['Network Security', 'Firewalls', 'VPN', 'IDS'],
    ),
    Lesson(
      id: '24',
      title: 'Ethical Hacking Basics',
      courseTitle: 'Cybersecurity',
      description: 'Penetration testing and vulnerability assessment',
      duration: 75,
      isCompleted: false,
      type: 'Reading',
      difficulty: 'Hard',
      topics: ['Ethical Hacking', 'Pentesting', 'Security', 'Kali'],
    ),
    Lesson(
      id: '25',
      title: 'Cryptography Principles',
      courseTitle: 'Cybersecurity',
      description: 'Encryption, hashing, and digital signatures',
      duration: 55,
      isCompleted: false,
      type: 'Interactive',
      difficulty: 'Hard',
      topics: ['Cryptography', 'Encryption', 'RSA', 'AES'],
    ),

    // Biotechnology
    Lesson(
      id: '26',
      title: 'CRISPR Gene Editing',
      courseTitle: 'Biotechnology',
      description: 'Revolutionary gene editing technology explained',
      duration: 50,
      isCompleted: false,
      type: 'Video',
      difficulty: 'Hard',
      topics: ['CRISPR', 'Gene Editing', 'Genetics', 'DNA'],
    ),
    Lesson(
      id: '27',
      title: 'Bioinformatics Introduction',
      courseTitle: 'Biotechnology',
      description: 'Computational analysis of biological data',
      duration: 60,
      isCompleted: false,
      type: 'Reading',
      difficulty: 'Hard',
      topics: ['Bioinformatics', 'Genomics', 'Proteomics', 'Data'],
    ),
    Lesson(
      id: '28',
      title: 'Synthetic Biology',
      courseTitle: 'Biotechnology',
      description: 'Designing and constructing biological systems',
      duration: 55,
      isCompleted: false,
      type: 'Interactive',
      difficulty: 'Hard',
      topics: ['Synthetic Biology', 'Bioengineering', 'DNA', 'Cells'],
    ),

    // Economics & Finance
    Lesson(
      id: '29',
      title: 'Macroeconomic Theory',
      courseTitle: 'Economics',
      description: 'GDP, inflation, unemployment, and fiscal policy',
      duration: 65,
      isCompleted: false,
      type: 'Video',
      difficulty: 'Medium',
      topics: ['Macroeconomics', 'GDP', 'Inflation', 'Policy'],
    ),
    Lesson(
      id: '30',
      title: 'Financial Markets Analysis',
      courseTitle: 'Finance',
      description: 'Stock markets, bonds, and investment strategies',
      duration: 70,
      isCompleted: false,
      type: 'Reading',
      difficulty: 'Hard',
      topics: ['Finance', 'Markets', 'Stocks', 'Investment'],
    ),
    Lesson(
      id: '31',
      title: 'Behavioral Economics',
      courseTitle: 'Economics',
      description: 'Psychology and decision-making in economics',
      duration: 50,
      isCompleted: false,
      type: 'Interactive',
      difficulty: 'Medium',
      topics: ['Behavioral Economics', 'Psychology', 'Decisions'],
    ),

    // Philosophy & Ethics
    Lesson(
      id: '32',
      title: 'Modern Philosophy',
      courseTitle: 'Philosophy',
      description: 'Existentialism, phenomenology, and postmodernism',
      duration: 60,
      isCompleted: false,
      type: 'Reading',
      difficulty: 'Hard',
      topics: ['Philosophy', 'Existentialism', 'Phenomenology'],
    ),
    Lesson(
      id: '33',
      title: 'Applied Ethics',
      courseTitle: 'Philosophy',
      description: 'Ethical frameworks for real-world problems',
      duration: 55,
      isCompleted: false,
      type: 'Video',
      difficulty: 'Medium',
      topics: ['Ethics', 'Morality', 'Applied Philosophy'],
    ),
    Lesson(
      id: '34',
      title: 'Logic and Critical Thinking',
      courseTitle: 'Philosophy',
      description: 'Formal logic, fallacies, and argumentation',
      duration: 50,
      isCompleted: false,
      type: 'Interactive',
      difficulty: 'Medium',
      topics: ['Logic', 'Critical Thinking', 'Arguments', 'Fallacies'],
    ),

    // Cloud Computing & DevOps
    Lesson(
      id: '35',
      title: 'AWS Cloud Architecture',
      courseTitle: 'Cloud Computing',
      description: 'Designing scalable cloud solutions on AWS',
      duration: 70,
      isCompleted: false,
      type: 'Video',
      difficulty: 'Hard',
      topics: ['AWS', 'Cloud', 'Architecture', 'EC2', 'S3'],
    ),
    Lesson(
      id: '36',
      title: 'Docker and Kubernetes',
      courseTitle: 'DevOps',
      description: 'Container orchestration and microservices',
      duration: 65,
      isCompleted: false,
      type: 'Reading',
      difficulty: 'Hard',
      topics: ['Docker', 'Kubernetes', 'Containers', 'DevOps'],
    ),
    Lesson(
      id: '37',
      title: 'CI/CD Pipeline Design',
      courseTitle: 'DevOps',
      description: 'Continuous integration and deployment practices',
      duration: 55,
      isCompleted: false,
      type: 'Interactive',
      difficulty: 'Medium',
      topics: ['CI/CD', 'Jenkins', 'GitLab', 'Automation'],
    ),

    // Neuroscience
    Lesson(
      id: '38',
      title: 'Cognitive Neuroscience',
      courseTitle: 'Neuroscience',
      description: 'Brain mechanisms underlying cognition',
      duration: 60,
      isCompleted: false,
      type: 'Video',
      difficulty: 'Hard',
      topics: ['Neuroscience', 'Cognition', 'Brain', 'Memory'],
    ),
    Lesson(
      id: '39',
      title: 'Neuroplasticity',
      courseTitle: 'Neuroscience',
      description: 'How the brain adapts and changes',
      duration: 50,
      isCompleted: false,
      type: 'Reading',
      difficulty: 'Medium',
      topics: ['Neuroplasticity', 'Brain', 'Learning', 'Adaptation'],
    ),
    Lesson(
      id: '40',
      title: 'Brain-Computer Interfaces',
      courseTitle: 'Neuroscience',
      description: 'Direct communication between brain and devices',
      duration: 55,
      isCompleted: false,
      type: 'Interactive',
      difficulty: 'Hard',
      topics: ['BCI', 'Neurotechnology', 'Brain', 'Interface'],
    ),

    // Environmental Science
    Lesson(
      id: '41',
      title: 'Climate Change Science',
      courseTitle: 'Environmental Science',
      description: 'Understanding global warming and its impacts',
      duration: 65,
      isCompleted: false,
      type: 'Video',
      difficulty: 'Medium',
      topics: ['Climate', 'Environment', 'Global Warming', 'CO2'],
    ),
    Lesson(
      id: '42',
      title: 'Renewable Energy Systems',
      courseTitle: 'Environmental Science',
      description: 'Solar, wind, and sustainable energy technologies',
      duration: 60,
      isCompleted: false,
      type: 'Reading',
      difficulty: 'Medium',
      topics: ['Renewable Energy', 'Solar', 'Wind', 'Sustainability'],
    ),
    Lesson(
      id: '43',
      title: 'Ecosystem Conservation',
      courseTitle: 'Environmental Science',
      description: 'Biodiversity protection and restoration strategies',
      duration: 50,
      isCompleted: false,
      type: 'Interactive',
      difficulty: 'Medium',
      topics: ['Conservation', 'Biodiversity', 'Ecosystems'],
    ),

    // Robotics & Automation
    Lesson(
      id: '44',
      title: 'Robotics Fundamentals',
      courseTitle: 'Robotics',
      description: 'Kinematics, dynamics, and control systems',
      duration: 70,
      isCompleted: false,
      type: 'Video',
      difficulty: 'Hard',
      topics: ['Robotics', 'Kinematics', 'Control', 'Automation'],
    ),
    Lesson(
      id: '45',
      title: 'Computer Vision for Robots',
      courseTitle: 'Robotics',
      description: 'Image processing and object recognition',
      duration: 65,
      isCompleted: false,
      type: 'Reading',
      difficulty: 'Hard',
      topics: ['Computer Vision', 'Image Processing', 'AI', 'Robots'],
    ),
    Lesson(
      id: '46',
      title: 'Autonomous Systems',
      courseTitle: 'Robotics',
      description: 'Self-driving cars and autonomous navigation',
      duration: 60,
      isCompleted: false,
      type: 'Interactive',
      difficulty: 'Hard',
      topics: ['Autonomous', 'Self-Driving', 'Navigation', 'AI'],
    ),

    // Psychology
    Lesson(
      id: '47',
      title: 'Cognitive Psychology',
      courseTitle: 'Psychology',
      description: 'Memory, attention, perception, and problem-solving',
      duration: 55,
      isCompleted: false,
      type: 'Video',
      difficulty: 'Medium',
      topics: ['Psychology', 'Cognition', 'Memory', 'Attention'],
    ),
    Lesson(
      id: '48',
      title: 'Social Psychology',
      courseTitle: 'Psychology',
      description: 'Group behavior, influence, and social cognition',
      duration: 50,
      isCompleted: false,
      type: 'Reading',
      difficulty: 'Medium',
      topics: ['Social Psychology', 'Groups', 'Influence', 'Behavior'],
    ),
    Lesson(
      id: '49',
      title: 'Developmental Psychology',
      courseTitle: 'Psychology',
      description: 'Human development across the lifespan',
      duration: 55,
      isCompleted: false,
      type: 'Interactive',
      difficulty: 'Medium',
      topics: ['Development', 'Psychology', 'Lifespan', 'Growth'],
    ),

    // Quantum Computing
    Lesson(
      id: '50',
      title: 'Quantum Computing Basics',
      courseTitle: 'Quantum Computing',
      description: 'Qubits, superposition, and entanglement',
      duration: 65,
      isCompleted: false,
      type: 'Video',
      difficulty: 'Hard',
      topics: ['Quantum', 'Computing', 'Qubits', 'Superposition'],
    ),
    Lesson(
      id: '51',
      title: 'Quantum Algorithms',
      courseTitle: 'Quantum Computing',
      description: 'Shor\'s algorithm, Grover\'s search, and more',
      duration: 70,
      isCompleted: false,
      type: 'Reading',
      difficulty: 'Hard',
      topics: ['Quantum Algorithms', 'Shor', 'Grover', 'Computing'],
    ),
    Lesson(
      id: '52',
      title: 'Quantum Programming',
      courseTitle: 'Quantum Computing',
      description: 'Programming quantum computers with Qiskit',
      duration: 60,
      isCompleted: false,
      type: 'Interactive',
      difficulty: 'Hard',
      topics: ['Quantum Programming', 'Qiskit', 'IBM Q', 'Python'],
    ),
  ];

  List<Lesson> get filteredLessons {
    if (selectedFilter == 'All') return lessons;
    if (selectedFilter == 'Completed') {
      return lessons.where((l) => l.isCompleted).toList();
    }
    if (selectedFilter == 'Not Started') {
      return lessons.where((l) => !l.isCompleted).toList();
    }
    return lessons;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Learning Hub'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF9800), Color(0xFFFFCC80)],
            ),
          ),
        ),
        actions: [
          IconButton(icon: Icon(Icons.search), onPressed: () => _showSearch()),
        ],
      ),
      body: Column(
        children: [
          // Progress overview with gradient
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFFF9800).withOpacity(0.1),
                  Color(0xFFFFCC80).withOpacity(0.1),
                ],
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildProgressStat(
                      'Completed',
                      lessons.where((l) => l.isCompleted).length.toString(),
                      Icons.check_circle,
                      Colors.green,
                    ),
                    _buildProgressStat(
                      'In Progress',
                      lessons.where((l) => !l.isCompleted).length.toString(),
                      Icons.pending,
                      Colors.orange,
                    ),
                    _buildProgressStat(
                      'Total Hours',
                      (lessons.map((l) => l.duration).reduce((a, b) => a + b) /
                              60)
                          .toStringAsFixed(1),
                      Icons.access_time,
                      Colors.blue,
                    ),
                  ],
                ),
                SizedBox(height: 12),
                LinearProgressIndicator(
                  value:
                      lessons.where((l) => l.isCompleted).length /
                      lessons.length,
                  backgroundColor: Colors.grey.shade300,
                  minHeight: 8,
                ),
                SizedBox(height: 8),
                Text(
                  '${((lessons.where((l) => l.isCompleted).length / lessons.length) * 100).toStringAsFixed(0)}% Complete',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          // Filter chips
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: filters.map((filter) {
                  return Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filter),
                      selected: selectedFilter == filter,
                      onSelected: (selected) {
                        setState(() {
                          selectedFilter = filter;
                        });
                      },
                      selectedColor: Colors.blue,
                      labelStyle: TextStyle(
                        color: selectedFilter == filter
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          // Lessons list
          Expanded(
            child: filteredLessons.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.school, size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No lessons found',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: filteredLessons.length,
                    itemBuilder: (context, index) {
                      return _buildLessonCard(filteredLessons[index]);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showRecommendations(),
        icon: Icon(Icons.lightbulb),
        label: Text('Recommendations'),
      ),
    );
  }

  Widget _buildProgressStat(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 30),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildLessonCard(Lesson lesson) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _showLessonDetails(lesson),
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
                      color: _getTypeColor(lesson.type),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getTypeIcon(lesson.type),
                          size: 14,
                          color: Colors.white,
                        ),
                        SizedBox(width: 4),
                        Text(
                          lesson.type,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(lesson.difficulty),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      lesson.difficulty,
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  Spacer(),
                  if (lesson.isCompleted)
                    Icon(Icons.check_circle, color: Colors.green, size: 24),
                ],
              ),
              SizedBox(height: 12),
              Text(
                lesson.title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                lesson.courseTitle,
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Text(
                lesson.description,
                style: TextStyle(color: Colors.grey.shade700),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    '${lesson.duration} min',
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Wrap(
                      spacing: 4,
                      children: lesson.topics.take(2).map((topic) {
                        return Chip(
                          label: Text(topic, style: TextStyle(fontSize: 10)),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              if (!lesson.isCompleted) ...[
                SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => _startLesson(lesson),
                  icon: Icon(Icons.play_arrow),
                  label: Text('Start Lesson'),
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

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Video':
        return Colors.red;
      case 'Reading':
        return Colors.blue;
      case 'Interactive':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'Video':
        return Icons.play_circle;
      case 'Reading':
        return Icons.book;
      case 'Interactive':
        return Icons.touch_app;
      default:
        return Icons.school;
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

  void _startLesson(Lesson lesson) {
    if (lesson.type == 'Video') {
      // Navigate to Video Player
      Get.to(
        () => VideoPlayerView(
          title: lesson.title,
          videoUrl: _getVideoUrl(lesson.id),
          description: lesson.description,
          duration: lesson.duration,
          courseTitle: lesson.courseTitle,
        ),
      );
    } else if (lesson.type == 'Reading') {
      // Navigate to Content Reader
      Get.to(
        () => ContentReaderView(
          title: lesson.title,
          courseTitle: lesson.courseTitle,
          content: _getReadingContent(lesson.id),
          duration: lesson.duration,
          type: 'Reading',
        ),
      );
    } else if (lesson.type == 'Interactive') {
      // Navigate to Interactive Lesson
      Get.to(
        () => InteractiveLessonView(
          title: lesson.title,
          courseTitle: lesson.courseTitle,
          description: lesson.description,
          duration: lesson.duration,
        ),
      );
    } else {
      Get.snackbar(
        'Error',
        'Unknown lesson type',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  String _getVideoUrl(String lessonId) {
    // Sample YouTube URLs - Educational content
    final videoUrls = {
      '1':
          'https://www.youtube.com/watch?v=aircAruvnKk', // Neural Networks by 3Blue1Brown
      '4': 'https://www.youtube.com/watch?v=DfY-DRsE86s', // Quantum Mechanics
      // Add more video URLs as needed
    };
    return videoUrls[lessonId] ?? 'https://www.youtube.com/watch?v=aircAruvnKk';
  }

  String _getReadingContent(String lessonId) {
    final contentMap = {
      '3': _getAIEthicsContent(),
      '8': _getModernPoetryContent(),
      '10': _getThermodynamicsContent(),
      '14': _getAlgorithmsContent(),
      '16': _getChemicalBondingContent(),
      '18': _getMachineLearningContent(),
      '21': _getSmartContractsContent(),
      '24': _getEthicalHackingContent(),
      '27': _getBioinformaticsContent(),
      '30': _getFinancialMarketsContent(),
      '32': _getModernPhilosophyContent(),
      '36': _getDockerKubernetesContent(),
      '39': _getNeuroplasticityContent(),
      '42': _getRenewableEnergyContent(),
      '45': _getComputerVisionContent(),
      '48': _getSocialPsychologyContent(),
      '51': _getQuantumAlgorithmsContent(),
    };

    return contentMap[lessonId] ??
        'Content for this lesson will be available soon.';
  }

  String _getAIEthicsContent() {
    return '''
AI Ethics and Society: Navigating the Future

As artificial intelligence becomes increasingly integrated into our daily lives, understanding its ethical implications has never been more critical. This comprehensive guide explores the complex relationship between AI technology and society.

The Ethical Landscape

AI systems are making decisions that affect millions of people - from loan approvals to medical diagnoses, from job applications to criminal justice. These decisions raise fundamental questions about fairness, accountability, and human autonomy.

Key Ethical Concerns

1. Bias and Fairness
AI systems can perpetuate and amplify existing societal biases. When trained on historical data that reflects past discrimination, algorithms may make unfair decisions affecting marginalized communities. For example, facial recognition systems have shown higher error rates for people of color, and hiring algorithms have demonstrated gender bias.

2. Privacy and Surveillance
The data hunger of AI systems poses significant privacy risks. Mass surveillance capabilities, enabled by AI-powered facial recognition and behavior analysis, threaten individual freedoms and civil liberties. The question becomes: how much privacy should we sacrifice for convenience or security?

3. Accountability and Transparency
When an AI system makes a harmful decision, who is responsible? The developer? The company? The algorithm itself? The "black box" nature of many AI systems makes it difficult to understand how decisions are made, creating accountability challenges.

4. Job Displacement
Automation powered by AI threatens to displace millions of workers across various industries. While new jobs may be created, the transition period could cause significant economic disruption and social upheaval.

5. Autonomous Weapons
The development of AI-powered weapons systems raises profound moral questions. Should machines have the authority to make life-or-death decisions? What are the implications for warfare and international security?

Ethical Frameworks

Several frameworks have emerged to guide ethical AI development:

Fairness, Accountability, and Transparency (FAT): This approach emphasizes the need for AI systems to be fair in their outcomes, accountable for their decisions, and transparent in their operations.

Human-Centered AI: This framework prioritizes human values and wellbeing, ensuring that AI systems augment rather than replace human decision-making.

Value Alignment: This approach focuses on ensuring AI systems are aligned with human values and goals, preventing unintended consequences.

Regulatory Approaches

Different regions are taking varied approaches to AI regulation:

European Union: The EU's AI Act proposes risk-based regulation, with strict requirements for high-risk applications like healthcare and law enforcement.

United States: The US has taken a more sector-specific approach, with different agencies regulating AI in their respective domains.

China: China has implemented regulations focusing on algorithm recommendations and deep synthesis technology, balancing innovation with social stability.

The Path Forward

Addressing AI ethics requires collaboration between technologists, policymakers, ethicists, and the public. Key steps include:

• Developing diverse and inclusive AI teams
• Implementing rigorous testing for bias and fairness
• Creating transparent documentation of AI systems
• Establishing clear accountability mechanisms
• Engaging in public dialogue about AI's role in society
• Investing in education and retraining programs
• Developing international standards and cooperation

Conclusion

AI ethics is not just about preventing harm - it's about actively shaping technology to benefit humanity. As AI continues to evolve, our ethical frameworks must evolve with it, ensuring that these powerful tools serve the common good while respecting fundamental human rights and values.

The choices we make today about AI ethics will shape society for generations to come. It's crucial that these decisions involve diverse voices and perspectives, reflecting the full spectrum of human experience and values.
''';
  }

  String _getModernPoetryContent() {
    return '''
Modern Poetry Analysis: Breaking Traditional Boundaries

Modern poetry, emerging in the late 19th and flourishing throughout the 20th century, represents a radical departure from traditional poetic forms. This movement revolutionized how we think about poetry, language, and artistic expression.

The Modern Revolution

Modern poetry arose from a desire to break free from Victorian conventions and capture the fragmented, fast-paced nature of modern life. Poets sought new forms, techniques, and subjects that reflected the changing world around them.

Key Characteristics

1. Free Verse
Modern poets abandoned traditional meter and rhyme schemes, embracing free verse that allowed for more natural speech patterns and greater flexibility in expression. This liberation from formal constraints enabled poets to focus on imagery, rhythm, and meaning.

2. Imagism
The Imagist movement, led by Ezra Pound, emphasized clear, precise images over abstract ideas. The famous principle "no ideas but in things" encouraged poets to show rather than tell, creating vivid sensory experiences.

3. Stream of Consciousness
Influenced by psychological theories, modern poets experimented with stream-of-consciousness techniques, capturing the flow of thoughts and perceptions without logical organization.

4. Fragmentation
Modern poetry often presents fragmented images and disjointed narratives, reflecting the fractured nature of modern experience. T.S. Eliot's "The Waste Land" exemplifies this technique.

Major Movements and Poets

Imagism (1912-1917)
Ezra Pound, H.D. (Hilda Doolittle), and Amy Lowell championed precise imagery and economy of language. Pound's "In a Station of the Metro" demonstrates imagist principles in just two lines.

Modernism (1890-1950)
T.S. Eliot, Wallace Stevens, and William Carlos Williams explored themes of alienation, disillusionment, and the search for meaning in a chaotic world.

Harlem Renaissance (1920s-1930s)
Langston Hughes, Claude McKay, and Countee Cullen celebrated African American culture and experience, blending traditional forms with jazz rhythms and vernacular speech.

Confessional Poetry (1950s-1960s)
Sylvia Plath, Robert Lowell, and Anne Sexton broke taboos by writing intimately about personal experiences, mental illness, and family relationships.

Beat Generation (1950s-1960s)
Allen Ginsberg, Jack Kerouac, and Lawrence Ferlinghetti rejected mainstream values, experimenting with spontaneous composition and jazz-influenced rhythms.

Analytical Techniques

Close Reading
Examine word choice, imagery, sound patterns, and structure. Consider how form reinforces meaning.

Historical Context
Understand the social, political, and cultural circumstances that influenced the poet's work.

Intertextuality
Identify references to other texts, myths, and cultural artifacts. Modern poetry often engages in dialogue with literary tradition.

Symbolism and Metaphor
Analyze how poets use symbols and metaphors to convey complex ideas and emotions.

Notable Examples

"The Love Song of J. Alfred Prufrock" by T.S. Eliot
This dramatic monologue captures modern alienation and paralysis through fragmented imagery and literary allusions.

"The Red Wheelbarrow" by William Carlos Williams
A minimalist masterpiece demonstrating the power of simple, precise observation.

"Howl" by Allen Ginsberg
A raw, powerful critique of conformist society and celebration of nonconformity.

"Daddy" by Sylvia Plath
An intense confessional poem exploring complex father-daughter relationships through Holocaust imagery.

Contemporary Relevance

Modern poetry's innovations continue to influence contemporary poets. The freedom to experiment with form, the emphasis on authentic voice, and the willingness to tackle difficult subjects remain central to poetry today.

Slam poetry, spoken word, and digital poetry all build on modernist foundations, adapting poetic expression to new media and audiences.

Conclusion

Modern poetry challenged readers to engage actively with texts, to tolerate ambiguity, and to find meaning in fragmentation. While initially controversial, these innovations expanded poetry's possibilities and continue to shape how we understand and create poetry today.

Understanding modern poetry requires patience, openness, and willingness to embrace complexity. The rewards include deeper appreciation for language's power and insight into the human condition in all its complexity.
''';
  }

  void _showLessonDetails(Lesson lesson) {
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
                Row(
                  children: [
                    Icon(
                      _getTypeIcon(lesson.type),
                      size: 30,
                      color: Colors.blue,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        lesson.title,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  lesson.courseTitle,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 16),
                Text(lesson.description, style: TextStyle(fontSize: 16)),
                SizedBox(height: 20),
                Divider(),
                SizedBox(height: 12),
                _buildDetailRow('Type', lesson.type),
                _buildDetailRow('Duration', '${lesson.duration} minutes'),
                _buildDetailRow('Difficulty', lesson.difficulty),
                _buildDetailRow(
                  'Status',
                  lesson.isCompleted ? 'Completed' : 'Not Started',
                ),
                SizedBox(height: 12),
                Divider(),
                SizedBox(height: 12),
                Text(
                  'Topics Covered',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: lesson.topics.map((topic) {
                    return Chip(
                      label: Text(topic),
                      backgroundColor: Colors.blue.shade50,
                    );
                  }).toList(),
                ),
                SizedBox(height: 24),
                // Start Button - Always visible and prominent
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: lesson.isCompleted
                          ? [Colors.green.shade600, Colors.green.shade400]
                          : [Colors.blue.shade600, Colors.blue.shade400],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: (lesson.isCompleted ? Colors.green : Colors.blue)
                            .withValues(alpha: 0.3),
                        spreadRadius: 1,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _startLesson(lesson);
                    },
                    icon: Icon(
                      lesson.isCompleted ? Icons.replay : Icons.play_arrow,
                      size: 28,
                    ),
                    label: Text(
                      lesson.isCompleted ? 'Review Lesson' : 'Start Lesson',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          Text(value, style: TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _showSearch() {
    showSearch(context: context, delegate: LessonSearchDelegate(lessons));
  }

  void _showRecommendations() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recommended for You',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildRecommendationCard(
                    'Complete Calculus Fundamentals',
                    'Continue your math journey',
                    Icons.functions,
                    Colors.orange,
                  ),
                  _buildRecommendationCard(
                    'Try Quantum Mechanics',
                    'Based on your physics progress',
                    Icons.science,
                    Colors.purple,
                  ),
                  _buildRecommendationCard(
                    'Python Advanced Topics',
                    'Next step in programming',
                    Icons.code,
                    Colors.green,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.pop(context);
          Get.snackbar(
            'Recommendation',
            'Opening $title...',
            snackPosition: SnackPosition.BOTTOM,
          );
        },
      ),
    );
  }
}

class LessonSearchDelegate extends SearchDelegate<Lesson?> {
  final List<Lesson> lessons;

  LessonSearchDelegate(this.lessons);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [IconButton(icon: Icon(Icons.clear), onPressed: () => query = '')];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildSuggestions(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final results = lessons.where((lesson) {
      return lesson.title.toLowerCase().contains(query.toLowerCase()) ||
          lesson.courseTitle.toLowerCase().contains(query.toLowerCase()) ||
          lesson.topics.any(
            (topic) => topic.toLowerCase().contains(query.toLowerCase()),
          );
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final lesson = results[index];
        return ListTile(
          leading: Icon(Icons.school),
          title: Text(lesson.title),
          subtitle: Text(lesson.courseTitle),
          onTap: () {
            close(context, lesson);
          },
        );
      },
    );
  }
}

String _getThermodynamicsContent() {
  return '''
Thermodynamics Laws: The Foundation of Energy Science

Thermodynamics governs how energy flows and transforms in our universe. Understanding these fundamental laws is essential for physics, chemistry, engineering, and even biology.

The Four Laws of Thermodynamics

Zeroth Law: Thermal Equilibrium
If two systems are each in thermal equilibrium with a third system, they are in thermal equilibrium with each other. This law establishes the concept of temperature and makes thermometry possible.

Practical Application: This principle allows us to use thermometers reliably. When a thermometer reaches thermal equilibrium with your body, it accurately measures your temperature.

First Law: Conservation of Energy
Energy cannot be created or destroyed, only transformed from one form to another. Mathematically: ΔU = Q - W, where ΔU is the change in internal energy, Q is heat added to the system, and W is work done by the system.

Practical Applications:
• Heat engines convert thermal energy to mechanical work
• Refrigerators transfer heat from cold to hot regions using work
• Metabolic processes convert chemical energy to heat and work

Second Law: Entropy Always Increases
In any spontaneous process, the total entropy of a system and its surroundings always increases. Heat naturally flows from hot to cold, never the reverse without external work.

This law explains:
• Why perpetual motion machines are impossible
• The arrow of time - why processes have a preferred direction
• Why energy quality degrades over time
• The ultimate fate of the universe (heat death)

Practical Applications:
• Efficiency limits of heat engines (Carnot efficiency)
• Refrigeration and air conditioning design
• Chemical reaction spontaneity
• Information theory and computing

Third Law: Absolute Zero is Unreachable
As temperature approaches absolute zero (0 Kelvin or -273.15°C), the entropy of a perfect crystal approaches zero. It's impossible to reach absolute zero in a finite number of steps.

Implications:
• Quantum mechanical effects dominate at very low temperatures
• Superconductivity and superfluidity emerge
• Limits on cooling technologies

Key Concepts

Entropy
Entropy measures disorder or randomness in a system. High entropy means high disorder; low entropy means high order. The universe's entropy constantly increases.

Enthalpy
Enthalpy (H) represents the total heat content of a system at constant pressure. It's useful for analyzing chemical reactions and phase changes.

Gibbs Free Energy
Gibbs free energy (G) determines whether a process will occur spontaneously. If ΔG < 0, the process is spontaneous; if ΔG > 0, it requires energy input.

Heat Engines and Efficiency

The Carnot Cycle represents the most efficient possible heat engine, with efficiency η = 1 - (Tc/Th), where Tc is the cold reservoir temperature and Th is the hot reservoir temperature.

Real engines (car engines, power plants) are less efficient than the Carnot limit due to friction, heat loss, and irreversible processes.

Applications Across Disciplines

Chemistry: Predicting reaction spontaneity and equilibrium
Biology: Understanding metabolism and cellular processes
Engineering: Designing engines, refrigerators, and power plants
Cosmology: Explaining the universe's evolution and fate
Information Theory: Connecting entropy to information and computation

Modern Developments

Statistical Mechanics: Connects microscopic particle behavior to macroscopic thermodynamic properties
Non-equilibrium Thermodynamics: Studies systems far from equilibrium
Quantum Thermodynamics: Explores thermodynamics at quantum scales
Black Hole Thermodynamics: Applies thermodynamic concepts to black holes

Conclusion

Thermodynamics provides fundamental constraints on what's possible in our universe. These laws govern everything from the smallest chemical reactions to the largest cosmic processes, making thermodynamics one of the most universal and powerful frameworks in science.
''';
}

String _getAlgorithmsContent() {
  return '''
Algorithms and Complexity: The Science of Efficient Computing

Understanding algorithms and their complexity is fundamental to computer science. This knowledge enables you to write efficient code, solve complex problems, and make informed design decisions.

What is an Algorithm?

An algorithm is a step-by-step procedure for solving a problem or accomplishing a task. Good algorithms are:
• Correct: Produce the right output for all valid inputs
• Efficient: Use minimal time and space resources
• Clear: Easy to understand and implement
• General: Work for a wide range of inputs

Big O Notation

Big O notation describes how an algorithm's runtime or space requirements grow as input size increases. It focuses on the dominant term and ignores constants.

Common Time Complexities (from fastest to slowest):

O(1) - Constant Time
The algorithm takes the same time regardless of input size.
Example: Accessing an array element by index
array[5] // Always takes the same time

O(log n) - Logarithmic Time
Runtime grows logarithmically with input size.
Example: Binary search in a sorted array
Doubling the input size adds only one more step

O(n) - Linear Time
Runtime grows proportionally with input size.
Example: Finding the maximum element in an unsorted array
Must check every element once

O(n log n) - Linearithmic Time
Common in efficient sorting algorithms.
Example: Merge sort, quicksort (average case)
The best possible time for comparison-based sorting

O(n²) - Quadratic Time
Runtime grows with the square of input size.
Example: Bubble sort, selection sort, insertion sort
Nested loops often indicate quadratic complexity

O(2ⁿ) - Exponential Time
Runtime doubles with each additional input element.
Example: Recursive Fibonacci without memoization
Quickly becomes impractical for large inputs

O(n!) - Factorial Time
Runtime grows factorially with input size.
Example: Generating all permutations
Only feasible for very small inputs

Fundamental Algorithms

Sorting Algorithms

Bubble Sort - O(n²)
Simple but inefficient. Repeatedly swaps adjacent elements if they're in wrong order.

Selection Sort - O(n²)
Finds minimum element and places it at the beginning. Repeat for remaining elements.

Insertion Sort - O(n²)
Builds sorted array one element at a time. Efficient for small or nearly-sorted arrays.

Merge Sort - O(n log n)
Divide-and-conquer algorithm. Divides array in half, recursively sorts, then merges.

Quick Sort - O(n log n) average, O(n²) worst
Picks a pivot, partitions array around it, recursively sorts partitions. Very fast in practice.

Heap Sort - O(n log n)
Uses a binary heap data structure. Guaranteed O(n log n) but slower than quicksort in practice.

Searching Algorithms

Linear Search - O(n)
Checks each element sequentially until finding the target.

Binary Search - O(log n)
Requires sorted array. Repeatedly divides search space in half.

Depth-First Search (DFS) - O(V + E)
Explores graph by going as deep as possible before backtracking.

Breadth-First Search (BFS) - O(V + E)
Explores graph level by level, visiting all neighbors before going deeper.

Graph Algorithms

Dijkstra's Algorithm - O((V + E) log V)
Finds shortest path from source to all vertices in weighted graph.

Bellman-Ford Algorithm - O(VE)
Finds shortest paths, handles negative edge weights.

Floyd-Warshall Algorithm - O(V³)
Finds shortest paths between all pairs of vertices.

Kruskal's Algorithm - O(E log E)
Finds minimum spanning tree by sorting edges and adding them greedily.

Prim's Algorithm - O(E log V)
Finds minimum spanning tree by growing tree from starting vertex.

Dynamic Programming

Dynamic programming solves complex problems by breaking them into simpler subproblems and storing results to avoid redundant computation.

Classic Examples:
• Fibonacci sequence
• Longest common subsequence
• Knapsack problem
• Edit distance
• Matrix chain multiplication

Greedy Algorithms

Greedy algorithms make locally optimal choices at each step, hoping to find a global optimum.

Examples:
• Huffman coding
• Activity selection
• Fractional knapsack
• Dijkstra's algorithm

Space Complexity

Space complexity measures memory usage. Common patterns:

O(1) - Constant Space: Only a few variables
O(n) - Linear Space: Array or list proportional to input
O(n²) - Quadratic Space: 2D array or matrix

Trade-offs

Often there's a trade-off between time and space:
• Memoization uses more space to save time
• In-place algorithms save space but may be slower
• Hash tables use space for O(1) lookup time

Practical Considerations

1. Choose the right algorithm for your use case
2. Consider input size and characteristics
3. Profile before optimizing
4. Readability matters - don't optimize prematurely
5. Know your language's built-in algorithms

Conclusion

Understanding algorithms and complexity analysis is essential for writing efficient code. While you won't always need the most optimal algorithm, knowing the trade-offs helps you make informed decisions and avoid performance pitfalls.

The key is recognizing patterns, understanding fundamental algorithms, and applying complexity analysis to evaluate solutions. With practice, this becomes second nature, enabling you to tackle increasingly complex computational problems.
''';
}

String _getChemicalBondingContent() {
  return '''
Chemical Bonding: The Forces That Hold Matter Together

Chemical bonds are the attractive forces that hold atoms together to form molecules and compounds. Understanding bonding is fundamental to chemistry, materials science, and biology.

Types of Chemical Bonds

Ionic Bonds

Ionic bonds form when electrons transfer from one atom to another, creating oppositely charged ions that attract each other.

Characteristics:
• Occur between metals and nonmetals
• Large electronegativity difference (> 1.7)
• Form crystalline solids
• High melting and boiling points
• Conduct electricity when molten or dissolved
• Brittle - shatter when struck

Example: Sodium chloride (NaCl)
Sodium (Na) loses one electron to become Na⁺
Chlorine (Cl) gains one electron to become Cl⁻
The ions attract through electrostatic forces

Other Examples:
• Magnesium oxide (MgO)
• Calcium fluoride (CaF₂)
• Potassium bromide (KBr)

Covalent Bonds

Covalent bonds form when atoms share electrons to achieve stable electron configurations.

Types of Covalent Bonds:

Single Bond: One pair of shared electrons (e.g., H-H)
Double Bond: Two pairs of shared electrons (e.g., O=O)
Triple Bond: Three pairs of shared electrons (e.g., N≡N)

Characteristics:
• Occur between nonmetals
• Small electronegativity difference
• Can form molecules or network solids
• Variable melting and boiling points
• Generally don't conduct electricity
• Can be flexible or rigid depending on structure

Polar vs. Nonpolar Covalent:

Nonpolar Covalent: Equal sharing of electrons (e.g., H₂, O₂, N₂)
Polar Covalent: Unequal sharing due to electronegativity difference (e.g., H₂O, HCl)

Examples:
• Water (H₂O) - polar covalent
• Methane (CH₄) - nonpolar covalent
• Carbon dioxide (CO₂) - polar bonds, nonpolar molecule
• Diamond (C) - network covalent solid

Metallic Bonds

Metallic bonds occur in metals, where electrons are delocalized across many atoms, forming an "electron sea."

Characteristics:
• Occur in metals and alloys
• Electrons move freely throughout the structure
• Conduct electricity and heat well
• Malleable and ductile
• Lustrous appearance
• Variable melting points

The "sea of electrons" model explains:
• Electrical conductivity: Free electrons carry charge
• Thermal conductivity: Electrons transfer kinetic energy
• Malleability: Atoms can slide past each other without breaking bonds
• Luster: Free electrons interact with light

Examples:
• Copper (Cu) - excellent conductor
• Iron (Fe) - strong and malleable
• Gold (Au) - highly malleable and conductive
• Aluminum (Al) - lightweight and conductive

Intermolecular Forces

These are weaker forces between molecules (not within molecules):

London Dispersion Forces
• Weakest intermolecular force
• Present in all molecules
• Caused by temporary dipoles
• Strength increases with molecular size

Dipole-Dipole Forces
• Occur between polar molecules
• Stronger than London forces
• Permanent dipoles attract each other

Hydrogen Bonding
• Special case of dipole-dipole
• Occurs when H bonds to N, O, or F
• Strongest intermolecular force
• Explains water's unique properties

Bond Properties

Bond Length
Distance between nuclei of bonded atoms. Triple bonds are shorter than double bonds, which are shorter than single bonds.

Bond Energy
Energy required to break a bond. Triple bonds are stronger than double bonds, which are stronger than single bonds.

Bond Polarity
Determined by electronegativity difference. Affects molecular properties like solubility and reactivity.

Molecular Geometry

VSEPR Theory (Valence Shell Electron Pair Repulsion) predicts molecular shapes based on electron pair repulsion:

• Linear: 180° (e.g., CO₂)
• Trigonal planar: 120° (e.g., BF₃)
• Tetrahedral: 109.5° (e.g., CH₄)
• Trigonal bipyramidal: 90° and 120° (e.g., PCl₅)
• Octahedral: 90° (e.g., SF₆)

Hybridization

Atomic orbitals mix to form hybrid orbitals:

sp: Linear geometry (e.g., BeH₂)
sp²: Trigonal planar (e.g., BH₃)
sp³: Tetrahedral (e.g., CH₄)
sp³d: Trigonal bipyramidal (e.g., PCl₅)
sp³d²: Octahedral (e.g., SF₆)

Applications

Materials Science: Designing new materials with specific properties
Drug Design: Understanding how molecules interact
Biochemistry: Protein folding, DNA structure, enzyme function
Nanotechnology: Creating molecular machines and devices

Conclusion

Chemical bonding explains why substances have their characteristic properties. Understanding bonds helps predict reactivity, design new materials, and explain biological processes. From the salt on your table to the DNA in your cells, chemical bonds are fundamental to the material world.
''';
}

String _getMachineLearningContent() {
  return '''
Machine Learning Algorithms: From Theory to Practice

Machine learning has revolutionized how computers learn from data without explicit programming. This comprehensive guide explores the fundamental algorithms that power modern AI applications.

What is Machine Learning?

Machine learning is a subset of artificial intelligence that enables systems to learn and improve from experience. Instead of following explicit instructions, ML algorithms identify patterns in data and make predictions or decisions.

Types of Machine Learning

Supervised Learning
The algorithm learns from labeled training data, making predictions on new, unseen data.

Unsupervised Learning
The algorithm finds patterns in unlabeled data without predefined categories.

Reinforcement Learning
The algorithm learns through trial and error, receiving rewards or penalties for actions.

Semi-Supervised Learning
Combines small amounts of labeled data with large amounts of unlabeled data.

Supervised Learning Algorithms

Linear Regression
Predicts continuous values by fitting a linear relationship between features and target.

Use Cases: House price prediction, sales forecasting, trend analysis

Advantages:
• Simple and interpretable
• Fast training and prediction
• Works well with linear relationships

Limitations:
• Assumes linear relationship
• Sensitive to outliers
• May underfit complex data

Logistic Regression
Despite its name, it's a classification algorithm that predicts probabilities using the sigmoid function.

Use Cases: Email spam detection, disease diagnosis, customer churn prediction

Advantages:
• Probabilistic output
• Efficient and interpretable
• Works well for binary classification

Limitations:
• Assumes linear decision boundary
• May underfit complex patterns

Decision Trees
Tree-like models that make decisions based on feature values, splitting data at each node.

Use Cases: Credit approval, medical diagnosis, customer segmentation

Advantages:
• Easy to understand and visualize
• Handles both numerical and categorical data
• No feature scaling required
• Captures non-linear relationships

Limitations:
• Prone to overfitting
• Unstable - small data changes can create very different trees
• Biased toward features with more levels

Random Forests
Ensemble method that combines multiple decision trees to improve accuracy and reduce overfitting.

Use Cases: Feature importance analysis, classification and regression tasks

Advantages:
• Reduces overfitting compared to single trees
• Handles missing values well
• Provides feature importance
• Works well with high-dimensional data

Limitations:
• Less interpretable than single trees
• Slower training and prediction
• Requires more memory

Support Vector Machines (SVM)
Finds the optimal hyperplane that maximally separates classes in high-dimensional space.

Use Cases: Image classification, text categorization, bioinformatics

Advantages:
• Effective in high-dimensional spaces
• Memory efficient
• Versatile through different kernel functions

Limitations:
• Slow training on large datasets
• Sensitive to feature scaling
• Difficult to interpret

Neural Networks
Interconnected layers of nodes (neurons) that learn complex patterns through backpropagation.

Use Cases: Image recognition, natural language processing, speech recognition

Advantages:
• Can learn extremely complex patterns
• Scales well with data
• Flexible architecture

Limitations:
• Requires large amounts of data
• Computationally expensive
• Black box - difficult to interpret
• Prone to overfitting

Gradient Boosting (XGBoost, LightGBM, CatBoost)
Ensemble method that builds trees sequentially, each correcting errors of previous trees.

Use Cases: Kaggle competitions, ranking problems, structured data

Advantages:
• Often achieves best performance on structured data
• Handles missing values
• Built-in regularization
• Feature importance

Limitations:
• Prone to overfitting if not tuned properly
• Sensitive to hyperparameters
• Slower training than random forests

Unsupervised Learning Algorithms

K-Means Clustering
Partitions data into K clusters by minimizing within-cluster variance.

Use Cases: Customer segmentation, image compression, anomaly detection

Advantages:
• Simple and fast
• Scales well to large datasets
• Easy to implement

Limitations:
• Must specify K in advance
• Sensitive to initial centroids
• Assumes spherical clusters
• Sensitive to outliers

Hierarchical Clustering
Creates a tree of clusters, either bottom-up (agglomerative) or top-down (divisive).

Use Cases: Gene sequence analysis, social network analysis, taxonomy creation

Advantages:
• No need to specify number of clusters
• Produces dendrogram for visualization
• Can capture hierarchical relationships

Limitations:
• Computationally expensive
• Sensitive to noise and outliers
• Difficult to scale to large datasets

DBSCAN (Density-Based Spatial Clustering)
Groups together points that are closely packed, marking outliers as noise.

Use Cases: Anomaly detection, geographic data analysis, image segmentation

Advantages:
• Doesn't require specifying number of clusters
• Can find arbitrarily shaped clusters
• Robust to outliers

Limitations:
• Sensitive to parameters (epsilon and min_points)
• Struggles with varying density clusters
• Not suitable for high-dimensional data

Principal Component Analysis (PCA)
Reduces dimensionality by finding principal components that capture maximum variance.

Use Cases: Data visualization, noise reduction, feature extraction

Advantages:
• Reduces computational cost
• Helps visualize high-dimensional data
• Removes correlated features

Limitations:
• Linear transformation only
• Principal components may not be interpretable
• Sensitive to feature scaling

Model Evaluation

Classification Metrics:
• Accuracy: Overall correctness
• Precision: True positives / (True positives + False positives)
• Recall: True positives / (True positives + False negatives)
• F1-Score: Harmonic mean of precision and recall
• ROC-AUC: Area under receiver operating characteristic curve

Regression Metrics:
• Mean Absolute Error (MAE)
• Mean Squared Error (MSE)
• Root Mean Squared Error (RMSE)
• R² Score: Proportion of variance explained

Overfitting and Underfitting

Overfitting: Model learns training data too well, including noise, performing poorly on new data.
Solutions: Regularization, cross-validation, more data, simpler model

Underfitting: Model is too simple to capture underlying patterns.
Solutions: More complex model, more features, less regularization

Best Practices

1. Start simple, then increase complexity
2. Always split data into training, validation, and test sets
3. Use cross-validation for robust evaluation
4. Scale features when necessary
5. Handle missing values appropriately
6. Monitor for overfitting
7. Try multiple algorithms
8. Tune hyperparameters systematically
9. Understand your data before modeling
10. Consider interpretability vs. performance trade-offs

Conclusion

Machine learning offers powerful tools for extracting insights from data. Success requires understanding algorithm strengths and limitations, proper data preparation, careful evaluation, and iterative refinement. The best algorithm depends on your specific problem, data characteristics, and requirements for interpretability and performance.
''';
}

String _getSmartContractsContent() {
  return '''
Smart Contracts Development: Building on the Blockchain

Smart contracts are self-executing programs stored on blockchain networks that automatically enforce agreements when predefined conditions are met. They're revolutionizing how we think about trust, transactions, and decentralized applications.

What are Smart Contracts?

A smart contract is code that runs on a blockchain, typically Ethereum. Once deployed, it cannot be altered, ensuring transparency and trust. Smart contracts eliminate intermediaries, reduce costs, and enable new types of applications.

Key Characteristics:
• Immutable: Cannot be changed after deployment
• Deterministic: Same inputs always produce same outputs
• Transparent: Code is publicly visible
• Autonomous: Execute automatically without human intervention
• Distributed: Replicated across all network nodes

Solidity Programming Language

Solidity is the most popular language for writing Ethereum smart contracts. It's statically typed, supports inheritance, and has syntax similar to JavaScript.

Basic Structure:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleStorage {
    uint256 private storedData;
    
    function set(uint256 x) public {
        storedData = x;
    }
    
    function get() public view returns (uint256) {
        return storedData;
    }
}
```

Data Types:

Value Types:
• bool: true or false
• uint: unsigned integers (uint8 to uint256)
• int: signed integers
• address: Ethereum address (20 bytes)
• bytes: fixed-size byte arrays

Reference Types:
• arrays: dynamic or fixed-size
• structs: custom data structures
• mappings: key-value stores

Functions:

Visibility Modifiers:
• public: Callable from anywhere
• private: Only within the contract
• internal: Within contract and derived contracts
• external: Only from outside the contract

State Mutability:
• view: Reads state but doesn't modify
• pure: Neither reads nor modifies state
• payable: Can receive Ether

Example Token Contract:

```solidity
pragma solidity ^0.8.0;

contract SimpleToken {
    mapping(address => uint256) public balances;
    uint256 public totalSupply;
    
    constructor(uint256 _initialSupply) {
        balances[msg.sender] = _initialSupply;
        totalSupply = _initialSupply;
    }
    
    function transfer(address _to, uint256 _amount) public {
        require(balances[msg.sender] >= _amount, "Insufficient balance");
        balances[msg.sender] -= _amount;
        balances[_to] += _amount;
    }
}
```

Advanced Concepts

Events
Events allow contracts to communicate with external applications:

```solidity
event Transfer(address indexed from, address indexed to, uint256 value);

function transfer(address _to, uint256 _amount) public {
    // ... transfer logic
    emit Transfer(msg.sender, _to, _amount);
}
```

Modifiers
Reusable code that can modify function behavior:

```solidity
modifier onlyOwner() {
    require(msg.sender == owner, "Not the owner");
    _;
}

function restrictedFunction() public onlyOwner {
    // Only owner can call this
}
```

Inheritance
Contracts can inherit from other contracts:

```solidity
contract Owned {
    address public owner;
    
    constructor() {
        owner = msg.sender;
    }
}

contract MyContract is Owned {
    // Inherits owner variable and constructor
}
```

Common Patterns

Factory Pattern
Create multiple contract instances:

```solidity
contract TokenFactory {
    address[] public tokens;
    
    function createToken(uint256 supply) public {
        address newToken = address(new SimpleToken(supply));
        tokens.push(newToken);
    }
}
```

Withdrawal Pattern
Safer than direct transfers:

```solidity
mapping(address => uint256) public pendingWithdrawals;

function withdraw() public {
    uint256 amount = pendingWithdrawals[msg.sender];
    pendingWithdrawals[msg.sender] = 0;
    payable(msg.sender).transfer(amount);
}
```

Security Considerations

Reentrancy Attacks
Malicious contracts can call back into your contract before state updates complete.

Prevention:
• Update state before external calls
• Use ReentrancyGuard from OpenZeppelin
• Follow checks-effects-interactions pattern

Integer Overflow/Underflow
Arithmetic operations can wrap around.

Prevention:
• Use Solidity 0.8+ (built-in overflow checks)
• Or use SafeMath library for older versions

Access Control
Ensure only authorized users can call sensitive functions.

Prevention:
• Use modifiers for access control
• Implement role-based permissions
• Use OpenZeppelin's AccessControl

Gas Optimization

Smart contracts cost gas to execute. Optimization techniques:

1. Use appropriate data types (uint256 is often most efficient)
2. Pack variables to save storage slots
3. Use events instead of storing data when possible
4. Minimize storage operations (most expensive)
5. Use memory instead of storage for temporary data
6. Batch operations when possible

Development Tools

Hardhat
Modern development environment with testing, debugging, and deployment tools.

Truffle
Comprehensive framework for smart contract development.

Remix
Browser-based IDE for quick prototyping and learning.

Ganache
Personal blockchain for testing.

OpenZeppelin
Library of secure, audited smart contract components.

Testing

Always write comprehensive tests:

```javascript
const { expect } = require("chai");

describe("SimpleToken", function() {
    it("Should transfer tokens correctly", async function() {
        const Token = await ethers.getContractFactory("SimpleToken");
        const token = await Token.deploy(1000);
        
        await token.transfer(addr1.address, 100);
        expect(await token.balances(addr1.address)).to.equal(100);
    });
});
```

Deployment

1. Compile contracts
2. Test thoroughly on local network
3. Deploy to testnet (Goerli, Sepolia)
4. Audit code (for production)
5. Deploy to mainnet
6. Verify contract on Etherscan

Real-World Applications

DeFi (Decentralized Finance):
• Lending protocols (Aave, Compound)
• Decentralized exchanges (Uniswap, SushiSwap)
• Stablecoins (DAI, USDC)

NFTs (Non-Fungible Tokens):
• Digital art marketplaces
• Gaming assets
• Digital identity

DAOs (Decentralized Autonomous Organizations):
• Governance systems
• Treasury management
• Voting mechanisms

Supply Chain:
• Product tracking
• Authenticity verification
• Automated payments

Best Practices

1. Keep contracts simple and modular
2. Follow established patterns (OpenZeppelin)
3. Write comprehensive tests
4. Get security audits for production code
5. Use established libraries when possible
6. Document code thoroughly
7. Plan for upgradability if needed
8. Monitor deployed contracts
9. Have emergency pause mechanisms
10. Stay updated on security vulnerabilities

Conclusion

Smart contract development requires careful attention to security, gas optimization, and best practices. While the technology is powerful, mistakes can be costly and irreversible. Start with simple contracts, use established libraries, test thoroughly, and always prioritize security.

The smart contract ecosystem is rapidly evolving, with new patterns, tools, and use cases emerging constantly. Continuous learning and staying connected with the developer community are essential for success in this exciting field.
''';
}

String _getEthicalHackingContent() {
  return '''
Ethical Hacking Basics: Penetration Testing and Security Assessment

Ethical hacking involves legally breaking into systems to find vulnerabilities before malicious hackers do. This comprehensive guide covers the fundamentals of penetration testing and security assessment.

What is Ethical Hacking?

Ethical hackers, also called white hat hackers or penetration testers, use the same techniques as malicious hackers but with permission and for defensive purposes. Their goal is to identify and fix security weaknesses.

Key Principles:
• Always get written permission before testing
• Respect privacy and confidentiality
• Report all findings responsibly
• Don't cause damage or disruption
• Stay within agreed scope
• Follow legal and ethical guidelines

The Hacking Methodology

1. Reconnaissance (Information Gathering)
Collect information about the target system.

Passive Reconnaissance:
• WHOIS lookups
• DNS enumeration
• Social media research
• Public records
• Google dorking

Active Reconnaissance:
• Port scanning
• Network mapping
• Service enumeration
• OS fingerprinting

Tools: Nmap, Maltego, theHarvester, Shodan, Recon-ng

2. Scanning and Enumeration
Identify live hosts, open ports, and running services.

Network Scanning:
• Ping sweeps to find live hosts
• Port scans to identify open ports
• Service version detection
• OS detection

Vulnerability Scanning:
• Automated vulnerability scanners
• Configuration audits
• Patch level assessment

Tools: Nmap, Nessus, OpenVAS, Nikto, Burp Suite

3. Gaining Access (Exploitation)
Exploit identified vulnerabilities to gain system access.

Common Attack Vectors:
• Unpatched software vulnerabilities
• Weak passwords
• Misconfigured services
• Social engineering
• SQL injection
• Cross-site scripting (XSS)
• Buffer overflows

Tools: Metasploit, SQLmap, BeEF, Social-Engineer Toolkit

4. Maintaining Access
Establish persistent access for further testing.

Techniques:
• Installing backdoors
• Creating user accounts
• Modifying system files
• Rootkits (for testing only!)

Note: In real penetration tests, maintaining access is documented but typically not implemented to avoid security risks.

5. Covering Tracks
Understanding how attackers hide their activities.

Techniques:
• Clearing log files
• Hiding files and processes
• Timestomping
• Using encryption

Note: Ethical hackers document these techniques but don't actually cover tracks during authorized tests.

6. Reporting
Document findings and provide remediation recommendations.

Report Components:
• Executive summary
• Methodology
• Findings with severity ratings
• Evidence (screenshots, logs)
• Remediation recommendations
• Risk assessment

Common Vulnerabilities

Web Application Vulnerabilities

SQL Injection
Inserting malicious SQL code into input fields.

Example:
```
' OR '1'='1' --
```

Prevention:
• Use parameterized queries
• Input validation
• Least privilege database accounts

Cross-Site Scripting (XSS)
Injecting malicious scripts into web pages.

Types:
• Reflected XSS
• Stored XSS
• DOM-based XSS

Prevention:
• Input validation
• Output encoding
• Content Security Policy

Cross-Site Request Forgery (CSRF)
Tricking users into performing unwanted actions.

Prevention:
• CSRF tokens
• SameSite cookies
• Verify origin headers

Network Vulnerabilities

Man-in-the-Middle (MITM)
Intercepting communication between two parties.

Prevention:
• Use encryption (TLS/SSL)
• Certificate pinning
• VPNs for sensitive communications

Denial of Service (DoS)
Overwhelming systems to make them unavailable.

Types:
• Network flooding
• Application layer attacks
• Distributed DoS (DDoS)

Prevention:
• Rate limiting
• Load balancing
• DDoS protection services

Password Attacks

Brute Force
Trying all possible password combinations.

Dictionary Attack
Using common passwords and variations.

Rainbow Tables
Precomputed hash tables for password cracking.

Prevention:
• Strong password policies
• Account lockout mechanisms
• Multi-factor authentication
• Password hashing with salt

Social Engineering

Phishing
Fraudulent emails or websites to steal credentials.

Pretexting
Creating false scenarios to extract information.

Baiting
Offering something enticing to trick victims.

Prevention:
• Security awareness training
• Email filtering
• Verification procedures
• Incident reporting mechanisms

Essential Tools

Kali Linux
Specialized Linux distribution with hundreds of security tools pre-installed.

Metasploit Framework
Comprehensive penetration testing platform.

Key Features:
• Exploit database
• Payload generation
• Post-exploitation modules
• Auxiliary modules

Burp Suite
Web application security testing tool.

Features:
• Proxy for intercepting requests
• Scanner for finding vulnerabilities
• Intruder for automated attacks
• Repeater for manual testing

Wireshark
Network protocol analyzer for capturing and analyzing traffic.

Nmap
Network scanner for host discovery and port scanning.

Common Commands:
```
nmap -sS target.com  # SYN scan
nmap -sV target.com  # Service version detection
nmap -O target.com   # OS detection
nmap -A target.com   # Aggressive scan
```

John the Ripper
Password cracking tool.

Aircrack-ng
Wireless network security testing suite.

Certifications

CEH (Certified Ethical Hacker)
Entry-level certification covering hacking techniques.

OSCP (Offensive Security Certified Professional)
Hands-on certification requiring practical exploitation skills.

GPEN (GIAC Penetration Tester)
Advanced penetration testing certification.

CREST
Internationally recognized penetration testing certifications.

Legal and Ethical Considerations

Legal Framework:
• Computer Fraud and Abuse Act (CFAA) in the US
• Computer Misuse Act in the UK
• Similar laws in other countries

Always:
• Get written authorization
• Define scope clearly
• Follow rules of engagement
• Report findings responsibly
• Maintain confidentiality

Never:
• Test without permission
• Exceed authorized scope
• Cause damage or disruption
• Disclose findings publicly without permission
• Use findings for personal gain

Career Paths

Penetration Tester
Conducts authorized security assessments.

Security Consultant
Advises organizations on security strategy.

Red Team Operator
Simulates advanced persistent threats.

Bug Bounty Hunter
Finds vulnerabilities in exchange for rewards.

Security Researcher
Discovers new vulnerabilities and attack techniques.

Best Practices

1. Continuous learning - security landscape constantly evolves
2. Practice in legal environments (home labs, CTF competitions)
3. Stay updated on latest vulnerabilities and exploits
4. Join security communities and forums
5. Develop both technical and soft skills
6. Understand business impact of security issues
7. Maintain ethical standards always
8. Document everything thoroughly
9. Communicate findings clearly
10. Focus on helping organizations improve security

Conclusion

Ethical hacking is a rewarding career that helps organizations protect themselves from cyber threats. Success requires technical skills, ethical integrity, continuous learning, and strong communication abilities.

Remember: With great power comes great responsibility. Use your skills to make the digital world safer, not to cause harm. Always operate within legal and ethical boundaries, and contribute positively to the security community.
''';
}

String _getBioinformaticsContent() {
  return '''
Bioinformatics Introduction: Computational Analysis of Biological Data

Bioinformatics sits at the intersection of biology, computer science, and statistics, using computational tools to understand biological systems. This field has revolutionized modern biology and medicine.

What is Bioinformatics?

Bioinformatics involves developing and applying computational methods to analyze biological data, particularly molecular sequences, structures, and functions. It's essential for genomics, proteomics, drug discovery, and personalized medicine.

Key Applications:
• Genome sequencing and assembly
• Gene prediction and annotation
• Protein structure prediction
• Evolutionary analysis
• Drug discovery and design
• Personalized medicine
• Disease diagnosis and prognosis

Fundamental Concepts

DNA, RNA, and Proteins

DNA (Deoxyribonucleic Acid):
• Double helix structure
• Four nucleotides: A (Adenine), T (Thymine), G (Guanine), C (Cytosine)
• Stores genetic information
• Base pairing: A-T, G-C

RNA (Ribonucleic Acid):
• Single-stranded
• Four nucleotides: A, U (Uracil), G, C
• Messenger RNA (mRNA) carries genetic information
• Transfer RNA (tRNA) and ribosomal RNA (rRNA) involved in protein synthesis

Proteins:
• Made of amino acids (20 standard types)
• Perform most cellular functions
• Structure determines function
• Folding is complex and critical

Central Dogma of Molecular Biology:
DNA → RNA → Protein
(Transcription → Translation)

Sequence Analysis

Sequence Alignment

Pairwise Alignment:
Comparing two sequences to find similarities.

Global Alignment (Needleman-Wunsch):
Aligns entire sequences from end to end.
Best for similar-length sequences.

Local Alignment (Smith-Waterman):
Finds regions of similarity within sequences.
Best for finding conserved domains.

Multiple Sequence Alignment:
Aligning three or more sequences simultaneously.
Tools: Clustal Omega, MUSCLE, MAFFT

Scoring Systems:
• Match: positive score
• Mismatch: negative score
• Gap: penalty for insertions/deletions

BLAST (Basic Local Alignment Search Tool)

The most widely used tool for sequence similarity searching.

Types:
• BLASTN: nucleotide vs nucleotide
• BLASTP: protein vs protein
• BLASTX: translated nucleotide vs protein
• TBLASTN: protein vs translated nucleotide

E-value:
Measures statistical significance of matches.
Lower E-value = more significant match.

Applications:
• Identifying unknown sequences
• Finding homologous genes
• Functional annotation
• Evolutionary studies

Genomics

Genome Assembly

Next-Generation Sequencing (NGS) produces millions of short reads that must be assembled into complete genomes.

Approaches:
• De novo assembly: without reference genome
• Reference-based assembly: mapping to known genome

Challenges:
• Repetitive sequences
• Sequencing errors
• Computational complexity

Tools: SPAdes, Velvet, Trinity, Canu

Gene Prediction

Identifying protein-coding genes in genomic sequences.

Ab initio Methods:
Use statistical models based on gene features.
Tools: GeneMark, AUGUSTUS, GlimmerHMM

Evidence-based Methods:
Use experimental data (RNA-seq, protein sequences).
Tools: MAKER, BRAKER

Genome Annotation

Adding biological information to sequences:
• Gene locations and structures
• Functional descriptions
• Regulatory elements
• Repeat regions

Databases: GenBank, EMBL, DDBJ, Ensembl

Proteomics

Protein Structure

Four Levels:
1. Primary: amino acid sequence
2. Secondary: local structures (α-helices, β-sheets)
3. Tertiary: 3D structure of single chain
4. Quaternary: multiple chains together

Structure Prediction:

Homology Modeling:
Predict structure based on similar proteins with known structures.
Tools: SWISS-MODEL, Modeller

Ab initio Prediction:
Predict structure from sequence alone.
Tools: Rosetta, AlphaFold (revolutionary deep learning approach)

Protein Function Prediction

Sequence-based:
• Domain identification (Pfam, InterPro)
• Motif searching (PROSITE)
• Homology to characterized proteins

Structure-based:
• Active site identification
• Binding pocket analysis
• Structural similarity

Tools: InterProScan, Phyre2, I-TASSER

Phylogenetics and Evolution

Phylogenetic Trees

Represent evolutionary relationships between organisms or genes.

Tree Construction Methods:

Distance-based:
• UPGMA
• Neighbor-joining

Character-based:
• Maximum parsimony
• Maximum likelihood
• Bayesian inference

Tools: MEGA, RAxML, MrBayes, IQ-TREE

Molecular Evolution

Analyzing how sequences change over time.

Key Concepts:
• Substitution rates
• Selection pressure (dN/dS ratio)
• Molecular clock
• Horizontal gene transfer

Applications:
• Tracing disease outbreaks
• Understanding species relationships
• Identifying conserved regions
• Dating evolutionary events

Transcriptomics

RNA-Seq Analysis

Sequencing RNA to measure gene expression.

Workflow:
1. Quality control (FastQC)
2. Read alignment (STAR, HISAT2)
3. Quantification (featureCounts, Salmon)
4. Differential expression (DESeq2, edgeR)
5. Functional enrichment (GO, KEGG)

Applications:
• Identifying disease biomarkers
• Understanding development
• Drug response studies
• Alternative splicing analysis

Databases and Resources

Sequence Databases:
• GenBank/NCBI: comprehensive sequence database
• UniProt: protein sequences and functional information
• Ensembl: genome annotation

Structure Databases:
• PDB (Protein Data Bank): 3D structures
• SCOP/CATH: structure classification

Pathway Databases:
• KEGG: metabolic pathways
• Reactome: biological pathways
• GO (Gene Ontology): functional annotation

Programming for Bioinformatics

Python
Popular for bioinformatics due to readability and libraries.

Key Libraries:
• Biopython: sequence analysis, file parsing
• NumPy/Pandas: data manipulation
• Matplotlib/Seaborn: visualization
• Scikit-learn: machine learning

R
Statistical computing language widely used in bioinformatics.

Key Packages:
• Bioconductor: comprehensive bioinformatics tools
• ggplot2: visualization
• DESeq2/edgeR: differential expression
• pheatmap: heatmaps

Command Line Tools
Essential for processing large datasets:
• awk, sed, grep: text processing
• samtools, bcftools: sequence file manipulation
• bedtools: genomic interval operations

Machine Learning in Bioinformatics

Applications:
• Protein structure prediction (AlphaFold)
• Gene expression classification
• Drug-target interaction prediction
• Disease diagnosis from genomic data
• Variant effect prediction

Challenges:
• High-dimensional data
• Small sample sizes
• Interpretability
• Biological validation

Practical Considerations

Data Management:
• Biological data is large (terabytes common)
• Need robust storage and backup
• Version control for analysis scripts
• Reproducible workflows

Computational Resources:
• High-performance computing clusters
• Cloud computing (AWS, Google Cloud)
• GPU acceleration for deep learning

Best Practices:
• Document analysis workflows
• Use version control (Git)
• Write reproducible code
• Validate results experimentally
• Stay current with literature

Career Opportunities

Research Scientist:
Academic or industry research in computational biology.

Bioinformatics Analyst:
Analyzing genomic data for research or clinical applications.

Computational Biologist:
Developing new algorithms and methods.

Data Scientist:
Applying machine learning to biological problems.

Clinical Bioinformatician:
Interpreting genomic data for patient care.

Conclusion

Bioinformatics is a rapidly evolving field at the forefront of biological discovery. Success requires interdisciplinary knowledge spanning biology, computer science, statistics, and domain-specific expertise.

The explosion of biological data from high-throughput technologies creates unprecedented opportunities to understand life at the molecular level. Whether you're interested in curing diseases, understanding evolution, or developing new biotechnologies, bioinformatics provides powerful tools to tackle these challenges.

The future of bioinformatics is bright, with artificial intelligence, single-cell technologies, and personalized medicine driving innovation. Continuous learning and adaptation are essential in this dynamic field.
''';
}

String _getFinancialMarketsContent() {
  return '''
Financial Markets Analysis: Understanding Investment and Trading

Financial markets are complex systems where securities, commodities, and other financial instruments are traded. Understanding these markets is essential for investors, traders, and financial professionals.

Types of Financial Markets

Stock Markets
Where company shares are bought and sold.

Major Exchanges:
• NYSE (New York Stock Exchange)
• NASDAQ
• London Stock Exchange
• Tokyo Stock Exchange
• Shanghai Stock Exchange

Market Participants:
• Retail investors
• Institutional investors
• Market makers
• High-frequency traders

Bond Markets
Where debt securities are traded.

Types of Bonds:
• Government bonds (Treasury bonds, T-bills)
• Corporate bonds
• Municipal bonds
• International bonds

Key Concepts:
• Yield and price inverse relationship
• Credit ratings
• Duration and convexity
• Default risk

Derivatives Markets
Trading contracts based on underlying assets.

Common Derivatives:
• Options (calls and puts)
• Futures contracts
• Swaps
• Forwards

Uses:
• Hedging risk
• Speculation
• Arbitrage
• Leverage

Foreign Exchange (Forex)
Currency trading market.

Characteristics:
• Largest financial market (\$6+ trillion daily)
• 24-hour trading
• High liquidity
• Leverage available

Major Currency Pairs:
• EUR/USD
• USD/JPY
• GBP/USD
• USD/CHF

Commodity Markets
Trading physical goods.

Categories:
• Energy (oil, natural gas)
• Metals (gold, silver, copper)
• Agriculture (wheat, corn, soybeans)
• Livestock

Fundamental Analysis

Evaluating securities based on intrinsic value.

For Stocks:

Financial Statement Analysis:
• Income statement (revenue, earnings)
• Balance sheet (assets, liabilities)
• Cash flow statement

Key Metrics:
• P/E Ratio (Price-to-Earnings)
• EPS (Earnings Per Share)
• ROE (Return on Equity)
• Debt-to-Equity Ratio
• Free Cash Flow

Valuation Methods:
• Discounted Cash Flow (DCF)
• Comparable Company Analysis
• Precedent Transactions

Economic Indicators:
• GDP growth
• Inflation rates
• Interest rates
• Employment data
• Consumer confidence

Industry Analysis:
• Porter's Five Forces
• Industry life cycle
• Competitive positioning
• Market share trends

Technical Analysis

Analyzing price patterns and trends.

Chart Types:
• Line charts
• Bar charts
• Candlestick charts (most popular)

Trend Analysis:
• Uptrend: higher highs and higher lows
• Downtrend: lower highs and lower lows
• Sideways: range-bound movement

Support and Resistance:
• Support: price level where buying pressure emerges
• Resistance: price level where selling pressure emerges
• Breakouts: price moves beyond these levels

Moving Averages:
• Simple Moving Average (SMA)
• Exponential Moving Average (EMA)
• Golden Cross: 50-day MA crosses above 200-day MA (bullish)
• Death Cross: 50-day MA crosses below 200-day MA (bearish)

Technical Indicators:

Momentum Indicators:
• RSI (Relative Strength Index): overbought/oversold
• MACD (Moving Average Convergence Divergence)
• Stochastic Oscillator

Volume Indicators:
• On-Balance Volume (OBV)
• Volume Price Trend (VPT)
• Accumulation/Distribution Line

Volatility Indicators:
• Bollinger Bands
• Average True Range (ATR)
• Volatility Index (VIX)

Chart Patterns:

Reversal Patterns:
• Head and Shoulders
• Double Top/Bottom
• Triple Top/Bottom
• Rounding Bottom

Continuation Patterns:
• Triangles (ascending, descending, symmetrical)
• Flags and Pennants
• Rectangles
• Wedges

Investment Strategies

Value Investing
Buying undervalued securities.

Principles:
• Margin of safety
• Long-term perspective
• Fundamental analysis focus
• Patience and discipline

Famous Practitioners: Warren Buffett, Benjamin Graham

Growth Investing
Investing in companies with high growth potential.

Characteristics:
• High P/E ratios
• Reinvested earnings
• Expanding markets
• Innovation focus

Risks: Valuation concerns, growth disappointments

Dividend Investing
Focusing on stocks that pay regular dividends.

Benefits:
• Regular income stream
• Lower volatility
• Compounding through reinvestment
• Tax advantages (in some jurisdictions)

Metrics:
• Dividend yield
• Payout ratio
• Dividend growth rate
• Dividend coverage

Index Investing
Tracking market indices through ETFs or index funds.

Advantages:
• Low costs
• Diversification
• Passive management
• Tax efficiency
• Consistent with market returns

Popular Indices:
• S&P 500
• NASDAQ-100
• Russell 2000
• MSCI World

Momentum Investing
Buying securities showing upward price trends.

Principles:
• Trend is your friend
• Cut losses quickly
• Let winners run
• Relative strength analysis

Risks: Trend reversals, whipsaws

Risk Management

Portfolio Diversification
Spreading investments across different assets.

Diversification Dimensions:
• Asset classes (stocks, bonds, real estate)
• Geographic regions
• Sectors and industries
• Company sizes (large-cap, mid-cap, small-cap)
• Investment styles (value, growth, blend)

Modern Portfolio Theory:
• Efficient frontier
• Risk-return optimization
• Correlation analysis

Position Sizing
Determining how much to invest in each security.

Methods:
• Equal weighting
• Risk parity
• Kelly Criterion
• Percentage of portfolio

Stop-Loss Orders
Automatic sell orders to limit losses.

Types:
• Fixed stop-loss (specific price)
• Trailing stop-loss (follows price up)
• Percentage-based stop-loss

Hedging Strategies
Protecting against adverse price movements.

Techniques:
• Options (protective puts)
• Inverse ETFs
• Short selling
• Diversification
• Currency hedging

Market Psychology

Behavioral Finance
Understanding psychological factors affecting investment decisions.

Common Biases:
• Confirmation bias: seeking information that confirms beliefs
• Anchoring: over-relying on first information
• Herd mentality: following the crowd
• Loss aversion: fear of losses exceeds desire for gains
• Overconfidence: overestimating abilities
• Recency bias: overweighting recent events

Market Sentiment Indicators:
• VIX (Fear Index)
• Put/Call Ratio
• Bull/Bear surveys
• Advance/Decline Line

Market Cycles
Markets move through predictable phases.

Four Phases:
1. Accumulation: smart money buying
2. Markup: public participation, rising prices
3. Distribution: smart money selling
4. Markdown: declining prices, panic selling

Trading vs. Investing

Day Trading:
• Holding positions for minutes to hours
• High frequency, high risk
• Requires significant time and skill
• Technical analysis focused

Swing Trading:
• Holding positions for days to weeks
• Capturing short-term trends
• Balance of technical and fundamental analysis

Position Trading:
• Holding positions for months to years
• Long-term trend following
• Fundamental analysis focused

Long-term Investing:
• Buy and hold strategy
• Years to decades timeframe
• Fundamental analysis
• Lower transaction costs

Regulatory Environment

Securities Regulations:
• SEC (Securities and Exchange Commission) in US
• FCA (Financial Conduct Authority) in UK
• Similar bodies in other countries

Key Regulations:
• Insider trading prohibitions
• Disclosure requirements
• Market manipulation rules
• Investor protection measures

Modern Developments

Algorithmic Trading
Computer programs executing trades based on predefined rules.

Types:
• High-frequency trading (HFT)
• Statistical arbitrage
• Market making
• Trend following

Cryptocurrency Markets
Digital assets traded on blockchain networks.

Characteristics:
• 24/7 trading
• High volatility
• Decentralized
• Emerging regulation

ESG Investing
Environmental, Social, and Governance factors.

Growing Importance:
• Climate change concerns
• Social responsibility
• Corporate governance
• Sustainable investing

Robo-Advisors
Automated investment platforms.

Features:
• Algorithm-based portfolio management
• Low fees
• Automatic rebalancing
• Tax-loss harvesting

Practical Tips for Success

1. Educate yourself continuously
2. Start with a clear investment plan
3. Understand your risk tolerance
4. Diversify appropriately
5. Control emotions
6. Keep costs low
7. Think long-term
8. Don't try to time the market
9. Review and rebalance regularly
10. Learn from mistakes

Common Mistakes to Avoid

• Investing without a plan
• Chasing hot stocks
• Panic selling during downturns
• Overtrading
• Ignoring fees and taxes
• Lack of diversification
• Following tips blindly
• Emotional decision-making
• Overleveraging
• Not doing research

Conclusion

Financial markets offer opportunities for wealth creation but require knowledge, discipline, and risk management. Success comes from understanding market mechanics, developing a sound strategy, managing emotions, and maintaining a long-term perspective.

Whether you're a conservative investor seeking steady returns or an active trader pursuing short-term gains, the principles of analysis, risk management, and continuous learning remain essential. The markets reward those who approach them with respect, preparation, and patience.
''';
}

String _getModernPhilosophyContent() {
  return '''
Modern Philosophy: Existentialism, Phenomenology, and Postmodernism

Modern philosophy, emerging in the late 19th and flourishing through the 20th century, represents a radical rethinking of fundamental questions about existence, knowledge, meaning, and reality.

Historical Context

Modern philosophy arose in response to:
• Scientific revolutions challenging traditional worldviews
• World wars questioning human progress and rationality
• Industrialization and urbanization changing social structures
• Decline of religious authority in Western societies
• Technological advancement raising new ethical questions

This period saw philosophy become more specialized, diverse, and engaged with concrete human experience rather than abstract metaphysics.

Existentialism

Core Themes:
• Existence precedes essence
• Individual freedom and responsibility
• Authenticity vs. bad faith
• Absurdity of existence
• Anxiety and dread
• Death and finitude

Key Philosophers:

Søren Kierkegaard (1813-1855)
Often called the "father of existentialism."

Key Ideas:
• Three stages of life: aesthetic, ethical, religious
• Leap of faith required for authentic existence
• Anxiety as fundamental to human condition
• Subjective truth over objective truth

Famous Quote: "Life can only be understood backwards; but it must be lived forwards."

Friedrich Nietzsche (1844-1900)
Radical critic of traditional morality and religion.

Key Ideas:
• "God is dead" - decline of religious authority
• Will to power as fundamental drive
• Übermensch (Overman) as ideal
• Eternal recurrence
• Master vs. slave morality
• Perspectivism - no absolute truth

Famous Quote: "He who has a why to live can bear almost any how."

Jean-Paul Sartre (1905-1980)
Systematic existentialist philosopher.

Key Ideas:
• Existence precedes essence - we create our own nature
• Radical freedom and responsibility
• Bad faith - self-deception about our freedom
• "Hell is other people" - others' gaze objectifies us
• Commitment and engagement necessary

Famous Quote: "Man is condemned to be free."

Albert Camus (1913-1960)
Philosopher of the absurd.

Key Ideas:
• Life is fundamentally absurd - no inherent meaning
• Sisyphus as metaphor for human condition
• Revolt, freedom, and passion as responses to absurdity
• Must imagine Sisyphus happy
• Rejection of suicide and philosophical suicide

Famous Quote: "The only way to deal with an unfree world is to become so absolutely free that your very existence is an act of rebellion."

Simone de Beauvoir (1908-1986)
Existentialist feminist philosopher.

Key Ideas:
• "One is not born, but rather becomes, a woman"
• Gender as social construction
• Women's oppression through "othering"
• Ethics of ambiguity
• Freedom requires recognition of others' freedom

Phenomenology

The study of structures of consciousness and experience.

Edmund Husserl (1859-1938)
Founder of phenomenology.

Key Ideas:
• Intentionality - consciousness is always "of" something
• Phenomenological reduction (epoché) - bracketing assumptions
• Return "to the things themselves"
• Transcendental ego
• Life-world (Lebenswelt)

Method:
1. Suspend natural attitude
2. Describe phenomena as they appear
3. Identify essential structures
4. Understand meaning constitution

Martin Heidegger (1889-1976)
Existential phenomenologist.

Key Ideas:
• Being-in-the-world (Dasein)
• Thrownness - we're born into specific contexts
• Being-toward-death - death gives life meaning
• Authenticity vs. inauthenticity
• Technology as "enframing" reality
• Critique of Western metaphysics

Famous Work: "Being and Time"

Maurice Merleau-Ponty (1908-1961)
Phenomenology of embodiment.

Key Ideas:
• Embodied consciousness - mind and body inseparable
• Perception as primary access to world
• Lived body vs. objective body
• Ambiguity of perception
• Intersubjectivity through embodiment

Postmodernism

Skepticism toward grand narratives and universal truths.

Core Themes:
• Rejection of metanarratives
• Deconstruction of binary oppositions
• Power/knowledge relationships
• Fragmentation and plurality
• Linguistic turn - reality mediated by language
• Critique of Enlightenment rationality

Michel Foucault (1926-1984)
Philosopher of power and knowledge.

Key Ideas:
• Power/knowledge - they're inseparable
• Discourse shapes reality
• Disciplinary power and surveillance
• Biopower - control over populations
• Genealogy - tracing historical contingencies
• Critique of institutions (prisons, hospitals, schools)

Famous Works: "Discipline and Punish," "The History of Sexuality"

Jacques Derrida (1930-2004)
Founder of deconstruction.

Key Ideas:
• Deconstruction - revealing hidden assumptions
• Différance - meaning is deferred and differential
• Binary oppositions are unstable
• No presence outside text
• Logocentrism critique
• Trace and supplement

Method: Show how texts undermine their own claims.

Jean-François Lyotard (1924-1998)
Theorist of postmodern condition.

Key Ideas:
• Incredulity toward metanarratives
• Language games (from Wittgenstein)
• Legitimation crisis
• Differend - incommensurable discourses
• Postmodern knowledge

Famous Work: "The Postmodern Condition"

Jean Baudrillard (1929-2007)
Theorist of simulation and hyperreality.

Key Ideas:
• Simulacra - copies without originals
• Hyperreality - simulation more real than reality
• Implosion of meaning
• Consumer society critique
• Media and technology analysis

Stages of Simulation:
1. Reflection of reality
2. Perversion of reality
3. Absence of reality
4. Pure simulacrum

Analytic Philosophy

Parallel tradition emphasizing logic and language.

Ludwig Wittgenstein (1889-1951)
Two major phases of thought.

Early Wittgenstein ("Tractatus"):
• Picture theory of language
• Logical atomism
• "Whereof one cannot speak, thereof one must be silent"

Later Wittgenstein ("Philosophical Investigations"):
• Language games
• Meaning as use
• Family resemblances
• Private language argument
• Forms of life

Bertrand Russell (1872-1970)
Logician and philosopher.

Key Ideas:
• Logical atomism
• Theory of descriptions
• Critique of idealism
• Scientific philosophy
• Pacifism and social activism

Karl Popper (1902-1994)
Philosopher of science.

Key Ideas:
• Falsificationism - science progresses through refutation
• Demarcation problem - distinguishing science from pseudoscience
• Open society vs. closed society
• Critique of historicism
• Evolutionary epistemology

Contemporary Relevance

Existentialism:
• Mental health and authenticity
• Meaning-making in secular age
• Individual responsibility in complex world

Phenomenology:
• Cognitive science and embodied cognition
• User experience design
• Qualitative research methods

Postmodernism:
• Identity politics and social construction
• Media studies and cultural criticism
• Critique of authority and expertise
• Digital culture and virtual reality

Critiques and Debates

Criticisms of Existentialism:
• Too individualistic
• Neglects social structures
• Overly pessimistic
• Lacks systematic ethics

Criticisms of Phenomenology:
• Too subjective
• Difficult methodology
• Limited scientific applicability
• Idealist tendencies

Criticisms of Postmodernism:
• Relativism and nihilism
• Obscure writing
• Political implications unclear
• Undermines progressive politics

Practical Applications

Personal Development:
• Authentic living
• Taking responsibility
• Confronting mortality
• Creating meaning

Ethics:
• Situational ethics
• Care ethics
• Recognition of others
• Ambiguity and complexity

Politics:
• Critique of power structures
• Recognition of difference
• Resistance to totalitarianism
• Democratic participation

Art and Culture:
• Experimental forms
• Questioning conventions
• Multiple perspectives
• Self-reflexivity

Conclusion

Modern philosophy challenges us to question assumptions, embrace complexity, and take responsibility for creating meaning in an uncertain world. While these movements differ significantly, they share a commitment to engaging with concrete human experience rather than abstract speculation.

Understanding modern philosophy helps us navigate contemporary challenges: identity formation in diverse societies, meaning-making in secular contexts, power dynamics in institutions, and the impact of technology on human existence.

These philosophical traditions remain vital for addressing questions about authenticity, freedom, knowledge, power, and meaning in the 21st century. They remind us that philosophy isn't just academic exercise but a way of living thoughtfully and critically in the world.
''';
}

String _getDockerKubernetesContent() {
  return '''
Docker and Kubernetes: Container Orchestration and Microservices

Containerization has revolutionized software deployment and infrastructure management. Docker and Kubernetes are the leading technologies enabling modern cloud-native applications.

Understanding Containers

What are Containers?

Containers package applications with their dependencies into isolated, portable units that run consistently across different environments.

Key Characteristics:
• Lightweight - share host OS kernel
• Portable - run anywhere Docker is installed
• Isolated - separate from host and other containers
• Efficient - start in seconds, minimal overhead
• Consistent - same behavior in dev, test, and production

Containers vs. Virtual Machines:

Containers:
• Share host OS kernel
• Megabytes in size
• Start in seconds
• More efficient resource usage
• Less isolation

Virtual Machines:
• Include full OS
• Gigabytes in size
• Start in minutes
• More resource intensive
• Stronger isolation

Docker Fundamentals

Docker Architecture:

Docker Client:
Command-line interface for interacting with Docker.

Docker Daemon:
Background service managing containers, images, networks, and volumes.

Docker Registry:
Repository for Docker images (Docker Hub, private registries).

Docker Images:
Read-only templates for creating containers.

Docker Containers:
Running instances of images.

Essential Docker Commands:

Image Management:
```bash
docker pull nginx:latest          # Download image
docker images                     # List images
docker rmi image_name             # Remove image
docker build -t myapp:1.0 .      # Build image from Dockerfile
docker tag myapp:1.0 user/myapp  # Tag image
docker push user/myapp           # Push to registry
```

Container Management:
```bash
docker run -d -p 80:80 nginx     # Run container
docker ps                         # List running containers
docker ps -a                      # List all containers
docker stop container_id          # Stop container
docker start container_id         # Start container
docker restart container_id       # Restart container
docker rm container_id            # Remove container
docker logs container_id          # View logs
docker exec -it container_id bash # Execute command in container
```

Dockerfile

Text file with instructions for building Docker images.

Example Dockerfile:
```dockerfile
# Base image
FROM node:16-alpine

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy application code
COPY . .

# Expose port
EXPOSE 3000

# Set environment variable
ENV NODE_ENV=production

# Define startup command
CMD ["node", "server.js"]
```

Best Practices:
• Use official base images
• Minimize layers
• Use .dockerignore file
• Don't run as root
• Use multi-stage builds
• Leverage build cache
• Keep images small

Multi-Stage Builds:
```dockerfile
# Build stage
FROM node:16 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Production stage
FROM node:16-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY package*.json ./
RUN npm install --production
CMD ["node", "dist/server.js"]
```

Docker Compose

Tool for defining and running multi-container applications.

docker-compose.yml Example:
```yaml
version: '3.8'

services:
  web:
    build: .
    ports:
      - "3000:3000"
    environment:
      - DATABASE_URL=postgresql://db:5432/myapp
    depends_on:
      - db
    volumes:
      - ./src:/app/src
    networks:
      - app-network

  db:
    image: postgres:14
    environment:
      - POSTGRES_PASSWORD=secret
      - POSTGRES_DB=myapp
    volumes:
      - postgres-data:/var/lib/postgresql/data
    networks:
      - app-network

volumes:
  postgres-data:

networks:
  app-network:
    driver: bridge
```

Commands:
```bash
docker-compose up -d              # Start services
docker-compose down               # Stop services
docker-compose ps                 # List services
docker-compose logs -f web        # View logs
docker-compose exec web bash      # Execute command
docker-compose build              # Build images
```

Docker Networking

Network Types:

Bridge (default):
Containers on same host communicate through virtual bridge.

Host:
Container uses host's network directly.

None:
No networking.

Overlay:
Multi-host networking for Swarm/Kubernetes.

Commands:
```bash
docker network create mynetwork
docker network ls
docker network inspect mynetwork
docker run --network mynetwork nginx
```

Docker Volumes

Persistent data storage for containers.

Types:

Volumes (recommended):
Managed by Docker, stored in Docker area.

Bind Mounts:
Mount host directory into container.

tmpfs Mounts:
Stored in host memory only.

Commands:
```bash
docker volume create myvolume
docker volume ls
docker volume inspect myvolume
docker run -v myvolume:/data nginx
docker run -v /host/path:/container/path nginx
```

Kubernetes Fundamentals

What is Kubernetes?

Open-source container orchestration platform for automating deployment, scaling, and management of containerized applications.

Key Features:
• Automatic scaling
• Self-healing
• Load balancing
• Rolling updates and rollbacks
• Service discovery
• Secret and configuration management
• Storage orchestration

Kubernetes Architecture:

Control Plane Components:

API Server:
Frontend for Kubernetes control plane.

etcd:
Distributed key-value store for cluster data.

Scheduler:
Assigns pods to nodes based on resource requirements.

Controller Manager:
Runs controller processes (replication, endpoints, etc.).

Node Components:

Kubelet:
Agent running on each node, manages pods.

Container Runtime:
Software for running containers (Docker, containerd, CRI-O).

Kube-proxy:
Network proxy maintaining network rules.

Kubernetes Objects

Pod:
Smallest deployable unit, contains one or more containers.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
spec:
  containers:
  - name: nginx
    image: nginx:latest
    ports:
    - containerPort: 80
```

Deployment:
Manages replica sets and rolling updates.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        ports:
        - containerPort: 80
```

Service:
Exposes pods as network service.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    app: nginx
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
  type: LoadBalancer
```

Service Types:
• ClusterIP: Internal cluster access only
• NodePort: Exposes on each node's IP
• LoadBalancer: External load balancer
• ExternalName: Maps to external DNS name

ConfigMap:
Configuration data for applications.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  database_url: "postgresql://db:5432/myapp"
  log_level: "info"
```

Secret:
Sensitive data like passwords and tokens.

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secret
type: Opaque
data:
  password: cGFzc3dvcmQxMjM=  # base64 encoded
```

Ingress:
HTTP/HTTPS routing to services.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app-ingress
spec:
  rules:
  - host: myapp.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: nginx-service
            port:
              number: 80
```

Essential kubectl Commands:

Cluster Management:
```bash
kubectl cluster-info
kubectl get nodes
kubectl describe node node-name
```

Pod Management:
```bash
kubectl get pods
kubectl describe pod pod-name
kubectl logs pod-name
kubectl exec -it pod-name -- bash
kubectl delete pod pod-name
```

Deployment Management:
```bash
kubectl create deployment nginx --image=nginx
kubectl get deployments
kubectl scale deployment nginx --replicas=5
kubectl set image deployment/nginx nginx=nginx:1.22
kubectl rollout status deployment/nginx
kubectl rollout undo deployment/nginx
kubectl delete deployment nginx
```

Service Management:
```bash
kubectl get services
kubectl expose deployment nginx --port=80 --type=LoadBalancer
kubectl describe service nginx
```

Apply Configuration:
```bash
kubectl apply -f deployment.yaml
kubectl apply -f .                    # Apply all YAML files
kubectl delete -f deployment.yaml
```

Namespaces:
```bash
kubectl get namespaces
kubectl create namespace dev
kubectl get pods -n dev
kubectl config set-context --current --namespace=dev
```

Advanced Kubernetes Concepts

StatefulSets:
For stateful applications requiring stable network identities and persistent storage.

DaemonSets:
Ensures pod runs on all (or selected) nodes.

Jobs and CronJobs:
Run tasks to completion or on schedule.

Horizontal Pod Autoscaler:
Automatically scales pods based on CPU/memory usage.

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: nginx-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: nginx-deployment
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

Persistent Volumes:
Cluster-level storage resources.

Resource Limits:
```yaml
resources:
  requests:
    memory: "64Mi"
    cpu: "250m"
  limits:
    memory: "128Mi"
    cpu: "500m"
```

Health Checks:

Liveness Probe:
Determines if container is running.

Readiness Probe:
Determines if container is ready to serve traffic.

```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 8080
  initialDelaySeconds: 30
  periodSeconds: 10

readinessProbe:
  httpGet:
    path: /ready
    port: 8080
  initialDelaySeconds: 5
  periodSeconds: 5
```

Best Practices

Docker:
• Keep images small
• Use specific image tags, not "latest"
• Scan images for vulnerabilities
• Use multi-stage builds
• Don't store secrets in images
• Run as non-root user
• Use .dockerignore
• Leverage layer caching

Kubernetes:
• Use namespaces for organization
• Set resource requests and limits
• Implement health checks
• Use ConfigMaps and Secrets
• Enable RBAC (Role-Based Access Control)
• Monitor and log everything
• Use Helm for package management
• Implement network policies
• Regular backups of etcd
• Use GitOps for deployments

Microservices Architecture

Benefits:
• Independent deployment
• Technology diversity
• Scalability
• Fault isolation
• Team autonomy

Challenges:
• Increased complexity
• Distributed system issues
• Data consistency
• Testing difficulty
• Monitoring and debugging

Tools and Ecosystem

Container Registries:
• Docker Hub
• Amazon ECR
• Google Container Registry
• Azure Container Registry
• Harbor (self-hosted)

Kubernetes Distributions:
• Google Kubernetes Engine (GKE)
• Amazon Elastic Kubernetes Service (EKS)
• Azure Kubernetes Service (AKS)
• Red Hat OpenShift
• Rancher

Service Mesh:
• Istio
• Linkerd
• Consul

Monitoring:
• Prometheus
• Grafana
• ELK Stack
• Datadog

CI/CD:
• Jenkins
• GitLab CI
• GitHub Actions
• ArgoCD
• Flux

Conclusion

Docker and Kubernetes have become essential technologies for modern software development and deployment. They enable consistent, scalable, and efficient application delivery across diverse environments.

Success with these technologies requires understanding both the fundamentals and best practices. Start with Docker to containerize applications, then progress to Kubernetes for orchestration at scale. The learning curve is steep, but the benefits in terms of deployment speed, reliability, and scalability are substantial.

The container ecosystem continues to evolve rapidly, with new tools and patterns emerging regularly. Staying current with developments and engaging with the community are essential for mastering these technologies.
''';
}

String _getNeuroplasticityContent() {
  return '''
Neuroplasticity: How the Brain Adapts and Changes

Neuroplasticity, also called brain plasticity, is the brain's remarkable ability to reorganize itself by forming new neural connections throughout life. This discovery has revolutionized our understanding of the brain and opened new possibilities for learning, recovery, and personal development.

Understanding Neuroplasticity

What is Neuroplasticity?

Neuroplasticity refers to the brain's capacity to change its structure and function in response to experience, learning, injury, or environmental demands. Contrary to earlier beliefs that the adult brain was fixed and unchangeable, we now know the brain remains malleable throughout life.

Types of Neuroplasticity:

Structural Plasticity:
Physical changes in brain structure, including:
• Growth of new neurons (neurogenesis)
• Formation of new synapses (synaptogenesis)
• Strengthening or weakening of existing connections
• Pruning of unused connections
• Changes in gray and white matter density

Functional Plasticity:
Changes in how brain functions are organized:
• Shifting functions from damaged to healthy areas
• Recruiting additional brain regions for tasks
• Reorganizing neural networks
• Compensatory mechanisms after injury

Mechanisms of Neuroplasticity

Synaptic Plasticity

Long-Term Potentiation (LTP):
Strengthening of synapses based on recent activity patterns. When neurons fire together repeatedly, their connection strengthens.

Principle: "Neurons that fire together, wire together" (Hebb's Law)

Long-Term Depression (LTD):
Weakening of synaptic connections through reduced activity. Unused connections become less efficient.

Principle: "Use it or lose it"

Structural Changes

Dendritic Branching:
Neurons grow new branches (dendrites) to form more connections.

Axonal Sprouting:
Axons develop new terminals to connect with other neurons.

Myelination:
Increased myelin sheath around axons improves signal transmission speed.

Neurogenesis:
Birth of new neurons, particularly in the hippocampus (memory) and olfactory bulb (smell).

Factors Influencing Neuroplasticity

Positive Factors:

Learning and Education:
• Acquiring new skills
• Studying new subjects
• Problem-solving activities
• Creative pursuits

Physical Exercise:
• Aerobic exercise increases BDNF (Brain-Derived Neurotrophic Factor)
• Improves blood flow to brain
• Promotes neurogenesis
• Enhances cognitive function

Mental Stimulation:
• Challenging cognitive tasks
• Learning new languages
• Playing musical instruments
• Strategic games (chess, puzzles)

Social Interaction:
• Meaningful relationships
• Collaborative activities
• Communication and empathy
• Social learning

Sleep:
• Memory consolidation
• Synaptic pruning
• Waste removal (glymphatic system)
• Neural repair

Nutrition:
• Omega-3 fatty acids (DHA, EPA)
• Antioxidants
• B vitamins
• Adequate protein
• Hydration

Mindfulness and Meditation:
• Increases gray matter density
• Strengthens attention networks
• Reduces stress-related damage
• Enhances emotional regulation

Negative Factors:

Chronic Stress:
• Elevated cortisol damages hippocampus
• Impairs neurogenesis
• Weakens synaptic connections
• Reduces brain volume

Sleep Deprivation:
• Impairs memory consolidation
• Reduces neuroplasticity
• Accumulates metabolic waste
• Decreases cognitive performance

Substance Abuse:
• Alcohol damages neurons
• Drugs alter neurotransmitter systems
• Impairs natural plasticity mechanisms
• Can cause lasting structural changes

Sedentary Lifestyle:
• Reduced BDNF production
• Decreased blood flow
• Lower neurogenesis rates
• Cognitive decline

Poor Nutrition:
• Deficiencies impair brain function
• Inflammation damages neurons
• Oxidative stress
• Reduced energy for neural processes

Neuroplasticity Across the Lifespan

Critical Periods:
Early developmental windows when brain is especially plastic:
• Language acquisition (birth to ~7 years)
• Vision development (birth to ~2 years)
• Emotional regulation (early childhood)
• Social skills (childhood and adolescence)

Childhood and Adolescence:
• Rapid synapse formation
• Extensive pruning of unused connections
• High learning capacity
• Vulnerability to environmental influences

Adulthood:
• Continued plasticity, though slower
• Experience-dependent changes
• Skill refinement
• Compensation for aging

Aging:
• Reduced but still present plasticity
• Cognitive reserve can compensate
• "Use it or lose it" becomes more critical
• Lifestyle factors increasingly important

Applications of Neuroplasticity

Recovery from Brain Injury

Stroke Rehabilitation:
• Constraint-induced movement therapy
• Repetitive task practice
• Brain-computer interfaces
• Transcranial magnetic stimulation

Traumatic Brain Injury:
• Cognitive rehabilitation
• Compensatory strategies
• Environmental modifications
• Gradual skill rebuilding

Learning and Education

Effective Learning Strategies:
• Spaced repetition
• Active recall
• Interleaving practice
• Elaborative rehearsal
• Teaching others

Growth Mindset:
Understanding that abilities can be developed through effort encourages persistence and learning.

Mental Health Treatment

Depression and Anxiety:
• Cognitive-behavioral therapy rewires thought patterns
• Mindfulness meditation changes brain structure
• Exercise promotes neurogenesis
• Medication can facilitate plasticity

PTSD:
• Exposure therapy creates new associations
• EMDR may facilitate memory reconsolidation
• Mindfulness reduces amygdala reactivity

Addiction Recovery:
• Breaking old neural pathways
• Building new healthy habits
• Cognitive training
• Environmental changes

Skill Acquisition

Motor Skills:
• Deliberate practice
• Mental rehearsal
• Feedback and correction
• Progressive difficulty

Cognitive Skills:
• Working memory training
• Attention exercises
• Processing speed improvement
• Executive function development

Language Learning:
• Immersion experiences
• Regular practice
• Multiple modalities (reading, speaking, listening)
• Cultural engagement

Musical Training:
• Enhances auditory processing
• Improves motor coordination
• Strengthens memory
• Increases gray matter in multiple regions

Practical Strategies to Enhance Neuroplasticity

1. Challenge Your Brain:
• Learn new skills regularly
• Step outside comfort zone
• Vary activities and approaches
• Embrace difficulty as growth opportunity

2. Exercise Regularly:
• Aim for 150 minutes moderate aerobic activity weekly
• Include strength training
• Try coordination-demanding activities (dance, martial arts)
• Exercise outdoors when possible

3. Prioritize Sleep:
• 7-9 hours nightly for adults
• Consistent sleep schedule
• Good sleep hygiene
• Address sleep disorders

4. Manage Stress:
• Mindfulness meditation
• Deep breathing exercises
• Time in nature
• Social support
• Professional help when needed

5. Eat Brain-Healthy Foods:
• Fatty fish (omega-3s)
• Berries (antioxidants)
• Leafy greens
• Nuts and seeds
• Whole grains
• Limit processed foods and sugar

6. Stay Socially Connected:
• Maintain meaningful relationships
• Engage in group activities
• Volunteer
• Join clubs or classes

7. Practice Mindfulness:
• Meditation
• Yoga
• Tai chi
• Mindful walking
• Body scan exercises

8. Engage in Creative Activities:
• Art and crafts
• Music
• Writing
• Dance
• Creative problem-solving

9. Learn Continuously:
• Take courses
• Read diverse materials
• Explore new subjects
• Travel and experience new cultures

10. Limit Screen Time:
• Especially passive consumption
• Take regular breaks
• Engage in active rather than passive activities
• Protect sleep from blue light

Research Frontiers

Brain-Computer Interfaces:
Direct communication between brain and external devices.

Neurofeedback:
Training brain activity patterns through real-time feedback.

Transcranial Stimulation:
Non-invasive brain stimulation to enhance plasticity.

Pharmacological Enhancement:
Drugs that promote neuroplasticity (still experimental).

Virtual Reality:
Immersive environments for rehabilitation and training.

Limitations and Misconceptions

Misconceptions:

"You only use 10% of your brain":
False - we use all brain regions, though not all simultaneously.

"Brain training games make you smarter":
Limited evidence - improvements often don't transfer to real-world tasks.

"Left brain vs. right brain personality":
Oversimplified - both hemispheres work together for most tasks.

Limitations:

• Plasticity decreases with age
• Some changes are difficult to reverse
• Critical periods exist for certain abilities
• Individual variation in plasticity capacity
• Not all brain damage can be compensated

Conclusion

Neuroplasticity reveals the brain's remarkable capacity for change and adaptation. This understanding empowers us to actively shape our brains through lifestyle choices, learning experiences, and therapeutic interventions.

The key message is hopeful: our brains are not fixed. Through consistent effort, healthy habits, and appropriate challenges, we can enhance cognitive abilities, recover from injury, break harmful patterns, and continue growing throughout life.

However, neuroplasticity is not magic. It requires time, effort, and appropriate strategies. The brain changes in response to what we do repeatedly, so our daily habits and choices matter profoundly.

By understanding and leveraging neuroplasticity, we can take greater control of our cognitive health, learning capacity, and overall brain function. The brain you have tomorrow depends on what you do with it today.
''';
}

String _getRenewableEnergyContent() {
  return '''
Renewable Energy: Powering a Sustainable Future

Introduction

Renewable energy comes from natural sources that are constantly replenished. Unlike fossil fuels, these energy sources don't deplete and produce minimal environmental impact. As climate change accelerates, transitioning to renewable energy has become critical for our planet's future.

Types of Renewable Energy

1. Solar Energy:
• Photovoltaic cells convert sunlight to electricity
• Solar thermal systems heat water or air
• Advantages: Abundant, clean, decreasing costs
• Challenges: Intermittent, requires storage

2. Wind Energy:
• Wind turbines convert kinetic energy to electricity
• Onshore and offshore installations
• Advantages: Cost-effective, scalable
• Challenges: Location-dependent, visual impact

3. Hydroelectric Power:
• Water flow drives turbines
• Largest renewable energy source globally
• Advantages: Reliable, energy storage capability
• Challenges: Environmental impact, location-limited

4. Geothermal Energy:
• Heat from Earth's core generates power
• Direct heating and electricity generation
• Advantages: Constant availability, small footprint
• Challenges: Location-specific, high initial costs

5. Biomass Energy:
• Organic materials produce heat and electricity
• Includes wood, crops, waste
• Advantages: Carbon-neutral potential, waste reduction
• Challenges: Land use, emissions concerns

The transition to renewable energy is essential for combating climate change and ensuring energy security for future generations.
''';
}

String _getComputerVisionContent() {
  return '''
Computer Vision: Teaching Machines to See

Introduction

Computer vision enables machines to interpret and understand visual information from the world. This field combines artificial intelligence, machine learning, and image processing to give computers the ability to "see" and make decisions based on visual data.

Core Concepts

1. Image Processing:
• Filtering and enhancement
• Edge detection
• Color space transformations
• Noise reduction

2. Feature Detection:
• Corner detection
• Blob detection
• Scale-invariant features
• Texture analysis

3. Object Recognition:
• Classification algorithms
• Deep learning models
• Convolutional Neural Networks (CNNs)
• Transfer learning

4. Image Segmentation:
• Semantic segmentation
• Instance segmentation
• Panoptic segmentation
• Medical image analysis

Applications

Healthcare:
• Medical image diagnosis
• Tumor detection
• Surgical assistance
• Patient monitoring

Autonomous Vehicles:
• Lane detection
• Object recognition
• Pedestrian detection
• Traffic sign recognition

Security:
• Facial recognition
• Surveillance systems
• Anomaly detection
• Access control

Retail:
• Product recognition
• Inventory management
• Customer analytics
• Automated checkout

Computer vision is revolutionizing how machines interact with the visual world, enabling countless applications that improve our daily lives.
''';
}

String _getSocialPsychologyContent() {
  return '''
Social Psychology: Understanding Human Interaction

Introduction

Social psychology examines how people's thoughts, feelings, and behaviors are influenced by others. This field explores the powerful impact of social situations on individual behavior and helps us understand group dynamics, prejudice, conformity, and interpersonal relationships.

Key Concepts

1. Social Influence:
• Conformity: Adjusting behavior to match group norms
• Obedience: Following authority figures
• Compliance: Agreeing to requests
• Peer pressure effects

2. Attribution Theory:
• Internal vs. external attributions
• Fundamental attribution error
• Self-serving bias
• Actor-observer bias

3. Attitudes and Persuasion:
• Attitude formation
• Cognitive dissonance
• Persuasion techniques
• Attitude change

4. Group Dynamics:
• Group polarization
• Groupthink
• Social facilitation
• Social loafing
• Deindividuation

5. Prejudice and Discrimination:
• Stereotypes formation
• In-group vs. out-group bias
• Implicit bias
• Reducing prejudice

6. Prosocial Behavior:
• Altruism
• Bystander effect
• Helping behavior
• Empathy and compassion

Classic Experiments

Milgram's Obedience Study:
Demonstrated how ordinary people follow authority even when causing harm.

Stanford Prison Experiment:
Showed how situational factors influence behavior and identity.

Asch Conformity Experiments:
Revealed the power of group pressure on individual judgment.

Applications

Understanding social psychology helps us:
• Improve interpersonal relationships
• Recognize bias and prejudice
• Make better group decisions
• Understand marketing and persuasion
• Enhance workplace dynamics
• Promote social change

Social psychology reveals that we are profoundly influenced by our social environment, often in ways we don't consciously recognize.
''';
}

String _getQuantumAlgorithmsContent() {
  return '''
Quantum Algorithms: Computing Beyond Classical Limits

Introduction

Quantum algorithms leverage quantum mechanical phenomena like superposition and entanglement to solve certain problems exponentially faster than classical computers. These algorithms represent a paradigm shift in computation, promising breakthroughs in cryptography, optimization, and simulation.

Fundamental Quantum Algorithms

1. Shor's Algorithm:
• Factors large numbers efficiently
• Threatens current encryption methods
• Exponential speedup over classical algorithms
• Requires fault-tolerant quantum computers

2. Grover's Algorithm:
• Searches unsorted databases
• Quadratic speedup (√N vs N)
• Applications in optimization
• More practical than Shor's algorithm

3. Quantum Fourier Transform:
• Foundation for many quantum algorithms
• Exponentially faster than classical FFT
• Used in period finding
• Key component of Shor's algorithm

4. Variational Quantum Eigensolver (VQE):
• Finds ground state energies
• Hybrid quantum-classical approach
• Near-term quantum applications
• Chemistry and materials science

5. Quantum Approximate Optimization Algorithm (QAOA):
• Solves combinatorial optimization
• Works on near-term devices
• Flexible framework
• Applications in logistics and finance

Key Concepts

Quantum Superposition:
Qubits exist in multiple states simultaneously, enabling parallel computation.

Quantum Entanglement:
Correlated qubits share information instantaneously, enabling complex operations.

Quantum Interference:
Amplifies correct answers while canceling wrong ones.

Quantum Gates:
Operations that manipulate qubit states (Hadamard, CNOT, Toffoli).

Applications

Cryptography:
• Breaking RSA encryption
• Quantum key distribution
• Post-quantum cryptography

Drug Discovery:
• Molecular simulation
• Protein folding
• Drug interaction modeling

Optimization:
• Supply chain optimization
• Portfolio optimization
• Traffic flow optimization

Machine Learning:
• Quantum neural networks
• Quantum support vector machines
• Quantum sampling

Challenges

• Quantum decoherence
• Error correction requirements
• Limited qubit counts
• High error rates
• Scalability issues

Future Outlook

Quantum algorithms promise to revolutionize computing, but practical implementation faces significant challenges. As quantum hardware improves, these algorithms will unlock solutions to problems currently beyond our reach.

The quantum advantage is not universal—quantum computers excel at specific problems while classical computers remain superior for most everyday tasks. The future likely involves hybrid systems leveraging both quantum and classical computing strengths.
''';
}
