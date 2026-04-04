import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_controller.dart';

class AdminUserManagementView extends StatefulWidget {
  const AdminUserManagementView({super.key});

  @override
  State<AdminUserManagementView> createState() =>
      _AdminUserManagementViewState();
}

class _AdminUserManagementViewState extends State<AdminUserManagementView>
    with SingleTickerProviderStateMixin {
  final AdminController adminController = Get.find();
  late TabController _tabController;
  String searchQuery = '';
  String selectedRole = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        title: const Text('User Management'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF5722), Color(0xFFFF9800)],
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.people), text: 'All Users'),
            Tab(icon: Icon(Icons.admin_panel_settings), text: 'Admins'),
            Tab(icon: Icon(Icons.person_add), text: 'Add User'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildAllUsersTab(), _buildAdminsTab(), _buildAddUserTab()],
      ),
    );
  }

  Widget _buildAllUsersTab() {
    return Column(
      children: [
        // Search and Filter Bar
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey.shade100,
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search users...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) => setState(() => searchQuery = value),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: selectedRole,
                      decoration: InputDecoration(
                        labelText: 'Filter by Role',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: ['All', 'Student', 'Staff', 'Admin']
                          .map(
                            (role) => DropdownMenuItem(
                              value: role,
                              child: Text(role),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => selectedRole = value!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        searchQuery = '';
                        selectedRole = 'All';
                      });
                    },
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // User Statistics
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Users',
                  '1,335',
                  Icons.people,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Active',
                  '1,180',
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Inactive',
                  '155',
                  Icons.cancel,
                  Colors.orange,
                ),
              ),
            ],
          ),
        ),

        // Users List
        Expanded(
          child: Obx(() {
            final allUsers = [
              ...adminController.students.map((s) => {...s, 'role': 'Student'}),
              ...adminController.staff.map((s) => {...s, 'role': 'Staff'}),
            ];

            final filteredUsers = allUsers.where((user) {
              final matchesSearch =
                  user['name'].toString().toLowerCase().contains(
                    searchQuery.toLowerCase(),
                  ) ||
                  user['email'].toString().toLowerCase().contains(
                    searchQuery.toLowerCase(),
                  );
              final matchesRole =
                  selectedRole == 'All' || user['role'] == selectedRole;
              return matchesSearch && matchesRole;
            }).toList();

            if (filteredUsers.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No users found',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredUsers.length,
              itemBuilder: (context, index) {
                final user = filteredUsers[index];
                return _buildUserCard(user);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildAdminsTab() {
    final admins = [
      {
        'id': 'ADM001',
        'name': 'System Administrator',
        'email': 'admin@jeduai.com',
        'role': 'Super Admin',
        'permissions': 'All',
        'lastLogin': 'Today at 9:30 AM',
        'status': 'Active',
      },
      {
        'id': 'ADM002',
        'name': 'John Manager',
        'email': 'john.manager@jeduai.com',
        'role': 'Admin',
        'permissions': 'User Management, Reports',
        'lastLogin': 'Yesterday at 3:45 PM',
        'status': 'Active',
      },
      {
        'id': 'ADM003',
        'name': 'Sarah Coordinator',
        'email': 'sarah.coord@jeduai.com',
        'role': 'Admin',
        'permissions': 'Course Management',
        'lastLogin': '2 days ago',
        'status': 'Active',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: admins.length,
      itemBuilder: (context, index) {
        final admin = admins[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFFFF5722),
                      child: Text(
                        admin['name']!.substring(0, 1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            admin['name']!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            admin['email']!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: admin['role'] == 'Super Admin'
                            ? Colors.red.withValues(alpha: 0.1)
                            : Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        admin['role']!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: admin['role'] == 'Super Admin'
                              ? Colors.red
                              : Colors.orange,
                        ),
                      ),
                    ),
                    PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 18),
                              SizedBox(width: 8),
                              Text('Edit Permissions'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'disable',
                          child: Row(
                            children: [
                              Icon(Icons.block, size: 18, color: Colors.orange),
                              SizedBox(width: 8),
                              Text('Disable Account'),
                            ],
                          ),
                        ),
                        if (admin['role'] != 'Super Admin')
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 18, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Remove Admin'),
                              ],
                            ),
                          ),
                      ],
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showEditPermissionsDialog(admin);
                        } else if (value == 'delete') {
                          _showDeleteConfirmation(admin['name']!);
                        }
                      },
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        'Permissions',
                        admin['permissions']!,
                        Icons.security,
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        'Last Login',
                        admin['lastLogin']!,
                        Icons.access_time,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddUserTab() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    String selectedUserRole = 'Student';
    String selectedClass = 'Class 10';
    String selectedSubject = 'Mathematics';

    return StatefulBuilder(
      builder: (context, setModalState) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Add New User',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedUserRole,
                decoration: InputDecoration(
                  labelText: 'Role',
                  prefixIcon: const Icon(Icons.badge),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: ['Student', 'Staff', 'Admin']
                    .map(
                      (role) =>
                          DropdownMenuItem(value: role, child: Text(role)),
                    )
                    .toList(),
                onChanged: (value) {
                  setModalState(() => selectedUserRole = value!);
                },
              ),
              const SizedBox(height: 16),
              if (selectedUserRole == 'Student')
                DropdownButtonFormField<String>(
                  initialValue: selectedClass,
                  decoration: InputDecoration(
                    labelText: 'Class',
                    prefixIcon: const Icon(Icons.school),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: List.generate(7, (i) => 'Class ${i + 6}')
                      .map(
                        (cls) => DropdownMenuItem(value: cls, child: Text(cls)),
                      )
                      .toList(),
                  onChanged: (value) {
                    setModalState(() => selectedClass = value!);
                  },
                ),
              if (selectedUserRole == 'Staff')
                DropdownButtonFormField<String>(
                  initialValue: selectedSubject,
                  decoration: InputDecoration(
                    labelText: 'Subject',
                    prefixIcon: const Icon(Icons.book),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items:
                      [
                            'Mathematics',
                            'Physics',
                            'Chemistry',
                            'Biology',
                            'English',
                            'Computer Science',
                          ]
                          .map(
                            (subject) => DropdownMenuItem(
                              value: subject,
                              child: Text(subject),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    setModalState(() => selectedSubject = value!);
                  },
                ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  if (nameController.text.isEmpty ||
                      emailController.text.isEmpty ||
                      passwordController.text.isEmpty) {
                    Get.snackbar(
                      'Error',
                      'Please fill all required fields',
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                    return;
                  }

                  final newUser = {
                    'id': 'USR${DateTime.now().millisecondsSinceEpoch}',
                    'name': nameController.text,
                    'email': emailController.text,
                    'role': selectedUserRole,
                    if (selectedUserRole == 'Student') 'class': selectedClass,
                    if (selectedUserRole == 'Staff') 'subject': selectedSubject,
                    'status': 'Active',
                    'joinDate': DateTime.now().toString().substring(0, 10),
                  };

                  if (selectedUserRole == 'Student') {
                    adminController.addStudent(newUser);
                  } else if (selectedUserRole == 'Staff') {
                    adminController.addStaff(newUser);
                  }

                  nameController.clear();
                  emailController.clear();
                  passwordController.clear();

                  Get.snackbar(
                    'Success',
                    'User added successfully',
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                  );

                  _tabController.animateTo(0);
                },
                icon: const Icon(Icons.person_add),
                label: const Text('Add User'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5722),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final roleColor = user['role'] == 'Student'
        ? Colors.blue
        : user['role'] == 'Staff'
        ? Colors.purple
        : Colors.orange;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: roleColor.withValues(alpha: 0.2),
          child: Text(
            user['name'].toString().substring(0, 1),
            style: TextStyle(color: roleColor, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          user['name'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user['email']),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: roleColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    user['role'],
                    style: TextStyle(
                      fontSize: 11,
                      color: roleColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (user['class'] != null)
                  Text(user['class'], style: const TextStyle(fontSize: 11)),
                if (user['subject'] != null)
                  Text(user['subject'], style: const TextStyle(fontSize: 11)),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
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
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 18),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'reset',
              child: Row(
                children: [
                  Icon(Icons.lock_reset, size: 18, color: Colors.orange),
                  SizedBox(width: 8),
                  Text('Reset Password'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 18, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete'),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'view') {
              _showUserDetails(user);
            } else if (value == 'delete') {
              _showDeleteUserConfirmation(user);
            } else if (value == 'reset') {
              Get.snackbar(
                'Success',
                'Password reset link sent to ${user['email']}',
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showUserDetails(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('ID', user['id']),
            _buildDetailRow('Email', user['email']),
            _buildDetailRow('Role', user['role']),
            if (user['class'] != null) _buildDetailRow('Class', user['class']),
            if (user['subject'] != null)
              _buildDetailRow('Subject', user['subject']),
            _buildDetailRow('Status', user['status'] ?? 'Active'),
            _buildDetailRow('Join Date', user['joinDate'] ?? 'N/A'),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showDeleteUserConfirmation(Map<String, dynamic> user) {
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
            onPressed: () {
              if (user['role'] == 'Student') {
                adminController.deleteStudent(user['id']);
              } else if (user['role'] == 'Staff') {
                adminController.deleteStaff(user['id']);
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showEditPermissionsDialog(Map<String, dynamic> admin) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Permissions - ${admin['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: const Text('User Management'),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('Course Management'),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('Reports & Analytics'),
              value: false,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('System Settings'),
              value: false,
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
              Get.snackbar(
                'Success',
                'Permissions updated successfully',
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Admin'),
        content: Text('Are you sure you want to remove $name as admin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Get.snackbar(
                'Success',
                'Admin removed successfully',
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}
