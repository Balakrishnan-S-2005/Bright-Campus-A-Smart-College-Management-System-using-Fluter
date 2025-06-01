import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentFeesDetailsScreen extends StatelessWidget {
  final String studentName;
  StudentFeesDetailsScreen({required this.studentName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Fees Details - $studentName",style: TextStyle(color: Colors.white),),backgroundColor: Color(0xFF674AEF)),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("students")
            .doc(studentName)
            .collection("fees")
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No fee records found"));
          }

          return ListView(
            children: snapshot.data!.docs.map((feeDoc) {
              String semester = feeDoc.id;
              Map<String, dynamic> feeData = feeDoc.data() as Map<String, dynamic>;
              String status = feeData["status"] ?? "Not Paid";
              String? receiptPath = feeData["receiptPath"];

              return Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  title: Text("Semester $semester"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Status: $status"),
                      if (receiptPath != null && receiptPath.isNotEmpty)
                        Column(
                          children: [
                            SizedBox(height: 10),
                            receiptPath.startsWith('http')
                                ? Image.network(receiptPath, height: 150, fit: BoxFit.cover)
                                : Image.file(File(receiptPath), height: 150, fit: BoxFit.cover),
                          ],
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
}