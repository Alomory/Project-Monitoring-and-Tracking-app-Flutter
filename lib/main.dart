import 'package:flutter/material.dart';
import 'package:project_monitoring_and_tracking/screens/login_page.dart';
import 'package:project_monitoring_and_tracking/screens/signup_page.dart';
import 'package:project_monitoring_and_tracking/themes/app_theme.dart';


void main() {
  runApp( MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) =>  LoginPage(),
        '/signup_page': (context) => const SignUpPage(),
      },
      theme: AppTheme.getTheme(),

    );
  }
}
