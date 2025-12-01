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

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.initialGoal});

  final int initialGoal;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
      _username = prefs.getString('username') ?? "Guest";
      _isLoggedIn = _userId != null;
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('username');
    setState(() {
      _userId = null;
      _username = "Guest";
      _isLoggedIn = false;
    });
  }

  Future<void> _showLoginDialog() async {
    final TextEditingController usernameController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log In'),
        content: TextField(
          controller: usernameController,
          decoration: const InputDecoration(hintText: "Enter username"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final username = usernameController.text.trim();
              if (username.isEmpty) return;

              try {
                final user = await _apiClient.login(username);
                final prefs = await SharedPreferences.getInstance();
                await prefs.setInt('userId', user['id']);
                await prefs.setString('username', user['username']);
                
                if (mounted) {
                  Navigator.pop(context);
                  _loadUserState();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Welcome back, ${user['username']}!')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Login failed. User not found?')),
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
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController weightController = TextEditingController();
    final TextEditingController heightController = TextEditingController();
    final TextEditingController ageController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Up'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: "Username"),
              ),
              TextField(
                controller: weightController,
                decoration: const InputDecoration(labelText: "Weight (kg)"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: heightController,
                decoration: const InputDecoration(labelText: "Height (cm)"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: ageController,
                decoration: const InputDecoration(labelText: "Age"),
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
            onPressed: () async {
              final username = usernameController.text.trim();
              if (username.isEmpty) return;

              try {
                final userData = {
                  "username": username,
                  "weight_kg": double.tryParse(weightController.text),
                  "height_cm": double.tryParse(heightController.text),
                  "age": int.tryParse(ageController.text),
                  "daily_goal_ml": 2000, // Default
                };

                final user = await _apiClient.createUser(userData);
                final prefs = await SharedPreferences.getInstance();
                await prefs.setInt('userId', user['id']);
                await prefs.setString('username', user['username']);

                if (mounted) {
                  Navigator.pop(context);
                  _loadUserState();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Account created! Welcome, ${user['username']}!')),
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

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _dailyGoal);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          centerTitle: true,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, _dailyGoal),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
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
                            _isLoggedIn ? _username : 'Guest User',
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
                                      ? 'Keep hydrating, $_username!'
                                      : 'Log in to sync your data',
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
                            child: const Text('Log in'),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF2563EB),
                              side: const BorderSide(
                                color: Color(0xFF2563EB),
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
                            child: const Text('Sign up'),
                          ),
                        ],
                      )
                    else
                      IconButton(
                        onPressed: _logout,
                        icon: const Icon(Icons.logout, color: Colors.redAccent),
                        tooltip: "Log out",
                      ),
                  ],
                ),

                const SizedBox(height: 24),
                // ==== SETTINGS BÖLÜMÜ ====
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Settings',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 12),

                // ==== GÜNLÜK HEDEF KARTI ====
                _ProfileCard(
                  title: 'Daily water goal',
                  subtitle: 'Adjust how much water you want to drink per day.',
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
                  title: 'Reminders',
                  subtitle: 'Get gentle reminders to drink water.',
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _notificationsEnabled
                            ? 'Reminders: On'
                            : 'Reminders: Off',
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

                    child: const Text(
                      'Save changes',
                      style: TextStyle(
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
        color: const Color(0xFFE5EDFF),
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
        color: Colors.white,
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
