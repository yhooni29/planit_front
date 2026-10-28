
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const MeetSyncApp());
}

class MeetSyncApp extends StatelessWidget {
  const MeetSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PlanIt',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F7CFF),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      ),
      home: const LoginScreen(),
    );
  }
}
