import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminLeaveApprovalScreen extends StatefulWidget {
  @override
  _AdminLeaveApprovalScreenState createState() => _AdminLeaveApprovalScreenState();
}

class _AdminLeaveApprovalScreenState extends State<AdminLeaveApprovalScreen> {
  Future<void> _handleLeaveApproval(String facultyId, String leaveId, String leaveType, int totalDays, bool isApproved) async {
    DocumentReference facultyDoc = FirebaseFirestore.instance.collection('faculty_leaves').doc(facultyId);
    DocumentReference leaveRequestDoc = facultyDoc.collection('leave_requests').doc(leaveId);

    DocumentSnapshot leaveSnapshot = await leaveRequestDoc.get();
    if (!leaveSnapshot.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Leave request not found.")),
      );
      return;
    }

    Map<String, dynamic> leaveData = leaveSnapshot.data() as Map<String, dynamic>;

    // Ensure `dates` is stored as a List<String>
    dynamic rawDates = leaveData["dates"];
    List<String> dates = [];

    if (rawDates is String) {
      dates = rawDates.replaceAll("[", "").replaceAll("]", "").replaceAll("'", "").split(", ");
    } else if (rawDates is List) {
      dates = List<String>.from(rawDates);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid date format in Firestore.")),
      );
      return;
    }

    // Fetch faculty details
    DocumentSnapshot facultySnapshot = await facultyDoc.get();
    if (!facultySnapshot.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Faculty data not found.")),
      );
      return;
    }

    Map<String, dynamic> facultyData = facultySnapshot.data() as Map<String, dynamic>;
    int monthlyCL = (facultyData['monthly_CL'] ?? 0);
    int lopCount = (facultyData['LOP'] ?? 0);
    Map<String, dynamic> leavesTaken = facultyData['leaves_taken'] ?? {};
    int previousCL = (leavesTaken['CL'] ?? 0);
    int previousLOP = (leavesTaken['LOP'] ?? 0);
    int previousOD = (leavesTaken['OD'] ?? 0);
    int previousPermission = (leavesTaken['Permission'] ?? 0);

    int clToApprove = 0;
    int lopToAdd = 0;
    int odToApprove = 0;
    int permissionToApprove = 0;

    if (isApproved) {
      if (leaveType == "CL") {
        if (totalDays <= monthlyCL) {
          clToApprove = totalDays;
        } else {
          clToApprove = monthlyCL;
          lopToAdd = totalDays - monthlyCL;
        }

        await facultyDoc.update({
          "monthly_CL": monthlyCL - clToApprove,
          "LOP": lopCount + lopToAdd,
          "leaves_taken.CL": previousCL + clToApprove,
          "leaves_taken.LOP": previousLOP + lopToAdd,
        });
      } else if (leaveType == "OD") {
        odToApprove = totalDays;
        await facultyDoc.update({
          "leaves_taken.OD": previousOD + odToApprove,
        });
      } else if (leaveType == "Permission") {
        permissionToApprove = totalDays;
        await facultyDoc.update({
          "leaves_taken.Permission": previousPermission + permissionToApprove,
        });
      }

      await leaveRequestDoc.update({
        "status": "Approved",
        "approvedCL": clToApprove,
        "approvedLOP": lopToAdd,
        "approvedOD": odToApprove,
        "approvedPermission": permissionToApprove,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Leave approved: $clToApprove CL, $lopToAdd LOP, $odToApprove OD, $permissionToApprove Permission")),
      );
    } else {
      // Revert values if rejected
      if (leaveType == "CL") {
        await facultyDoc.update({
          "monthly_CL": monthlyCL + totalDays,
          "leaves_taken.CL": previousCL - totalDays,
        });
      } else if (leaveType == "OD") {
        await facultyDoc.update({
          "leaves_taken.OD": previousOD - totalDays,
        });
      } else if (leaveType == "Permission") {
        await facultyDoc.update({
          "leaves_taken.Permission": previousPermission - totalDays,
        });
      }

      await leaveRequestDoc.update({
        "status": "Rejected",
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Leave request rejected.")),
      );
    }
  }









  Future<void> _handleLeaveRejection(String facultyId, String leaveId, String leaveType, int totalDays) async {
    DocumentReference facultyDoc = FirebaseFirestore.instance.collection('faculty_leaves').doc(facultyId);
    DocumentReference leaveRequestDoc = facultyDoc.collection('leave_requests').doc(leaveId);

    // Fetch faculty leave data
    DocumentSnapshot facultySnapshot = await facultyDoc.get();
    if (!facultySnapshot.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Faculty record not found.")),
      );
      return;
    }

    Map<String, dynamic> facultyData = facultySnapshot.data() as Map<String, dynamic>;
    int currentLeaveCount = (facultyData["leaves_taken"]?[leaveType] ?? 0); // Get current leave count

    // Fetch the leave request to check if it was approved
    DocumentSnapshot leaveSnapshot = await leaveRequestDoc.get();
    if (!leaveSnapshot.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Leave request not found.")),
      );
      return;
    }

    Map<String, dynamic> leaveData = leaveSnapshot.data() as Map<String, dynamic>;
    if (leaveData['status'] == "Approved") {
      // Only revert if leave was previously approved
      int newLeaveCount = currentLeaveCount - totalDays;
      if (newLeaveCount < 0) newLeaveCount = 0; // Ensure it doesn't go negative

      await facultyDoc.update({
        "leaves_taken.$leaveType": newLeaveCount, // Update with the correct reverted value
      });
    }

    // Update leave request status to "Rejected"
    await leaveRequestDoc.update({
      "status": "Rejected",
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Leave Rejected and Reverted Successfully.")),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Leave Approvals",style: TextStyle(color: Colors.white),), backgroundColor: const Color(0xFF674AEF)),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('faculty_leaves')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          var facultyDocs = snapshot.data!.docs;
          List<Widget> leaveRequests = [];

          for (var facultyDoc in facultyDocs) {
            String facultyId = facultyDoc.id;

            leaveRequests.add(
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('faculty_leaves')
                    .doc(facultyId)
                    .collection('leave_requests')
                    .where('status', isEqualTo: "Pending")
                    .snapshots(),
                builder: (context, leaveSnapshot) {
                  if (!leaveSnapshot.hasData) return const SizedBox.shrink();

                  var leaveDocs = leaveSnapshot.data!.docs;

                  return Column(
                    children: leaveDocs.map((leaveDoc) {
                      Map<String, dynamic> leaveData = leaveDoc.data() as Map<String, dynamic>;

                      return Card(
                        margin: const EdgeInsets.all(10),
                        child: ListTile(
                          title: Text("Faculty ID: $facultyId"),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Leave Type: ${leaveData['type']}"),
                              Text("Reason: ${leaveData['reason']}"),
                              Text("Dates: ${leaveData['dates']}"),
                              Text("Total Days: ${leaveData['total_days']}"),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.check, color: Colors.green),
                                onPressed: () => _handleLeaveApproval(facultyId, leaveDoc.id, leaveData['type'], leaveData['total_days'],true),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.red),
                                onPressed: () => _handleLeaveRejection(facultyId, leaveDoc.id, leaveData['type'], leaveData['total_days']),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            );
          }

          return ListView(children: leaveRequests);
        },
      ),
    );
  }
}
