import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/staff_controller.dart';

class StaffStudentManagementView extends StatefulWidget {
  const StaffStudentManagementView({super.key});

  @override
  State<StaffStudentManagementView> createState() =>
      _StaffStudentManagementViewState();
}

class _StaffStudentManagementViewState extends State<StaffStudentManagementView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final StaffController staffController = Get.find<StaffController>();
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Management'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.people), text: 'Students'),
            Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
            Tab(icon: Icon(Icons.add), text: 'Add New'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStudentListTab(),
          _buildAnalyticsTab(),
          _buildAddStudentTab(),
        ],
      ),
    );
  }

  Widget _buildStudentListTab() {
    return Column(
      children: [
        // Search Bar
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF4CAF50).withOpacity(0.1),
                Color(0xFF81C784).withOpacity(0.1),
              ],
            ),
          ),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search students...',
              prefixIcon: Icon(Icons.search, color: Color(0xFF4CAF50)),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) => setState(() => searchQuery = value),
          ),
        ),
        // Student List
        Expanded(
          child: Obx(() {
            if (staffController.isLoadingStudents.value) {
              return Center(child: CircularProgressIndicator());
            }

            final filteredStudents = staffController.students
                .where(
                  (s) =>
                      s.name.toLowerCase().contains(
                        searchQuery.toLowerCase(),
                      ) ||
                      s.email.toLowerCase().contains(searchQuery.toLowerCase()),
                )
                .toList();

            if (filteredStudents.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people_outline, size: 80, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No students found',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: filteredStudents.length,
              itemBuilder: (context, index) {
                return _buildStudentCard(filteredStudents[index]);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildStudentCard(student) {
    Color statusColor = student.status == 'Active'
        ? Colors.green
        : student.status == 'At Risk'
        ? Colors.orange
        : Colors.grey;

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showStudentDetails(student),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 30,
                backgroundColor: Color(0xFF4CAF50).withOpacity(0.2),
                child: Text(
                  student.name[0].toUpperCase(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4CAF50),
                  ),
                ),
              ),
              SizedBox(width: 16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            student.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getGradeColor(student.grade),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            student.grade,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      student.email,
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        _buildStatChip(
                          Icons.check_circle,
                          '${student.attendance.toStringAsFixed(0)}%',
                          Colors.blue,
                        ),
                        SizedBox(width: 8),
                        _buildStatChip(
                          Icons.star,
                          '${student.averageScore.toStringAsFixed(0)}%',
                          Colors.orange,
                        ),
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 4),
                              Text(
                                student.status,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: statusColor,
                                  fontWeight: FontWeight.w500,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overview Cards
          Text(
            'Class Overview',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildAnalyticsCard(
                  'Average Score',
                  '78.3%',
                  Icons.trending_up,
                  Color(0xFF4CAF50),
                  '+5.2%',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildAnalyticsCard(
                  'Attendance',
                  '87.5%',
                  Icons.people,
                  Color(0xFF2196F3),
                  '+2.1%',
                ),
              ),
            ],
          ),
          SizedBox(height: 24),

          // Performance Distribution
          Text(
            'Performance Distribution',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          _buildPerformanceChart(),

          SizedBox(height: 24),

          // Top Performers
          Text(
            'Top Performers',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Obx(
            () => Column(
              children: staffController.students
                  .where((s) => s.averageScore >= 85)
                  .take(5)
                  .map((student) => _buildTopPerformerCard(student))
                  .toList(),
            ),
          ),

          SizedBox(height: 24),

          // At Risk Students
          Text(
            'Students At Risk ⚠️',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Obx(() {
            final atRiskStudents = staffController.students
                .where((s) => s.status == 'At Risk')
                .toList();
            if (atRiskStudents.isEmpty) {
              return Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'No students at risk! Great job! 🎉',
                        style: TextStyle(color: Colors.green.shade900),
                      ),
                    ),
                  ],
                ),
              );
            }
            return Column(
              children: atRiskStudents.map((s) => _buildAtRiskCard(s)).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String change,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              change,
              style: TextStyle(
                fontSize: 10,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceChart() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildChartBar('A+ (90-100)', 2, Color(0xFF4CAF50)),
          _buildChartBar('A (80-89)', 2, Color(0xFF8BC34A)),
          _buildChartBar('B (70-79)', 1, Color(0xFFFFEB3B)),
          _buildChartBar('C (60-69)', 0, Color(0xFFFF9800)),
          _buildChartBar('Below 60', 0, Color(0xFFF44336)),
        ],
      ),
    );
  }

  Widget _buildChartBar(String label, int count, Color color) {
    final maxCount = 5;
    final percentage = count / maxCount;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(fontSize: 13)),
              Text(
                '$count students',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
          SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopPerformerCard(student) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFD700).withOpacity(0.2), Colors.white],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFFFD700).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.emoji_events, color: Color(0xFFFFD700), size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${student.averageScore.toStringAsFixed(1)}% average',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Color(0xFF4CAF50),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              student.grade,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAtRiskCard(student) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.warning, color: Colors.orange, size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Attendance: ${student.attendance.toStringAsFixed(0)}% | Score: ${student.averageScore.toStringAsFixed(0)}%',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward, color: Colors.orange),
            onPressed: () => _showStudentDetails(student),
          ),
        ],
      ),
    );
  }

  Widget _buildAddStudentTab() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final gradeController = TextEditingController();

    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(Icons.person_add, size: 80, color: Color(0xFF4CAF50)),
          SizedBox(height: 16),
          Text(
            'Add New Student',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),

          _buildTextField('Full Name', nameController, Icons.person),
          SizedBox(height: 16),
          _buildTextField('Email', emailController, Icons.email),
          SizedBox(height: 16),
          _buildTextField('Grade/Class', gradeController, Icons.school),
          SizedBox(height: 24),

          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ElevatedButton.icon(
              onPressed: () {
                if (nameController.text.isEmpty ||
                    emailController.text.isEmpty) {
                  Get.snackbar('Error', 'Please fill all fields');
                  return;
                }
                Get.snackbar(
                  'Success',
                  'Student ${nameController.text} added successfully!',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
                nameController.clear();
                emailController.clear();
                gradeController.clear();
              },
              icon: Icon(Icons.add),
              label: Text('Add Student'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFF4CAF50).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Color(0xFF4CAF50), size: 20),
              SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4CAF50),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              border: InputBorder.none,
              isDense: true,
            ),
          ),
        ],
      ),
    );
  }

  void _showStudentDetails(student) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: EdgeInsets.all(20),
            child: ListView(
              controller: scrollController,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Color(0xFF4CAF50).withOpacity(0.2),
                      child: Text(
                        student.name[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student.name,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            student.email,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getGradeColor(student.grade),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        student.grade,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),

                _buildDetailRow(
                  'Attendance',
                  '${student.attendance.toStringAsFixed(1)}%',
                ),
                _buildDetailRow(
                  'Average Score',
                  '${student.averageScore.toStringAsFixed(1)}%',
                ),
                _buildDetailRow('Status', student.status),
                _buildDetailRow('Courses', student.courses.join(', ')),

                SizedBox(height: 24),
                Text(
                  'AI Predictions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                _buildPredictionCard(
                  'Strong Areas',
                  student.courses.take(2).join(', '),
                  Colors.green,
                  Icons.trending_up,
                ),
                SizedBox(height: 8),
                _buildPredictionCard(
                  'Needs Improvement',
                  student.attendance < 85 ? 'Attendance' : 'None',
                  Colors.orange,
                  Icons.warning,
                ),

                SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Get.back();
                          Get.snackbar('Edit', 'Edit student feature');
                        },
                        icon: Icon(Icons.edit),
                        label: Text('Edit'),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Get.back();
                          Get.snackbar('Message', 'Message sent to student');
                        },
                        icon: Icon(Icons.message),
                        label: Text('Message'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF4CAF50),
                        ),
                      ),
                    ),
                  ],
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
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          Text(value, style: TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildPredictionCard(
    String title,
    String content,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold, color: color),
                ),
                Text(content, style: TextStyle(fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getGradeColor(String grade) {
    if (grade.contains('A')) return Color(0xFF4CAF50);
    if (grade.contains('B')) return Color(0xFF2196F3);
    if (grade.contains('C')) return Color(0xFFFF9800);
    return Colors.grey;
  }
}
