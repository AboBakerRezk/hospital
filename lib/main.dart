// main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'db_helper.dart';
import 'splash_screen.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'home_screen.dart';
import 'patients_list_screen.dart';
import 'patient_detail_screen.dart';
import 'settings_screen.dart';
import 'chat_screen.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // تهيئة Firebase
  await DBHelper().init();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'مساعد الرعاية الصحية التنبؤية',
      theme: ThemeData(
        primaryColor: Colors.teal[700],
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/home': (context) => HomeScreen(),
        '/patients': (context) => PatientsListScreen(),
        '/patientDetail': (context) => PatientDetailScreen(),
        '/settings': (context) => SettingsScreen(),
        '/chat': (context) => ChatScreen(),
      },
    );
  }
}
