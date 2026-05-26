import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const RacingBetApp());
}

class RacingBetApp extends StatelessWidget {
  const RacingBetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Racing Bet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFFFD700), // Gold
        scaffoldBackgroundColor: const Color(0xFF0F0F0F),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFFD700),
          brightness: Brightness.dark,
          primary: const Color(0xFFFFD700),
          secondary: Colors.redAccent,
        ),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
