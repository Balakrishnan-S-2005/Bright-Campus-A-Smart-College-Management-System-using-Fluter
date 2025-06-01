import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'Faculty_markentryscreen2.dart';



class StudentListScreen extends StatelessWidget {
  final String className;
  final String subjectName;

  StudentListScreen({required this.className, required this.subjectName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Students - $subjectName",style: TextStyle(color: Colors.white),),backgroundColor: Color(0xFF674AEF),),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('students')
            .where('class', isEqualTo: className)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
                      builder: (context) => MarkEntryScreen(
                        studentId: student.id,
                        studentName: student['name'],
                        className: className,
                        subjectName: subjectName,
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