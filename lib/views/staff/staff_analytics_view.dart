import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/staff_controller.dart';

class StaffAnalyticsView extends StatefulWidget {
  const StaffAnalyticsView({super.key});

  @override
  State<StaffAnalyticsView> createState() => _StaffAnalyticsViewState();
}

class _StaffAnalyticsViewState extends State<StaffAnalyticsView>
    with SingleTickerProviderStateMixin {
  final StaffController staffController = Get.find();
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
        title: const Text('Analytics & Insights'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF9C27B0), Color(0xFFBA68C8)],
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.people), text: 'Students'),
            Tab(icon: Icon(Icons.assessment), text: 'Assessments'),
            Tab(icon: Icon(Icons.trending_up), text: 'Performance'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildStudentsTab(),
          _buildAssessmentsTab(),
          _buildPerformanceTab(),
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
          // Key Metrics
          const Text(
            'Key Metrics',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Total Students',
                  '156',
                  Icons.people,
                  Colors.blue,
                  '+12 this month',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Avg Score',
                  '82.5%',
                  Icons.grade,
                  Colors.green,
                  '+3.2% from last',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Assessments',
                  '24',
                  Icons.assignment,
                  Colors.orange,
                  '8 pending review',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Attendance',
                  '91%',
                  Icons.calendar_today,
                  Colors.purple,
                  'Last 30 days',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Class Performance
          const Text(
            'Class Performance Trend',
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
                      _buildPerformanceBar('Week 1', 0.75, Colors.blue),
                      _buildPerformanceBar('Week 2', 0.82, Colors.blue),
                      _buildPerformanceBar('Week 3', 0.78, Colors.blue),
                      _buildPerformanceBar('Week 4', 0.85, Colors.blue),
                      _buildPerformanceBar('Week 5', 0.88, Colors.green),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Average class score by week',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Top Performers
          const Text(
            'Top Performers',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                _buildStudentRankItem(1, 'Rahul Kumar', 95.5, Colors.amber),
                const Divider(height: 1),
                _buildStudentRankItem(2, 'Priya Sharma', 93.2, Colors.grey),
                const Divider(height: 1),
                _buildStudentRankItem(3, 'Amit Patel', 91.8, Colors.brown),
                const Divider(height: 1),
                _buildStudentRankItem(4, 'Sneha Reddy', 90.5, Colors.blue),
                const Divider(height: 1),
                _buildStudentRankItem(5, 'Vikram Singh', 89.7, Colors.purple),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Recent Activity
          const Text(
            'Recent Activity',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                _buildActivityItem(
                  'Assessment Submitted',
                  '15 students completed Physics Quiz',
                  '2 hours ago',
                  Icons.assignment_turned_in,
                  Colors.green,
                ),
                const Divider(height: 1),
                _buildActivityItem(
                  'New Question',
                  'Rahul Kumar asked about Thermodynamics',
                  '5 hours ago',
                  Icons.help_outline,
                  Colors.orange,
                ),
                const Divider(height: 1),
                _buildActivityItem(
                  'Class Completed',
                  'Online class on Mechanics finished',
                  '1 day ago',
                  Icons.video_library,
                  Colors.blue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsTab() {
    return Obx(() {
      if (staffController.students.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_outline, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No student data available',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: staffController.students.length,
        itemBuilder: (context, index) {
          final student = staffController.students[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ExpansionTile(
              leading: CircleAvatar(
                backgroundColor: Colors.purple.withValues(alpha: 0.2),
                child: Text(
                  student.name.substring(0, 1),
                  style: const TextStyle(
                    color: Color(0xFF9C27B0),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                student.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('ID: ${student.id}'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getScoreColor(
                    student.averageScore,
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${student.averageScore.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getScoreColor(student.averageScore),
                  ),
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildStudentStat(
                              'Attendance',
                              '${student.attendance}%',
                              Icons.calendar_today,
                            ),
                          ),
                          Expanded(
                            child: _buildStudentStat(
                              'Completed',
                              '${12 + index}',
                              Icons.check_circle,
                            ),
                          ),
                          Expanded(
                            child: _buildStudentStat(
                              'Pending',
                              '${3 - (index % 3)}',
                              Icons.pending,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Performance Trend',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildMiniBar('W1', 0.7),
                          _buildMiniBar('W2', 0.75),
                          _buildMiniBar('W3', 0.8),
                          _buildMiniBar('W4', 0.85),
                        ],
                      ),
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

  Widget _buildAssessmentsTab() {
    return Obx(() {
      if (staffController.assessments.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.assignment_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No assessments created yet',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: staffController.assessments.length,
        itemBuilder: (context, index) {
          final assessment = staffController.assessments[index];
          final completionRate =
              (assessment.studentsCompleted / assessment.studentsAssigned * 100)
                  .toInt();
          final avgScore = 75 + (index * 3); // Mock data

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
                          color: const Color(0xFF9C27B0).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          assessment.type,
                          style: const TextStyle(
                            color: Color(0xFF9C27B0),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${assessment.totalQuestions} questions',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
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
                    assessment.subject,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Completion',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$completionRate%',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF9C27B0),
                              ),
                            ),
                            Text(
                              '${assessment.studentsCompleted}/${assessment.studentsAssigned}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
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
                              'Avg Score',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$avgScore%',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: _getScoreColor(avgScore.toDouble()),
                              ),
                            ),
                            Text(
                              _getScoreLabel(avgScore.toDouble()),
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Get.snackbar(
                            'Details',
                            'Viewing detailed analytics for ${assessment.title}',
                          );
                        },
                        icon: const Icon(Icons.analytics, size: 18),
                        label: const Text('Details'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9C27B0),
                          foregroundColor: Colors.white,
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

  Widget _buildPerformanceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subject-wise Performance
          const Text(
            'Subject-wise Performance',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildSubjectPerformanceCard('Mathematics', 85, 0.85, Colors.blue),
          const SizedBox(height: 12),
          _buildSubjectPerformanceCard('Physics', 78, 0.78, Colors.purple),
          const SizedBox(height: 12),
          _buildSubjectPerformanceCard('Chemistry', 82, 0.82, Colors.green),
          const SizedBox(height: 24),

          // Difficulty Analysis
          const Text(
            'Question Difficulty Analysis',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildDifficultyRow('Easy', 45, Colors.green),
                  const SizedBox(height: 12),
                  _buildDifficultyRow('Medium', 35, Colors.orange),
                  const SizedBox(height: 12),
                  _buildDifficultyRow('Hard', 20, Colors.red),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Improvement Suggestions
          const Text(
            'AI-Powered Insights',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildInsightCard(
            'Focus Area',
            'Students are struggling with Thermodynamics. Consider additional practice sessions.',
            Icons.lightbulb,
            Colors.orange,
          ),
          const SizedBox(height: 12),
          _buildInsightCard(
            'Positive Trend',
            'Overall class performance improved by 8% this month. Great work!',
            Icons.trending_up,
            Colors.green,
          ),
          const SizedBox(height: 12),
          _buildInsightCard(
            'Engagement',
            '12 students have not submitted recent assignments. Follow up recommended.',
            Icons.warning,
            Colors.red,
          ),
        ],
      ),
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

  Widget _buildPerformanceBar(String label, double value, Color color) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: 40,
              height: 100 * value,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
        Text(
          '${(value * 100).toInt()}%',
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildStudentRankItem(
    int rank,
    String name,
    double score,
    Color color,
  ) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '#$rank',
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: Text(
        '${score.toStringAsFixed(1)}%',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildActivityItem(
    String title,
    String description,
    String time,
    IconData icon,
    Color color,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(description),
      trailing: Text(
        time,
        style: const TextStyle(fontSize: 11, color: Colors.grey),
      ),
    );
  }

  Widget _buildStudentStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Widget _buildMiniBar(String label, double value) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: 24,
              height: 40 * value,
              decoration: BoxDecoration(
                color: const Color(0xFF9C27B0),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 9)),
      ],
    );
  }

  Widget _buildSubjectPerformanceCard(
    String subject,
    int avgScore,
    double progress,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.book, color: color),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    subject,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '$avgScore%',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyRow(String level, int percentage, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            level,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 20,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '$percentage%',
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _buildInsightCard(
    String title,
    String message,
    IconData icon,
    Color color,
  ) {
    return Card(
      color: color.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.bold, color: color),
                  ),
                  const SizedBox(height: 4),
                  Text(message, style: const TextStyle(fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 85) return Colors.green;
    if (score >= 70) return Colors.orange;
    return Colors.red;
  }

  String _getScoreLabel(double score) {
    if (score >= 85) return 'Excellent';
    if (score >= 70) return 'Good';
    return 'Needs Improvement';
  }
}
