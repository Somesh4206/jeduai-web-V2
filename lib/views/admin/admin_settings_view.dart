import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_controller.dart';

class AdminSettingsView extends StatefulWidget {
  const AdminSettingsView({super.key});

  @override
  State<AdminSettingsView> createState() => _AdminSettingsViewState();
}

class _AdminSettingsViewState extends State<AdminSettingsView> {
  final AdminController adminController = Get.find();

  bool emailNotifications = true;
  bool pushNotifications = true;
  bool autoBackup = true;
  bool maintenanceMode = false;
  bool twoFactorAuth = true;
  bool darkMode = false;

  String selectedLanguage = 'English';
  String selectedTimezone = 'UTC+5:30';
  int sessionTimeout = 30;
  int maxUploadSize = 50;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Settings'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF5722), Color(0xFFFF9800)],
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // General Settings
          _buildSectionHeader('General Settings', Icons.settings),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Email Notifications'),
                  subtitle: const Text(
                    'Receive email alerts for important events',
                  ),
                  value: emailNotifications,
                  onChanged: (value) =>
                      setState(() => emailNotifications = value),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Push Notifications'),
                  subtitle: const Text('Receive push notifications'),
                  value: pushNotifications,
                  onChanged: (value) =>
                      setState(() => pushNotifications = value),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Language'),
                  subtitle: Text(selectedLanguage),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showLanguageDialog(),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Timezone'),
                  subtitle: Text(selectedTimezone),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showTimezoneDialog(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // System Settings
          _buildSectionHeader('System Settings', Icons.computer),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Auto Backup'),
                  subtitle: const Text('Automatically backup data daily'),
                  value: autoBackup,
                  onChanged: (value) => setState(() => autoBackup = value),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Maintenance Mode'),
                  subtitle: const Text('Restrict access for maintenance'),
                  value: maintenanceMode,
                  onChanged: (value) => setState(() => maintenanceMode = value),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Session Timeout'),
                  subtitle: Text('$sessionTimeout minutes'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showSessionTimeoutDialog(),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Max Upload Size'),
                  subtitle: Text('$maxUploadSize MB'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showUploadSizeDialog(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Security Settings
          _buildSectionHeader('Security Settings', Icons.security),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Two-Factor Authentication'),
                  subtitle: const Text('Require 2FA for admin login'),
                  value: twoFactorAuth,
                  onChanged: (value) => setState(() => twoFactorAuth = value),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Change Password'),
                  subtitle: const Text('Update admin password'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showChangePasswordDialog(),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Security Logs'),
                  subtitle: const Text('View security activity'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Get.snackbar('Info', 'Opening security logs...');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Appearance
          _buildSectionHeader('Appearance', Icons.palette),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Use dark theme'),
                  value: darkMode,
                  onChanged: (value) => setState(() => darkMode = value),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Data Management
          _buildSectionHeader('Data Management', Icons.storage),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.backup, color: Colors.teal),
                  title: const Text('Backup Now'),
                  subtitle: const Text('Create manual backup'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Get.snackbar('Success', 'Backup started successfully');
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.restore, color: Colors.blue),
                  title: const Text('Restore Data'),
                  subtitle: const Text('Restore from backup'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Get.snackbar('Info', 'Opening restore options...');
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.cleaning_services,
                    color: Colors.orange,
                  ),
                  title: const Text('Clear Cache'),
                  subtitle: const Text('Free up storage space'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Get.snackbar('Success', 'Cache cleared successfully');
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.download, color: Colors.purple),
                  title: const Text('Export Data'),
                  subtitle: const Text('Download all data'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Get.snackbar('Info', 'Preparing data export...');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Get.snackbar(
                  'Success',
                  'Settings saved successfully',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              },
              icon: const Icon(Icons.save),
              label: const Text('Save Settings'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF5722),
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
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFF5722)),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['English', 'Hindi', 'Spanish', 'French', 'German'].map((
            lang,
          ) {
            return RadioListTile<String>(
              title: Text(lang),
              value: lang,
              groupValue: selectedLanguage,
              onChanged: (value) {
                setState(() => selectedLanguage = value!);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showTimezoneDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Timezone'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children:
              [
                'UTC+5:30 (IST)',
                'UTC+0:00 (GMT)',
                'UTC-5:00 (EST)',
                'UTC-8:00 (PST)',
              ].map((tz) {
                return RadioListTile<String>(
                  title: Text(tz),
                  value: tz,
                  groupValue: selectedTimezone,
                  onChanged: (value) {
                    setState(() => selectedTimezone = value!);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
        ),
      ),
    );
  }

  void _showSessionTimeoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Session Timeout'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [15, 30, 60, 120].map((minutes) {
            return RadioListTile<int>(
              title: Text('$minutes minutes'),
              value: minutes,
              groupValue: sessionTimeout,
              onChanged: (value) {
                setState(() => sessionTimeout = value!);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showUploadSizeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Max Upload Size'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [10, 25, 50, 100, 200].map((size) {
            return RadioListTile<int>(
              title: Text('$size MB'),
              value: size,
              groupValue: maxUploadSize,
              onChanged: (value) {
                setState(() => maxUploadSize = value!);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm Password',
                border: OutlineInputBorder(),
              ),
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
              if (newPasswordController.text ==
                  confirmPasswordController.text) {
                Navigator.pop(context);
                Get.snackbar('Success', 'Password changed successfully');
              } else {
                Get.snackbar('Error', 'Passwords do not match');
              }
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }
}
