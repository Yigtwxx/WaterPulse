// frontend/lib/config/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF2563EB), // Vibrant Blue
    scaffoldBackgroundColor: const Color(0xFFEFF6FF), // Blue 50
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF2563EB),
      secondary: Color(0xFF60A5FA),
      surface: Colors.white,
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

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF3B82F6),
    scaffoldBackgroundColor: const Color(0xFF0F172A), // Slate 900
    cardColor: const Color(0xFF1E293B), // Slate 800
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF3B82F6),
      secondary: Color(0xFF60A5FA),
      surface: Color(0xFF1E293B), // Slate 800
      onSurface: Color(0xFFF1F5F9), // Slate 100
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0F172A), // Slate 900
      elevation: 0,
      foregroundColor: Colors.white,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
