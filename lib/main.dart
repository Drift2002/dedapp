import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/assessment_screen.dart';
import 'screens/result_screen.dart';

void main() {
  runApp(const OcularCareApp());
}

class OcularCareApp extends StatelessWidget {
  const OcularCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OcularCare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF10141D),
        primaryColor: const Color(0xFF2F80ED),
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme.apply(
            bodyColor: Colors.white,
            displayColor: Colors.white,
          ),
        ),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF2F80ED),
          secondary: Color(0xFF2F80ED),
          surface: Color(0xFF1E2636),
          background: Color(0xFF10141D),
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/assessment': (context) => const AssessmentScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/result') {
          final args = settings.arguments as File?;
          return MaterialPageRoute(
            builder: (context) => ResultScreen(image: args),
          );
        }
        return null;
      },
    );
  }
}
