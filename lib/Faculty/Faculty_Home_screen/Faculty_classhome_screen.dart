import 'package:bpc/Faculty/Faculty_Attendance/Faculty_attendance_screen.dart';
import 'package:bpc/Faculty/Faculty_Fees/Faculty_fees_screen.dart';
import 'package:bpc/Faculty/Faculty_classreport_screen.dart';
import 'package:bpc/Faculty/Faculty_classroutine_screen.dart';
import 'package:bpc/Faculty/Faculty_studentmanagement_screen.dart';
import 'package:flutter/material.dart';

import '../Faculty_markentry_screen/Faculty_markentryscreen1.dart';


class ClassHomeScreen extends StatelessWidget {
  final String className;

  ClassHomeScreen({required this.className}); // Define className

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("$className - Home",style: TextStyle(color: Colors.white),),backgroundColor: Color(0xFF674AEF),),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildMenuItem(context, "Mark Attendance", StudentListScreen(className: className,)),
            _buildMenuItem(context, "Student Marks", FacultyMarkEntryScreen(className: className)),
            _buildMenuItem(context, "Manage Students", StudentManagementScreen(className: className)),
            _buildMenuItem(context, "Class Routine", UpdateRoutineScreen()),
            _buildMenuItem(context, "Student Fees", FacultyFeesScreen(className: className,)),
            _buildMenuItem(context, "Class Report", ClassReportScreen(className: className,)),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, Widget screen) {
    return Card(
      child: ListTile(
        title: Text(title),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
        },
      ),
    );
  }
}