import 'package:flutter/material.dart';

import 'Admin_Facultyassignment_screen.dart';
import 'Admin_Studentoverview_screen.dart';
 // Import the AddFacultyScreen

class ClassDetailScreen extends StatelessWidget {
  final String className;

  ClassDetailScreen({required this.className});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(className,style: TextStyle(color: Colors.white),),
        backgroundColor: Color(0xFF674AEF),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          ListTile(
            leading: Icon(Icons.person_add, color: Colors.blue),
            title: Text("Assign Faculty"),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddFacultyScreen(className: className),
                ),
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.group, color: Colors.green),
            title: Text("Student Overview"),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StudentOverviewScreen(className: className),
                ),
              );// Navigate to Student Overview Screen (Implement separately)
            },
          ),
        ],
      ),
    );
  }
}