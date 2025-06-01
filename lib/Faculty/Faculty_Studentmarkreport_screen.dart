import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class FacultyStudentMarksTableScreen extends StatefulWidget {
  final String className;

  FacultyStudentMarksTableScreen({required this.className});

  @override
  _FacultyStudentMarksTableScreenState createState() =>
      _FacultyStudentMarksTableScreenState();
}

class _FacultyStudentMarksTableScreenState extends State<FacultyStudentMarksTableScreen> {
  String selectedModule = "IA 1"; // Default module
  final List<String> modules = ["IA 1", "IA 2", "Model"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Marks - ${widget.className}", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF674AEF),
        actions: [
          IconButton(
            icon: Icon(Icons.print, color: Colors.white),
            onPressed: () => _printReport(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: selectedModule,
              onChanged: (newValue) {
                setState(() {
                  selectedModule = newValue!;
                });
              },
              items: modules.map((module) {
                return DropdownMenuItem<String>(
                  value: module,
                  child: Text(module),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: _buildMarksTable(),
          ),
        ],
      ),
    );
  }

  /// **📌 Function to Build Student Marks Table**
  Widget _buildMarksTable() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("students")
          .where("class", isEqualTo: widget.className)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No students found."));
        }

        var students = snapshot.data!.docs;

        // Collect unique subjects from all students
        Set<String> subjects = {};
        for (var student in students) {
          var marks = (student.data() as Map<String, dynamic>)["marks"] as List<dynamic>? ?? [];
          for (var subjectData in marks) {
            subjects.add(subjectData["subject"]);
          }
        }
        List<String> subjectList = subjects.toList();

        // Initialize pass/fail counters
        Map<String, int> passCount = {for (var subject in subjectList) subject: 0};
        Map<String, int> failCount = {for (var subject in subjectList) subject: 0};

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Table(
              border: TableBorder.all(color: Colors.black, width: 1),
              columnWidths: {
                0: FixedColumnWidth(150),
                1: FixedColumnWidth(100),
                for (int i = 2; i < subjectList.length + 2; i++) i: IntrinsicColumnWidth(),
              },
              children: [
                // **Table Header**
                TableRow(
                  decoration: BoxDecoration(color: Color(0xFF674AEF)),
                  children: [
                    _tableCell("Name", isHeader: true),
                    _tableCell("ID", isHeader: true),
                    ...subjectList.map((subject) => _tableCell(subject, isHeader: true)),
                  ],
                ),
                // **Student Data Rows**
                ...students.map((student) {
                  var studentData = student.data() as Map<String, dynamic>;
                  var name = studentData["name"] ?? "Unknown";
                  var id = studentData["id"] ?? "Unknown";
                  var marks = studentData["marks"] as List<dynamic>? ?? [];

                  Map<String, dynamic> subjectMarks = {};
                  for (var subjectData in marks) {
                    subjectMarks[subjectData["subject"]] = subjectData[this.selectedModule] ?? 0;
                  }

                  // Update pass/fail counts
                  for (var subject in subjectList) {
                    int mark = subjectMarks[subject] ?? 0;
                    int passMark = this.selectedModule == "Model" ? 30 : 16;
                    if (mark >= passMark) {
                      passCount[subject] = (passCount[subject] ?? 0) + 1;
                    } else {
                      failCount[subject] = (failCount[subject] ?? 0) + 1;
                    }
                  }

                  return TableRow(
                    children: [
                      _tableCell(name),
                      _tableCell(id),
                      ...subjectList.map((subject) =>
                          _tableCell(subjectMarks[subject]?.toString() ?? "0")),
                    ],
                  );
                }).toList(),
                // **Pass/Fail Summary Row**
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey.shade300),
                  children: [
                    _tableCell("Students", isHeader: true),
                    _tableCell("PassCount", isHeader: true),
                    ...subjectList.map((subject) =>
                        _tableCell("${passCount[subject]}", isHeader: true)),
                  ],
                ),
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey.shade300),
                  children: [
                    _tableCell("Students", isHeader: true),
                    _tableCell("FailCount", isHeader: true),
                    ...subjectList.map((subject) =>
                        _tableCell("${failCount[subject]}", isHeader: true)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _tableCell(String text, {bool isHeader = false}) {
    return Container(
      padding: EdgeInsets.all(8),
      color: isHeader ? Color(0xFF674AEF) : Colors.white,
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
            fontSize: 16,
            color: isHeader ? Colors.white : Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
  void _printReport() async {
    final pdf = pw.Document();

    final snapshot = await FirebaseFirestore.instance
        .collection("students")
        .where("class", isEqualTo: widget.className)
        .get();

    if (snapshot.docs.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("No students found to print")));
      return;
    }

    var students = snapshot.docs;

    // **Collect Unique Subjects**
    Set<String> subjects = {};
    for (var student in students) {
      var marks = student.data()["marks"] as List<dynamic>? ?? [];
      for (var subjectData in marks) {
        subjects.add(subjectData["subject"]);
      }
    }
    List<String> subjectList = subjects.toList();

    // **Calculate Pass/Fail Counts**
    Map<String, int> passCount = {for (var subject in subjectList) subject: 0};
    Map<String, int> failCount = {for (var subject in subjectList) subject: 0};

    List<List<String>> tableData = [];

    // **Header Row**
    tableData.add(["Name", "ID", ...subjectList]);

    // **Student Marks Data**
    for (var student in students) {
      var studentData = student.data();
      var name = studentData["name"] ?? "Unknown";
      var id = studentData["id"] ?? "Unknown";
      var marks = studentData["marks"] as List<dynamic>? ?? [];

      Map<String, dynamic> subjectMarks = {};
      for (var subjectData in marks) {
        subjectMarks[subjectData["subject"]] = subjectData[selectedModule] ?? 0;
      }

      // **Update Pass/Fail Counts**
      for (var subject in subjectList) {
        int mark = subjectMarks[subject] ?? 0;
        if (mark >= 16) {
          passCount[subject] = (passCount[subject] ?? 0) + 1;
        } else {
          failCount[subject] = (failCount[subject] ?? 0) + 1;
        }
      }

      tableData.add([
        name,
        id,
        ...subjectList.map((subject) => subjectMarks[subject]?.toString() ?? "0")
      ]);
    }

    // **Pass/Fail Summary Row**
    tableData.add([
      "Students",
      "PassCount",
      ...subjectList.map((subject) => "${passCount[subject]}")
    ]);
    tableData.add([
      "Students",
      "FailCount",
      ...subjectList.map((subject) => "${failCount[subject]}")
    ]);

    // **Generate PDF Table**
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text("Class Report - ${widget.className}",
                  style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.TableHelper.fromTextArray(
                context: context,
                data: tableData,
                border: pw.TableBorder.all(color: PdfColors.black),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: pw.BoxDecoration(color: PdfColors.blue),
                cellAlignment: pw.Alignment.center,
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }


  pw.Widget _pdfCell(String text, {bool isHeader = false}) {
    return pw.Container(
      padding: pw.EdgeInsets.all(8),
      color: isHeader ? PdfColors.blue : PdfColors.white,
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          fontSize: 14,
          color: isHeader ? PdfColors.white : PdfColors.black,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }
}
