import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final waterColorProvider = StateNotifierProvider<WaterColorNotifier, Color>((ref) {
  return WaterColorNotifier();
});

class WaterColorNotifier extends StateNotifier<Color> {
  static const _prefsKey = 'water_drop_color';
  static const _defaultColor = Color(0xFF2285FE); // The original blue

  WaterColorNotifier() : super(_defaultColor) {
    _loadColor();
  }

  Future<void> _loadColor() async {
    final prefs = await SharedPreferences.getInstance();
    final colorValue = prefs.getInt(_prefsKey);
    if (colorValue != null) {
      state = Color(colorValue);
    }
  }

  Future<void> setColor(Color color) async {
    state = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefsKey, color.value);
  }

  Future<void> resetToDefault() async {
    await setColor(_defaultColor);
  }
}
