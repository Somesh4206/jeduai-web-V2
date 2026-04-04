import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/user_data_service.dart';

class StaffProfileView extends StatefulWidget {
  const StaffProfileView({super.key});

  @override
  State<StaffProfileView> createState() => _StaffProfileViewState();
}

class _StaffProfileViewState extends State<StaffProfileView> {
  final UserDataService _userService = UserDataService();
  UserData? currentUser;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await _userService.getCurrentUser();
    setState(() {
      currentUser = user;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE91E63), Color(0xFFF48FB1)],
              ),
            ),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: Text('No user data found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE91E63), Color(0xFFF48FB1)],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _userService.logout();
              Get.offAllNamed('/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFE91E63), Color(0xFFF48FB1)],
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
                        currentUser!.name[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE91E63),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    currentUser!.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Faculty Member',
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
            ),

            // Profile Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildInfoCard('Personal Information', Icons.person, [
                    _buildInfoRow('Name', currentUser!.name),
                    _buildInfoRow('Email', currentUser!.email),
                    _buildInfoRow(
                      'Phone',
                      currentUser!.phone ?? 'Not provided',
                    ),
                    _buildInfoRow('Staff ID', currentUser!.id),
                  ]),
                  const SizedBox(height: 16),
                  _buildInfoCard('Professional Information', Icons.work, [
                    _buildInfoRow('College', currentUser!.college ?? 'N/A'),
                    _buildInfoRow(
                      'Department',
                      currentUser!.department ?? 'N/A',
                    ),
                    _buildInfoRow(
                      'Subject Handling',
                      currentUser!.subject ?? 'N/A',
                    ),
                    _buildInfoRow('Role', 'Faculty'),
                  ]),
                  const SizedBox(height: 16),
                  _buildClassesCard(),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Get.snackbar(
                        'Coming Soon',
                        'Profile editing will be available soon',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Profile'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE91E63),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, IconData icon, List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFFE91E63)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...children,
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
            width: 140,
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

  Widget _buildClassesCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.class_, color: Color(0xFFE91E63)),
                SizedBox(width: 8),
                Text(
                  'Teaching Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFE91E63).withAlpha(25),
                    const Color(0xFFF48FB1).withAlpha(25),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE91E63),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.book,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentUser!.subject ?? 'Subject',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'III CSBS - 3rd Year B.Tech',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  _buildStatRow('Total Students', '45'),
                  _buildStatRow('Assessments Created', '12'),
                  _buildStatRow('Classes Conducted', '28'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFFE91E63),
            ),
          ),
        ],
      ),
    );
  }
}
