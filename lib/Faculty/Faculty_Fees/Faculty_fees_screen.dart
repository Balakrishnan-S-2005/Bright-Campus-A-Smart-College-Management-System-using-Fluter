import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Faculty_Studentlist_screen.dart';


class FacultyFeesScreen extends StatefulWidget {
  final String className; // Class name selected by faculty
  FacultyFeesScreen({required this.className});

  @override
  _FacultyFeesScreenState createState() => _FacultyFeesScreenState();
}

class _FacultyFeesScreenState extends State<FacultyFeesScreen> {
  String? selectedStudent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Student Fees - ${widget.className}",style: TextStyle(color: Colors.white),),backgroundColor: Color(0xFF674AEF),),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("students")
            .where("class", isEqualTo: widget.className) // Fetch students of selected class
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No students found"));
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              String studentName = doc.id; // Student doc ID = Name

              return ListTile(
                title: Text(studentName),
                onTap: () {
                  setState(() {
                    selectedStudent = studentName;
                  });
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StudentFeesDetailsScreen(studentName: studentName),
                    ),
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}