import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddFacultyScreen extends StatefulWidget {
  @override
  _AddFacultyScreenState createState() => _AddFacultyScreenState();
}

class _AddFacultyScreenState extends State<AddFacultyScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _FacultyIdController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _addFaculty() async {
    String name = _nameController.text.trim();
    String FacultyID = _FacultyIdController.text.trim();
    String email = _emailController.text.trim();
    String password = FacultyID + "NBA"; // Generate password

    if (name.isEmpty || email.isEmpty || FacultyID.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("All fields are required!")),
      );
      return;
    }

    try {
      // Create user in Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Store faculty details in Firestore
      await _firestore.collection("users").doc(email).set({
        "name": name,
        "role": "faculty",
        "email": email,
        "facultyID":FacultyID,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Faculty added successfully!")),
      );

      // Clear input fields
      _nameController.clear();
      _FacultyIdController.clear();
      _emailController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Faculty",style: TextStyle(color: Colors.white),),backgroundColor: Color(0xFF674AEF),),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "Faculty Name"),
            ),
            TextField(
              controller: _FacultyIdController,
              decoration: InputDecoration(labelText: "Faculty ID"),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "Email"),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addFaculty,
              child: Text("Add Faculty"),
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
