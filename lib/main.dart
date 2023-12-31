import 'package:flutter/material.dart';
import 'package:newlogin/screens/coverpage.dart';
import 'package:newlogin/screens/login.dart';
import 'package:newlogin/screens/signup.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => CoverPage(),
        '/login': (context) => Login(),
        '/signup': (context) => Signup(),
      },
    );
  }
}
