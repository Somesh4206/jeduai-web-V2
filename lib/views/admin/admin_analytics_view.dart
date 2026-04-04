import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_controller.dart';

class AdminAnalyticsView extends StatelessWidget {
  const AdminAnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminController controller = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        backgroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overview Cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Students',
                    '1,234',
                    Icons.people,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Total Staff',
                    '87',
                    Icons.school,
                    Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Active Courses',
                    '45',
                    Icons.book,
                    Colors.teal,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Avg Attendance',
                    '92%',
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // AI Tool Engagement
            const Text(
              'AI Tool Engagement',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildEngagementBar('AI Tutor', 0.85, Colors.blue),
                    const SizedBox(height: 12),
                    _buildEngagementBar('Translation', 0.72, Colors.green),
                    const SizedBox(height: 12),
                    _buildEngagementBar('Assessment', 0.68, Colors.orange),
                    const SizedBox(height: 12),
                    _buildEngagementBar('Learning Hub', 0.91, Colors.purple),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Class-wise Performance
            const Text(
              'Class-wise Performance',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Obx(() {
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.classPerformance.length,
                itemBuilder: (context, index) {
                  final classData = controller.classPerformance[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.indigo,
                        child: Text(
                          classData['class'].toString(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text('Class ${classData['class']}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Students: ${classData['students']}'),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: classData['avgScore'] / 100,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getScoreColor(classData['avgScore']),
                            ),
                          ),
                        ],
                      ),
                      trailing: Text(
                        '${classData['avgScore']}%',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _getScoreColor(classData['avgScore']),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
            const SizedBox(height: 24),

            // Recent Activities
            const Text(
              'Recent Activities',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildActivityTile(
                    'New student enrolled',
                    'John Doe joined Class 10A',
                    Icons.person_add,
                    Colors.green,
                  ),
                  const Divider(),
                  _buildActivityTile(
                    'Assessment completed',
                    'Math Quiz - Class 9B',
                    Icons.assignment_turned_in,
                    Colors.blue,
                  ),
                  const Divider(),
                  _buildActivityTile(
                    'Staff added',
                    'New Physics teacher assigned',
                    Icons.school,
                    Colors.purple,
                  ),
                  const Divider(),
                  _buildActivityTile(
                    'Course updated',
                    'Chemistry syllabus revised',
                    Icons.book,
                    Colors.orange,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEngagementBar(String tool, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(tool, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text('${(value * 100).toInt()}%'),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: value,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
        ),
      ],
    );
  }

  Widget _buildActivityTile(
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.1),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle),
      trailing: Text(
        'Just now',
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }
}
