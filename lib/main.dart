import 'dart:io';
import 'package:bpc/welcome_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  Platform.isAndroid?
  await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyAAuEZwmBmJV36pcFgdL4RHtIde3wYIovU",
        appId: "1:572039761466:android:4e96dd3f5fbbe592e2af03",
        messagingSenderId: "572039761466",
        projectId: "bkpopz-3ac54",)
  )
      :await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Welcomescreen(),
    );
  }
}
