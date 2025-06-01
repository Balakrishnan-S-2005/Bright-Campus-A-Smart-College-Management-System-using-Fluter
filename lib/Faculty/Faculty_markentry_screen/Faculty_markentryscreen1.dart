import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'Faculty_markentryscreen_screen.dart';

class FacultyMarkEntryScreen extends StatefulWidget {
  final String className;

  FacultyMarkEntryScreen({required this.className});

  @override
  _FacultyMarkEntryScreenState createState() => _FacultyMarkEntryScreenState();
}

class _FacultyMarkEntryScreenState extends State<FacultyMarkEntryScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController subjectController = TextEditingController();
  List<String> subjects = [];

  @override
  void initState() {
    super.initState();
    fetchSubjects();
  }

  Future<void> fetchSubjects() async {
    QuerySnapshot studentSnapshot = await _firestore
        .collection('students')
        .where('class', isEqualTo: widget.className)
        .get();

    if (studentSnapshot.docs.isNotEmpty) {
      var firstStudent = studentSnapshot.docs.first.data() as Map<String, dynamic>;

      if (firstStudent.containsKey('marks')) {
        List<dynamic> marksList = firstStudent['marks'] ?? [];
        setState(() {
          subjects = marksList.map((m) => m['subject'] as String).toList();
        });
      } else {
        setState(() {
          subjects = [];
        });
      }
    }
  }

  Future<void> createSubject() async {
    if (subjectController.text.isNotEmpty) {
      String subjectName = subjectController.text.trim();
      QuerySnapshot studentSnapshot = await _firestore
          .collection('students')
          .where('class', isEqualTo: widget.className)
          .get();

      WriteBatch batch = _firestore.batch();

      for (var student in studentSnapshot.docs) {
        DocumentReference studentRef = _firestore.collection('students').doc(student.id);
        Map<String, dynamic> studentData = student.data() as Map<String, dynamic>;

        List<dynamic> marks = studentData.containsKey('marks') ? studentData['marks'] : [];

        if (!marks.any((m) => m['subject'] == subjectName)) {
          marks.add({
            'subject': subjectName,
            'IA 1': 0,
            'IA 2': 0,
            'Model': 0,
            'Semester': 0,
          });
          batch.update(studentRef, {'marks': marks});
        }
      }

      await batch.commit();
      subjectController.clear();
      fetchSubjects();
    }
  }

  Future<void> deleteSubject(String subjectName) async {
    QuerySnapshot studentSnapshot = await _firestore
        .collection('students')
        .where('class', isEqualTo: widget.className)
        .get();

    WriteBatch batch = _firestore.batch();

    for (var student in studentSnapshot.docs) {
      DocumentReference studentRef = _firestore.collection('students').doc(student.id);
      Map<String, dynamic> studentData = student.data() as Map<String, dynamic>;

      List<dynamic> marks = studentData.containsKey('marks') ? studentData['marks'] : [];

      marks.removeWhere((m) => m['subject'] == subjectName);
      batch.update(studentRef, {'marks': marks});
    }

    await batch.commit();
    fetchSubjects();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("ADD or Select Subjects",style: TextStyle(color: Colors.white),),backgroundColor: Color(0xFF674AEF),),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              controller: subjectController,
              decoration: InputDecoration(
                labelText: "Enter Subject Name",
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: createSubject,
                ),
              ),
            ),
          ),
          Expanded(
            child: subjects.isEmpty
                ? Center(child: Text("No subjects available"))
                : ListView.builder(
              itemCount: subjects.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text(subjects[index]),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => deleteSubject(subjects[index]),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StudentListScreen(
                            className: widget.className,
                            subjectName: subjects[index],
                          ),
                        ),
                      );
                    },
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