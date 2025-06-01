import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StudentAttendanceScreen extends StatefulWidget {
  @override
  _StudentAttendanceScreenState createState() => _StudentAttendanceScreenState();
}

class _StudentAttendanceScreenState extends State<StudentAttendanceScreen> {
  String? studentName;
  String? className;
  String? studentId;
  int attendedDays = 0;
  int totalDays = 0;
  int presentHours = 0;
  int totalHours = 0;
  double attendancePercentage = 0.0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchStudentDetails();
    });
  }

  // Fetch student details (Name, Class, and ID)
  Future<void> fetchStudentDetails() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print("No user logged in.");
      setState(() {
        isLoading = false;
      });
      return;
    }

    print("Current Logged-in User: ${user.displayName}, Email: ${user.email}");

    try {
      QuerySnapshot studentSnapshot = await FirebaseFirestore.instance
          .collection('students')
          .where('email', isEqualTo: user.email) // Fetch student by email
          .limit(1)
          .get();

      if (studentSnapshot.docs.isNotEmpty) {
        var studentData = studentSnapshot.docs.first.data() as Map<String, dynamic>;

        setState(() {
          studentName = studentData['name'];
          className = studentData['class'];
          studentId = studentData['id']; // Fetch the student ID from Firestore
        });

        print("Fetched Student: Name=$studentName, Class=$className, ID=$studentId");

        if (studentName != null && className != null) {
          fetchAttendance();
        }
      } else {
        print("Student not found for email: ${user.email}");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching student details: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  // Fetch attendance details using studentName and className
  Future<void> fetchAttendance() async {
    if (className == null || studentName == null) return;

    setState(() {
      attendedDays = 0;
      presentHours = 0;
      totalHours = 0;
      attendancePercentage = 0.0;
      isLoading = true;
    });

    try {
      String docId = "${className}_${studentName}"; // Match your Firestore document structure

      DocumentSnapshot attendanceDoc = await FirebaseFirestore.instance
          .collection('attendance')
          .doc(docId)
          .get();

      if (attendanceDoc.exists) {
        var data = attendanceDoc.data() as Map<String, dynamic>;

        setState(() {
          attendedDays = data['attendedDays'] ?? 0;
          totalDays = data['totalDays'] ?? 0;
          presentHours = data['presentHours'] ?? 0;
          totalHours = data['totalHours'] ?? 1; // Prevent division by zero
          attendancePercentage = data['attendancePercentage'] ?? 0.0;
        });

        print("Attendance fetched for: $studentName, Class: $className");
      } else {
        print("No attendance found for: $studentName, Class: $className");
      }
    } catch (e) {
      print("Error fetching attendance: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Attendance", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF674AEF),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : studentName == null || className == null
          ? Center(child: Text("No student data found."))
          : Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name: $studentName", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("Class: $className", style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text("Student ID: $studentId", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("Total Days: $totalDays", style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text("Total Hours: $totalHours", style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text("Present Hours: $presentHours", style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text(
              "Attendance Percentage: ${attendancePercentage.toStringAsFixed(2)}%",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}