// frontend/lib/config/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  static const Color neonColor = Color(0xFF00FFFF); // Cyan Neon

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
    useMaterial3: true,
    fontFamily: 'Inter', // Ensuring a modern font if set, otherwise falls back gracefully
    primaryColor: const Color(0xFF3B82F6), // Blue 500
    scaffoldBackgroundColor: const Color(0xFF020617), // Rich Midnight (Slate 950)
    cardColor: const Color(0xFF0F172A), // Deep Blue (Slate 900)
    canvasColor: const Color(0xFF020617),
    
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF3B82F6), // Blue 500
      secondary: Color(0xFF60A5FA), // Blue 400
      surface: Color(0xFF0F172A), // Deep Blue (Slate 900)
      background: Color(0xFF020617), // Rich Midnight
      onBackground: Color(0xFFF1F5F9), // Slate 100
      onSurface: Color(0xFFE2E8F0), // Slate 200
      surfaceTint: Color(0xFF3B82F6), // Subtle blue tint on surfaces
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF020617), // Matches background
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: Colors.white,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),

    cardTheme: CardThemeData(
      color: const Color(0xFF0F172A),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // Modern rounded corners
        side: const BorderSide(
          color: Color(0xFF1E293B), // Subtle border (Slate 800)
          width: 1,
        ),
      ),
      shadowColor: Colors.black54,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF3B82F6),
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF0F172A),
      contentPadding: const EdgeInsets.all(16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF1E293B)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF1E293B)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
      ),
      labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
      hintStyle: const TextStyle(color: Color(0xFF64748B)),
    ),

    iconTheme: const IconThemeData(
      color: Color(0xFF94A3B8), // Slate 400 for neutral icons
    ),
    
    dividerTheme: const DividerThemeData(
      color: Color(0xFF1E293B),
      thickness: 1,
    ),
  );

  // ==== FOREST THEMES ====
  static ThemeData forestLight = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    fontFamily: 'Inter',
    primaryColor: const Color(0xFF10B981), // Emerald 500
    scaffoldBackgroundColor: const Color(0xFFD1FAE5), // Emerald 100 (Pastel Mint)
    cardColor: const Color(0xFFECFDF5), // Emerald 50 (Tinted White)
    canvasColor: const Color(0xFFD1FAE5),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF10B981),
      secondary: Color(0xFF34D399),
      surface: Color(0xFFECFDF5),
      background: Color(0xFFD1FAE5),
      onBackground: Color(0xFF064E3B),
      onSurface: Color(0xFF064E3B),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFD1FAE5),
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: Color(0xFF064E3B),
      centerTitle: true,
      iconTheme: IconThemeData(color: Color(0xFF064E3B)),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFFECFDF5),
      elevation: 0,
      shadowColor: Colors.transparent, // Flat look for pastel
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF10B981), width: 0.5), // Subtle border
      ),
    ),
  );

  static ThemeData forestDark = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    fontFamily: 'Inter',
    primaryColor: const Color(0xFF10B981), // Emerald 500
    scaffoldBackgroundColor: const Color(0xFF0D1F16), // Very dark green
    cardColor: const Color(0xFF132A20), // Dark green surface
    canvasColor: const Color(0xFF0D1F16),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF10B981),
      secondary: Color(0xFF34D399),
      surface: Color(0xFF132A20),
      background: Color(0xFF0D1F16),
      onBackground: Color(0xFFECFDF5),
      onSurface: Color(0xFFD1FAE5),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0D1F16),
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: Colors.white,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.white),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF132A20),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF064E3B), width: 1),
      ),
    ),
  );

  // ==== SUNSET THEMES ====
  static ThemeData sunsetLight = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    fontFamily: 'Inter',
    primaryColor: const Color(0xFFF97316), // Orange 500
    scaffoldBackgroundColor: const Color(0xFFFFEDD5), // Orange 100 (Pastel Peach)
    cardColor: const Color(0xFFFFF7ED), // Orange 50
    canvasColor: const Color(0xFFFFEDD5),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFFF97316),
      secondary: Color(0xFFFB923C),
      surface: Color(0xFFFFF7ED),
      background: Color(0xFFFFEDD5),
      onBackground: Color(0xFF7C2D12),
      onSurface: Color(0xFF7C2D12),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFFFEDD5),
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: Color(0xFF7C2D12),
      centerTitle: true,
      iconTheme: IconThemeData(color: Color(0xFF7C2D12)),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFFFFF7ED),
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFF97316), width: 0.5),
      ),
    ),
  );

  static ThemeData sunsetDark = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    fontFamily: 'Inter',
    primaryColor: const Color(0xFFF97316), // Orange 500
    scaffoldBackgroundColor: const Color(0xFF1F120A), // Very dark orange/brown
    cardColor: const Color(0xFF2D1810), // Dark orange surface
    canvasColor: const Color(0xFF1F120A),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFF97316),
      secondary: Color(0xFFFB923C),
      surface: Color(0xFF2D1810),
      background: Color(0xFF1F120A),
      onBackground: Color(0xFFFFF7ED),
      onSurface: Color(0xFFFFEDD5),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1F120A),
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: Colors.white,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.white),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF2D1810),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF7C2D12), width: 1),
      ),
    ),
  );

  // ==== PINK THEMES ====
  static ThemeData pinkLight = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    fontFamily: 'Inter',
    primaryColor: const Color(0xFFEC4899), // Pink 500
    scaffoldBackgroundColor: const Color(0xFFFBCFE8), // Pink 200 (Darker Pink)
    cardColor: const Color(0xFFFCE7F3), // Pink 100 (Pink Surface)
    canvasColor: const Color(0xFFFBCFE8),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFFEC4899),
      secondary: Color(0xFFF472B6),
      surface: Color(0xFFFCE7F3),
      background: Color(0xFFFBCFE8),
      onBackground: Color(0xFF831843),
      onSurface: Color(0xFF831843),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFFBCFE8),
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: Color(0xFF831843),
      centerTitle: true,
      iconTheme: IconThemeData(color: Color(0xFF831843)),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFFFCE7F3),
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFEC4899), width: 0.5),
      ),
    ),
  );

  static ThemeData pinkDark = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    fontFamily: 'Inter',
    primaryColor: const Color(0xFFEC4899), // Pink 500
    scaffoldBackgroundColor: const Color(0xFF1F1016), // Very dark rose
    cardColor: const Color(0xFF2D1520), // Dark rose surface
    canvasColor: const Color(0xFF1F1016),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFEC4899),
      secondary: Color(0xFFF472B6),
      surface: Color(0xFF2D1520),
      background: Color(0xFF1F1016),
      onBackground: Color(0xFFFDF2F8),
      onSurface: Color(0xFFFCE7F3),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1F1016),
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: Colors.white,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.white),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF2D1520),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF831843), width: 1),
      ),
    ),
  );

  // ==== GALACTIC THEMES ====
  static ThemeData galacticLight = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    fontFamily: 'Inter',
    primaryColor: const Color(0xFF8B5CF6), // Violet 500
    scaffoldBackgroundColor: const Color(0xFFEDE9FE), // Violet 100 (Deep Pastel Violet)
    cardColor: const Color(0xFFF5F3FF), // Violet 50
    canvasColor: const Color(0xFFEDE9FE),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF8B5CF6),
      secondary: Color(0xFFA78BFA),
      surface: Color(0xFFF5F3FF),
      background: Color(0xFFEDE9FE),
      onBackground: Color(0xFF4C1D95),
      onSurface: Color(0xFF4C1D95),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFEDE9FE),
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: Color(0xFF4C1D95),
      centerTitle: true,
      iconTheme: IconThemeData(color: Color(0xFF4C1D95)),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFFF5F3FF),
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF8B5CF6), width: 0.5),
      ),
    ),
  );

  static ThemeData galacticDark = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    fontFamily: 'Inter',
    primaryColor: const Color(0xFF8B5CF6), // Violet 500
    scaffoldBackgroundColor: const Color(0xFF0F0B1E), // Deep Space
    cardColor: const Color(0xFF1A1633), // Space Surface
    canvasColor: const Color(0xFF0F0B1E),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF8B5CF6),
      secondary: Color(0xFFA78BFA),
      surface: Color(0xFF1A1633),
      background: Color(0xFF0F0B1E),
      onBackground: Color(0xFFF5F3FF),
      onSurface: Color(0xFFEDE9FE),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0F0B1E),
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: Colors.white,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.white),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF1A1633),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF4C1D95), width: 1),
      ),
    ),
  );

  static ThemeData getTheme(String key) {
    switch (key) {
      case 'light':
        return lightTheme;
      case 'forest_light':
        return forestLight;
      case 'sunset_light':
        return sunsetLight;
      case 'pink_light':
        return pinkLight;
      case 'galactic_light':
        return galacticLight;
      
      case 'forest':
      case 'forest_dark':
        return forestDark;
      case 'sunset':
      case 'sunset_dark':
        return sunsetDark;
      case 'pink':
      case 'pink_dark':
        return pinkDark;
      case 'galactic':
      case 'galactic_dark':
        return galacticDark;

      case 'dark':
      default:
        return darkTheme;
    }
  }
}
