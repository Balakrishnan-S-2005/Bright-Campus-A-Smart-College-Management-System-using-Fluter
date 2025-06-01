import 'package:bpc/Admin/Admin_Facultyleave_screen.dart';
import 'package:bpc/Admin/Admin_notification_screen.dart';
import 'package:bpc/info_screen.dart';
import 'package:bpc/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'Admin_Facultyoverview_screen.dart';
import 'Admin_Mainscreen.dart';
import 'Admin_addFaculty_screen.dart';
import 'Admin_calender_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index == 4) {
      _showLogoutDialog();
    } else {
      setState(() {
        _selectedIndex = index;
      });

      switch (index) {
        case 1:
          Navigator.push(context, MaterialPageRoute(builder: (context) => AdminNotificationsScreen()));
          break;
        case 2:
          Navigator.push(context, MaterialPageRoute(builder: (context) => AdminCalendarScreen()));
          break;
        case 3:
          Navigator.push(context, MaterialPageRoute(builder: (context) => AdminLeaveApprovalScreen()));
          break;
      }
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
              onPressed: () => Navigator.of(context).pop(false),
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
      "BCA II 'C'", "BCA I 'A'", "BCA I 'B'", "BCA I 'C'"
    ];

    return WillPopScope(
      onWillPop: _showLogoutDialog,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Admin Home", style: TextStyle(color: Colors.white)),
          backgroundColor: Color(0xFF674AEF),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildAddFacultyButton(),
              _buildFacultyOverviewButton(), // Faculty Overview Button
              SizedBox(height: 10),
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
                            builder: (context) => ClassDetailScreen(className: classNames[index]),
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
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Faculty Leaves"),
            BottomNavigationBarItem(icon: Icon(Icons.logout), label: "Logout"),
          ],
        ),
      ),
    );
  }

  Widget _buildFacultyOverviewButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FacultyOverviewScreen()),
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
                "Faculty Overview",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF674AEF)),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.black54, size: 18),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildAddFacultyButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddFacultyScreen()),
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
                "Add Faculty",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF674AEF)),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.black54, size: 18),
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