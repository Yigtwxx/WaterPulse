// frontend/lib/ui/screens/profile_screen.dart
//
// WaterPulse profil ekranı
// - Kullanıcı avatarı + isim + Login / Sign up
// - Günlük hedef ayarı (slider)
// - Bildirim ayarı (switch)
// - Basit "Save" butonu (şimdilik local)

import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.initialGoal});

  final int initialGoal;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Şimdilik sahte veriler (backend bağlayınca buraya entegre edersin)
  late int _dailyGoal;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _dailyGoal = widget.initialGoal;
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
                    const CircleAvatar(
                      radius: 32,
                      backgroundColor: Color(0xFFE5EDFF),
                      child: Icon(
                        Icons.person,
                        size: 32,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // İsim + açıklama
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'WaterPulse User',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  'Stay hydrated and keep your streaks alive',
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
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, _dailyGoal),
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
                          onPressed: () {
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Sign up screen will be added soon ✨'),
                                ),
                              );
                          },
                          child: const Text('Sign up'),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),

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
