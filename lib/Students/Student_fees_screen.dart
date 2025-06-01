import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:flutter/services.dart' show rootBundle;

class FeesStructureScreen extends StatefulWidget {
  @override
  _FeesStructureScreenState createState() => _FeesStructureScreenState();
}

class _FeesStructureScreenState extends State<FeesStructureScreen> {
  int _selectedSemester = 1;
  String _status = "Not Paid";
  File? _receiptImage;
  String? _studentName;
  String? _studentEmail;

  final List<Map<String, dynamic>> feesData = [
    {"semester": "Semester 1", "tuition": 15000, "exam": 2000, "total": 17000},
    {"semester": "Semester 2", "tuition": 15000, "exam": 2000, "total": 17000},
    {"semester": "Semester 3", "tuition": 15500, "exam": 2000, "total": 17500},
    {"semester": "Semester 4", "tuition": 15500, "exam": 2000, "total": 17500},
    {"semester": "Semester 5", "tuition": 16000, "exam": 2500, "total": 18500},
    {"semester": "Semester 6", "tuition": 16000, "exam": 2500, "total": 18500},
  ];

  @override
  void initState() {
    super.initState();
    _fetchStudentDetails();
  }

  Future<void> _fetchStudentDetails() async {
    var user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    var querySnapshot = await FirebaseFirestore.instance
        .collection('students')
        .where('email', isEqualTo: user.email)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      var studentData = querySnapshot.docs.first.data();
      setState(() {
        _studentName = studentData['name'];
        _studentEmail = studentData['email'];
      });
      _fetchFeeStatus();
    }
  }

  Future<void> _fetchFeeStatus() async {
    if (_studentName == null) return;

    var feeDoc = await FirebaseFirestore.instance
        .collection('students')
        .doc(_studentName)
        .collection('fees')
        .doc('semester_$_selectedSemester')
        .get();

    setState(() {
      _status = feeDoc.exists ? (feeDoc.data()?['status'] ?? "Not Paid") : "Not Paid";
    });
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker _picker = ImagePicker();
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);

      if (pickedFile != null) {
        setState(() {
          _receiptImage = File(pickedFile.path);
        });
        if (_studentEmail != null) {
          await _uploadToGoogleDrive(_receiptImage!, _studentEmail!);
        }
      }
    } catch (e) {
      print("🔥 Error picking image: $e");
    }
  }

  Future<void> _uploadToGoogleDrive(File imageFile, String studentEmail) async {
    try {
      final credentials = await rootBundle.loadString('assests/service_account.json');
      final accountCredentials = auth.ServiceAccountCredentials.fromJson(jsonDecode(credentials));

      final authClient = await auth.clientViaServiceAccount(accountCredentials, [drive.DriveApi.driveFileScope]);
      final driveApi = drive.DriveApi(authClient);

      String? folderId = await _getOrCreateFolder(driveApi, studentEmail);
      if (folderId == null) throw Exception("Failed to create/find folder for $studentEmail");

      var fileMetadata = drive.File()
        ..name = "receipt_semester_$_selectedSemester.jpg"
        ..parents = [folderId];

      var media = drive.Media(imageFile.openRead(), imageFile.lengthSync());
      var uploadedFile = await driveApi.files.create(fileMetadata, uploadMedia: media);

      String fileUrl = "https://drive.google.com/uc?id=${uploadedFile.id}";

      await FirebaseFirestore.instance
          .collection('students')
          .doc(_studentName)
          .collection('fees')
          .doc('semester_$_selectedSemester')
          .set({
        "status": "Paid",
        "receiptUrl": fileUrl,
      }, SetOptions(merge: true));

      setState(() {
        _status = "Paid";
      });

      print("✅ File uploaded: $fileUrl");
    } catch (e) {
      print("🔥 Error uploading to Google Drive: $e");
    }
  }

  Future<String?> _getOrCreateFolder(drive.DriveApi driveApi, String studentEmail) async {
    var folderQuery = "mimeType='application/vnd.google-apps.folder' and name='$studentEmail'";
    var response = await driveApi.files.list(q: folderQuery);

    if (response.files != null && response.files!.isNotEmpty) {
      return response.files!.first.id;
    }

    var folderMetadata = drive.File()
      ..name = studentEmail
      ..mimeType = "application/vnd.google-apps.folder";

    var createdFolder = await driveApi.files.create(folderMetadata);
    return createdFolder.id;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Fees Structure",
        style: TextStyle(color: Colors.white),
      ),
        backgroundColor: Color(0xFF674AEF),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // **Fees Structure Table**
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(Colors.deepPurple.shade600),
                border: TableBorder.all(color: Colors.black, width: 1),
                columns: const [
                  DataColumn(label: Text('Semester', style: TextStyle(color: Colors.white))),
                  DataColumn(label: Text('Tuition Fees', style: TextStyle(color: Colors.white))),
                  DataColumn(label: Text('Exam Fees', style: TextStyle(color: Colors.white))),
                  DataColumn(label: Text('Total Fees', style: TextStyle(color: Colors.white))),
                ],
                rows: feesData.map((data) {
                  return DataRow(cells: [
                    DataCell(Text(data['semester'])),
                    DataCell(Text('₹${data['tuition']}')),
                    DataCell(Text('₹${data['exam']}')),
                    DataCell(Text('₹${data['total']}')),
                  ]);
                }).toList(),
              ),
            ),
            SizedBox(height: 20),

            // **Semester Selection**
            DropdownButton<int>(
              value: _selectedSemester,
              items: List.generate(6, (index) => DropdownMenuItem(
                value: index + 1,
                child: Text("Semester ${index + 1}",style: TextStyle(fontSize: 20),),
              )),
              onChanged: (newValue) {
                setState(() {
                  _selectedSemester = newValue!;
                });
                _fetchFeeStatus();
              },
            ),
            SizedBox(height: 10,),

            Text("Fee Status: $_status",style: TextStyle(fontSize: 20),),
            SizedBox(height: 30),

            ElevatedButton(
              onPressed: _pickImage,
              child: Text("Capture Receipt"),
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