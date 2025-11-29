// frontend/lib/ui/screens/home_screen.dart
//
// WaterPulse ana ekranı (Home tab).
// - Üstte günlük su ilerlemesi
// - Ortada hızlı ekleme butonları (+250 / +500)
// - Sağ üstte profil ikonu
// - Profil ikonunun altında Calendar butonu
// - Suggestions bölümü
// - Quick actions: Achievements / Friends
// - En altta BottomNavigationBar: Home / Friends / Achievements / Sports

import 'package:flutter/material.dart';
import 'package:waterpulse/services/api_client.dart';
import 'package:waterpulse/ui/widgets/water_progress_bar.dart';
import 'package:waterpulse/ui/screens/profile_screen.dart';

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

  // Günlük hedef (ARTIK DEĞİŞEBİLİR)
  int _goalMl = 2400;

  // API çağrısı sırasında loading flag
  bool _loading = false;

  // BottomNavigationBar seçili tab
  // 0: Home, 1: Friends, 2: Achievements, 3: Sports
  int _selectedTabIndex = 0;

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
      // Şimdilik hata durumunu sessiz geçiyoruz (0 kalabilir)
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  // Belirtilen miktarda su ekle (ör: 250 ml, 500 ml)
  // Backend çalışsa da çalışmasa da UI'da animasyonu gösteriyoruz.
  Future<void> _addWater(int amount) async {
    if (!mounted) return;
    setState(() => _loading = true);

    bool serverOk = false;

    try {
      // 1) Backend'e isteği gönder
      await apiClient.addWater(userId: 1, amountMl: amount);
      serverOk = true;
    } catch (_) {
      serverOk = false;
    }

    if (!mounted) return;

    if (serverOk) {
      // 2A) Backend başarılı -> gerçek veriyi tekrar çek
      try {
        await _loadTodayTotal();
      } catch (_) {
        // backend cevapta sorun çıkarırsa local fallback
        setState(() {
          _currentMl = (_currentMl + amount).clamp(0, _goalMl);
        });
      }
    } else {
      // 2B) Backend'e ulaşılamadı -> local olarak artır (UI animasyonu için)
      setState(() {
        _currentMl = (_currentMl + amount).clamp(0, _goalMl);
      });
      // Artık SnackBar göstermiyoruz, sessizce local güncelliyoruz.
    }

    if (mounted) {
      setState(() => _loading = false);
    }
  }

  // Quick actions tıklamaları -> ilgili taba geç
  void _onAchievementsTap() {
    if (!mounted) return;
    setState(() => _selectedTabIndex = 2);
  }

  void _onFriendsTap() {
    if (!mounted) return;
    setState(() => _selectedTabIndex = 1);
  }

  // ignore: unused_element
  void _onSportsTap() {
    if (!mounted) return;
    setState(() => _selectedTabIndex = 3);
  }

  // Calendar butonu -> DatePicker aç
  void _onCalendarTap() {
    if (!mounted) return;
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime(DateTime.now().year + 1),
    ).then((selectedDate) {
      if (!mounted || selectedDate == null) return;

      final formatted =
          '${selectedDate.day.toString().padLeft(2, '0')}.${selectedDate.month.toString().padLeft(2, '0')}.${selectedDate.year}';

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('Selected date: $formatted')),
        );
    });
  }

  // BottomNavigationBar item seçilince
  void _onTabSelected(int index) {
    if (!mounted) return;
    setState(() => _selectedTabIndex = index);
  }

  // Seçili taba göre gövdeyi üret
  Widget _buildBody(BuildContext context) {
    switch (_selectedTabIndex) {
      case 0:
        // HOME TAB (orijinal içerik)
        return Container(
          color: const Color(0xfff5f7fb),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==========================
                // PROFİL ALTINDA CALENDAR BUTONU
                // ==========================
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: _onCalendarTap,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      foregroundColor: Colors.blueAccent,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    icon: const Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                    ),
                    label: const Text('Calendar'),
                  ),
                ),

                const SizedBox(height: 12),

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
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30),

                      // Ortadaki büyük dairesel progress (tam ortalı)
                      Center(
                        child: WaterProgressBar(
                          currentMl: _currentMl,
                          goalMl: _goalMl,
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Hızlı ekleme butonları (tam ortalı ve eşit genişlik)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 130,
                            child: _AmountButton(
                              label: '+250 ml',
                              onTap: _loading ? null : () => _addWater(250),
                            ),
                          ),
                          const SizedBox(width: 30),
                          SizedBox(
                            width: 130,
                            child: _AmountButton(
                              label: '+500 ml',
                              onTap: _loading ? null : () => _addWater(500),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Hedef metni (tam ortalı)
                      Text(
                        'Goal: $_goalMl ml',
                        textAlign: TextAlign.center,
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
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
                // 3) QUICK ACTIONS (Achievements / Friends)
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
                        icon: Icons.group_outlined,
                        title: 'Friends',
                        subtitle: 'Compare with your friends',
                        onTap: _onFriendsTap,
                      ),
                      _QuickActionCard(
                        icon: Icons.emoji_events_outlined,
                        title: 'Achievements',
                        subtitle: 'Track your streaks & badges',
                        onTap: _onAchievementsTap,
                      ),
                    ];

                    if (isWide) {
                      // Desktop / geniş ekran: 2 kart yan yana
                      return Row(
                        children: cards
                            .map(
                              (c) => Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4),
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
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );

      case 1:
        // FRIENDS TAB
        return const _TabPlaceholder(
          icon: Icons.group_rounded,
          title: 'Friends',
          description:
              'Here you will soon see your friends, leaderboards and challenges.',
        );

      case 2:
        // ACHIEVEMENTS TAB
        return const _TabPlaceholder(
          icon: Icons.emoji_events_rounded,
          title: 'Achievements',
          description:
              'Your streaks, badges and milestones will be listed here soon.',
        );

      case 3:
        // SPORTS TAB
        return const _TabPlaceholder(
          icon: Icons.fitness_center_rounded,
          title: 'Sports',
          description:
              'Water tracking integrated with your sports activities will appear here.',
        );

      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ÜST BAR
appBar: AppBar(
  title: const Text('WaterPulse'),
  centerTitle: true,
  elevation: 0,
  actions: [
    IconButton(
      tooltip: 'Profile',
      // Küçük yuvarlak avatarlı buton
      icon: const CircleAvatar(
        radius: 16,
        backgroundColor: Color(0xFFE5EDFF),
        child: Icon(
          Icons.person,
          size: 18,
          color: Color(0xFF2563EB),
        ),
      ),
      onPressed: () async {
        // ProfileScreen'den yeni goal değerini bekle
        final int? newGoal = await Navigator.of(context).push<int>(
          MaterialPageRoute(
            builder: (_) => const ProfileScreen(),
          ),
        );

        // Eğer profil ekranı bir değer döndürmediyse (back tuşu vs.)
        if (!mounted) return;
        if (newGoal == null) {
          // Bunu görürsen, ProfileScreen tarafı Navigator.pop(context, _dailyGoal)
          // ile dönmüyor demektir.
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text('No goal returned from ProfileScreen'),
              ),
            );
          return;
        }

        // Değer geldiyse state'i güncelle
        setState(() {
          _goalMl = newGoal;
          if (_currentMl > _goalMl) {
            _currentMl = _goalMl;
          }
        });
      },
    ),
    const SizedBox(width: 8),
  ],
),


      // GÖVDE
      body: SafeArea(
        child: _buildBody(context),
      ),

      // ==========================
      // BOTTOM NAVIGATION BAR
      // Home / Friends / Achievements / Sports
      // ==========================
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedTabIndex,
        onTap: _onTabSelected,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group_rounded),
            label: 'Friends',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events_rounded),
            label: 'Achievements',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center_rounded),
            label: 'Sports',
          ),
        ],
      ),
    );
  }
}

// =======================================================
// HIZLI EKLEME BUTONU WIDGET'I (Ripple basma efekti ile)
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

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(30),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
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
                      color: Colors.blueAccent.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: enabled ? Colors.blueAccent : Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
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
              color: Colors.black.withOpacity(0.04),
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
                color: Colors.blue.withOpacity(0.08),
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

// =======================================================
// TAB PLACEHOLDER WIDGET'İ (Friends / Achievements / Sports)
// =======================================================
class _TabPlaceholder extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _TabPlaceholder({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xfff5f7fb),
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 52,
              color: Colors.blueAccent,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
