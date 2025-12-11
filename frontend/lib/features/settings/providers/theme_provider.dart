import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, String>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<String> {
  ThemeNotifier() : super('dark') {
    _loadTheme();
  }

  static const _key = 'theme_key';

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_key);
    state = savedTheme ?? 'dark';
  }

  Future<void> setTheme(String key) async {
    state = key;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, key);
  }
}
