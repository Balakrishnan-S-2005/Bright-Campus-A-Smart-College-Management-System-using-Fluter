import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FacultyOverviewScreen extends StatelessWidget {
  final List<String> classNames = [
    "BCA III 'A'", "BCA III 'B'", "BCA II 'A'", "BCA II 'B'",
    "BCA II 'C'", "BCA I 'A'", "BCA I 'B'", "BCA I 'C'"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Faculty Overview",style: TextStyle(color: Colors.white),),backgroundColor: Color(0xFF674AEF)),
      body: FutureBuilder(
        future: FirebaseFirestore.instance.collection('faculty_assignments').get(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          Map<String, String> tutors = {};
          List<Map<String, dynamic>> otherFaculty = [];

          // Extract tutors & faculty lists
          for (var doc in snapshot.data!.docs) {
            String className = doc.id;
            var data = doc.data() as Map<String, dynamic>;

            if (data.containsKey('tutor')) {
              tutors[className] = data['tutor'];
            }

            if (data.containsKey('faculties')) {
              for (var faculty in data['faculties']) {
                otherFaculty.add({
                  'name': faculty['name'],
                  'subject': faculty['subject'],
                  'class': className,
                });
              }
            }
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Tutors Section
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Class Tutors", style: TextStyle(color: Color(0xFF674AEF),fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: classNames.length,
                  itemBuilder: (context, index) {
                    String className = classNames[index];
                    return Card(
                      margin: EdgeInsets.all(8),
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(className, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            SizedBox(height: 8),
                            Text(tutors[className] ?? "Not Assigned", style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // Other Faculty Section
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Other Faculty Members", style: TextStyle(color: Color(0xFF674AEF),fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                if (otherFaculty.isEmpty)
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("No additional faculty found", style: TextStyle(color: Colors.black54)),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: otherFaculty.length,
                    itemBuilder: (context, index) {
                      var faculty = otherFaculty[index];
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          title: Text(faculty['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("${faculty['subject']} - ${faculty['class']}"),
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