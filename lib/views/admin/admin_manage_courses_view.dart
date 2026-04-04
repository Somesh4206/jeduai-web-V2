import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_controller.dart';

class AdminManageCoursesView extends StatefulWidget {
  const AdminManageCoursesView({super.key});

  @override
  State<AdminManageCoursesView> createState() => _AdminManageCoursesViewState();
}

class _AdminManageCoursesViewState extends State<AdminManageCoursesView> {
  final AdminController controller = Get.find();
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Courses'),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search courses...',
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
          // Courses Grid
          Expanded(
            child: Obx(() {
              final coursesList = controller.coursesList.where((course) {
                if (_searchQuery.isEmpty) return true;
                return course['name'].toString().toLowerCase().contains(
                      _searchQuery,
                    ) ||
                    course['instructor'].toString().toLowerCase().contains(
                      _searchQuery,
                    );
              }).toList();

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                itemCount: coursesList.length,
                itemBuilder: (context, index) {
                  final course = coursesList[index];
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: () => _showCourseDetails(course),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.teal.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.book,
                                    color: Colors.teal,
                                    size: 24,
                                  ),
                                ),
                                PopupMenuButton(
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
                                          Icon(
                                            Icons.delete,
                                            size: 20,
                                            color: Colors.red,
                                          ),
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
                                      _showEditCourseDialog(course);
                                    } else if (value == 'delete') {
                                      _showDeleteConfirmation(course['id']);
                                    }
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              course['name'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Instructor: ${course['instructor']}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${course['enrolled']} enrolled',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    Text(
                                      '${course['duration']}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: course['status'] == 'Active'
                                        ? Colors.green.withOpacity(0.1)
                                        : Colors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    course['status'],
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: course['status'] == 'Active'
                                          ? Colors.green
                                          : Colors.orange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
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
        onPressed: _showAddCourseDialog,
        backgroundColor: Colors.teal,
        icon: const Icon(Icons.add),
        label: const Text('Add Course'),
      ),
    );
  }

  void _showCourseDetails(Map<String, dynamic> course) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(course['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Instructor: ${course['instructor']}'),
            const SizedBox(height: 8),
            Text('Duration: ${course['duration']}'),
            const SizedBox(height: 8),
            Text('Enrolled Students: ${course['enrolled']}'),
            const SizedBox(height: 8),
            Text('Status: ${course['status']}'),
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

  void _showAddCourseDialog() {
    final nameController = TextEditingController();
    final instructorController = TextEditingController();
    final durationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Course'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Course Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: instructorController,
                decoration: const InputDecoration(
                  labelText: 'Instructor',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: durationController,
                decoration: const InputDecoration(
                  labelText: 'Duration (e.g., 12 weeks)',
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
              controller.addCourse({
                'name': nameController.text,
                'instructor': instructorController.text,
                'duration': durationController.text,
              });
              Navigator.pop(context);
              Get.snackbar('Success', 'Course added successfully');
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditCourseDialog(Map<String, dynamic> course) {
    final nameController = TextEditingController(text: course['name']);
    final instructorController = TextEditingController(
      text: course['instructor'],
    );
    final durationController = TextEditingController(text: course['duration']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Course'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Course Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: instructorController,
                decoration: const InputDecoration(
                  labelText: 'Instructor',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: durationController,
                decoration: const InputDecoration(
                  labelText: 'Duration',
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
              controller.updateCourse(course['id'], {
                'name': nameController.text,
                'instructor': instructorController.text,
                'duration': durationController.text,
              });
              Navigator.pop(context);
              Get.snackbar('Success', 'Course updated successfully');
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(String courseId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Course'),
        content: const Text('Are you sure you want to delete this course?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.deleteCourse(courseId);
              Navigator.pop(context);
              Get.snackbar('Success', 'Course deleted successfully');
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
