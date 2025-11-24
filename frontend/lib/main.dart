// frontend/lib/main.dart
import 'package:flutter/material.dart';
import 'package:waterpulse/config/app_theme.dart';
import 'package:waterpulse/ui/screens/home_screen.dart';

void main() {
  runApp(const WaterPulseApp());
}

class WaterPulseApp extends StatelessWidget {
  const WaterPulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WaterPulse',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}
