import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentManagementScreen extends StatefulWidget {
  final String className;
  StudentManagementScreen({required this.className});

  @override
  _StudentManagementScreenState createState() => _StudentManagementScreenState();
}

class _StudentManagementScreenState extends State<StudentManagementScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController idController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController dobController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Manage Students",style: TextStyle(color: Colors.white),),backgroundColor: Color(0xFF674AEF),),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('students').where('class', isEqualTo: widget.className).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No students found"));
          }

          var students = snapshot.data!.docs;

          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              var student = students[index];
              return ListTile(
                title: Text(student['name']),
                subtitle: Text(student['email']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue,),
                      onPressed: () => showStudentDialog(student: student),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => deleteStudent(student['name'], student['email']),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => showStudentDialog(),
      ),
    );
  }

  // 🔹 Add Student Function
  void addStudent() async {
    if (idController.text.isNotEmpty &&
        nameController.text.isNotEmpty &&
        emailController.text.isNotEmpty) {
      try {
        String studentID = idController.text.trim();
        String studentEmail = emailController.text.trim();
        String studentPassword = "${studentID}TNC"; // Default password
        String studentName = nameController.text.trim();

        // Create student in Firebase Authentication
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: studentEmail,
          password: studentPassword,
        );

        // Store student details in Firestore
        await _firestore.collection('students').doc(studentName).set({
          'id': studentID,
          'name': studentName,
          'email': studentEmail,
          'phone': phoneController.text,
          'age': int.tryParse(ageController.text) ?? 0, // Ensure age is stored as int
          'dob': dobController.text,
          'class': widget.className,
        });

        await _firestore.collection('users').doc(studentEmail).set({
          'email': studentEmail,
          'role': 'student',
          'class': widget.className,
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Student added successfully")));
        _clearFields();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
      }
    }
  }

  // 🔹 Update Student Function
  void updateStudent(String oldStudentName, String oldEmail, Map<String, dynamic> updatedData) async {
    try {
      String newStudentName = updatedData['name'];
      String newEmail = updatedData['email'];

      // Delete old authentication user if email changed
      if (newEmail != oldEmail) {
        List<String> signInMethods = await _auth.fetchSignInMethodsForEmail(oldEmail);
        if (signInMethods.isNotEmpty) {
          UserCredential userCredential = await _auth.signInWithEmailAndPassword(
            email: oldEmail,
            password: "${updatedData['id']}TNC",
          );
          await userCredential.user?.delete();
        }

        // Create new authentication user
        await _auth.createUserWithEmailAndPassword(
          email: newEmail,
          password: "${updatedData['id']}NBA",
        );
      }

      // Delete old student document if name changed
      if (oldStudentName != newStudentName) {
        await _firestore.collection('students').doc(oldStudentName).delete();
      }

      // Delete old users collection entry if email changed
      if (newEmail != oldEmail) {
        await _firestore.collection('users').doc(oldEmail).delete();
      }

      // Create new student document
      updatedData['age'] = int.tryParse(updatedData['age']) ?? 0; // Ensure age is stored as int

      await _firestore.collection('students').doc(newStudentName).set(updatedData);
      await _firestore.collection('users').doc(newEmail).set({
        'email': newEmail,
        'role': 'student',
        'class': updatedData['class'],
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Student details updated successfully")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    }
  }

  // 🔹 Delete Student Function
  void deleteStudent(String studentName, String email) async {
    try {
      await _firestore.collection('students').doc(studentName).delete();
      await _firestore.collection('users').doc(email).delete();

      List<String> signInMethods = await _auth.fetchSignInMethodsForEmail(email);
      if (signInMethods.isNotEmpty) {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: "${studentName}TNC",
        );
        await userCredential.user?.delete();
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Student removed successfully")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    }
  }

  // 🔹 Show Add/Edit Student Dialog
  void showStudentDialog({DocumentSnapshot? student}) {
    if (student != null) {
      idController.text = student.get('id').toString();
      nameController.text = student.get('name');
      emailController.text = student.get('email');
      phoneController.text = student.data().toString().contains('phone') ? student.get('phone') : "";
      ageController.text = student.data().toString().contains('age') ? student.get('age').toString() : "";
      dobController.text = student.data().toString().contains('dob') ? student.get('dob') : "";
    } else {
      _clearFields();
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(student == null ? "Add Student" : "Edit Student"),
          content: SingleChildScrollView(  // ✅ Wrap content in SingleChildScrollView
            child: Column(
              mainAxisSize: MainAxisSize.min, // ✅ Prevent unnecessary expansion
              children: [
                _buildTextField(idController, "Student ID"),
                _buildTextField(nameController, "Student Name"),
                _buildTextField(emailController, "Student Email"),
                _buildTextField(phoneController, "Phone Number"),
                _buildTextField(ageController, "Age"),
                _buildTextField(dobController, "Date of Birth"),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                if (student == null) {
                  addStudent();
                } else {
                  updateStudent(student.get('name'), student.get('email'), {
                    'id': idController.text,
                    'name': nameController.text,
                    'email': emailController.text,
                    'phone': phoneController.text,
                    'age': ageController.text,
                    'dob': dobController.text,
                    'class': widget.className,
                  });
                }
                Navigator.pop(context);
              },
              child: Text(student == null ? "Add" : "Save"),
            ),
          ],
        );
      },
    );
  }


  // 🔹 Function to Build Input Fields
  Widget _buildTextField(TextEditingController controller, String labelText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  void _clearFields() {
    idController.clear();
    nameController.clear();
    emailController.clear();
    phoneController.clear();
    ageController.clear();
    dobController.clear();
  }
}