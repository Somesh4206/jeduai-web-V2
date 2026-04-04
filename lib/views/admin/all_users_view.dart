import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

class AllUsersView extends StatefulWidget {
  const AllUsersView({super.key});

  @override
  State<AllUsersView> createState() => _AllUsersViewState();
}

class _AllUsersViewState extends State<AllUsersView> {
  List<Map<String, dynamic>> allUsers = [];
  bool isLoading = true;
  String selectedRole = 'all';

  @override
  void initState() {
    super.initState();
    loadAllUsers();
  }

  Future<void> loadAllUsers() async {
    setState(() => isLoading = true);

    try {
      List<Map<String, dynamic>> users = [];

      // Try to load from Firestore first
      try {
        final FirebaseFirestore firestore = FirebaseFirestore.instance;

        // Fetch from all role-specific collections
        final studentsSnapshot = await firestore.collection('students').get();
        final staffSnapshot = await firestore.collection('staff').get();
        final adminsSnapshot = await firestore.collection('admins').get();

        // Add students
        for (var doc in studentsSnapshot.docs) {
          users.add({
            ...doc.data(),
            'uid': doc.id,
            'source': 'firebase',
          });
        }

        // Add staff
        for (var doc in staffSnapshot.docs) {
          users.add({
            ...doc.data(),
            'uid': doc.id,
            'source': 'firebase',
          });
        }

        // Add admins
        for (var doc in adminsSnapshot.docs) {
          users.add({
            ...doc.data(),
            'uid': doc.id,
            'source': 'firebase',
          });
        }

        print('✅ Loaded ${users.length} users from Firestore');
      } catch (firebaseError) {
        print('⚠️ Firestore error: $firebaseError');
        print('🔄 Falling back to local storage...');

        // Fallback to local storage
        final prefs = await SharedPreferences.getInstance();
        final usersJson = prefs.getString('local_users') ?? '[]';
        final List<dynamic> localUsers = jsonDecode(usersJson);

        users = localUsers
            .map((u) => {
                  ...Map<String, dynamic>.from(u),
                  'source': 'local',
                })
            .toList();

        print('✅ Loaded ${users.length} users from local storage');
      }

      setState(() {
        allUsers = users;
        isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading users: $e');
      setState(() => isLoading = false);
    }
  }

  List<Map<String, dynamic>> get filteredUsers {
    if (selectedRole == 'all') return allUsers;
    return allUsers.where((u) => u['role'] == selectedRole).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Users Database'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadAllUsers,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Statistics Header
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.blue.shade50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatChip(
                        'Total',
                        allUsers.length.toString(),
                        Colors.blue,
                      ),
                      _buildStatChip(
                        'Students',
                        allUsers
                            .where((u) => u['role'] == 'student')
                            .length
                            .toString(),
                        Colors.green,
                      ),
                      _buildStatChip(
                        'Staff',
                        allUsers
                            .where((u) => u['role'] == 'staff')
                            .length
                            .toString(),
                        Colors.orange,
                      ),
                      _buildStatChip(
                        'Admins',
                        allUsers
                            .where((u) => u['role'] == 'admin')
                            .length
                            .toString(),
                        Colors.red,
                      ),
                    ],
                  ),
                ),

                // Filter Chips
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All', 'all'),
                        _buildFilterChip('Students', 'student'),
                        _buildFilterChip('Staff', 'staff'),
                        _buildFilterChip('Admins', 'admin'),
                      ],
                    ),
                  ),
                ),

                // Users List
                Expanded(
                  child: filteredUsers.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 64,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No users found',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = filteredUsers[index];
                            return _buildUserCard(user);
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showDatabaseInfo(context),
        icon: const Icon(Icons.info_outline),
        label: const Text('Database Info'),
        backgroundColor: const Color(0xFF2196F3),
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String role) {
    final isSelected = selectedRole == role;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => selectedRole = role);
        },
        selectedColor: Colors.blue.shade100,
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final roleColor = _getRoleColor(user['role']);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 2,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: roleColor,
          child: Text(
            (user['name'] ?? 'U')[0].toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          user['name'] ?? 'Unknown',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(user['email'] ?? 'No email'),
        trailing: Chip(
          label: Text(
            (user['role'] ?? 'unknown').toUpperCase(),
            style: const TextStyle(fontSize: 10, color: Colors.white),
          ),
          backgroundColor: roleColor,
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('User ID', user['uid'] ?? 'N/A'),
                _buildInfoRow('Email', user['email'] ?? 'N/A'),
                _buildInfoRow('Role', user['role'] ?? 'N/A'),
                _buildInfoRow('Created', _formatTimestamp(user['createdAt'])),
                _buildInfoRow('Source', _getDataSource(user)),
                if (user['department'] != null)
                  _buildInfoRow('Department', user['department']),
                if (user['year'] != null) _buildInfoRow('Year', user['year']),
                if (user['section'] != null)
                  _buildInfoRow('Section', user['section']),
                if (user['designation'] != null)
                  _buildInfoRow('Designation', user['designation']),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _showUserDetails(user),
                      icon: const Icon(Icons.visibility),
                      label: const Text('View Full Data'),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => _deleteUser(user),
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
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

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    
    try {
      DateTime date;
      if (timestamp is Timestamp) {
        date = timestamp.toDate();
      } else if (timestamp is String) {
        date = DateTime.parse(timestamp);
      } else {
        return 'N/A';
      }
      
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'N/A';
    }
  }

  Color _getRoleColor(String? role) {
    switch (role?.toLowerCase()) {
      case 'student':
        return Colors.green;
      case 'staff':
        return Colors.orange;
      case 'admin':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getDataSource(Map<String, dynamic> user) {
    return user['source'] == 'firebase' ? 'Cloud (Firebase)' : 'Local Storage';
  }

  void _showUserDetails(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${user['name']} - Full Data'),
        content: SingleChildScrollView(
          child: SelectableText(
            const JsonEncoder.withIndent('  ').convert(user),
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
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

  void _deleteUser(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performDelete(user);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _performDelete(Map<String, dynamic> user) async {
    try {
      final source = user['source'] ?? 'local';

      if (source == 'firebase') {
        // Delete from Firestore
        final FirebaseFirestore firestore = FirebaseFirestore.instance;
        final role = user['role']?.toLowerCase() ?? '';

        if (role == 'student') {
          await firestore.collection('students').doc(user['uid']).delete();
        } else if (role == 'staff') {
          await firestore.collection('staff').doc(user['uid']).delete();
        } else if (role == 'admin') {
          await firestore.collection('admins').doc(user['uid']).delete();
        }

        // Also delete from users collection
        await firestore.collection('users').doc(user['uid']).delete();

        // Delete from Firebase Auth if possible
        // Note: This requires admin SDK, so we skip it for now
        print('✅ User deleted from Firestore');
      } else {
        // Delete from local storage
        final prefs = await SharedPreferences.getInstance();
        final usersJson = prefs.getString('local_users') ?? '[]';
        final List<dynamic> users = jsonDecode(usersJson);

        users.removeWhere((u) => u['uid'] == user['uid']);

        await prefs.setString('local_users', jsonEncode(users));
        print('✅ User deleted from local storage');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${user['name']} deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }

      await loadAllUsers();
    } catch (e) {
      print('❌ Error deleting user: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting user: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDatabaseInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.storage, color: Color(0xFF2196F3)),
            SizedBox(width: 8),
            Text('Database Information'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Storage Type:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text('Local Storage (SharedPreferences)'),
              const SizedBox(height: 12),
              const Text(
                'Storage Key:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text('local_users'),
              const SizedBox(height: 12),
              const Text(
                'Location:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text('Device local storage'),
              const SizedBox(height: 12),
              const Text(
                'Access:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text(
                '• Android: /data/data/com.example.jeduai_app1/shared_prefs/',
              ),
              const Text('• iOS: Library/Preferences/'),
              const Text('• Web: Browser LocalStorage'),
              const SizedBox(height: 12),
              const Text(
                'Note:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const Text(
                'This view shows users from both Firebase Cloud and Local Storage. Users with "Source: Cloud (Firebase)" are synced across all devices.',
                style: TextStyle(fontSize: 12),
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
}
