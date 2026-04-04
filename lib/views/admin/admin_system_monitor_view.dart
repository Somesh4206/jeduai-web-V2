import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_controller.dart';

class AdminSystemMonitorView extends StatefulWidget {
  const AdminSystemMonitorView({super.key});

  @override
  State<AdminSystemMonitorView> createState() => _AdminSystemMonitorViewState();
}

class _AdminSystemMonitorViewState extends State<AdminSystemMonitorView> {
  final AdminController adminController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Monitor'),
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
              setState(() {});
              Get.snackbar('Refreshed', 'System data updated');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
          setState(() {});
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // System Health Overview
            _buildSectionHeader('System Health', Icons.health_and_safety),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildHealthIndicator(
                      'Server Status',
                      'Online',
                      100,
                      Colors.green,
                    ),
                    const SizedBox(height: 12),
                    _buildHealthIndicator(
                      'Database',
                      'Healthy',
                      95,
                      Colors.green,
                    ),
                    const SizedBox(height: 12),
                    _buildHealthIndicator(
                      'API Services',
                      'Running',
                      98,
                      Colors.green,
                    ),
                    const SizedBox(height: 12),
                    _buildHealthIndicator(
                      'Storage',
                      '65% Used',
                      65,
                      Colors.orange,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Resource Usage
            _buildSectionHeader('Resource Usage', Icons.memory),
            Row(
              children: [
                Expanded(
                  child: _buildResourceCard(
                    'CPU',
                    '45%',
                    Icons.computer,
                    Colors.blue,
                    0.45,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildResourceCard(
                    'Memory',
                    '6.2 GB',
                    Icons.memory,
                    Colors.purple,
                    0.62,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildResourceCard(
                    'Disk',
                    '2.4 GB',
                    Icons.storage,
                    Colors.orange,
                    0.65,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildResourceCard(
                    'Network',
                    '125 MB/s',
                    Icons.network_check,
                    Colors.green,
                    0.35,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Active Sessions
            _buildSectionHeader('Active Sessions', Icons.people_alt),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildSessionRow('Students', 856, Colors.blue),
                    const Divider(height: 24),
                    _buildSessionRow('Staff', 78, Colors.purple),
                    const Divider(height: 24),
                    _buildSessionRow('Admins', 3, Colors.orange),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Active',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '937',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Recent Activity
            _buildSectionHeader('Recent Activity', Icons.history),
            Card(
              child: Column(
                children: [
                  _buildActivityItem(
                    'User Login',
                    'student123@jeduai.com logged in',
                    '2 min ago',
                    Icons.login,
                    Colors.blue,
                  ),
                  const Divider(height: 1),
                  _buildActivityItem(
                    'Assessment Created',
                    'Physics Quiz by Teacher John',
                    '15 min ago',
                    Icons.assignment,
                    Colors.green,
                  ),
                  const Divider(height: 1),
                  _buildActivityItem(
                    'Data Backup',
                    'Automatic backup completed',
                    '1 hour ago',
                    Icons.backup,
                    Colors.teal,
                  ),
                  const Divider(height: 1),
                  _buildActivityItem(
                    'Security Scan',
                    'System security scan completed',
                    '2 hours ago',
                    Icons.security,
                    Colors.orange,
                  ),
                  const Divider(height: 1),
                  _buildActivityItem(
                    'User Registration',
                    '5 new students registered',
                    '3 hours ago',
                    Icons.person_add,
                    Colors.purple,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // System Alerts
            _buildSectionHeader('System Alerts', Icons.warning_amber),
            _buildAlertCard(
              'Storage Warning',
              'Storage usage is above 60%. Consider cleaning up old files.',
              Icons.storage,
              Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildAlertCard(
              'Backup Reminder',
              'Last manual backup was 7 days ago.',
              Icons.backup,
              Colors.blue,
            ),
            const SizedBox(height: 24),

            // Quick Actions
            _buildSectionHeader('Quick Actions', Icons.flash_on),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.snackbar(
                        'Backup Started',
                        'System backup in progress...',
                        backgroundColor: Colors.teal,
                        colorText: Colors.white,
                      );
                    },
                    icon: const Icon(Icons.backup),
                    label: const Text('Backup Now'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.snackbar(
                        'Cache Cleared',
                        'System cache cleared successfully',
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                      );
                    },
                    icon: const Icon(Icons.cleaning_services),
                    label: const Text('Clear Cache'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
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

  Widget _buildHealthIndicator(
    String label,
    String status,
    double percentage,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  status,
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildResourceCard(
    String label,
    String value,
    IconData icon,
    Color color,
    double usage,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: usage,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionRow(String label, int count, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontSize: 16)),
          ],
        ),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(
    String title,
    String description,
    String time,
    IconData icon,
    Color color,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(description),
      trailing: Text(
        time,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
    );
  }

  Widget _buildAlertCard(
    String title,
    String message,
    IconData icon,
    Color color,
  ) {
    return Card(
      color: color.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.bold, color: color),
                  ),
                  const SizedBox(height: 4),
                  Text(message, style: const TextStyle(fontSize: 13)),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: () {
                Get.snackbar('Dismissed', 'Alert dismissed');
              },
            ),
          ],
        ),
      ),
    );
  }
}
