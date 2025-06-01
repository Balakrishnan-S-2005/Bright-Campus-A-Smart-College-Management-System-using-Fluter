import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentOverviewScreen extends StatelessWidget {
  final String className;

  StudentOverviewScreen({required this.className});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Student Overview - $className", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF674AEF),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('students')
            .where('class', isEqualTo: className)
            .snapshots(),
        builder: (context, studentSnapshot) {
          if (studentSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!studentSnapshot.hasData || studentSnapshot.data!.docs.isEmpty) {
            return Center(child: Text("No students found in this class."));
          }

          var students = studentSnapshot.data!.docs;

          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              var student = students[index];
              var studentData = student.data() as Map<String, dynamic>;
              String studentName = studentData['name'];
              String studentId = studentData['id'];
              List<dynamic> marks = studentData['marks'] ?? [];

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('attendance')
                    .doc("${className}_${studentName}") // Fetch attendance using className_studentName
                    .get(),
                builder: (context, attendanceSnapshot) {
                  double attendancePercentage = 0.0;

                  if (attendanceSnapshot.connectionState == ConnectionState.done &&
                      attendanceSnapshot.data != null &&
                      attendanceSnapshot.data!.exists) {
                    var attendanceData = attendanceSnapshot.data!.data() as Map<String, dynamic>;
                    attendancePercentage = (attendanceData['attendancePercentage'] ?? 0.0);
                  }

                  return Card(
                    margin: EdgeInsets.all(10),
                    child: ExpansionTile(
                      title: Text(
                        studentName,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text("Attendance: ${attendancePercentage.toStringAsFixed(2)}%"),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Student ID: $studentId", style: TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(height: 5),
                              Text("Attendance Percentage: ${attendancePercentage.toStringAsFixed(2)}%"),
                              SizedBox(height: 10),
                              Text("Marks:", style: TextStyle(fontWeight: FontWeight.bold)),

                              // **Scrollable Section for Marks**
                              Container(
                                height: 150, // Set a fixed height for scrolling
                                child: Scrollbar(
                                  thumbVisibility: true,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: marks.map((mark) {
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 8.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Subject: ${mark['subject']}",
                                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                              ),
                                              SizedBox(height: 5),
                                              Text("IA 1: ${mark['IA 1']}"),
                                              Text("IA 2: ${mark['IA 2']}"),
                                              Text("Model: ${mark['Model']}"),
                                              Text("Semester: ${mark['Semester']}"),
                                              Divider(), // Adds a separator between subjects
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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