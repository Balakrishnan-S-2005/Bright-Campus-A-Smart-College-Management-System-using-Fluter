import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentRoutineScreen extends StatefulWidget {
  @override
  _StudentRoutineScreenState createState() => _StudentRoutineScreenState();
}

class _StudentRoutineScreenState extends State<StudentRoutineScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  String? studentClass;
  List<Map<String, dynamic>> routine = [];

  @override
  void initState() {
    super.initState();
    _fetchStudentClassRoutine();
  }

  Future<void> _fetchStudentClassRoutine() async {
    if (user != null) {
      String studentEmail = user!.email!;
      print("Fetching student details for email: $studentEmail");

      // Fetch student's class
      QuerySnapshot studentSnapshot = await FirebaseFirestore.instance
          .collection('students')
          .where('email', isEqualTo: studentEmail)
          .get();

      if (studentSnapshot.docs.isNotEmpty) {
        var studentDoc = studentSnapshot.docs.first;
        studentClass = studentDoc["class"];
        print("Student class: $studentClass");

        if (studentClass != null) {
          // Fetch routine for the student's class
          QuerySnapshot routineSnapshot = await FirebaseFirestore.instance
              .collection('week_table')
              .where('class', isEqualTo: studentClass)  // Ensure this matches Firestore field
              .get();

          print("Routine docs count: ${routineSnapshot.docs.length}");

          if (routineSnapshot.docs.isNotEmpty) {
            setState(() {
              routine = routineSnapshot.docs
                  .map((doc) => doc.data() as Map<String, dynamic>)
                  .toList();
            });
            print("Routine fetched successfully: $routine");
          } else {
            print("No routine found for class: $studentClass");
          }
        }
      } else {
        print("No student found with email: $studentEmail");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Class Routine",style: TextStyle(color: Colors.white),),backgroundColor: Color(0xFF674AEF),),
      body: studentClass == null
          ? Center(child: CircularProgressIndicator())
          : routine.isEmpty
          ? Center(child: Text(""))
          : SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(Colors.deepPurple.shade600),
          border: TableBorder.all(color: Colors.black, width: 1),
          columns: [
            DataColumn(label: Text("Day",style: TextStyle(color: Colors.white),)),
            DataColumn(label: Text("08:40-09:30",style: TextStyle(color: Colors.white))),
            DataColumn(label: Text("09:30-10:25",style: TextStyle(color: Colors.white))),
            DataColumn(label: Text("10:25-11:20",style: TextStyle(color: Colors.white))),
            DataColumn(label: Text("11:20-11:40",style: TextStyle(color: Colors.white))),
            DataColumn(label: Text("11:40-12:35",style: TextStyle(color: Colors.white))),
            DataColumn(label: Text("12:35-01:30",style: TextStyle(color: Colors.white))),
          ],
          rows: routine.map((dayRoutine) {
            List<dynamic> subjects = dayRoutine["subjects"] ?? [];

            return DataRow(cells: [
              DataCell(Text(dayRoutine["day"] ?? "N/A")),
              DataCell(Text(subjects.length > 0 ? subjects[0]["name"] : "-")),
              DataCell(Text(subjects.length > 1 ? subjects[1]["name"] : "-")),
              DataCell(Text(subjects.length > 2 ? subjects[2]["name"] : "-")),
              DataCell(Text("Interval", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red))), // Interval
              DataCell(Text(subjects.length > 3 ? subjects[3]["name"] : "-")),
              DataCell(Text(subjects.length > 4 ? subjects[4]["name"] : "-")),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}