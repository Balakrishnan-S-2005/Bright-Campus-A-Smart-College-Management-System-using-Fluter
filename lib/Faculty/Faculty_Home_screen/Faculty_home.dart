import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../info_screen.dart';
import '../../login_screen.dart';
import '../Faculty_calender_screen.dart';
import 'Faculty_classhome_screen.dart';
import 'package:bpc/Faculty/Faculty_Leave/Faculty_Leave_screen.dart';
import 'package:bpc/Faculty/Faculty_notification_screen.dart';

class FacultyHomeScreen extends StatefulWidget {
  @override
  _FacultyHomeScreenState createState() => _FacultyHomeScreenState();
}

class _FacultyHomeScreenState extends State<FacultyHomeScreen> {
  int _selectedIndex = 0;
  String _facultyId = ""; // Store Faculty ID

  @override
  void initState() {
    super.initState();
    _fetchFacultyId(); // Fetch Faculty ID on screen load
  }

  // Fetch Faculty ID from Firestore
  Future<void> _fetchFacultyId() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String email = user.email ?? "";

        // Query Firestore to find faculty details
        var querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: email)
            .where('role', isEqualTo: 'faculty')
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          setState(() {
            _facultyId = querySnapshot.docs.first['facultyID'] ?? "";
          });
        } else {
          Fluttertoast.showToast(msg: "Faculty details not found.");
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error fetching faculty ID: $e");
    }
  }

  // Navigation bar actions
  void _onItemTapped(int index) {
    if (index == 3) {
      _showLogoutDialog(); // Show logout confirmation
    } else {
      setState(() {
        _selectedIndex = index;
      });

      switch (index) {
        case 1:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NotificationsScreen()),
          );
          break;
        case 2:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FacultyCalendarScreen()),
          );
          break;
      }
    }
  }

  // Show logout confirmation dialog
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
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text("Logout"),
              onPressed: () async {
                Navigator.of(context).pop(true);
                try {
                  await FirebaseAuth.instance.signOut();
                  Fluttertoast.showToast(msg: "Logged out successfully");
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                        (Route<dynamic> route) => false,
                  );
                } catch (e) {
                  Fluttertoast.showToast(msg: "Logout failed. Try again.");
                }
              },
            ),
          ],
        );
      },
    ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    List<String> classNames = [
      "BCA III 'A'", "BCA III 'B'", "BCA II 'A'", "BCA II 'B'",
      "BCA II 'C'", "BCA I 'A'", "BCA I 'B'", "BCA I 'C'",
    ];

    return WillPopScope(
      onWillPop: _showLogoutDialog,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Faculty Home", style: TextStyle(color: Colors.white)),
          backgroundColor: Color(0xFF674AEF),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: classNames.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ClassHomeScreen(className: classNames[index]),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 4,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.school, size: 50, color: Color(0xFF674AEF)),
                            SizedBox(height: 8),
                            Text(
                              classNames[index],
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              _buildFacultyLeaveButton(), // Faculty Leave Button
              _buildAboutusButton(),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: Colors.deepPurple,
          unselectedItemColor: Colors.black54,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Notifications"),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Calendar"),
            BottomNavigationBarItem(icon: Icon(Icons.logout), label: "Logout"),
          ],
        ),
      ),
    );
  }

  Widget _buildFacultyLeaveButton() {
    return GestureDetector(
      onTap: () {
        if (_facultyId.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FacultyLeaveRequestScreen(facultyId: _facultyId)),
          );
        } else {
          Fluttertoast.showToast(msg: "Faculty ID not available.");
        }
      },
      child: Card(
        elevation: 4,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Faculty Leave",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF674AEF)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAboutusButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => InfoPage()),
        );
      },
      child: Card(
        elevation: 4,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "About Us",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF674AEF)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
