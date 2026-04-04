import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StudentStudyPlannerView extends StatefulWidget {
  const StudentStudyPlannerView({super.key});

  @override
  State<StudentStudyPlannerView> createState() =>
      _StudentStudyPlannerViewState();
}

class _StudentStudyPlannerViewState extends State<StudentStudyPlannerView> {
  DateTime selectedDate = DateTime.now();
  String selectedView = 'Day';

  final Map<String, List<Map<String, dynamic>>> schedule = {
    'Monday': [
      {
        'time': '09:00 AM',
        'subject': 'Mathematics',
        'topic': 'Calculus',
        'duration': '1 hr',
        'color': Colors.blue,
      },
      {
        'time': '11:00 AM',
        'subject': 'Physics',
        'topic': 'Mechanics',
        'duration': '1.5 hrs',
        'color': Colors.purple,
      },
      {
        'time': '02:00 PM',
        'subject': 'Chemistry',
        'topic': 'Organic Chemistry',
        'duration': '1 hr',
        'color': Colors.green,
      },
    ],
    'Tuesday': [
      {
        'time': '10:00 AM',
        'subject': 'English',
        'topic': 'Literature',
        'duration': '1 hr',
        'color': Colors.orange,
      },
      {
        'time': '01:00 PM',
        'subject': 'Computer Science',
        'topic': 'Data Structures',
        'duration': '2 hrs',
        'color': Colors.teal,
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Planner'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddTaskDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // View Selector
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Row(
              children: [
                Expanded(
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'Day',
                        label: Text('Day'),
                        icon: Icon(Icons.today),
                      ),
                      ButtonSegment(
                        value: 'Week',
                        label: Text('Week'),
                        icon: Icon(Icons.view_week),
                      ),
                      ButtonSegment(
                        value: 'Month',
                        label: Text('Month'),
                        icon: Icon(Icons.calendar_month),
                      ),
                    ],
                    selected: {selectedView},
                    onSelectionChanged: (Set<String> newSelection) {
                      setState(() {
                        selectedView = newSelection.first;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // Calendar Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    setState(() {
                      selectedDate = selectedDate.subtract(
                        const Duration(days: 1),
                      );
                    });
                  },
                ),
                Column(
                  children: [
                    Text(
                      _getFormattedDate(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _getWeekday(),
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    setState(() {
                      selectedDate = selectedDate.add(const Duration(days: 1));
                    });
                  },
                ),
              ],
            ),
          ),

          // Study Stats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Hours',
                    '5.5',
                    Icons.access_time,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Tasks',
                    '8',
                    Icons.task_alt,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Completed',
                    '5',
                    Icons.check_circle,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Schedule List
          Expanded(child: _buildScheduleView()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTaskDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
        backgroundColor: const Color(0xFF2196F3),
      ),
    );
  }

  Widget _buildScheduleView() {
    final daySchedule = schedule[_getWeekday()] ?? [];

    if (daySchedule.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No tasks scheduled for ${_getWeekday()}',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => _showAddTaskDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Add Task'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: daySchedule.length,
      itemBuilder: (context, index) {
        final task = daySchedule[index];
        return _buildTaskCard(task);
      },
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showTaskDetails(task),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 60,
                decoration: BoxDecoration(
                  color: task['color'] as Color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task['subject'] as String,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      task['topic'] as String,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${task['time']} • ${task['duration']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Checkbox(
                value: false,
                onChanged: (value) {
                  Get.snackbar(
                    'Task Completed',
                    '${task['subject']} marked as complete',
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                  );
                },
              ),
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
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
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
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  String _getFormattedDate() {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[selectedDate.month - 1]} ${selectedDate.day}, ${selectedDate.year}';
  }

  String _getWeekday() {
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[selectedDate.weekday - 1];
  }

  void _showAddTaskDialog() {
    final subjectController = TextEditingController();
    final topicController = TextEditingController();
    String selectedTime = '09:00 AM';
    String selectedDuration = '1 hr';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Study Task'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: subjectController,
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: topicController,
                decoration: const InputDecoration(
                  labelText: 'Topic',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedTime,
                decoration: const InputDecoration(
                  labelText: 'Time',
                  border: OutlineInputBorder(),
                ),
                items:
                    ['09:00 AM', '10:00 AM', '11:00 AM', '02:00 PM', '03:00 PM']
                        .map(
                          (time) =>
                              DropdownMenuItem(value: time, child: Text(time)),
                        )
                        .toList(),
                onChanged: (value) => selectedTime = value!,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedDuration,
                decoration: const InputDecoration(
                  labelText: 'Duration',
                  border: OutlineInputBorder(),
                ),
                items: ['30 min', '1 hr', '1.5 hrs', '2 hrs', '3 hrs']
                    .map(
                      (dur) => DropdownMenuItem(value: dur, child: Text(dur)),
                    )
                    .toList(),
                onChanged: (value) => selectedDuration = value!,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Get.snackbar(
                'Task Added',
                'Study task added successfully',
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showTaskDetails(Map<String, dynamic> task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(task['subject'] as String),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Topic', task['topic'] as String),
            _buildDetailRow('Time', task['time'] as String),
            _buildDetailRow('Duration', task['duration'] as String),
            const SizedBox(height: 16),
            const Text('Notes:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Focus on practice problems and review key concepts.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              Get.snackbar('Deleted', 'Task removed from schedule');
            },
            icon: const Icon(Icons.delete),
            label: const Text('Delete'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
