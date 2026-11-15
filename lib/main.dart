import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:project_monitoring_and_tracking/screens/login_page.dart';
import 'package:project_monitoring_and_tracking/screens/signup_page.dart';
import 'package:project_monitoring_and_tracking/themes/app_theme.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Load the .env file first
  await dotenv.load(fileName: ".env");
  
  // 2. Initialize Firebase using the loaded variables
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
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
