// frontend/lib/config/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF3B82F6),
    scaffoldBackgroundColor: const Color(0xFFF5F7FB),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF3B82F6),
      secondary: Color(0xFF60A5FA),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      foregroundColor: Color(0xFF0F172A),
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Color(0xFF0F172A),
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
