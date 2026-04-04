import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/student_controller.dart';
import 'student_assessment_view.dart';
import '../common/advanced_translation_view.dart';
import 'student_ai_tutor_view.dart';
import 'student_learning_view.dart';
import 'student_online_classes_view.dart';
import 'personalized_profile_view.dart';
import '../admin/all_users_view.dart';

class StudentDashboardView extends StatefulWidget {
  const StudentDashboardView({super.key});

  @override
  State<StudentDashboardView> createState() => _StudentDashboardViewState();
}

class _StudentDashboardViewState extends State<StudentDashboardView> {
  int _selectedIndex = 0;
  final StudentController studentController = Get.put(StudentController());

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildDashboardContent(),
      StudentAssessmentView(),
      AdvancedTranslationView(),
      StudentAiTutorView(),
      StudentLearningView(),
      StudentOnlineClassesView(),
      PersonalizedProfileView(),
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
                        'Student Portal',
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
                    colors: [Colors.blue.shade400, Colors.purple.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(Icons.storage),
                  onPressed: () {
                    Get.to(() => const AllUsersView());
                  },
                  tooltip: 'View All Users',
                ),
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
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assessment_rounded),
              label: 'Assessment',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.translate_rounded),
              label: 'Translate',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_rounded),
              label: 'AI Tutor',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.school_rounded),
              label: 'Learning',
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
          selectedItemColor: Colors.purple,
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 11,
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
          // Colorful Banner with gradient
          Container(
            height: 200,
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF6B4CE6),
                  Color(0xFF9B59B6),
                  Color(0xFFE74C3C),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -20,
                  top: -20,
                  child: Icon(
                    Icons.school,
                    size: 150,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Welcome Back! 👋',
                        style: TextStyle(
                          fontSize: 28,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Ready to continue your learning journey?',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      SizedBox(height: 16),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '🔥 7 Day Streak!',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Colorful Quick Stats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Obx(
                  () => _buildColorfulStatCard(
                    'Completed',
                    studentController.completedCourses.value.toString(),
                    Icons.book_rounded,
                    Color(0xFF4CAF50),
                    Color(0xFF81C784),
                  ),
                ),
                Obx(
                  () => _buildColorfulStatCard(
                    'Pending',
                    studentController.pendingQuizzes.value.toString(),
                    Icons.quiz_rounded,
                    Color(0xFFFF9800),
                    Color(0xFFFFB74D),
                  ),
                ),
                Obx(
                  () => _buildColorfulStatCard(
                    'AI Usage',
                    studentController.aiTutorUsage.value.toString(),
                    Icons.smart_toy_rounded,
                    Color(0xFF2196F3),
                    Color(0xFF64B5F6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Colorful Shortcuts
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(Icons.rocket_launch_rounded, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'Quick Access',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            padding: const EdgeInsets.all(20),
            childAspectRatio: 1.0,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildColorfulShortcutCard(
                'Smart Assessment',
                Icons.analytics_rounded,
                Color(0xFFE91E63),
                Color(0xFFF48FB1),
                () => _onItemTapped(1),
              ),
              _buildColorfulShortcutCard(
                'AI Translation',
                Icons.g_translate_rounded,
                Color(0xFF9C27B0),
                Color(0xFFCE93D8),
                () => _onItemTapped(2),
              ),
              _buildColorfulShortcutCard(
                'AI Tutor',
                Icons.psychology_rounded,
                Color(0xFF2196F3),
                Color(0xFF90CAF9),
                () => _onItemTapped(3),
              ),
              _buildColorfulShortcutCard(
                'Learning Hub',
                Icons.auto_stories_rounded,
                Color(0xFFFF9800),
                Color(0xFFFFCC80),
                () => _onItemTapped(4),
              ),
            ],
          ),
          // Upcoming Classes with colorful design
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(Icons.event_rounded, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'Upcoming Classes',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            itemBuilder: (context, index) {
              final colors = [
                [Color(0xFF3F51B5), Color(0xFF5C6BC0)],
                [Color(0xFF00BCD4), Color(0xFF4DD0E1)],
                [Color(0xFF4CAF50), Color(0xFF81C784)],
              ];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: colors[index],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: colors[index][0].withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.3),
                    child: Icon(Icons.video_call_rounded, color: Colors.white),
                  ),
                  title: Text(
                    'Class ${index + 1}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Time: ${10 + index}:00 AM',
                    style: TextStyle(color: Colors.white.withOpacity(0.9)),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                  onTap: () => _onItemTapped(5),
                ),
              );
            },
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildColorfulStatCard(
    String title,
    String value,
    IconData icon,
    Color color1,
    Color color2,
  ) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color1, color2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
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
          children: [
            Icon(icon, size: 32, color: Colors.white),
            SizedBox(height: 8),
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
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorfulShortcutCard(
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
          gradient: LinearGradient(
            colors: [color1, color2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color1.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative background pattern
            Positioned(
              right: -20,
              top: -20,
              child: Icon(
                icon,
                size: 100,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            // Main content
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Icon(icon, size: 40, color: Colors.white),
                ),
                SizedBox(height: 16),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          offset: Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
