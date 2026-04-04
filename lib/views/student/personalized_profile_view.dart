import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/user_session_service.dart';
import '../../controllers/auth_controller.dart';
import '../../services/app_update_service.dart';

class PersonalizedProfileView extends StatefulWidget {
  const PersonalizedProfileView({super.key});

  @override
  State<PersonalizedProfileView> createState() =>
      _PersonalizedProfileViewState();
}

class _PersonalizedProfileViewState extends State<PersonalizedProfileView> {
  late UserSessionService _sessionService;
  late AuthController _authController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  void _initializeServices() {
    try {
      // Try to get existing instance or create new one
      if (Get.isRegistered<UserSessionService>()) {
        _sessionService = Get.find<UserSessionService>();
      } else {
        _sessionService = Get.put(UserSessionService());
      }

      if (Get.isRegistered<AuthController>()) {
        _authController = Get.find<AuthController>();
      } else {
        _authController = Get.put(AuthController());
      }

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      print('❌ Error initializing services: $e');
      setState(() {
        _isInitialized = true; // Show error state
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Profile'),
          backgroundColor: const Color(0xFF2196F3),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authController.logout();
            },
          ),
        ],
      ),
      body: _sessionService.currentUser.value == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No user logged in',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Get.offAllNamed('/login');
                    },
                    child: Text('Go to Login'),
                  ),
                ],
              ),
            )
          : Obx(
              () => SingleChildScrollView(
                child: Column(
                  children: [
                    // Profile Header with User Info
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.white,
                              child: Text(
                                _sessionService.userName[0].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2196F3),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _sessionService.userName,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _sessionService.userRole.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(51),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Login Count: ${_sessionService.loginCount.value}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // User Statistics
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildStatisticsCard(),
                          const SizedBox(height: 16),
                          _buildPersonalInfoCard(),
                          const SizedBox(height: 16),
                          _buildActivityCard(),
                          const SizedBox(height: 24),
                          _buildEditProfileButton(context),
                          const SizedBox(height: 12),
                          _buildCheckUpdatesButton(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCheckUpdatesButton() {
    return OutlinedButton.icon(
      onPressed: () {
        if (Get.isRegistered<AppUpdateService>()) {
          Get.find<AppUpdateService>().manualUpdateCheck();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Update service not available'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      },
      icon: const Icon(Icons.system_update),
      label: const Text('Check for Updates'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: const BorderSide(color: Color(0xFF2196F3)),
      ),
    );
  }

  Widget _buildStatisticsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.analytics, color: Color(0xFF2196F3)),
                SizedBox(width: 8),
                Text(
                  'My Statistics',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    Icons.assignment_turned_in,
                    'Assessments',
                    _sessionService.assessmentsCompleted.value.toString(),
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    Icons.video_library,
                    'Videos',
                    _sessionService.videosWatched.value.toString(),
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    Icons.translate,
                    'Translations',
                    _sessionService.translationsUsed.value.toString(),
                    Colors.purple,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    Icons.star,
                    'Avg Score',
                    _sessionService.averageScore.value.toStringAsFixed(1),
                    Colors.amber,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
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
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoCard() {
    final profile = _sessionService.userProfile;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.person, color: Color(0xFF2196F3)),
                SizedBox(width: 8),
                Text(
                  'Personal Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow('Name', profile['name'] ?? 'N/A'),
            _buildInfoRow('Email', profile['email'] ?? 'N/A'),
            _buildInfoRow('Role', profile['role']?.toUpperCase() ?? 'N/A'),
            _buildInfoRow('User ID', profile['uid'] ?? 'N/A'),
            if (profile['department']?.isNotEmpty == true)
              _buildInfoRow('Department', profile['department']),
            if (profile['year']?.isNotEmpty == true)
              _buildInfoRow('Year', profile['year']),
            if (profile['section']?.isNotEmpty == true)
              _buildInfoRow('Section', profile['section']),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.history, color: Color(0xFF2196F3)),
                SizedBox(width: 8),
                Text(
                  'Activity',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(
              'Total Logins',
              _sessionService.loginCount.value.toString(),
            ),
            _buildInfoRow(
              'Last Login',
              _formatDate(_sessionService.lastLoginDate.value),
            ),
            _buildInfoRow(
              'Total Score',
              _sessionService.totalScore.value.toString(),
            ),
            _buildInfoRow(
              'Account Created',
              _formatDate(_sessionService.userProfile['createdAt'] ?? ''),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditProfileButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        _showEditProfileDialog(context);
      },
      icon: const Icon(Icons.edit),
      label: const Text('Edit Profile'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2196F3),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final nameController = TextEditingController(
      text: _sessionService.userName,
    );
    final departmentController = TextEditingController(
      text: _sessionService.userProfile['department'] ?? '',
    );
    final yearController = TextEditingController(
      text: _sessionService.userProfile['year'] ?? '',
    );
    final sectionController = TextEditingController(
      text: _sessionService.userProfile['section'] ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: departmentController,
                decoration: const InputDecoration(
                  labelText: 'Department',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: yearController,
                decoration: const InputDecoration(
                  labelText: 'Year',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: sectionController,
                decoration: const InputDecoration(
                  labelText: 'Section',
                  border: OutlineInputBorder(),
                ),
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
            onPressed: () async {
              await _sessionService.updateUserProfile({
                'name': nameController.text,
                'department': departmentController.text,
                'year': yearController.text,
                'section': sectionController.text,
              });

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profile updated successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic dateValue) {
    if (dateValue == null) return 'N/A';

    try {
      DateTime date;
      
      // Handle Firestore Timestamp
      if (dateValue is Timestamp) {
        date = dateValue.toDate();
      } else if (dateValue is String) {
        if (dateValue.isEmpty) return 'N/A';
        date = DateTime.parse(dateValue);
      } else if (dateValue is DateTime) {
        date = dateValue;
      } else {
        return 'N/A';
      }

      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      print('Error formatting date: $e');
      return 'N/A';
    }
  }
}
