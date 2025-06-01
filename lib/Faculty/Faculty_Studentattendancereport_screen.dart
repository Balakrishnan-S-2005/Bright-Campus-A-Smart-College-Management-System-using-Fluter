import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class FacultyAttendancePercentageScreen extends StatefulWidget {
  final String className;

  FacultyAttendancePercentageScreen({required this.className});

  @override
  _FacultyAttendancePercentageScreenState createState() =>
      _FacultyAttendancePercentageScreenState();
}

class _FacultyAttendancePercentageScreenState
    extends State<FacultyAttendancePercentageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Attendance - ${widget.className}",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF674AEF),
        actions: [
          IconButton(
            icon: Icon(Icons.print, color: Colors.white),
            onPressed: () => _printReport(),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Center(
            child: Text(
              "Attendance Report - ${widget.className}",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF674AEF),
              ),
            ),
          ),
          SizedBox(height: 20),
          Expanded(child: _buildAttendanceTable()),
        ],
      ),
    );
  }

  Widget _buildAttendanceTable() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("students")
          .where("class", isEqualTo: widget.className)
          .snapshots(),
      builder: (context, studentSnapshot) {
        if (studentSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!studentSnapshot.hasData || studentSnapshot.data!.docs.isEmpty) {
          return Center(child: Text("No students found."));
        }

        var students = studentSnapshot.data!.docs;

        return FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance.collection("attendance").get(),
          builder: (context, attendanceSnapshot) {
            if (attendanceSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            Map<String, double> attendanceMap = {};
            if (attendanceSnapshot.hasData) {
              for (var doc in attendanceSnapshot.data!.docs) {
                var data = doc.data() as Map<String, dynamic>;
                attendanceMap["${data['studentName']}_${data['className']}"] =
                    (data['attendancePercentage'] ?? 0).toDouble();
              }
            }

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Table(
                  border: TableBorder.all(color: Colors.black, width: 1),
                  columnWidths: {
                    0: FixedColumnWidth(150),
                    1: FixedColumnWidth(100),
                    2: FixedColumnWidth(120),
                  },
                  children: [
                    TableRow(
                      decoration: BoxDecoration(color: Color(0xFF674AEF)),
                      children: [
                        _tableCell("Name", isHeader: true),
                        _tableCell("ID", isHeader: true),
                        _tableCell("Attendance %", isHeader: true),
                      ],
                    ),
                    ...students.map((student) {
                      var studentData = student.data() as Map<String, dynamic>;
                      var name = studentData["name"] ?? "Unknown";
                      var id = studentData["id"] ?? "Unknown";
                      var attendanceKey = "${name}_${widget.className}";
                      var attendancePercentage = attendanceMap[attendanceKey] ?? 0.0;

                      Color percentageColor = attendancePercentage < 45
                          ? Colors.red
                          : (attendancePercentage < 75 ? Colors.amber : Colors.green);

                      return TableRow(
                        children: [
                          _tableCell(name),
                          _tableCell(id),
                          _tableCell(
                            attendancePercentage.toStringAsFixed(2) + "%",
                            textColor: percentageColor,
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _tableCell(String text, {bool isHeader = false, Color textColor = Colors.black}) {
    return Container(
      padding: EdgeInsets.all(8),
      color: isHeader ? Color(0xFF674AEF) : Colors.white,
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
            fontSize: 16,
            color: isHeader ? Colors.white : textColor,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void _printReport() async {
    final pdf = pw.Document();

    final studentSnapshot = await FirebaseFirestore.instance
        .collection("students")
        .where("class", isEqualTo: widget.className)
        .get();

    if (studentSnapshot.docs.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("No students found to print")));
      return;
    }

    var students = studentSnapshot.docs;

    final attendanceSnapshot =
    await FirebaseFirestore.instance.collection("attendance").get();
    Map<String, double> attendanceMap = {};
    for (var doc in attendanceSnapshot.docs) {
      var data = doc.data();
      attendanceMap["${data['studentName']}_${data['className']}"] =
          (data['attendancePercentage'] ?? 0).toDouble();
    }

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text("Attendance Report - ${widget.className}",
                  style: pw.TextStyle(
                      fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Table(
                border: pw.TableBorder.all(width: 1),
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.blue),
                    children: [
                      _pdfCell("Name", isHeader: true),
                      _pdfCell("ID", isHeader: true),
                      _pdfCell("Attendance %", isHeader: true),
                    ],
                  ),
                  ...students.map((student) {
                    var studentData = student.data();
                    var name = studentData["name"] ?? "Unknown";
                    var id = studentData["id"] ?? "Unknown";
                    var attendanceKey = "${name}_${widget.className}";
                    var attendancePercentage = attendanceMap[attendanceKey] ?? 0.0;

                    PdfColor percentageColor = attendancePercentage < 45
                        ? PdfColors.red
                        : (attendancePercentage < 75 ? PdfColors.amber : PdfColors.black);

                    return pw.TableRow(
                      children: [
                        _pdfCell(name),
                        _pdfCell(id),
                        _pdfCell(
                          attendancePercentage.toStringAsFixed(2) + "%",
                          textColor: percentageColor,
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  pw.Widget _pdfCell(String text, {bool isHeader = false, PdfColor textColor = PdfColors.black}) {
    return pw.Padding(
      padding: pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          fontSize: 14,
          color: isHeader ? PdfColors.white : textColor,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }
}
