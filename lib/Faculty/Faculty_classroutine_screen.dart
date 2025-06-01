import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateRoutineScreen extends StatefulWidget {
  @override
  _UpdateRoutineScreenState createState() => _UpdateRoutineScreenState();
}

class _UpdateRoutineScreenState extends State<UpdateRoutineScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? selectedClass;
  String? selectedDay;

  final List<String> classes = [
    "BCA III 'A'",
    "BCA III 'B'",
    "BCA II 'A'",
    "BCA II 'B'",
    "BCA II 'C'",
    "BCA I 'A'",
    "BCA I 'B'",
    "BCA I 'C'"
  ];

  final List<String> days = [
    "Day 1",
    "Day 2",
    "Day 3",
    "Day 4",
    "Day 5",
    "Day 6"
  ];

  List<TextEditingController> subjectControllers =
  List.generate(6, (index) => TextEditingController());

  void _updateRoutine() async {
    if (selectedClass == null || selectedDay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select class and day")),
      );
      return;
    }

    List<Map<String, String>> subjects = [];
    for (var controller in subjectControllers) {
      subjects.add({"name": controller.text});
    }

    await _firestore
        .collection('week_table')
        .doc('${selectedClass}_$selectedDay')
        .set({
      'class': selectedClass,
      'day': selectedDay,
      'subjects': subjects,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Routine Updated Successfully")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
        Text("Update Class Routine", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF674AEF),
        centerTitle: true,
      ),
      body: SingleChildScrollView( // 🔹 Prevents pixel breaking when keyboard appears
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: selectedClass,
                hint: Text("Select Class"),
                items: classes.map((cls) {
                  return DropdownMenuItem(value: cls, child: Text(cls));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedClass = value;
                  });
                },
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedDay,
                hint: Text("Select Day"),
                items: days.map((day) {
                  return DropdownMenuItem(value: day, child: Text(day));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedDay = value;
                  });
                },
              ),
              SizedBox(height: 20),
              Column(
                children: List.generate(5, (index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 5),
                    child: TextField(
                      controller: subjectControllers[index],
                      decoration: InputDecoration(
                        labelText: "Subject ${index + 1}",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  );
                }),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateRoutine,
                child: Text("Update Routine"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF674AEF),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}