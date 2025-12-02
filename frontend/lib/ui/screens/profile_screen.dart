// frontend/lib/ui/screens/profile_screen.dart
//
// WaterPulse profil ekranı
// - Kullanıcı avatarı + isim + Login / Sign up
// - Günlük hedef ayarı (slider)
// - Bildirim ayarı (switch)
// - Basit "Save" butonu (şimdilik local)

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waterpulse/services/api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waterpulse/features/settings/providers/theme_provider.dart';
import 'package:waterpulse/l10n/generated/app_localizations.dart';
import 'package:waterpulse/features/settings/providers/language_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key, required this.initialGoal});

  final int initialGoal;

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final ApiClient _apiClient = ApiClient();
  late int _dailyGoal;
  bool _notificationsEnabled = true;

  // User state
  bool _isLoggedIn = false;
  String _username = "Guest";
  int? _userId;

  @override
  void initState() {
    super.initState();
    _dailyGoal = widget.initialGoal;
    _loadUserState();
  }

  Future<void> _loadUserState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('userId');
      final name = prefs.getString('name');
      final email = prefs.getString('email');
      _username = name ?? email ?? "Guest";
      _isLoggedIn = _userId != null;
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('name');
    await prefs.remove('email');
    setState(() {
      _userId = null;
      _username = "Guest";
      _isLoggedIn = false;
    });
  }

  Future<void> _showLoginDialog() async {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Log In', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email",
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: "Password",
                prefixIcon: const Icon(Icons.lock_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () async {
              final email = emailController.text.trim();
              final password = passwordController.text;
              if (email.isEmpty || password.isEmpty) return;

              try {
                final user = await _apiClient.login(email, password);
                final prefs = await SharedPreferences.getInstance();
                await prefs.setInt('userId', user['id']);
                await prefs.setString('email', user['email']);
                if (user['name'] != null) {
                  await prefs.setString('name', user['name']);
                }
                
                if (mounted) {
                  Navigator.pop(context);
                  _loadUserState();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Welcome back, ${user['name'] ?? user['email']}!')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Login failed. Check your credentials.')),
                  );
                }
              }
            },
            child: const Text('Log In'),
          ),
        ],
      ),
    );
  }

  Future<void> _showSignupDialog() async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController surnameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController weightController = TextEditingController();
    final TextEditingController heightController = TextEditingController();
    final TextEditingController ageController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign Up', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: "Name",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: surnameController,
                      decoration: InputDecoration(
                        labelText: "Surname",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: weightController,
                      decoration: InputDecoration(
                        labelText: "Weight (kg)",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: heightController,
                      decoration: InputDecoration(
                        labelText: "Height (cm)",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ageController,
                decoration: InputDecoration(
                  labelText: "Age",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () async {
              final name = nameController.text.trim();
              final surname = surnameController.text.trim();
              final email = emailController.text.trim();
              final password = passwordController.text;
              
              if (email.isEmpty || password.isEmpty) return;

              try {
                final userData = {
                  "name": name,
                  "surname": surname,
                  "email": email,
                  "password": password,
                  "weight_kg": double.tryParse(weightController.text),
                  "height_cm": double.tryParse(heightController.text),
                  "age": int.tryParse(ageController.text),
                  "daily_goal_ml": 2000, // Default
                };

                final user = await _apiClient.createUser(userData);
                final prefs = await SharedPreferences.getInstance();
                await prefs.setInt('userId', user['id']);
                await prefs.setString('email', user['email']);
                 if (user['name'] != null) {
                  await prefs.setString('name', user['name']);
                }

                if (mounted) {
                  Navigator.pop(context);
                  _loadUserState();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Account created! Welcome, ${user['name'] ?? user['email']}!')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Signup failed: $e')),
                  );
                }
              }
            },
            child: const Text('Sign Up'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _dailyGoal);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.profile),
          centerTitle: true,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, _dailyGoal),
          ),
        ),
        body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    const Color(0xFF0F172A), // Slate 900
                    const Color(0xFF1E293B), // Slate 800
                  ]
                : [
                    const Color(0xFFEFF6FF), // Blue 50
                    const Color(0xFFFFFFFF), // White
                  ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context, _dailyGoal),
                    ),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.profile,
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48), // To balance the back button
                  ],
                ),
                const SizedBox(height: 24),
                // ==== ÜST KISIM: AVATAR + İSİM + LOGIN / SIGN UP ====
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const _WaterAvatar(),
                    const SizedBox(width: 16),

                    // İsim + açıklama
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isLoggedIn ? _username : AppLocalizations.of(context)!.guestUser,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  _isLoggedIn
                                      ? AppLocalizations.of(context)!.keepHydrating(_username)
                                      : AppLocalizations.of(context)!.loginToSync,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text('💧'),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Login / Sign up butonları
                    if (!_isLoggedIn)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: _showLoginDialog,
                            child: Text(AppLocalizations.of(context)!.login),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: theme.colorScheme.primary,
                              side: BorderSide(
                                color: theme.colorScheme.primary,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: _showSignupDialog,
                            child: Text(AppLocalizations.of(context)!.signup),
                          ),
                        ],
                      )
                    else
                      IconButton(
                        onPressed: _logout,
                        icon: const Icon(Icons.logout, color: Colors.redAccent),
                        tooltip: AppLocalizations.of(context)!.logout,
                      ),
                  ],
                ),

                const SizedBox(height: 24),
                // ==== SETTINGS BÖLÜMÜ ====
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppLocalizations.of(context)!.settings,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 12),

                // ==== GÜNLÜK HEDEF KARTI ====
                _ProfileCard(
                  title: AppLocalizations.of(context)!.dailyGoal,
                  subtitle: AppLocalizations.of(context)!.dailyGoalSubtitle,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$_dailyGoal ml',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2563EB),
                        ),
                      ),
                      Slider(
                        value: _dailyGoal.toDouble(),
                        min: 1200,
                        max: 4000,
                        divisions: (4000 - 1200) ~/ 200,
                        label: '$_dailyGoal ml',
                        onChanged: (value) {
                          setState(() => _dailyGoal = value.round());
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ==== BİLDİRİM AYARLARI ====
                _ProfileCard(
                  title: AppLocalizations.of(context)!.reminders,
                  subtitle: AppLocalizations.of(context)!.remindersSubtitle,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _notificationsEnabled
                            ? AppLocalizations.of(context)!.remindersOn
                            : AppLocalizations.of(context)!.remindersOff,
                        style: theme.textTheme.bodyMedium,
                      ),
                      Switch(
                        value: _notificationsEnabled,
                        activeColor: const Color(0xFF2563EB),
                        onChanged: (value) {
                          setState(() => _notificationsEnabled = value);
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ==== TEMA AYARLARI ====
                _ProfileCard(
                  title: AppLocalizations.of(context)!.theme,
                  subtitle: AppLocalizations.of(context)!.themeSubtitle,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        ref.watch(themeProvider) == ThemeMode.dark
                            ? AppLocalizations.of(context)!.darkMode
                            : AppLocalizations.of(context)!.lightMode,
                        style: theme.textTheme.bodyMedium,
                      ),
                      Switch(
                        value: ref.watch(themeProvider) == ThemeMode.dark,
                        activeColor: const Color(0xFF2563EB),
                        onChanged: (value) {
                          ref.read(themeProvider.notifier).toggleTheme();
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ==== DİL AYARLARI ====
                _ProfileCard(
                  title: AppLocalizations.of(context)!.language,
                  subtitle: AppLocalizations.of(context)!.languageSubtitle,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        ref.watch(languageProvider).languageCode == 'tr'
                            ? 'Türkçe'
                            : 'English',
                        style: theme.textTheme.bodyMedium,
                      ),
                      DropdownButton<String>(
                        value: ref.watch(languageProvider).languageCode,
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(
                            value: 'en',
                            child: Text('English'),
                          ),
                          DropdownMenuItem(
                            value: 'tr',
                            child: Text('Türkçe'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            ref
                                .read(languageProvider.notifier)
                                .setLanguage(Locale(value));
                          }
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ==== SAVE BUTONU ====
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context, _dailyGoal),

                    child: Text(
                      AppLocalizations.of(context)!.save,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WaterAvatar extends StatelessWidget {
  const _WaterAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1E293B)
            : const Color(0xFFE5EDFF),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.10),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: const [
          Icon(
            Icons.water_drop,
            size: 36,
            color: Color(0xFF2563EB),
          ),
          Positioned(
            bottom: 12,
            child: Icon(
              Icons.emoji_emotions_outlined,
              size: 12,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// Basit profil kart widget’ı
class _ProfileCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _ProfileCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
