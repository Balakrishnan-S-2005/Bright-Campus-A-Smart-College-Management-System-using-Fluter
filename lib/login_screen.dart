import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
// Import screens for different roles
import 'Admin/Admin_home_screen.dart';
import 'Faculty/Faculty_Home_screen/Faculty_home.dart';
import 'Students/Studentclass1_screen.dart';
import 'Students/Studentclass2_screen.dart';
import 'Students/Studentclass3_screen.dart';
import 'Students/Studentclass4_screen.dart';
import 'Students/Studentclass5_screen.dart';
import 'Students/Studentclass6_screen.dart';
import 'Students/Studentclass7_screen.dart';
import 'Students/Studentclass8_screen.dart';


class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _authService = AuthService();
  final _firestoreService = FirestoreService();

  void login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    final user = await _authService.signInWithEmailPassword(email, password);

    if (user != null) {
      final userData = await _firestoreService.getUserDetails(email);
      if (userData != null) {
        final role = userData['role'];

        Widget nextScreen;
        if (role == 'student') {
          final studentClass = userData['class'];
          switch (studentClass) {
            case "BCA III 'A'":
              nextScreen = Class1HomeScreen();
              break;
            case "BCA III 'B'":
              nextScreen = Class2HomeScreen();
              break;
            case "BCA II 'A'":
              nextScreen = Class3HomeScreen();
              break;
            case "BCA II 'B'":
              nextScreen = Class4HomeScreen();
              break;
            case "BCA II 'C'":
              nextScreen = Class5HomeScreen();
              break;
            case "BCA I 'A'":
              nextScreen = Class6HomeScreen();
              break;
            case "BCA I 'B'":
              nextScreen = Class7HomeScreen();
              break;
            case "BCA I 'C'":
              nextScreen = Class8HomeScreen();
              break;
            default:
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Unknown class for student!')));
              return;
          }
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => nextScreen),
          );
        } else if (role == 'faculty') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => FacultyHomeScreen()),
          );
        } else if (role == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => AdminHomeScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Unknown role!')));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User data not found!')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Column(
        children: [
          // Top Half (60%) with Image
          Flexible(
            flex: 6, // 60% of screen
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xFF674AEF), // Purple background
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
              child: Center(
                child: Image.asset(
                  "images/login3.png",
                  height: screenHeight * 0.50, // 25% of screen height
                ),
              ),
            ),
          ),

          // Bottom Half (40%) with Login Form
          Flexible(
            flex: 4, // 40% of screen
            child: SingleChildScrollView(
              child: Container(
                width: double.infinity,
                color: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Welcome Back!",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF674AEF),
                      ),
                    ),
                    SizedBox(height: 15),
                    _buildTextField(emailController, "Email"),
                    SizedBox(height: 10),
                    _buildTextField(passwordController, "Password", obscureText: true),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF674AEF), // Purple button
                        foregroundColor: Colors.white, // White text
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        "Login",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText, {bool obscureText = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.grey[200], // Light grey background for text fields
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}