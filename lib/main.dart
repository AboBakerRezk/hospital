import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'ai/DoctorDashboardScreen.dart';
import 'ai/analytics_screen.dart';
import 'home/splash_screen.dart';
import 'home/login_screen.dart';
import 'home/signup_screen.dart';
import 'home/home_screen.dart';
import 'page/patients_list_screen.dart';
import 'page/patient_detail_screen.dart';
import 'page/settings_screen.dart';
import 'ai/chat_screen.dart';
import 'ai/ClinicalNotesSummarizerScreen.dart';
import 'ai/ClinicalRiskAssessmentScreen.dart';
import 'ai/DifferentialDiagnosisScreen.dart';
import 'ai/TreatmentRecommendationScreen.dart';
import 'data/db_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await DBHelper().init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Health Assistant',
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
        '/doctorAnalytics': (context) => DoctorAnalyticsScreen(),
        '/clinicalNotesSummarizer': (context) => ClinicalNotesSummarizerScreen(),
        '/clinicalRiskAssessment': (context) => ClinicalRiskAssessmentScreen(),
        '/differentialDiagnosis': (context) => DifferentialDiagnosisScreen(),
        '/medicationInteraction': (context) => MedicationInteractionScreen(),
        '/treatmentRecommendation': (context) => TreatmentRecommendationScreen(),
      },
    );
  }
}
