import 'package:bpc/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../info_screen.dart';
import 'Student_attendance_screen.dart';
import 'Student_calender_screen.dart';
import 'Student_classroutine_screen.dart';
import 'Student_facultylist_screen.dart';
import 'Student_fees_screen.dart';
import 'Student_markreview_screen.dart';
import 'Student_notification_screen.dart';

class Class1HomeScreen extends StatefulWidget {
  @override
  _Class1HomeScreenState createState() => _Class1HomeScreenState();
}

class _Class1HomeScreenState extends State<Class1HomeScreen> {
  String studentName = "";
  String className = "";
  bool isLoading = true;
  int _selectedIndex = 0; // For bottom navigation

  @override
  void initState() {
    super.initState();
    getStudentDetails();
  }

  Future<void> getStudentDetails() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print("No user logged in.");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No user logged in.")),
      );
      return;
    }

    try {
      QuerySnapshot studentQuery = await FirebaseFirestore.instance
          .collection('students')
          .where('name', isEqualTo: user.displayName) // Fetch by Name
          .limit(1)
          .get();

      if (studentQuery.docs.isNotEmpty) {
        var studentDoc = studentQuery.docs.first;
        setState(() {
          studentName = studentDoc['name'];
          className = studentDoc['class'];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Student details not found!")),
        );
      }
    } catch (e) {
      print("Error fetching student details: $e");
    }
  }

  void _onItemTapped(int index) {
    if (index == 3) {
      _showLogoutDialog(); // Call the logout confirmation
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Future<bool> _showLogoutDialog() async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Logout"),
          content: Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop(false); // Stay on the page
              },
            ),
            TextButton(
              child: Text("Logout"),
              onPressed: () async {
                Navigator.of(context).pop(true); // Close the dialog first

                try {
                  await FirebaseAuth.instance.signOut(); // Sign out

                  // Show Toast Notification
                  Fluttertoast.showToast(
                    msg: "Logged out successfully",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.black54,
                    textColor: Colors.white,
                  );

                  // Navigate to LoginScreen and remove previous routes
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                        (Route<dynamic> route) => false,
                  );
                } catch (e) {
                  print("Error logging out: $e");
                  Fluttertoast.showToast(
                    msg: "Logout failed. Try again.",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                  );
                }
              },
            ),
          ],
        );
      },
    ) ??
        false; // Default to false if the dialog is dismissed
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      _buildHomeScreen(),
      NotificationsScreen(),
      studentCalendarScreen(),
      Container(), // Placeholder for logout
    ];

    return WillPopScope(
      onWillPop: () async {
        return await _showLogoutDialog(); // Show logout confirmation when back button is pressed
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Class III BCA "A"', style: TextStyle(color: Colors.white)),
          backgroundColor: Color(0xFF674AEF),
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : pages[_selectedIndex], // Your existing home screen content
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: Colors.deepPurple,
          unselectedItemColor: Colors.grey,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Notifications"),
            BottomNavigationBarItem(icon: Icon(Icons.event), label: "Calendar"),
            BottomNavigationBarItem(icon: Icon(Icons.exit_to_app), label: "Logout"),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeScreen() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        children: [
          _buildGridItem(Icons.check, "Attendance", () {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) => StudentAttendanceScreen(),
            ));
          }),
          _buildGridItem(Icons.schedule, "Class Routine", () {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) => StudentRoutineScreen(),
            ));
          }),
          _buildGridItem(Icons.assessment, "Mark Review", () {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) => StudentMarksScreen(),
            ));
          }),
          _buildGridItem(Icons.people, "Faculty List", () {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) => FacultyListScreen(className: className),
            ));
          }),
          _buildGridItem(Icons.payment, "Fees", () {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) => FeesStructureScreen(),
            ));
          }),
          _buildGridItem(Icons.info, "About Us", () {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) => InfoPage(),
            ));
          }),
        ],
      ),
    );
  }

  Widget _buildGridItem(IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Color(0xFF674AEF)),
            SizedBox(height: 10),
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}