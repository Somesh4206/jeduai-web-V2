import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/admin_controller.dart';
import 'admin_user_management_view.dart';
import 'admin_settings_view.dart';
import 'admin_system_monitor_view.dart';

class AdminProfileView extends StatelessWidget {
  const AdminProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find();
    final AdminController adminController = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Profile'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF5722), Color(0xFFFF9800)],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              adminController.refreshData();
              Get.snackbar('Refreshed', 'Data updated successfully');
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
                  colors: [Color(0xFFFF5722), Color(0xFFFF9800)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
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
                    child: const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.admin_panel_settings,
                        size: 50,
                        color: Color(0xFFFF5722),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'System Administrator',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'admin@jeduai.com',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatBadge('Users', '1,335', Icons.people),
                      _buildStatBadge('Courses', '45', Icons.school),
                      _buildStatBadge('Active', '1,180', Icons.check_circle),
                    ],
                  ),
                ],
              ),
            ),

            // Quick Actions
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Actions',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickActionCard(
                          'Add User',
                          Icons.person_add,
                          Colors.blue,
                          () => _showAddUserDialog(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickActionCard(
                          'Backup',
                          Icons.backup,
                          Colors.teal,
                          () => _showBackupDialog(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickActionCard(
                          'Reports',
                          Icons.assessment,
                          Colors.indigo,
                          () => _showReportsDialog(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickActionCard(
                          'Settings',
                          Icons.settings,
                          Colors.purple,
                          () => Get.to(() => const AdminSettingsView()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // System Management
                  const Text(
                    'System Management',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildManagementCard(
                    'User Management',
                    'Manage admin users and permissions',
                    Icons.people,
                    Colors.blue,
                    () => Get.to(() => const AdminUserManagementView()),
                  ),
                  const SizedBox(height: 12),
                  _buildManagementCard(
                    'Database Management',
                    'Backup, restore, and optimize database',
                    Icons.storage,
                    Colors.teal,
                    () => _showDatabaseDialog(context),
                  ),
                  const SizedBox(height: 12),
                  _buildManagementCard(
                    'Security Center',
                    'Security settings, logs, and monitoring',
                    Icons.security,
                    Colors.red,
                    () => _showSecurityDialog(context),
                  ),
                  const SizedBox(height: 12),
                  _buildManagementCard(
                    'Notification Center',
                    'Manage system-wide notifications',
                    Icons.notifications_active,
                    Colors.orange,
                    () => _showNotificationDialog(context),
                  ),
                  const SizedBox(height: 12),
                  _buildManagementCard(
                    'System Monitor',
                    'Real-time system health and performance',
                    Icons.monitor_heart,
                    Colors.green,
                    () => Get.to(() => const AdminSystemMonitorView()),
                  ),
                  const SizedBox(height: 12),
                  _buildManagementCard(
                    'System Logs',
                    'View and export system activity logs',
                    Icons.description,
                    Colors.purple,
                    () => _showLogsDialog(context),
                  ),
                  const SizedBox(height: 12),
                  _buildManagementCard(
                    'API Management',
                    'Manage API keys and integrations',
                    Icons.api,
                    Colors.green,
                    () => _showAPIDialog(context),
                  ),
                  const SizedBox(height: 24),

                  // System Information
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: Color(0xFFFF5722),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'System Information',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Obx(
                            () => Column(
                              children: [
                                _buildInfoRow('App Version', '1.0.0'),
                                _buildInfoRow('Last Login', 'Today at 9:30 AM'),
                                _buildInfoRow(
                                  'Total Users',
                                  '${adminController.totalStudents.value + adminController.totalStaff.value}',
                                ),
                                _buildInfoRow(
                                  'Active Sessions',
                                  '${adminController.activeUsers.value}',
                                ),
                                _buildInfoRow(
                                  'System Health',
                                  '${adminController.systemHealth.value.toStringAsFixed(1)}%',
                                ),
                                _buildInfoRow('Database Size', '2.4 GB'),
                                _buildInfoRow(
                                  'Server Status',
                                  'Online',
                                  isStatus: true,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _showLogoutDialog(context, authController),
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBadge(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManagementCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isStatus = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          isStatus
              ? Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      value,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ],
                )
              : Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthController authController) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.logout, color: Colors.red),
            SizedBox(width: 8),
            Text('Logout'),
          ],
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              authController.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showAddUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New User'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(),
                ),
                items: ['Student', 'Staff', 'Admin']
                    .map(
                      (role) =>
                          DropdownMenuItem(value: role, child: Text(role)),
                    )
                    .toList(),
                onChanged: (value) {},
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
              Get.snackbar('Success', 'User added successfully');
            },
            child: const Text('Add User'),
          ),
        ],
      ),
    );
  }

  void _showBackupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.backup, color: Colors.teal),
            SizedBox(width: 8),
            Text('Database Backup'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select backup options:'),
            const SizedBox(height: 12),
            CheckboxListTile(
              title: const Text('Include user data'),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('Include course data'),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('Include assessments'),
              value: true,
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Get.snackbar('Success', 'Backup started successfully');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            child: const Text('Start Backup'),
          ),
        ],
      ),
    );
  }

  void _showReportsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generate Reports'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.people, color: Colors.blue),
              title: const Text('User Activity Report'),
              onTap: () {
                Navigator.pop(context);
                Get.snackbar('Generating', 'User activity report...');
              },
            ),
            ListTile(
              leading: const Icon(Icons.school, color: Colors.green),
              title: const Text('Course Performance Report'),
              onTap: () {
                Navigator.pop(context);
                Get.snackbar('Generating', 'Course performance report...');
              },
            ),
            ListTile(
              leading: const Icon(Icons.assessment, color: Colors.orange),
              title: const Text('Assessment Analytics'),
              onTap: () {
                Navigator.pop(context);
                Get.snackbar('Generating', 'Assessment analytics...');
              },
            ),
            ListTile(
              leading: const Icon(Icons.trending_up, color: Colors.purple),
              title: const Text('System Usage Report'),
              onTap: () {
                Navigator.pop(context);
                Get.snackbar('Generating', 'System usage report...');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDatabaseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Database Management'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.backup, color: Colors.teal),
              title: const Text('Create Backup'),
              onTap: () {
                Navigator.pop(context);
                _showBackupDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.restore, color: Colors.blue),
              title: const Text('Restore from Backup'),
              onTap: () {
                Navigator.pop(context);
                Get.snackbar('Info', 'Restore feature coming soon');
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.cleaning_services,
                color: Colors.orange,
              ),
              title: const Text('Optimize Database'),
              onTap: () {
                Navigator.pop(context);
                Get.snackbar('Success', 'Database optimization started');
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_sweep, color: Colors.red),
              title: const Text('Clear Cache'),
              onTap: () {
                Navigator.pop(context);
                Get.snackbar('Success', 'Cache cleared successfully');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSecurityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Security Center'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Security Status',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildSecurityItem('Firewall', 'Active', Colors.green),
              _buildSecurityItem('SSL Certificate', 'Valid', Colors.green),
              _buildSecurityItem('2FA', 'Enabled', Colors.green),
              _buildSecurityItem(
                'Last Security Scan',
                '2 hours ago',
                Colors.blue,
              ),
              const Divider(height: 24),
              ListTile(
                leading: const Icon(Icons.vpn_key, color: Colors.orange),
                title: const Text('Change Admin Password'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.history, color: Colors.purple),
                title: const Text('View Security Logs'),
                onTap: () {},
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityItem(String label, String status, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(
                status,
                style: TextStyle(fontWeight: FontWeight.w600, color: color),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showNotificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Center'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.send, color: Colors.blue),
              title: const Text('Send Announcement'),
              subtitle: const Text('Broadcast to all users'),
              onTap: () {
                Navigator.pop(context);
                Get.snackbar('Info', 'Opening announcement composer...');
              },
            ),
            ListTile(
              leading: const Icon(Icons.schedule, color: Colors.orange),
              title: const Text('Schedule Notification'),
              subtitle: const Text('Set up automated messages'),
              onTap: () {
                Navigator.pop(context);
                Get.snackbar('Info', 'Opening scheduler...');
              },
            ),
            ListTile(
              leading: const Icon(Icons.history, color: Colors.purple),
              title: const Text('Notification History'),
              subtitle: const Text('View past notifications'),
              onTap: () {
                Navigator.pop(context);
                Get.snackbar('Info', 'Opening history...');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLogsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('System Logs'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              _buildLogItem(
                'User Login',
                'admin@jeduai.com logged in',
                '2 min ago',
              ),
              _buildLogItem(
                'Data Update',
                'Student records updated',
                '15 min ago',
              ),
              _buildLogItem(
                'Backup',
                'Automatic backup completed',
                '1 hour ago',
              ),
              _buildLogItem(
                'Security',
                'Security scan completed',
                '2 hours ago',
              ),
              _buildLogItem('System', 'Server restart', '5 hours ago'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.snackbar('Success', 'Logs exported successfully');
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  Widget _buildLogItem(String type, String message, String time) {
    return ListTile(
      leading: const Icon(Icons.circle, size: 8, color: Colors.blue),
      title: Text(type, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(message),
      trailing: Text(time, style: const TextStyle(fontSize: 12)),
    );
  }

  void _showAPIDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('API Management'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.key, color: Colors.green),
              title: const Text('Generate API Key'),
              onTap: () {
                Navigator.pop(context);
                Get.snackbar('Success', 'New API key generated');
              },
            ),
            ListTile(
              leading: const Icon(Icons.list, color: Colors.blue),
              title: const Text('View API Keys'),
              onTap: () {
                Navigator.pop(context);
                Get.snackbar('Info', 'Opening API keys list...');
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.integration_instructions,
                color: Colors.purple,
              ),
              title: const Text('Integration Settings'),
              onTap: () {
                Navigator.pop(context);
                Get.snackbar('Info', 'Opening integration settings...');
              },
            ),
            ListTile(
              leading: const Icon(Icons.analytics, color: Colors.orange),
              title: const Text('API Usage Analytics'),
              onTap: () {
                Navigator.pop(context);
                Get.snackbar('Info', 'Opening analytics...');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
