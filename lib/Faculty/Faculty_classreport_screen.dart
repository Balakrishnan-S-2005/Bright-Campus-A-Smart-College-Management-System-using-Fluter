import 'package:bpc/Faculty/Faculty_Studentattendancereport_screen.dart';
import 'package:bpc/Faculty/Faculty_Studentmarkreport_screen.dart';
import 'package:flutter/material.dart';


class ClassReportScreen extends StatelessWidget {
  final String className;

  ClassReportScreen({required this.className}); // Define className

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Class Report",style: TextStyle(color: Colors.white),),backgroundColor: Color(0xFF674AEF),),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildMenuItem(context, "Student Marks Report", FacultyStudentMarksTableScreen(className: className,)),
            _buildMenuItem(context, "Student Attendance Report", FacultyAttendancePercentageScreen(className: className,)),
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