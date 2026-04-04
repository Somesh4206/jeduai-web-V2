import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/online_class_controller.dart';
import '../../models/online_class_model.dart';

class AdminOnlineClassMonitoringView extends StatefulWidget {
  const AdminOnlineClassMonitoringView({super.key});

  @override
  State<AdminOnlineClassMonitoringView> createState() =>
      _AdminOnlineClassMonitoringViewState();
}

class _AdminOnlineClassMonitoringViewState
    extends State<AdminOnlineClassMonitoringView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Lazy getter for controller
  OnlineClassController get controller {
    try {
      return Get.find<OnlineClassController>();
    } catch (e) {
      return Get.put(OnlineClassController());
    }
  }

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
        title: const Text('Online Class Monitoring'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF6B6B), Color(0xFFFFE66D)],
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Obx(
              () => Tab(
                text: 'All (${controller.allClasses.length})',
                icon: const Icon(Icons.list),
              ),
            ),
            Obx(
              () => Tab(
                text: 'Live (${controller.liveClasses.length})',
                icon: const Icon(Icons.circle, color: Colors.red, size: 12),
              ),
            ),
            Obx(
              () => Tab(
                text: 'Upcoming (${controller.upcomingClasses.length})',
                icon: const Icon(Icons.schedule),
              ),
            ),
            const Tab(text: 'Analytics', icon: Icon(Icons.analytics)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAllClassesTab(),
          _buildLiveClassesTab(),
          _buildUpcomingClassesTab(),
          _buildAnalyticsTab(),
        ],
      ),
    );
  }

  Widget _buildAllClassesTab() {
    return Obx(() {
      final allClasses = controller.allClasses;

      print('📊 Admin All Classes Tab: ${allClasses.length} classes');

      if (allClasses.isEmpty) {
        return _buildEmptyState(
          'No Classes Yet',
          'Staff members can create online classes',
          Icons.video_library,
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          // Trigger rebuild
          setState(() {});
          await Future.delayed(const Duration(milliseconds: 300));
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: allClasses.length,
          itemBuilder: (context, index) {
            return _buildAdminClassCard(allClasses[index]);
          },
        ),
      );
    });
  }

  Widget _buildLiveClassesTab() {
    return Obx(() {
      if (controller.liveClasses.isEmpty) {
        return _buildEmptyState(
          'No Live Classes',
          'No classes are currently in session',
          Icons.videocam_off,
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.liveClasses.length,
        itemBuilder: (context, index) {
          return _buildAdminClassCard(
            controller.liveClasses[index],
            isLive: true,
          );
        },
      );
    });
  }

  Widget _buildUpcomingClassesTab() {
    return Obx(() {
      // Force rebuild
      final allClasses = controller.allClasses;
      final upcomingClasses =
          allClasses.where((c) => c.status == ClassStatus.scheduled).toList()
            ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));

      print('📊 Admin Upcoming Tab: ${upcomingClasses.length} classes');

      if (upcomingClasses.isEmpty) {
        return _buildEmptyState(
          'No Upcoming Classes',
          'No classes scheduled for the future',
          Icons.event_available,
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          // Trigger rebuild
          setState(() {});
          await Future.delayed(const Duration(milliseconds: 300));
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: upcomingClasses.length,
          itemBuilder: (context, index) {
            return _buildAdminClassCard(upcomingClasses[index]);
          },
        ),
      );
    });
  }

  Widget _buildAnalyticsTab() {
    return Obx(() {
      final totalClasses = controller.allClasses.length;
      final liveClasses = controller.liveClasses.length;
      final upcomingClasses = controller.upcomingClasses.length;
      final completedClasses = controller.allClasses
          .where((c) => c.status == ClassStatus.completed)
          .length;
      final totalEnrollments = controller.allClasses.fold<int>(
        0,
        (sum, c) => sum + c.enrolledStudents.length,
      );

      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            Row(
              children: [
                Expanded(
                  child: _buildAnalyticsCard(
                    'Total Classes',
                    totalClasses.toString(),
                    Icons.video_library,
                    const Color(0xFF6C5CE7),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildAnalyticsCard(
                    'Live Now',
                    liveClasses.toString(),
                    Icons.circle,
                    Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildAnalyticsCard(
                    'Upcoming',
                    upcomingClasses.toString(),
                    Icons.schedule,
                    const Color(0xFF4ECDC4),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildAnalyticsCard(
                    'Completed',
                    completedClasses.toString(),
                    Icons.check_circle,
                    const Color(0xFF4CAF50),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Enrollment Stats
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.people, color: Color(0xFFFF6B6B)),
                      SizedBox(width: 8),
                      Text(
                        'Enrollment Statistics',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildStatRow(
                    'Total Enrollments',
                    totalEnrollments.toString(),
                    Icons.person_add,
                  ),
                  const SizedBox(height: 12),
                  _buildStatRow(
                    'Average per Class',
                    totalClasses > 0
                        ? (totalEnrollments / totalClasses).toStringAsFixed(1)
                        : '0',
                    Icons.trending_up,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Recent Classes
            const Text(
              'Recent Classes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...controller.allClasses.take(5).map((classData) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: classData.status.color,
                    child: Icon(
                      classData.status.icon,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: Text(classData.title),
                  subtitle: Text(
                    '${classData.teacherName} • ${classData.enrolledStudents.length} students',
                  ),
                  trailing: Text(
                    classData.status.displayName,
                    style: TextStyle(
                      color: classData.status.color,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      );
    });
  }

  Widget _buildAdminClassCard(OnlineClass classData, {bool isLive = false}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isLive ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isLive
            ? const BorderSide(color: Colors.red, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (isLive)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.circle, size: 8, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'LIVE',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: classData.status.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    classData.status.displayName,
                    style: TextStyle(
                      color: classData.status.color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'view',
                      child: Row(
                        children: [
                          Icon(Icons.visibility, size: 18),
                          SizedBox(width: 8),
                          Text('View Details'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'copy',
                      child: Row(
                        children: [
                          Icon(Icons.copy, size: 18),
                          SizedBox(width: 8),
                          Text('Copy Link'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'notify',
                      child: Row(
                        children: [
                          Icon(Icons.notifications, size: 18),
                          SizedBox(width: 8),
                          Text('Send Reminder'),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'copy') {
                      Clipboard.setData(
                        ClipboardData(text: classData.meetingLink),
                      );
                      Get.snackbar('Copied', 'Meeting link copied');
                    } else if (value == 'view') {
                      _showClassDetails(classData);
                    } else if (value == 'notify') {
                      Get.snackbar(
                        'Reminder Sent',
                        'Notification sent to all enrolled students',
                      );
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              classData.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  classData.teacherName,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.subject, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  classData.subject,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${classData.formattedDate} • ${classData.formattedTime}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.timer, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${classData.duration} min',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.people, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${classData.enrolledStudents.length}/${classData.maxStudents}',
                  style: const TextStyle(color: Colors.grey),
                ),
                const Spacer(),
                Text(
                  'Code: ${classData.classCode}',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showClassDetails(OnlineClass classData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: ListView(
              controller: scrollController,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        classData.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: classData.status.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        classData.status.displayName,
                        style: TextStyle(
                          color: classData.status.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildDetailRow('Teacher', classData.teacherName),
                _buildDetailRow('Subject', classData.subject),
                _buildDetailRow(
                  'Date & Time',
                  '${classData.formattedDate} at ${classData.formattedTime}',
                ),
                _buildDetailRow('Duration', '${classData.duration} minutes'),
                _buildDetailRow(
                  'Enrolled',
                  '${classData.enrolledStudents.length}/${classData.maxStudents}',
                ),
                _buildDetailRow('Class Code', classData.classCode),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                const Text(
                  'Meeting Link',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.blue.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: SelectableText(
                          classData.meetingLink,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 20),
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(text: classData.meetingLink),
                          );
                          Get.snackbar('Copied', 'Link copied to clipboard');
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                const Text(
                  'Description',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(classData.description),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 8),
          Text(subtitle, style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.7)]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: Colors.white),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFFFF6B6B)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFF6B6B),
          ),
        ),
      ],
    );
  }
}
