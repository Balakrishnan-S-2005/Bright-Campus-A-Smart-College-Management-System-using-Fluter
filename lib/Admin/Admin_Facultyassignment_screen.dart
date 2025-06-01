import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddFacultyScreen extends StatefulWidget {
  final String className;

  const AddFacultyScreen({Key? key, required this.className}) : super(key: key);

  @override
  _AddFacultyScreenState createState() => _AddFacultyScreenState();
}

class _AddFacultyScreenState extends State<AddFacultyScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController subjectController = TextEditingController();
  bool isTutor = false;

  Future<void> addFaculty() async {
    if (nameController.text.isEmpty || subjectController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    final classRef = FirebaseFirestore.instance.collection('faculty_assignments').doc(widget.className);
    final classData = await classRef.get();

    if (isTutor && classData.exists && classData.data()?['tutor'] != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("This class already has a tutor")),
      );
      return;
    }

    await classRef.set({
      'tutor': isTutor ? nameController.text : classData.data()?['tutor'],
      'faculties': FieldValue.arrayUnion([
        {
          'name': nameController.text,
          'subject': subjectController.text,
        }
      ])
    }, SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Faculty Added Successfully")),
    );

    nameController.clear();
    subjectController.clear();
    setState(() {
      isTutor = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Faculty - ${widget.className}",style: TextStyle(color: Colors.white),),backgroundColor: Color(0xFF674AEF),),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: "Faculty Name")),
            TextField(controller: subjectController, decoration: InputDecoration(labelText: "Subject")),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Assign as Tutor"),
                Switch(value: isTutor, onChanged: (val) => setState(() => isTutor = val)),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: addFaculty,
              child: Text("Assign Faculty"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF674AEF),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}