import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/online_class_controller.dart';
import '../../services/user_service.dart';
import '../../models/online_class_model.dart';

class StaffOnlineClassCreationView extends StatefulWidget {
  const StaffOnlineClassCreationView({super.key});

  @override
  State<StaffOnlineClassCreationView> createState() =>
      _StaffOnlineClassCreationViewState();
}

class _StaffOnlineClassCreationViewState
    extends State<StaffOnlineClassCreationView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Lazy getter for controller to avoid initialization issues
  OnlineClassController get classController {
    try {
      return Get.find<OnlineClassController>();
    } catch (e) {
      print('❌ Error finding OnlineClassController: $e');
      // Fallback: try to create if not found
      return Get.put(OnlineClassController());
    }
  }

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final meetingLinkController = TextEditingController();

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  String selectedSubject = 'Mathematics';
  String selectedClass = 'Class 12';
  int duration = 60;
  bool notifyStudents = true;
  bool recordClass = false;
  bool autoGenerateLink = true;

  final List<String> subjects = [
    // Core Engineering Subjects
    'Mathematics',
    'Physics',
    'Chemistry',
    'Engineering Graphics',
    'Engineering Mechanics',

    // Computer Science & IT
    'Computer Science',
    'Data Structures',
    'Algorithms',
    'Database Management',
    'Operating Systems',
    'Computer Networks',
    'Software Engineering',
    'Web Development',
    'Mobile App Development',
    'Artificial Intelligence',
    'Machine Learning',
    'Deep Learning',
    'Data Science',
    'Big Data Analytics',
    'Cloud Computing',
    'Cyber Security',
    'Internet of Things',
    'Blockchain Technology',

    // Electronics & Communication
    'Digital Electronics',
    'Analog Electronics',
    'Microprocessors',
    'Embedded Systems',
    'Signal Processing',
    'Communication Systems',
    'VLSI Design',
    'Control Systems',

    // Electrical Engineering
    'Electrical Circuits',
    'Power Systems',
    'Electrical Machines',
    'Power Electronics',
    'Renewable Energy',

    // Mechanical Engineering
    'Thermodynamics',
    'Fluid Mechanics',
    'Manufacturing Technology',
    'Machine Design',
    'Automobile Engineering',
    'Robotics',

    // Business & Management
    'Business Management',
    'Financial Management',
    'Marketing Management',
    'Human Resource Management',
    'Entrepreneurship',
    'Project Management',
    'Operations Management',

    // Languages & Communication
    'English',
    'Technical Writing',
    'Communication Skills',
    'Professional Ethics',

    // General Subjects
    'Biology',
    'Environmental Science',
    'History',
    'Economics',
    'Statistics',
    'Research Methodology',
  ];

  final List<String> classes = [
    // School Classes
    'Class 6',
    'Class 7',
    'Class 8',
    'Class 9',
    'Class 10',
    'Class 11',
    'Class 12',
    // College Years - CSBS
    'I CSBS',
    'II CSBS',
    'III CSBS',
    'IV CSBS',
    // College Years - CSE
    'I CSE',
    'II CSE',
    'III CSE',
    'IV CSE',
    // College Years - ECE
    'I ECE',
    'II ECE',
    'III ECE',
    'IV ECE',
    // College Years - EEE
    'I EEE',
    'II EEE',
    'III EEE',
    'IV EEE',
    // College Years - MECH
    'I MECH',
    'II MECH',
    'III MECH',
    'IV MECH',
    // All Classes
    'All Classes',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _generateMeetingLink(); // Auto-generate link on init
  }

  void _generateMeetingLink() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomCode = (timestamp % 1000000).toString().padLeft(6, '0');
    // Use Jitsi Meet - a FREE, real video conferencing service
    meetingLinkController.text = 'https://meet.jit.si/JeduAI-$randomCode';
  }

  @override
  void dispose() {
    _tabController.dispose();
    titleController.dispose();
    descriptionController.dispose();
    meetingLinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Online Classes'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00BCD4), Color(0xFF4DD0E1)],
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.add), text: 'Schedule New'),
            Tab(icon: Icon(Icons.list), text: 'Upcoming'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildScheduleTab(), _buildUpcomingTab()],
      ),
    );
  }

  Widget _buildScheduleTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00BCD4), Color(0xFF4DD0E1)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(Icons.video_call, size: 50, color: Colors.white),
                SizedBox(height: 12),
                Text(
                  'Schedule Online Class',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Create and schedule virtual classes for students',
                  style: TextStyle(color: Colors.white.withOpacity(0.9)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          SizedBox(height: 24),

          // Class Title
          _buildInputField(
            'Class Title',
            'e.g., Algebra Basics',
            titleController,
            Icons.title,
          ),
          SizedBox(height: 16),

          // Subject & Class Selection
          Row(
            children: [
              Expanded(
                child: _buildDropdownField(
                  'Subject',
                  selectedSubject,
                  subjects,
                  Icons.subject,
                  (value) => setState(() => selectedSubject = value!),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildDropdownField(
                  'Class',
                  selectedClass,
                  classes,
                  Icons.school,
                  (value) => setState(() => selectedClass = value!),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Date & Time Selection
          Row(
            children: [
              Expanded(
                child: _buildDateTimeCard(
                  'Date',
                  DateFormat('MMM dd, yyyy').format(selectedDate),
                  Icons.calendar_today,
                  () => _selectDate(),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildDateTimeCard(
                  'Time',
                  selectedTime.format(context),
                  Icons.access_time,
                  () => _selectTime(),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Duration
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xFF00BCD4).withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.timer, color: Color(0xFF00BCD4)),
                    SizedBox(width: 8),
                    Text(
                      'Duration: $duration minutes',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Slider(
                  value: duration.toDouble(),
                  min: 30,
                  max: 180,
                  divisions: 10,
                  activeColor: Color(0xFF00BCD4),
                  label: '$duration min',
                  onChanged: (value) =>
                      setState(() => duration = value.toInt()),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),

          // Meeting Link
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Color(0xFF00BCD4).withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.link, color: Color(0xFF00BCD4), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Meeting Link',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00BCD4),
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.refresh, size: 20),
                      onPressed: _generateMeetingLink,
                      tooltip: 'Generate New Link',
                    ),
                    IconButton(
                      icon: Icon(Icons.copy, size: 20),
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(text: meetingLinkController.text),
                        );
                        Get.snackbar(
                          'Copied',
                          'Meeting link copied to clipboard',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                      tooltip: 'Copy Link',
                    ),
                  ],
                ),
                SizedBox(height: 8),
                TextField(
                  controller: meetingLinkController,
                  decoration: InputDecoration(
                    hintText: 'Auto-generated meeting link',
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  readOnly: autoGenerateLink,
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Checkbox(
                      value: autoGenerateLink,
                      onChanged: (value) {
                        setState(() {
                          autoGenerateLink = value!;
                          if (autoGenerateLink) {
                            _generateMeetingLink();
                          }
                        });
                      },
                      activeColor: Color(0xFF00BCD4),
                    ),
                    Text('Auto-generate meeting link'),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 16),

          // Description
          _buildInputField(
            'Description',
            'Class description and topics...',
            descriptionController,
            Icons.description,
            maxLines: 3,
          ),
          SizedBox(height: 16),

          // Options
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xFF00BCD4).withOpacity(0.3)),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: Text('Notify Students'),
                  subtitle: Text('Send notification to all students'),
                  value: notifyStudents,
                  activeThumbColor: Color(0xFF00BCD4),
                  onChanged: (value) => setState(() => notifyStudents = value),
                  contentPadding: EdgeInsets.zero,
                ),
                Divider(),
                SwitchListTile(
                  title: Text('Record Class'),
                  subtitle: Text('Save recording for later viewing'),
                  value: recordClass,
                  activeThumbColor: Color(0xFF00BCD4),
                  onChanged: (value) => setState(() => recordClass = value),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          SizedBox(height: 24),

          // Schedule Button
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00BCD4), Color(0xFF4DD0E1)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF00BCD4).withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: _scheduleClass,
              icon: Icon(Icons.event_available),
              label: Text(
                'Schedule Class',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
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

  Widget _buildUpcomingTab() {
    return Obx(() {
      // Force rebuild by accessing the observable
      final allClasses = classController.allClasses;
      final upcomingClasses =
          allClasses.where((c) => c.status == ClassStatus.scheduled).toList()
            ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));

      print('📊 Staff Upcoming Tab: ${upcomingClasses.length} classes');

      if (upcomingClasses.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.event_available, size: 80, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No upcoming classes',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              SizedBox(height: 8),
              Text(
                'Schedule a new class to get started',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          // Trigger rebuild by calling setState
          setState(() {});
          await Future.delayed(Duration(milliseconds: 300));
        },
        child: ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: upcomingClasses.length,
          itemBuilder: (context, index) {
            final classData = upcomingClasses[index];
            return _buildRealClassCard(classData);
          },
        ),
      );
    });
  }

  Widget _buildRealClassCard(classData) {
    final date = classData.scheduledTime;
    final isToday = date.day == DateTime.now().day;
    final timeUntil = date.difference(DateTime.now());
    final canStart =
        timeUntil.inMinutes <= 15 && timeUntil.inMinutes >= -classData.duration;

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isToday ? Colors.red : Color(0xFF00BCD4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isToday ? 'TODAY' : 'UPCOMING',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    classData.classCode,
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Spacer(),
                PopupMenuButton(
                  icon: Icon(Icons.more_vert),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'copy',
                      child: Row(
                        children: [
                          Icon(Icons.copy, size: 18),
                          SizedBox(width: 8),
                          Text('Copy Link'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'cancel',
                      child: Row(
                        children: [
                          Icon(Icons.cancel, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Cancel', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'copy') {
                      Clipboard.setData(
                        ClipboardData(text: classData.meetingLink),
                      );
                      Get.snackbar(
                        'Copied',
                        'Meeting link copied to clipboard',
                      );
                    } else if (value == 'cancel') {
                      _showCancelDialog(classData);
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              classData.title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.subject, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text(classData.subject, style: TextStyle(color: Colors.grey)),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Color(0xFF00BCD4)),
                SizedBox(width: 4),
                Text('${classData.formattedDate} • ${classData.formattedTime}'),
                SizedBox(width: 16),
                Icon(Icons.timer, size: 16, color: Color(0xFF00BCD4)),
                SizedBox(width: 4),
                Text('${classData.duration} min'),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.people, size: 16, color: Color(0xFF00BCD4)),
                SizedBox(width: 4),
                Text(
                  '${classData.enrolledStudents.length}/${classData.maxStudents} enrolled',
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(text: classData.meetingLink),
                      );
                      Get.snackbar('Copied', 'Meeting link copied!');
                    },
                    icon: Icon(Icons.link, size: 18),
                    label: Text('Copy Link'),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Color(0xFF00BCD4)),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: canStart
                        ? () async {
                            try {
                              final uri = Uri.parse(classData.meetingLink);
                              final canLaunch = await canLaunchUrl(uri);

                              if (canLaunch) {
                                await launchUrl(
                                  uri,
                                  mode: LaunchMode.externalApplication,
                                );
                                Get.snackbar(
                                  'Starting Class',
                                  'Opening ${classData.title}...',
                                  backgroundColor: Colors.green,
                                  colorText: Colors.white,
                                );
                              } else {
                                Clipboard.setData(
                                  ClipboardData(text: classData.meetingLink),
                                );
                                Get.snackbar(
                                  'Link Copied',
                                  'Meeting link copied. Please open it manually.',
                                  backgroundColor: Colors.orange,
                                  colorText: Colors.white,
                                );
                              }
                            } catch (e) {
                              Clipboard.setData(
                                ClipboardData(text: classData.meetingLink),
                              );
                              Get.snackbar(
                                'Link Copied',
                                'Meeting link copied to clipboard',
                                backgroundColor: Colors.orange,
                                colorText: Colors.white,
                              );
                            }
                          }
                        : null,
                    icon: Icon(Icons.video_call, size: 18),
                    label: Text(canStart ? 'Start Class' : 'Not Yet'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF00BCD4),
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

  void _showCancelDialog(classData) {
    final reasonController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Text('Cancel Class'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to cancel "${classData.title}"?'),
            SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: 'Reason for cancellation',
                border: OutlineInputBorder(),
                hintText: 'Enter reason...',
              ),
              maxLines: 3,
            ),
            SizedBox(height: 8),
            Text(
              '${classData.enrolledStudents.length} students will be notified',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Keep Class')),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.isEmpty) {
                Get.snackbar('Error', 'Please provide a reason');
                return;
              }
              Get.back();
              classController.cancelClass(classData.id, reasonController.text);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Cancel Class'),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(
    String label,
    String hint,
    TextEditingController controller,
    IconData icon, {
    int maxLines = 1,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFF00BCD4).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Color(0xFF00BCD4), size: 20),
              SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00BCD4),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
              isDense: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    String value,
    List<String> items,
    IconData icon,
    Function(String?) onChanged,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFF00BCD4).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Color(0xFF00BCD4), size: 20),
              SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00BCD4),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: SizedBox(),
            isDense: true,
            items: items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(item, style: TextStyle(fontSize: 14)),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeCard(
    String label,
    String value,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Color(0xFF00BCD4).withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Color(0xFF00BCD4), size: 20),
                SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00BCD4),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null && picked != selectedDate) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      setState(() => selectedTime = picked);
    }
  }

  void _scheduleClass() async {
    if (titleController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter class title');
      return;
    }

    if (meetingLinkController.text.isEmpty) {
      Get.snackbar('Error', 'Please provide a meeting link');
      return;
    }

    // Show loading
    Get.dialog(
      Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Creating class...'),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      // Get current user info
      final userService = Get.find<UserService>();
      final currentUser = userService.currentUser.value;

      // Combine date and time
      final scheduledDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );

      // Generate class code
      final classCode =
          '${selectedSubject.substring(0, 3).toUpperCase()}-${DateTime.now().millisecondsSinceEpoch % 10000}';

      // Create the class
      final newClass = await classController.createClass(
        title: titleController.text,
        subject: selectedSubject,
        teacherName: currentUser?.name ?? 'Teacher',
        teacherId: currentUser?.id ?? 'TCH001',
        scheduledTime: scheduledDateTime,
        duration: duration,
        meetingLink: meetingLinkController.text,
        description: descriptionController.text.isEmpty
            ? 'Class description and topics...'
            : descriptionController.text,
        classCode: classCode,
        targetClass: selectedClass,
        maxStudents: 50,
      );

      // Close loading dialog
      Get.back();

      if (newClass != null) {
        // Show success dialog with class details
        Get.dialog(
          AlertDialog(
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 32),
                SizedBox(width: 12),
                Text('Class Created!'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your class has been scheduled successfully.',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Class Code: $classCode',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('Meeting Link:'),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              meetingLinkController.text,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.copy, size: 18),
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: meetingLinkController.text),
                              );
                              Get.snackbar('Copied', 'Link copied!');
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (notifyStudents) ...[
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.notifications_active, color: Colors.green),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'All students in $selectedClass have been notified',
                            style: TextStyle(color: Colors.green.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back();
                  // Clear form
                  titleController.clear();
                  descriptionController.clear();
                  _generateMeetingLink();
                },
                child: Text('Create Another'),
              ),
              ElevatedButton(
                onPressed: () {
                  Get.back();
                  _tabController.animateTo(1);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF00BCD4),
                ),
                child: Text('View Classes'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      Get.back(); // Close loading
      Get.snackbar(
        'Error',
        'Failed to create class: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
