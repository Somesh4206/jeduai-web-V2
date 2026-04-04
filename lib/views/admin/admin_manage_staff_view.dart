import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_controller.dart';

class AdminManageStaffView extends StatefulWidget {
  const AdminManageStaffView({super.key});

  @override
  State<AdminManageStaffView> createState() => _AdminManageStaffViewState();
}

class _AdminManageStaffViewState extends State<AdminManageStaffView> {
  final AdminController controller = Get.find();
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Staff'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search staff by name or subject...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          // Staff List
          Expanded(
            child: Obx(() {
              final staffList = controller.staffList.where((staff) {
                if (_searchQuery.isEmpty) return true;
                return staff['name'].toString().toLowerCase().contains(
                      _searchQuery,
                    ) ||
                    staff['subject'].toString().toLowerCase().contains(
                      _searchQuery,
                    );
              }).toList();

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: staffList.length,
                itemBuilder: (context, index) {
                  final staff = staffList[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.deepPurple,
                        child: Text(
                          staff['name'].toString()[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        staff['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Subject: ${staff['subject']}'),
                          Text('Email: ${staff['email']}'),
                          Text('Classes: ${staff['classes']}'),
                        ],
                      ),
                      trailing: PopupMenuButton(
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 20),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 20, color: Colors.red),
                                SizedBox(width: 8),
                                Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showEditStaffDialog(staff);
                          } else if (value == 'delete') {
                            _showDeleteConfirmation(staff['id']);
                          }
                        },
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddStaffDialog,
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.add),
        label: const Text('Add Staff'),
      ),
    );
  }

  void _showAddStaffDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final subjectController = TextEditingController();
    final classesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Staff'),
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
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: subjectController,
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: classesController,
                decoration: const InputDecoration(
                  labelText: 'Classes (comma separated)',
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
            onPressed: () {
              controller.addStaff({
                'name': nameController.text,
                'email': emailController.text,
                'subject': subjectController.text,
                'classes': classesController.text,
              });
              Navigator.pop(context);
              Get.snackbar('Success', 'Staff added successfully');
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditStaffDialog(Map<String, dynamic> staff) {
    final nameController = TextEditingController(text: staff['name']);
    final emailController = TextEditingController(text: staff['email']);
    final subjectController = TextEditingController(text: staff['subject']);
    final classesController = TextEditingController(text: staff['classes']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Staff'),
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
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: subjectController,
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: classesController,
                decoration: const InputDecoration(
                  labelText: 'Classes (comma separated)',
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
            onPressed: () {
              controller.updateStaff(staff['id'], {
                'name': nameController.text,
                'email': emailController.text,
                'subject': subjectController.text,
                'classes': classesController.text,
              });
              Navigator.pop(context);
              Get.snackbar('Success', 'Staff updated successfully');
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(String staffId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Staff'),
        content: const Text(
          'Are you sure you want to delete this staff member?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.deleteStaff(staffId);
              Navigator.pop(context);
              Get.snackbar('Success', 'Staff deleted successfully');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
