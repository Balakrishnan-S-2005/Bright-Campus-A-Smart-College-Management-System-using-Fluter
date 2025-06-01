import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'Faculty_attendance1_screen.dart';

class StudentListScreen extends StatelessWidget {
  final String className; // Use className instead of classId

  StudentListScreen({required this.className});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("$className - Students",style: TextStyle(color: Colors.white),),backgroundColor: Color(0xFF674AEF),),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('students')
            .where('class', isEqualTo: className) // Filter by className
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          var students = snapshot.data!.docs;

          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              var student = students[index];
              return ListTile(
                title: Text(student['name']),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AttendanceScreen(
                        studentName: student['name'],
                        className: className, // Pass className
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}