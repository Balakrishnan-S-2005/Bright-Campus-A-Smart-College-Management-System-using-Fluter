import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class FacultyLeaveRequestScreen extends StatefulWidget {
  final String facultyId;

  const FacultyLeaveRequestScreen({Key? key, required this.facultyId}) : super(key: key);

  @override
  _FacultyLeaveRequestScreenState createState() => _FacultyLeaveRequestScreenState();
}

class _FacultyLeaveRequestScreenState extends State<FacultyLeaveRequestScreen> {
  Set<DateTime> selectedDates = {};
  String selectedLeaveType = "CL";
  TextEditingController reasonController = TextEditingController();
  int availableCL = 12, usedCL = 0, usedOD = 0, usedPermission = 0, usedLOP = 0;

  @override
  void initState() {
    super.initState();
    _initializeFacultyLeaveData();
  }

  Future<void> _initializeFacultyLeaveData() async {
    DocumentSnapshot facultyDoc = await FirebaseFirestore.instance.collection('faculty_leaves').doc(widget.facultyId).get();

    if (facultyDoc.exists) {
      Map<String, dynamic> data = facultyDoc.data() as Map<String, dynamic>;
      setState(() {
        usedCL = data['leaves_taken']['CL'] ?? 0;
        usedOD = data['leaves_taken']['OD'] ?? 0;
        usedPermission = data['leaves_taken']['Permission'] ?? 0;
        usedLOP = data['leaves_taken']['LOP'] ?? 0;
      });
    }
  }

  void _onDaySelected(DateTime day, DateTime focusedDay) {
    setState(() {
      if (selectedDates.contains(day)) {
        selectedDates.remove(day);
      } else {
        selectedDates.add(day);
      }
    });
  }

  Future<void> _submitLeaveRequest() async {
    if (selectedDates.isEmpty || reasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select dates and enter a reason.")),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('faculty_leaves').doc(widget.facultyId).collection("leave_requests").add({
      "type": selectedLeaveType,
      "dates": selectedDates.map((date) => DateFormat('yyyy-MM-dd').format(date)).toList(),
      "reason": reasonController.text,
      "total_days": selectedDates.length,
      "status": "Pending",
      "timestamp": FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Leave request submitted successfully.")),
    );

    setState(() {
      selectedDates.clear();
      reasonController.clear();
      selectedLeaveType = "CL";
    });
  }

  @override
  Widget build(BuildContext context) {
    DateTime today = DateTime.now();

    return Scaffold(
      appBar: AppBar(title: const Text("Apply for Leave", style: TextStyle(color: Colors.white)), backgroundColor: const Color(0xFF674AEF)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TableCalendar(
                focusedDay: today,
                firstDay: DateTime(today.year, 1, 1),
                lastDay: DateTime(today.year, 12, 31),
                selectedDayPredicate: (day) => selectedDates.contains(day),
                onDaySelected: _onDaySelected,
                calendarFormat: CalendarFormat.month,
                headerStyle: const HeaderStyle(formatButtonVisible: false),
              ),
              const SizedBox(height: 10),
              Text("Casual Leave (CL): $usedCL / $availableCL"),
              Text("On Duty (OD): $usedOD"),
              Text("Permission: $usedPermission"),
              Text("Loss of Pay (LOP): $usedLOP"),
              const SizedBox(height: 10),
              DropdownButton<String>(
                value: selectedLeaveType,
                onChanged: (value) => setState(() => selectedLeaveType = value!),
                items: ["CL", "OD", "Permission"].map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
              ),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(labelText: "Reason"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitLeaveRequest,
                child: const Text("Submit Request"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF674AEF),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
              ),
              const SizedBox(height: 20),
              const Text("Leave History", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              _buildLeaveHistory(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeaveHistory() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('faculty_leaves').doc(widget.facultyId).collection("leave_requests").orderBy("timestamp", descending: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        var leaveRequests = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: leaveRequests.length,
          itemBuilder: (context, index) {
            var leave = leaveRequests[index];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 5),
              child: ListTile(
                title: Text("Type: ${leave["type"]}"),
                subtitle: Text("Dates: ${leave["dates"]}\nReason: ${leave["reason"]}"),
                trailing: Chip(
                  label: Text(leave["status"], style: TextStyle(color: Colors.white)),
                  backgroundColor: leave["status"] == "Approved" ? Colors.green : leave["status"] == "Rejected" ? Colors.red : Colors.orange,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
