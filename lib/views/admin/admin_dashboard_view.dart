import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/admin_controller.dart';
import 'admin_manage_students_view.dart';
import 'admin_manage_staff_view.dart';
import 'admin_manage_courses_view.dart';
import 'admin_analytics_view.dart';
import 'admin_profile_view.dart';
import 'admin_online_class_monitoring_view.dart';
import 'all_users_view.dart';

class AdminDashboardView extends StatefulWidget {
  const AdminDashboardView({super.key});

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> {
  int _selectedIndex = 0;
  final AdminController adminController = Get.put(AdminController());

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildDashboardContent(),
      AdminManageStudentsView(),
      AdminManageStaffView(),
      AdminManageCoursesView(),
      const AdminOnlineClassMonitoringView(),
      AdminAnalyticsView(),
      AdminProfileView(),
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
                        'Admin Portal',
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
                    colors: [Color(0xFFFF6B6B), Color(0xFFFFE66D)],
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () =>
                      Get.snackbar('Notifications', 'No new notifications'),
                ),
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () => Get.find<AuthController>().logout(),
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
              icon: Icon(Icons.people_rounded),
              label: 'Students',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Staff',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book_rounded),
              label: 'Courses',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.video_library_rounded),
              label: 'Classes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics_rounded),
              label: 'Analytics',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.admin_panel_settings_rounded),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Color(0xFFFF6B6B),
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 11,
          unselectedFontSize: 10,
        ),
      ),
    );
  }

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.all(20),
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFFF6B6B),
                  Color(0xFFFFE66D),
                  Color(0xFF4ECDC4),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFFFF6B6B).withOpacity(0.3),
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
                        'Admin Portal 👑',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Manage everything from one place',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.admin_panel_settings,
                  size: 60,
                  color: Colors.white.withOpacity(0.3),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Row(
                  children: [
                    Obx(
                      () => _buildStatCard(
                        'Students',
                        adminController.totalStudents.value.toString(),
                        Icons.people,
                        Color(0xFF4ECDC4),
                        Color(0xFF44A08D),
                      ),
                    ),
                    SizedBox(width: 12),
                    Obx(
                      () => _buildStatCard(
                        'Staff',
                        adminController.totalStaff.value.toString(),
                        Icons.person,
                        Color(0xFFFF6B6B),
                        Color(0xFFFF8E53),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Obx(
                      () => _buildStatCard(
                        'Courses',
                        adminController.totalCourses.value.toString(),
                        Icons.book,
                        Color(0xFF6C5CE7),
                        Color(0xFFA29BFE),
                      ),
                    ),
                    SizedBox(width: 12),
                    Obx(
                      () => _buildStatCard(
                        'Classes',
                        adminController.totalClasses.value.toString(),
                        Icons.video_call,
                        Color(0xFFFD79A8),
                        Color(0xFFFDCB6E),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
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
                      Icon(Icons.analytics, color: Color(0xFFFF6B6B)),
                      SizedBox(width: 8),
                      Text(
                        'System Overview',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Obx(
                    () => _buildProgressBar(
                      'AI Tool Engagement',
                      adminController.aiToolEngagement.value,
                      Color(0xFF6C5CE7),
                    ),
                  ),
                  SizedBox(height: 16),
                  Obx(
                    () => _buildProgressBar(
                      'System Health',
                      adminController.systemHealth.value,
                      Color(0xFF4ECDC4),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24),
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
                      'Quick Management',
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
                      'Manage Students',
                      Icons.people,
                      Color(0xFF4ECDC4),
                      Color(0xFF44A08D),
                      () => _onItemTapped(1),
                    ),
                    _buildQuickAction(
                      'Manage Staff',
                      Icons.person,
                      Color(0xFFFF6B6B),
                      Color(0xFFFF8E53),
                      () => _onItemTapped(2),
                    ),
                    _buildQuickAction(
                      'Manage Courses',
                      Icons.book,
                      Color(0xFF6C5CE7),
                      Color(0xFFA29BFE),
                      () => _onItemTapped(3),
                    ),
                    _buildQuickAction(
                      'Online Classes',
                      Icons.video_library,
                      Color(0xFFFD79A8),
                      Color(0xFFFDCB6E),
                      () => _onItemTapped(4),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                // All Users Database Button
                GestureDetector(
                  onTap: () => Get.to(() => const AllUsersView()),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF667eea).withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.storage,
                            size: 28,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'All Users Database',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'View all registered users',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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

  Widget _buildProgressBar(String label, double value, Color color) {
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
