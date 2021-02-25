import 'package:daily_steps/pagese/signup_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:daily_steps/daily_steps_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Hive.initFlutter();
  await Hive.openBox<int>('steps');
  runApp(MyApp());
}
//firebase auth

class MyApp extends StatelessWidget {
  User firebaseUser = FirebaseAuth.instance.currentUser;
  Widget firstWidget;

// Assign widget based on availability of currentUser
  @override
  Widget build(BuildContext context) {
    if (firebaseUser != null) {
      firstWidget = DailyStepsPage();
    } else {
      firstWidget = LoginPage();
    }
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Daily Steps',
      home: firstWidget,
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        textTheme: GoogleFonts.darkerGrotesqueTextTheme(
          Theme.of(context).textTheme,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData.dark().copyWith(
        textTheme: GoogleFonts.darkerGrotesqueTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
    );
//===============================================================================
  }
}
