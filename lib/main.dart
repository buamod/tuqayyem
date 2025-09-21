import 'package:flutter/material.dart';
import 'pages/landing.dart';

void main() {
  runApp(const TuqayyemApp());
}

class TuqayyemApp extends StatelessWidget {
  const TuqayyemApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tuqayyem',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2196F3), // Bright blue
          brightness: Brightness.light,
        ),
        cardTheme: const CardThemeData(
          elevation: 2,
          margin: EdgeInsets.all(8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
      home: const LandingPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
