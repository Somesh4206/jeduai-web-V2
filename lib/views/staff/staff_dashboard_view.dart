import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/staff_controller.dart';
import './staff_assessment_creation_view.dart';
import './staff_student_management_view.dart';
import './staff_online_class_creation_view.dart';
import './staff_profile_view.dart';

class StaffDashboardView extends StatefulWidget {
  const StaffDashboardView({super.key});

  @override
  State<StaffDashboardView> createState() => _StaffDashboardViewState();
}

class _StaffDashboardViewState extends State<StaffDashboardView> {
  int _selectedIndex = 0;
  final StaffController staffController = Get.put(StaffController());

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildDashboardContent(),
      const StaffAssessmentCreationView(),
      const StaffStudentManagementView(),
      const StaffOnlineClassCreationView(),
      const StaffProfileView(),
    ];

    return Scaffold(
      appBar: _selectedIndex == 0
          ? AppBar(
              title: Row(
                children: [
                  Icon(Icons.school_rounded, size: 28),
                  SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'JeduAI',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        'Staff Portal',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6B4CE6), Color(0xFF9B59B6)],
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {
                    Get.snackbar('Notifications', 'No new notifications');
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    Get.find<AuthController>().logout();
                  },
                ),
              ],
            )
          : null,
      body: pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 10,
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_rounded),
              label: 'Assessments',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_rounded),
              label: 'Students',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.video_call_rounded),
              label: 'Classes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Color(0xFF6B4CE6),
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 12,
          unselectedFontSize: 10,
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Welcome Banner
          Container(
            margin: EdgeInsets.all(20),
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6B4CE6), Color(0xFF9B59B6)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF6B4CE6).withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome Back! 👋',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Manage your classes and students',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.school,
                  size: 60,
                  color: Colors.white.withOpacity(0.3),
                ),
              ],
            ),
          ),

          // Quick Stats
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Row(
                  children: [
                    Obx(
                      () => _buildStatCard(
                        'Total Students',
                        staffController.totalStudents.value.toString(),
                        Icons.people,
                        Color(0xFF4CAF50),
                        Color(0xFF81C784),
                      ),
                    ),
                    SizedBox(width: 12),
                    Obx(
                      () => _buildStatCard(
                        'Active',
                        staffController.activeStudents.value.toString(),
                        Icons.check_circle,
                        Color(0xFF2196F3),
                        Color(0xFF64B5F6),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Obx(
                      () => _buildStatCard(
                        'Assessments',
                        staffController.totalAssessments.value.toString(),
                        Icons.assignment,
                        Color(0xFFFF9800),
                        Color(0xFFFFB74D),
                      ),
                    ),
                    SizedBox(width: 12),
                    Obx(
                      () => _buildStatCard(
                        'Classes',
                        staffController.upcomingClasses.value.toString(),
                        Icons.video_call,
                        Color(0xFFE91E63),
                        Color(0xFFF48FB1),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 24),

          // Performance Overview
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.analytics, color: Color(0xFF6B4CE6)),
                      SizedBox(width: 8),
                      Text(
                        'Performance Overview',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Obx(
                    () => _buildPerformanceBar(
                      'Average Attendance',
                      staffController.averageAttendance.value,
                      Color(0xFF4CAF50),
                    ),
                  ),
                  SizedBox(height: 16),
                  Obx(
                    () => _buildPerformanceBar(
                      'Average Performance',
                      staffController.averagePerformance.value,
                      Color(0xFF2196F3),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 24),

          // Quick Actions
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.flash_on, color: Colors.orange),
                    SizedBox(width: 8),
                    Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                GridView.count(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 1.3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    _buildQuickAction(
                      'Create Assessment',
                      Icons.add_circle,
                      Color(0xFFE91E63),
                      Color(0xFFF48FB1),
                      () => _onItemTapped(1),
                    ),
                    _buildQuickAction(
                      'View Students',
                      Icons.people,
                      Color(0xFF4CAF50),
                      Color(0xFF81C784),
                      () => _onItemTapped(2),
                    ),
                    _buildQuickAction(
                      'Schedule Class',
                      Icons.event,
                      Color(0xFF2196F3),
                      Color(0xFF64B5F6),
                      () => _onItemTapped(3),
                    ),
                    _buildQuickAction(
                      'Analytics',
                      Icons.bar_chart,
                      Color(0xFFFF9800),
                      Color(0xFFFFB74D),
                      () {
                        Get.snackbar('Analytics', 'Coming soon!');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 24),

          // Recent Activities
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.history, color: Color(0xFF6B4CE6)),
                      SizedBox(width: 8),
                      Text(
                        'Recent Activities',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Obx(
                    () => Column(
                      children: staffController.recentActivities
                          .take(5)
                          .map(
                            (activity) => Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Color(0xFF6B4CE6),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      activity,
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color1,
    Color color2,
  ) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color1, color2]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color1.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32, color: Colors.white),
            SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
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
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceBar(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
            Text(
              '${value.toStringAsFixed(1)}%',
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
        SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: value / 100,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAction(
    String title,
    IconData icon,
    Color color1,
    Color color2,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color1, color2]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color1.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: Colors.white),
            ),
            SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
