import 'package:flutter/material.dart';

class AdminManageStudentsView extends StatelessWidget {
  const AdminManageStudentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Students')),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          ElevatedButton(onPressed: () {}, child: Text('Add Student')),
          SizedBox(height: 20),
          Text(
            'Student List',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Card(
            child: ListTile(
              title: Text('Student 1'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: Icon(Icons.edit), onPressed: () {}),
                  IconButton(icon: Icon(Icons.delete), onPressed: () {}),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
