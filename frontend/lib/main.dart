// frontend/lib/main.dart
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:waterpulse/config/app_theme.dart';
import 'package:waterpulse/services/notification_service.dart';
import 'package:waterpulse/features/settings/providers/theme_provider.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waterpulse/core/router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:waterpulse/l10n/generated/app_localizations.dart';
import 'package:waterpulse/features/settings/providers/language_provider.dart';

Future<void> main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    try {
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
          await windowManager.ensureInitialized();
          await windowManager.setMinimumSize(const Size(1100, 720));
      }
    } catch (e) {
      debugPrint('Error setting window size: $e');
    }

    try {
      final notificationService = NotificationService();
      await notificationService.init();
      // notificationService.schedulePeriodicNotification(); (Removed)
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }

    runApp(const ProviderScope(child: WaterPulseApp()));
  }, (error, stack) {
    debugPrint('Unhandled error: $error');
    debugPrint(stack.toString());
  });
}

class WaterPulseApp extends ConsumerWidget {
  const WaterPulseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeKey = ref.watch(themeProvider);
    final themeData = AppTheme.getTheme(themeKey);
    final locale = ref.watch(languageProvider);

    return MaterialApp.router(
      title: 'WaterPulse',
      debugShowCheckedModeBanner: false,
      theme: themeData,
      themeMode: ThemeMode.light, // Always use the 'theme' property which we update dynamically
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('tr'),
      ],
      routerConfig: ref.watch(routerProvider),
    );
  }
}
