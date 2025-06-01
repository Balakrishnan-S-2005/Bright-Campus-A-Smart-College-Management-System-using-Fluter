import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StudentMarksScreen extends StatefulWidget {
  @override
  _StudentMarksScreenState createState() => _StudentMarksScreenState();
}

class _StudentMarksScreenState extends State<StudentMarksScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? studentName;
  String? className;
  List<Map<String, dynamic>> marks = [];
  bool isLoading = true;
  String selectedCategory = "IA 1"; // Default category

  @override
  void initState() {
    super.initState();
    fetchStudentDetails();
  }

  Future<void> fetchStudentDetails() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        print("Fetching student details for UID: ${user.uid}"); // Debug print

        QuerySnapshot studentSnapshot = await _firestore
            .collection('students')
            .where('email', isEqualTo: user.email) // Assuming email is stored
            .get();

        if (studentSnapshot.docs.isNotEmpty) {
          var data = studentSnapshot.docs.first.data() as Map<String, dynamic>;

          setState(() {
            studentName = data['name'];
            className = data['class'];
          });

          print("Student Name: $studentName, Class: $className"); // Debug print

          fetchStudentMarks();
        } else {
          print("No student document found for email: ${user.email}"); // Debug print
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error fetching student details: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchStudentMarks() async {
    if (studentName == null || className == null) return;

    try {
      print("Fetching marks for: Name - $studentName, Class - $className"); // Debugging print

      QuerySnapshot studentSnapshot = await _firestore
          .collection('students')
          .where('class', isEqualTo: className)
          .where('name', isEqualTo: studentName)
          .get();

      if (studentSnapshot.docs.isNotEmpty) {
        var studentData = studentSnapshot.docs.first.data() as Map<String, dynamic>;

        print("Fetched Document: $studentData"); // Debugging print

        if (studentData.containsKey('marks') && studentData['marks'] is List) {
          setState(() {
            marks = List<Map<String, dynamic>>.from(studentData['marks']);
            isLoading = false;
          });
          print("Marks Data: $marks"); // Debugging print
        } else {
          print("Marks field does not exist or is empty"); // Debugging print
          setState(() {
            marks = [];
            isLoading = false;
          });
        }
      } else {
        print("No student document found"); // Debugging print
        setState(() {
          marks = [];
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching marks: $e'); // Debugging print
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Student Marks',style: TextStyle(color: Colors.white),),backgroundColor: Color(0xFF674AEF),),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Category Selection Buttons (IA 1, IA 2, Model, Semester)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ["IA 1", "IA 2", "Model"].map((category) {
              return ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedCategory = category;
                  });
                },
                child: Text(category),
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedCategory == category ? Color(0xFF674AEF) : Colors.grey,
                  foregroundColor: Colors.white,
                ),
              );
            }).toList(),
          ),
          Expanded(
            child: marks.isEmpty
                ? Center(child: Text("No marks available"))
                : ListView.builder(
              itemCount: marks.length,
              itemBuilder: (context, index) {
                var mark = marks[index];
                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(mark['subject'], style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('$selectedCategory: ${mark[selectedCategory] ?? 'N/A'}'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}