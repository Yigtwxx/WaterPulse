// frontend/lib/ui/screens/home_screen.dart
//
// WaterPulse ana ekranı (Home tab).
// - Üstte günlük su ilerlemesi
// - Ortada hızlı ekleme butonları (+250 / +500)
// - Suggestions bölümü
// - Quick actions: Achievements / Friends / Calendar

import 'package:flutter/material.dart';
import 'package:waterpulse/services/local_db/dao/api_client.dart';
import 'package:waterpulse/ui/widgets/water_progress_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Backend ile konuşan local SQLite + API client
  final ApiClient apiClient = ApiClient();

  // Bugünkü içilen su miktarı
  int _currentMl = 0;

  // Günlük hedef
  int _goalMl = 2400;

  // API çağrısı sırasında loading flag
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadTodayTotal();
  }

  // Bugünkü toplam su miktarını backend’den çek
  Future<void> _loadTodayTotal() async {
    if (!mounted) return;
    setState(() => _loading = true);

    try {
      final total = await apiClient.getTodayTotal(userId: 1);
      if (!mounted) return;
      setState(() => _currentMl = total);
    } catch (_) {
      // Şimdilik hata durumunu sessiz geçiyoruz
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  // Belirtilen miktarda su ekle (ör: 250 ml, 500 ml)
  Future<void> _addWater(int amount) async {
    if (!mounted) return;
    setState(() => _loading = true);

    try {
      await apiClient.addWater(userId: 1, amountMl: amount);
      if (!mounted) return;
      await _loadTodayTotal(); // Ekledikten sonra güncel değeri çek
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not add water')),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  // Quick actions tıklamaları (şimdilik sadece SnackBar)
  void _onAchievementsTap() {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Achievements is coming soon ✨')),
      );
  }

  void _onFriendsTap() {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Friends is coming soon ✨')),
      );
  }

  void _onCalendarTap() {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Calendar view is coming soon ✨')),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ÜST BAR
      appBar: AppBar(
        title: const Text('WaterPulse'),
        centerTitle: true,
        elevation: 0,
        // Sağ üstte profil ikonu (Profile tab yerine buradan da erişebilirsin)
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(
                    content: Text('Profile screen is coming soon ✨'),
                  ),
                );
            },
          ),
        ],
      ),

      // GÖVDE
      body: SafeArea(
        child: Container(
          color: const Color(0xfff5f7fb),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==========================
                // 1) ÜST KART (PROGRESS + BUTONLAR)
                // ==========================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 24,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 8),

                      // Ortadaki büyük dairesel progress
                      // Burada sadece WaterProgressBar kullanıyoruz,
                      // ekstra text overlay yapmıyoruz ki "çift yazı" olmasın.
                      SizedBox(
                        height: 180,
                        child: Center(
                          child: WaterProgressBar(
                            currentMl: _currentMl,
                            goalMl: _goalMl,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Hızlı ekleme butonları
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _AmountButton(
                            label: '+250 ml',
                            onTap: _loading ? null : () => _addWater(250),
                          ),
                          _AmountButton(
                            label: '+500 ml',
                            onTap: _loading ? null : () => _addWater(500),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Hedef metni
                      Text(
                        'Goal: $_goalMl ml',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ==========================
                // 2) SUGGESTIONS BÖLÜMÜ
                // ==========================
                Text(
                  'Suggestions',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.opacity, color: Colors.black87),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Based on your activity, drink a bit more water 💧',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.grey[800]),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ==========================
                // 3) QUICK ACTIONS (Achievements / Friends / Calendar)
                // ==========================
                Text(
                  'Quick actions',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 700;

                    // Kart listesi
                    final cards = [
                      _QuickActionCard(
                        icon: Icons.emoji_events_outlined,
                        title: 'Achievements',
                        subtitle: 'Track your streaks & badges',
                        onTap: _onAchievementsTap,
                      ),
                      _QuickActionCard(
                        icon: Icons.group_outlined,
                        title: 'Friends',
                        subtitle: 'Compare with your friends',
                        onTap: _onFriendsTap,
                      ),
                      _QuickActionCard(
                        icon: Icons.calendar_today_outlined,
                        title: 'Calendar',
                        subtitle: 'See your monthly history',
                        onTap: _onCalendarTap,
                      ),
                    ];

                    if (isWide) {
                      // Desktop / geniş ekran: 3 kart yan yana, Calendar sağda
                      return Row(
                        children: cards
                            .map(
                              (c) => Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  child: c,
                                ),
                              ),
                            )
                            .toList(),
                      );
                    } else {
                      // Mobil: alt alta
                      return Column(
                        children: [
                          cards[0],
                          const SizedBox(height: 12),
                          cards[1],
                          const SizedBox(height: 12),
                          cards[2],
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      // Alt taraftaki bottom navigation bar (Home / Stats / Profile)
      // main.dart içerisinde tanımlı, burada ayrıca eklemeye gerek yok.
    );
  }
}

// =======================================================
// HIZLI EKLEME BUTONU WIDGET'I
// =======================================================
class _AmountButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _AmountButton({
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 32.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: enabled ? Colors.white : Colors.grey[200],
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: enabled ? Colors.blueAccent : Colors.grey,
          ),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: Colors.blueAccent.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: enabled ? Colors.blueAccent : Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// =======================================================
// QUICK ACTION KART WIDGET'I
// =======================================================
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Sol taraftaki yuvarlak ikon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.blueAccent),
            ),
            const SizedBox(width: 12),

            // Başlık + açıklama
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            // Sağdaki ">" oku
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
