// frontend/lib/main.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:window_size/window_size.dart' as window_size;
import 'package:waterpulse/config/app_theme.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waterpulse/core/router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    // Masaüstünde pencereyi çok küçültemeyelim
    window_size.setWindowMinSize(const Size(1100, 720));
  }
  runApp(const ProviderScope(child: WaterPulseApp()));
}

class WaterPulseApp extends StatelessWidget {
  const WaterPulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'WaterPulse',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
