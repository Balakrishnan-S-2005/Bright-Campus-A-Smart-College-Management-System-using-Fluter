import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MarkEntryScreen extends StatefulWidget {
  final String studentId;
  final String studentName;
  final String className;
  final String subjectName;

  MarkEntryScreen({
    required this.studentId,
    required this.studentName,
    required this.className,
    required this.subjectName,
  });

  @override
  _MarkEntryScreenState createState() => _MarkEntryScreenState();
}

class _MarkEntryScreenState extends State<MarkEntryScreen> {
  String selectedCategory = "IA 1";
  TextEditingController markController = TextEditingController();
  int currentMark = 0;

  @override
  void initState() {
    super.initState();
    fetchCurrentMark();
  }

  void fetchCurrentMark() async {
    DocumentSnapshot studentDoc =
    await FirebaseFirestore.instance.collection('students').doc(widget.studentId).get();

    if (studentDoc.exists) {
      List<dynamic> marks = studentDoc['marks'] ?? [];
      var subjectData = marks.firstWhere((m) => m['subject'] == widget.subjectName, orElse: () => null);

      if (subjectData != null) {
        setState(() {
          currentMark = subjectData[selectedCategory] ?? 0;
          markController.text = currentMark.toString();
        });
      }
    }
  }

  void saveMark() async {
    if (markController.text.isNotEmpty) {
      int mark = int.tryParse(markController.text) ?? 0;

      DocumentReference studentRef =
      FirebaseFirestore.instance.collection('students').doc(widget.studentId);

      DocumentSnapshot studentDoc = await studentRef.get();
      if (studentDoc.exists) {
        List<dynamic> marks = studentDoc['marks'] ?? [];

        int subjectIndex = marks.indexWhere((m) => m['subject'] == widget.subjectName);

        if (subjectIndex != -1) {
          marks[subjectIndex][selectedCategory] = mark;
        }

        await studentRef.update({'marks': marks});
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Mark updated!")));
        fetchCurrentMark(); // Refresh displayed mark
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.studentName} - ${widget.subjectName}",style: TextStyle(color: Colors.white),),backgroundColor: Color(0xFF674AEF),),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ["IA 1", "IA 2", "Model"].map((category) {
              return ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedCategory = category;
                    fetchCurrentMark();
                  });
                },
                child: Text(category),
              );
            }).toList(),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              controller: markController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Enter Mark"),
            ),
          ),
          ElevatedButton(
            onPressed: saveMark,
            child: Text("Save Mark"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF674AEF),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            ),
          ),
        ],
      ),
    );
  }
}