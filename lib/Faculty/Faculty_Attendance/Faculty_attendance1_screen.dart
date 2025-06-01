import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AttendanceScreen extends StatefulWidget {
  final String studentName;
  final String className;

  AttendanceScreen({required this.studentName, required this.className});

  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  Map<int, String> attendance = {}; // Stores attendance for each period
  String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now()); // Get current date

  void markAttendance(int period, String status) async {
    setState(() {
      attendance[period] = status;
    });

    String docId = "${widget.className}_${widget.studentName}";
    DocumentReference attendanceDoc =
    FirebaseFirestore.instance.collection('attendance').doc(docId);

    // Check if document exists, else create a new one
    DocumentSnapshot snapshot = await attendanceDoc.get();
    Map<String, dynamic> data = snapshot.exists ? snapshot.data() as Map<String, dynamic> : {};

    // Get existing attendance records or initialize a new map
    Map<String, dynamic> attendanceRecords = data['attendanceRecords'] ?? {};

    // Convert int period numbers to strings
    Map<String, String> stringAttendance = attendance.map((key, value) => MapEntry(key.toString(), value));

    // Update today's attendance
    attendanceRecords[currentDate] = stringAttendance;

    // Count total unique attendance days
    int totalDays = attendanceRecords.length;

    // Count total hours (5 periods per day * total days)
    int totalHours = totalDays * 5;

    // Count present hours
    int presentHours = 0;
    attendanceRecords.forEach((date, periods) {
      periods.forEach((key, value) {
        if (value == "Present") {
          presentHours++;
        }
      });
    });

    // Calculate attendance percentage
    double attendancePercentage = totalHours > 0 ? (presentHours / totalHours) * 100 : 0;

    // Ensure Firestore document is created if it doesn't exist
    await attendanceDoc.set({
      'studentName': widget.studentName,
      'className': widget.className,
      'attendanceRecords': attendanceRecords,
      'totalDays': totalDays,
      'totalHours': totalHours,
      'presentHours': presentHours,
      'attendancePercentage': attendancePercentage,
    }, SetOptions(merge: true));

    // **Show Popup Message (Snackbar)**
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Period $period marked as $status"),
        duration: Duration(seconds: 1), // Popup disappears in 1 second
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mark Attendance: ${widget.studentName}",style: TextStyle(color: Colors.white),),backgroundColor: Color(0xFF674AEF),),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Text("Date: $currentDate", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: 5, // 5 periods
                itemBuilder: (context, index) {
                  int period = index + 1;
                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      title: Text("Period $period", style: TextStyle(fontWeight: FontWeight.bold)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            onPressed: () => markAttendance(period, "Present"),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                            child: Text("Present",style: TextStyle(color: Colors.white),),
                          ),
                          SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () => markAttendance(period, "Absent"),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            child: Text("Absent",style: TextStyle(color: Colors.white),),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}