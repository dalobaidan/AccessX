import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mobile_project/firebase_options.dart';
import 'services/mqtt_service.dart';

import 'pages/splash.dart';
import 'pages/welcome.dart';
import 'pages/tutorial.dart';
import 'pages/account.dart';
import 'pages/sign_up.dart';
import 'pages/login_first.dart';
import 'pages/signup_complete.dart';
import 'pages/dashboard.dart';
import 'pages/appointments.dart';
import 'pages/view_appointments.dart';
import 'pages/specialities.dart';
import 'pages/book_doctor.dart';
import 'pages/select_month.dart';
import 'pages/select_week.dart';
import 'pages/select_day.dart';
import 'pages/select_time.dart';
import 'pages/confirmation.dart';
import 'pages/contacts.dart';
import 'pages/prescriptions.dart';
import 'pages/profile.dart';
import 'pages/lab_results.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MainApp());

  // connect after the first frame so the iOS run loop is fully established
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    try {
      await mqttService.connect('192.168.8.190');
    } catch (e) {
      print('MQTT failed silently: $e');
    }
  });
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const Splash(),
      routes: {
        '/splash': (context) => const Splash(),
        '/welcome': (context) => const Welcome(),
        '/tutorial': (context) => const Tutorial(),
        '/account': (context) => const Account(),
        '/sign_up': (context) => const SignUp(),
        '/login_first': (context) => const LoginFirst(),
        '/signup_complete': (context) => const SignUpComplete(),
        '/dashboard': (context) => const Dashboard(),
        '/appointments': (context) => const Appointments(),
        '/view_appointments': (context) => const ViewAppointments(),
        '/specialities': (context) => const Specialities(),
        '/book_doctor': (context) => const BookDoctor(specialty: 'Cardiology'),
        '/select_month': (context) => const SelectMonth(
              doctorName: 'Dr. Sarah Mohammed',
              hospital: 'Dr. Alhabib - Takhasussi',
              specialty: 'Cardiology',
            ),
        '/select_week': (context) => const SelectWeek(
              doctorName: 'Dr. Sarah Mohammed',
              hospital: 'Dr. Alhabib - Takhasussi',
              specialty: 'Cardiology',
              month: 'April',
            ),
        '/select_day': (context) => const SelectDay(
              doctorName: 'Dr. Sarah Mohammed',
              hospital: 'Dr. Alhabib - Takhasussi',
              specialty: 'Cardiology',
              month: 'April',
              week: 'Apr 5 - Apr 11',
            ),
        '/select_time': (context) => const SelectTime(
              doctorName: 'Dr. Sarah Mohammed',
              hospital: 'Dr. Alhabib - Takhasussi',
              specialty: 'Cardiology',
              month: 'April',
              week: 'Apr 5 - Apr 11',
              day: 'Tue 28',
            ),
        '/confirmation': (context) => const Confirmation(
              doctorName: 'Dr. Sarah Mohammed',
              hospital: 'Dr. Alhabib - Takhasussi',
              specialty: 'Cardiology',
              month: 'April',
              week: 'Apr 5 - Apr 11',
              day: 'Tue 28',
              time: '9:00',
            ),
        '/contacts': (context) => const Contacts(),
        '/prescriptions': (context) => const Prescriptions(),
        '/profile': (context) => const Profile(),
        '/lab_results': (context) => const LabResults(),
      },
    );
  }
}
