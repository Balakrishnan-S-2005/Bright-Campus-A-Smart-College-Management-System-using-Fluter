import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FacultyListScreen extends StatelessWidget {
  final String className; // Class name to fetch faculty details

  FacultyListScreen({required this.className});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Faculty List - $className', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF674AEF),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection('faculty_assignments').doc(className).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text("No faculty assigned for this class"));
          }

          var data = snapshot.data!.data() as Map<String, dynamic>;

          // Get tutor name
          String tutor = data.containsKey('tutor') ? data['tutor'] : "Not Assigned";

          // Get faculty list
          List facultyList = (data['faculties'] as List<dynamic>?)
              ?.map((e) => Map<String, String>.from(e))
              .toList() ?? [];

          return SingleChildScrollView(
            child: Column(
              children: [
                // Tutor Card
                Card(
                  margin: EdgeInsets.all(10),
                  color: Colors.deepPurple.shade100,
                  child: ListTile(
                    title: Text("Class Tutor", style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(tutor, style: TextStyle(fontSize: 16)),
                    leading: Icon(Icons.person, color: Colors.deepPurple),
                  ),
                ),

                // Faculty List
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    "Faculty Members",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                if (facultyList.isEmpty)
                  Center(child: Text("No faculty assigned yet"))
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: facultyList.length,
                    itemBuilder: (context, index) {
                      var facultyData = facultyList[index];

                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: ListTile(
                          title: Text(facultyData['subject'] ?? "No Subject", style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("Faculty: ${facultyData['name']}"),
                          leading: Icon(Icons.school, color: Colors.deepPurple),
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}