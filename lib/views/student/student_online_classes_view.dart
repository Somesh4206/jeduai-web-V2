import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/online_class_controller.dart';
import '../../models/online_class_model.dart';
import '../../services/user_service.dart';

class StudentOnlineClassesView extends StatefulWidget {
  const StudentOnlineClassesView({super.key});

  @override
  State<StudentOnlineClassesView> createState() =>
      _StudentOnlineClassesViewState();
}

class _StudentOnlineClassesViewState extends State<StudentOnlineClassesView>
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

  String studentId = 'STU001'; // Will be updated from UserService

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCurrentUser();
  }

  void _loadCurrentUser() {
    try {
      final userService = Get.find<UserService>();
      final currentUser = userService.currentUser.value;
      if (currentUser != null) {
        setState(() {
          studentId = currentUser.id;
        });
      }
    } catch (e) {
      // UserService not found, use default
    }
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
        title: const Text('Online Classes'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00BCD4), Color(0xFF4DD0E1)],
            ),
          ),
        ),
        actions: [
          // Notification Bell with Badge
          Obx(
            () => Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications),
                  onPressed: () => _showNotifications(),
                ),
                if (controller.unreadNotificationCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${controller.unreadNotificationCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
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
            const Tab(text: 'My Classes', icon: Icon(Icons.video_library)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildLiveTab(), _buildUpcomingTab(), _buildMyClassesTab()],
      ),
    );
  }

  Widget _buildLiveTab() {
    return Obx(() {
      if (controller.liveClasses.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.videocam_off, size: 80, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'No live classes at the moment',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                'Check upcoming classes',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.liveClasses.length,
        itemBuilder: (context, index) {
          return _buildClassCard(controller.liveClasses[index], isLive: true);
        },
      );
    });
  }

  Widget _buildUpcomingTab() {
    return Obx(() {
      // Force rebuild by accessing allClasses
      final allClasses = controller.allClasses;
      final upcomingClasses =
          allClasses.where((c) => c.status == ClassStatus.scheduled).toList()
            ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));

      print('📊 Student Upcoming Tab: ${upcomingClasses.length} classes');

      if (upcomingClasses.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.event_available, size: 80, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No upcoming classes',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
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
            return _buildClassCard(upcomingClasses[index]);
          },
        ),
      );
    });
  }

  Widget _buildMyClassesTab() {
    return Obx(() {
      final myClasses = controller.getStudentClasses(studentId);

      if (myClasses.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.class_, size: 80, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'You haven\'t enrolled in any classes yet',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: myClasses.length,
        itemBuilder: (context, index) {
          return _buildClassCard(myClasses[index], showEnrolled: true);
        },
      );
    });
  }

  Widget _buildClassCard(
    OnlineClass classData, {
    bool isLive = false,
    bool showEnrolled = false,
  }) {
    final isEnrolled = controller.isStudentEnrolled(classData.id, studentId);
    final timeUntil = classData.scheduledTime.difference(DateTime.now());
    final isStartingSoon = timeUntil.inMinutes <= 15 && timeUntil.inMinutes > 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isLive ? 4 : 2,
      child: InkWell(
        onTap: () => _showClassDetails(classData),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: isLive ? Border.all(color: Colors.red, width: 2) : null,
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
                              'LIVE NOW',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (isStartingSoon && !isLive)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Starting Soon',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        classData.subject,
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  classData.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      classData.teacherName,
                      style: TextStyle(color: Colors.grey.shade700),
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
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.timer, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${classData.duration} minutes',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.people, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${classData.enrolledStudents.length}/${classData.maxStudents}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (!isEnrolled)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _enrollInClass(classData),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Enroll'),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF00BCD4)),
                          ),
                        ),
                      ),
                    if (isEnrolled) ...[
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showMeetingLink(classData),
                          icon: const Icon(Icons.link, size: 18),
                          label: const Text('Copy Link'),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF00BCD4)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: isLive || isStartingSoon
                              ? () => _joinClass(classData)
                              : null,
                          icon: const Icon(Icons.video_call, size: 18),
                          label: Text(
                            isLive
                                ? 'Join Now'
                                : isStartingSoon
                                ? 'Join'
                                : 'Enrolled',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isLive
                                ? Colors.red
                                : isStartingSoon
                                ? Colors.orange
                                : Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _enrollInClass(OnlineClass classData) async {
    final success = await controller.joinClass(classData.id, studentId);
    if (success) {
      setState(() {});
    }
  }

  void _showMeetingLink(OnlineClass classData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.link, color: Color(0xFF00BCD4)),
            SizedBox(width: 8),
            Text('Meeting Link'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              classData.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: SelectableText(
                classData.meetingLink,
                style: const TextStyle(fontSize: 13, color: Colors.blue),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Class starts at ${classData.formattedTime}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: classData.meetingLink));
              Navigator.pop(context);
              Get.snackbar(
                'Link Copied',
                'Meeting link copied to clipboard',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copy'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00BCD4),
            ),
          ),
        ],
      ),
    );
  }

  void _joinClass(OnlineClass classData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.video_call, color: Colors.red, size: 28),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Join Live Class', style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              classData.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.person, 'Teacher', classData.teacherName),
            _buildInfoRow(
              Icons.timer,
              'Duration',
              '${classData.duration} minutes',
            ),
            _buildInfoRow(
              Icons.people,
              'Participants',
              '${classData.enrolledStudents.length}/${classData.maxStudents}',
            ),
            _buildInfoRow(Icons.subject, 'Subject', classData.subject),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.link, size: 16, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      classData.meetingLink,
                      style: const TextStyle(fontSize: 12, color: Colors.blue),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 18),
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(text: classData.meetingLink),
                      );
                      Get.snackbar(
                        'Copied',
                        'Meeting link copied to clipboard',
                        snackPosition: SnackPosition.BOTTOM,
                        duration: const Duration(seconds: 2),
                      );
                    },
                    tooltip: 'Copy Link',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '✓ You will be redirected to the meeting room',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const Text(
              '✓ Make sure your camera and microphone are ready',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              await _launchMeetingUrl(classData.meetingLink, classData.title);
            },
            icon: const Icon(Icons.video_call),
            label: const Text('Join Now'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchMeetingUrl(String url, String className) async {
    try {
      final uri = Uri.parse(url);

      // Show loading indicator
      Get.dialog(
        const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Opening meeting...'),
                ],
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );

      // Try to launch the URL
      final canLaunch = await canLaunchUrl(uri);

      // Close loading dialog
      Get.back();

      if (canLaunch) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);

        Get.snackbar(
          'Joining Class',
          'Opening $className in your browser...',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          icon: const Icon(Icons.check_circle, color: Colors.white),
        );
      } else {
        // If can't launch, show the URL for manual copy
        _showManualLinkDialog(url, className);
      }
    } catch (e) {
      Get.back(); // Close loading dialog if open
      _showManualLinkDialog(url, className);
    }
  }

  void _showManualLinkDialog(String url, String className) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Meeting Link'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Please copy this link and open it in your browser:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: SelectableText(
                url,
                style: const TextStyle(fontSize: 12, color: Colors.blue),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: url));
              Navigator.pop(context);
              Get.snackbar(
                'Link Copied',
                'Meeting link copied to clipboard',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copy Link'),
          ),
        ],
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
                Text(
                  classData.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildDetailRow('Teacher', classData.teacherName),
                _buildDetailRow('Subject', classData.subject),
                _buildDetailRow(
                  'Date & Time',
                  '${classData.formattedDate} at ${classData.formattedTime}',
                ),
                _buildDetailRow('Duration', '${classData.duration} minutes'),
                _buildDetailRow(
                  'Participants',
                  '${classData.enrolledStudents.length}/${classData.maxStudents}',
                ),
                _buildDetailRow('Status', classData.status.displayName),
                _buildDetailRow('Class Code', classData.classCode),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                const Text(
                  'Description',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(classData.description),
                const SizedBox(height: 20),
                if (classData.isLive ||
                    classData.scheduledTime
                            .difference(DateTime.now())
                            .inMinutes <=
                        15)
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _joinClass(classData);
                    },
                    icon: const Icon(Icons.video_call),
                    label: Text(
                      classData.isLive ? 'Join Live Class' : 'Join Class',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: classData.isLive
                          ? Colors.red
                          : Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                if (!classData.isLive &&
                    classData.scheduledTime
                            .difference(DateTime.now())
                            .inMinutes >
                        15)
                  OutlinedButton.icon(
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(text: classData.meetingLink),
                      );
                      Get.snackbar(
                        'Link Copied',
                        'Meeting link copied. You can join when class starts.',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                    icon: const Icon(Icons.link),
                    label: const Text('Copy Meeting Link'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Color(0xFF00BCD4)),
                    ),
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
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
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

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Notifications',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    controller.markAllNotificationsAsRead();
                  },
                  child: const Text('Mark all as read'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                if (controller.notifications.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No notifications yet',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: controller.notifications.length,
                  itemBuilder: (context, index) {
                    final notification = controller.notifications[index];
                    return Card(
                      color: notification.isRead
                          ? Colors.white
                          : Colors.blue.shade50,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getNotificationColor(
                            notification.type,
                          ),
                          child: Icon(
                            _getNotificationIcon(notification.type),
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          notification.title,
                          style: TextStyle(
                            fontWeight: notification.isRead
                                ? FontWeight.normal
                                : FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(notification.message),
                            const SizedBox(height: 4),
                            Text(
                              notification.timeAgo,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        isThreeLine: true,
                        onTap: () {
                          controller.markNotificationAsRead(notification.id);
                          final classData = controller.getClassById(
                            notification.classId,
                          );
                          if (classData != null) {
                            Navigator.pop(context);
                            _showClassDetails(classData);
                          }
                        },
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.newClass:
        return Colors.blue;
      case NotificationType.classStarted:
        return Colors.green;
      case NotificationType.reminder:
        return Colors.orange;
      case NotificationType.classCancelled:
        return Colors.red;
      case NotificationType.classUpdated:
        return Colors.purple;
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.newClass:
        return Icons.add_circle;
      case NotificationType.classStarted:
        return Icons.play_circle;
      case NotificationType.reminder:
        return Icons.alarm;
      case NotificationType.classCancelled:
        return Icons.cancel;
      case NotificationType.classUpdated:
        return Icons.update;
    }
  }
}
