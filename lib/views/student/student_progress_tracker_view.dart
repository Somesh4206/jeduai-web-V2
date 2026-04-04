import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/student_controller.dart';

class StudentProgressTrackerView extends StatefulWidget {
  const StudentProgressTrackerView({super.key});

  @override
  State<StudentProgressTrackerView> createState() =>
      _StudentProgressTrackerViewState();
}

class _StudentProgressTrackerViewState extends State<StudentProgressTrackerView>
    with SingleTickerProviderStateMixin {
  final StudentController studentController = Get.find();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Tracker'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.trending_up), text: 'Overview'),
            Tab(icon: Icon(Icons.subject), text: 'Subjects'),
            Tab(icon: Icon(Icons.emoji_events), text: 'Achievements'),
            Tab(icon: Icon(Icons.calendar_today), text: 'Timeline'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildSubjectsTab(),
          _buildAchievementsTab(),
          _buildTimelineTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overall Progress Card
          Card(
            elevation: 4,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    'Overall Progress',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 150,
                    height: 150,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 150,
                          height: 150,
                          child: CircularProgressIndicator(
                            value: 0.78,
                            strokeWidth: 12,
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.3,
                            ),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                        const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '78%',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Complete',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatBadge('Rank', '#12', Icons.emoji_events),
                      _buildStatBadge(
                        'Streak',
                        '15 days',
                        Icons.local_fire_department,
                      ),
                      _buildStatBadge('Points', '2,450', Icons.stars),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Performance Metrics
          const Text(
            'Performance Metrics',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Avg Score',
                  '85.5%',
                  Icons.grade,
                  Colors.green,
                  '+5.2%',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Completed',
                  '42/54',
                  Icons.check_circle,
                  Colors.blue,
                  '78%',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Study Time',
                  '24.5 hrs',
                  Icons.access_time,
                  Colors.orange,
                  'This week',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Attendance',
                  '95%',
                  Icons.calendar_today,
                  Colors.purple,
                  '38/40 days',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Weekly Activity
          const Text(
            'Weekly Activity',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildDayActivity('Mon', 0.8, Colors.blue),
                      _buildDayActivity('Tue', 0.6, Colors.blue),
                      _buildDayActivity('Wed', 0.9, Colors.blue),
                      _buildDayActivity('Thu', 0.7, Colors.blue),
                      _buildDayActivity('Fri', 0.85, Colors.blue),
                      _buildDayActivity('Sat', 0.5, Colors.grey),
                      _buildDayActivity('Sun', 0.3, Colors.grey),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Hours studied per day',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Strengths & Weaknesses
          const Text(
            'Strengths & Areas to Improve',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.trending_up, color: Colors.green),
                      SizedBox(width: 8),
                      Text(
                        'Strengths',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildSkillChip('Problem Solving', 92, Colors.green),
                  _buildSkillChip('Critical Thinking', 88, Colors.green),
                  _buildSkillChip('Time Management', 85, Colors.green),
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      Icon(Icons.trending_down, color: Colors.orange),
                      SizedBox(width: 8),
                      Text(
                        'Areas to Improve',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildSkillChip('Speed & Accuracy', 68, Colors.orange),
                  _buildSkillChip(
                    'Conceptual Understanding',
                    72,
                    Colors.orange,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectsTab() {
    final subjects = [
      {
        'name': 'Mathematics',
        'progress': 0.85,
        'score': 88,
        'topics': 24,
        'completed': 20,
        'color': Colors.blue,
      },
      {
        'name': 'Physics',
        'progress': 0.72,
        'score': 82,
        'topics': 18,
        'completed': 13,
        'color': Colors.purple,
      },
      {
        'name': 'Chemistry',
        'progress': 0.68,
        'score': 79,
        'topics': 22,
        'completed': 15,
        'color': Colors.green,
      },
      {
        'name': 'English',
        'progress': 0.90,
        'score': 92,
        'topics': 16,
        'completed': 14,
        'color': Colors.orange,
      },
      {
        'name': 'Computer Science',
        'progress': 0.78,
        'score': 86,
        'topics': 20,
        'completed': 16,
        'color': Colors.teal,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: subjects.length,
      itemBuilder: (context, index) {
        final subject = subjects[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
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
                        color: (subject['color'] as Color).withValues(
                          alpha: 0.1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.book, color: subject['color'] as Color),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subject['name'] as String,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${subject['completed']}/${subject['topics']} topics completed',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${subject['score']}%',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: subject['progress'] as double,
                    minHeight: 8,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      subject['color'] as Color,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${((subject['progress'] as double) * 100).toInt()}% Complete',
                  style: TextStyle(
                    fontSize: 12,
                    color: subject['color'] as Color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAchievementsTab() {
    final achievements = [
      {
        'title': 'Perfect Score',
        'description': 'Scored 100% in Mathematics Quiz',
        'date': '2 days ago',
        'icon': Icons.emoji_events,
        'color': Colors.amber,
        'unlocked': true,
      },
      {
        'title': '15 Day Streak',
        'description': 'Studied for 15 consecutive days',
        'date': 'Today',
        'icon': Icons.local_fire_department,
        'color': Colors.orange,
        'unlocked': true,
      },
      {
        'title': 'Fast Learner',
        'description': 'Completed 5 courses in a month',
        'date': '1 week ago',
        'icon': Icons.speed,
        'color': Colors.blue,
        'unlocked': true,
      },
      {
        'title': 'Top 10',
        'description': 'Ranked in top 10 of your class',
        'date': '3 days ago',
        'icon': Icons.star,
        'color': Colors.purple,
        'unlocked': true,
      },
      {
        'title': 'AI Master',
        'description': 'Complete 50 AI Tutor sessions',
        'date': 'Locked',
        'icon': Icons.psychology,
        'color': Colors.grey,
        'unlocked': false,
      },
      {
        'title': 'Assessment Pro',
        'description': 'Complete 100 assessments',
        'date': 'Locked',
        'icon': Icons.assignment_turned_in,
        'color': Colors.grey,
        'unlocked': false,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        final unlocked = achievement['unlocked'] as bool;
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: unlocked ? null : Colors.grey[100],
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (achievement['color'] as Color).withValues(
                  alpha: unlocked ? 0.2 : 0.1,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                achievement['icon'] as IconData,
                color: achievement['color'] as Color,
                size: 28,
              ),
            ),
            title: Text(
              achievement['title'] as String,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: unlocked ? Colors.black : Colors.grey,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement['description'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: unlocked ? Colors.grey[600] : Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  achievement['date'] as String,
                  style: TextStyle(
                    fontSize: 11,
                    color: unlocked ? Colors.blue : Colors.grey,
                  ),
                ),
              ],
            ),
            trailing: unlocked
                ? const Icon(Icons.check_circle, color: Colors.green)
                : const Icon(Icons.lock, color: Colors.grey),
          ),
        );
      },
    );
  }

  Widget _buildTimelineTab() {
    final timeline = [
      {
        'date': 'Today',
        'events': [
          {
            'time': '09:00 AM',
            'title': 'Completed Physics Quiz',
            'score': '92%',
          },
          {
            'time': '11:30 AM',
            'title': 'AI Tutor Session - Mathematics',
            'score': null,
          },
          {
            'time': '02:00 PM',
            'title': 'Submitted Chemistry Assignment',
            'score': 'Pending',
          },
        ],
      },
      {
        'date': 'Yesterday',
        'events': [
          {
            'time': '10:00 AM',
            'title': 'Attended Online Class - English',
            'score': null,
          },
          {
            'time': '03:00 PM',
            'title': 'Completed Math Assessment',
            'score': '88%',
          },
        ],
      },
      {
        'date': '2 days ago',
        'events': [
          {
            'time': '09:30 AM',
            'title': 'Perfect Score in Quiz',
            'score': '100%',
          },
          {
            'time': '01:00 PM',
            'title': 'Started New Course - Physics',
            'score': null,
          },
        ],
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: timeline.length,
      itemBuilder: (context, index) {
        final day = timeline[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                day['date'] as String,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2196F3),
                ),
              ),
            ),
            ...(day['events'] as List).map((event) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.access_time,
                      color: Color(0xFF2196F3),
                    ),
                  ),
                  title: Text(
                    event['title'] as String,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    event['time'] as String,
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: event['score'] != null
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: event['score'] == 'Pending'
                                ? Colors.orange.withValues(alpha: 0.1)
                                : Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            event['score'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: event['score'] == 'Pending'
                                  ? Colors.orange
                                  : Colors.green,
                            ),
                          ),
                        )
                      : null,
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildStatBadge(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String label,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayActivity(String day, double value, Color color) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: 32,
              height: 80 * value,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(day, style: const TextStyle(fontSize: 11)),
      ],
    );
  }

  Widget _buildSkillChip(String skill, int score, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(skill)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$score%',
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
          ),
        ],
      ),
    );
  }
}
