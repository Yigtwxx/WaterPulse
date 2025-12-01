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
import 'package:waterpulse/features/home/widgets/water_progress_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:waterpulse/features/home/widgets/weekly_hydration_row.dart';
import 'package:waterpulse/features/home/widgets/streak_card.dart';
import 'package:waterpulse/features/home/widgets/amount_button.dart';
import 'package:waterpulse/features/home/widgets/quick_action_card.dart';
import 'package:waterpulse/features/home/widgets/goal_badge.dart';
import 'package:waterpulse/ui/screens/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waterpulse/features/home/providers/water_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // Backend ile konuşan local SQLite + API client
  final ApiClient apiClient = ApiClient();

  int _userId = 1; // Default to 1, load from prefs

  // Bugünkü içilen su miktarı - Riverpod'dan geliyor
  // int _currentMl = 0;

  // Günlük hedef (ARTIK DEĞİŞEBİLİR)
  int _goalMl = 2400;

  // API çağrısı sırasında loading flag
  // bool _loading = false;
  bool _metaLoading = false;
  bool _weekLoading = false;


  Map<String, dynamic>? _streakSummary;
  List<dynamic> _avatarSkins = [];
  List<Map<String, dynamic>> _weekTotals = [];

  @override
  void initState() {
    super.initState();
    _initUserAndLoadData();
  }

  Future<void> _initUserAndLoadData() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _userId = prefs.getInt('userId') ?? 1;
      });
    }
    // _loadTodayTotal(); -> Provider hallediyor
    ref.read(waterProvider.notifier).loadTodayTotal();
    
    _loadMetaPanels();
    _loadWeekTotals();
  }

  // Bugünkü toplam su miktarını backend’den çek
  Future<void> _loadTodayTotal() async {
    await ref.read(waterProvider.notifier).loadTodayTotal();
  }

  Future<void> _loadMetaPanels() async {
    if (!mounted) return;
    setState(() => _metaLoading = true);
    try {
      final summary = await apiClient.getStreakSummary(userId: _userId);
      final skins = await apiClient.getAvatarSkins(userId: _userId);
      if (!mounted) return;
      setState(() {
        _streakSummary = summary;
        _avatarSkins = skins;
      });
    } catch (_) {
      // sessiz devam
    } finally {
      if (mounted) {
        setState(() => _metaLoading = false);
      }
    }
  }

  Future<void> _loadWeekTotals({bool showLoading = true}) async {
    if (!mounted) return;
    if (showLoading) {
      setState(() => _weekLoading = true);
    }
    try {
      final end = DateTime.now();
      final start = end.subtract(const Duration(days: 6));
      final data = await apiClient.getCalendarTotals(
        userId: _userId,
        startDate: start,
        endDate: end,
      );
      if (!mounted) return;
      final mapped = data
          .map((e) => {
                "date": DateTime.parse(e["date"] as String),
                "total": (e["total_ml"] as num?)?.toInt() ?? 0,
              })
          .cast<Map<String, dynamic>>()
          .toList();
      setState(() => _weekTotals = mapped);
    } catch (_) {
      // sessiz
    } finally {
      if (mounted && showLoading) {
        setState(() => _weekLoading = false);
      }
    }
  }

  void _bumpTodayWeekTotal(int delta) {
    if (!mounted) return;
    final today = DateTime.now();
    final todayKey =
        DateTime(today.year, today.month, today.day).toIso8601String();
    final start = DateTime(today.year, today.month, today.day)
        .subtract(const Duration(days: 6));

    final Map<String, int> map = {};
    for (final e in _weekTotals) {
      final d = e["date"] as DateTime;
      final key = DateTime(d.year, d.month, d.day).toIso8601String();
      map[key] = (e["total"] as int? ?? 0);
    }
    map[todayKey] = (map[todayKey] ?? 0) + delta;

    final List<Map<String, dynamic>> rebuilt = [];
    for (int i = 0; i < 7; i++) {
      final day = start.add(Duration(days: i));
      final key = DateTime(day.year, day.month, day.day).toIso8601String();
      rebuilt.add({
        "date": day,
        "total": map[key] ?? 0,
      });
    }
    setState(() => _weekTotals = rebuilt);
  }

  // Belirtilen miktarda su ekle (ör: 250 ml, 500 ml)
  Future<void> _addWater(int amount) async {
    if (!mounted) return;
    
    await ref.read(waterProvider.notifier).addWater(amount);

    _bumpTodayWeekTotal(amount);

    await _loadMetaPanels();
    _loadWeekTotals(showLoading: false);
  }

  // Quick actions tıklamaları -> ilgili taba geç
  // Quick actions tıklamaları -> ilgili taba geç
  void _onAchievementsTap() {
    context.go('/achievements');
  }

  void _onFriendsTap() {
    context.go('/friends');
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


  // Seçili taba göre gövdeyi üret
  // Seçili taba göre gövdeyi üret
  Widget _buildBody(BuildContext context) {
    final waterState = ref.watch(waterProvider);
    final currentMl = waterState.todayTotal;
    final loading = waterState.isLoading;
    final achievedToday = currentMl >= _goalMl;

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
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 78,
                    child: Center(
                      child: WeeklyHydrationRow(
                        loading: _weekLoading,
                        weekTotals: _weekTotals,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Ortadaki büyük dairesel progress (tam ortalı)
                  Center(
                    child: WaterProgressBar(
                      currentMl: currentMl,
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
                        child: AmountButton(
                          label: '+250 ml',
                          onTap: loading ? null : () => _addWater(250),
                        ),
                      ),
                      const SizedBox(width: 30),
                      SizedBox(
                        width: 130,
                        child: AmountButton(
                          label: '+500 ml',
                          onTap: loading ? null : () => _addWater(500),
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
                  QuickActionCard(
                    icon: Icons.group_outlined,
                    title: 'Friends',
                    subtitle: 'Compare with your friends',
                    onTap: _onFriendsTap,
                  ),
                  QuickActionCard(
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

            const SizedBox(height: 24),

            Text(
              'Streak & avatar',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            StreakCard(
              loading: _metaLoading,
              summary: _streakSummary,
              skins: _avatarSkins,
              goalAchievedToday: achievedToday,
              currentMl: currentMl,
              dailyGoal: _goalMl,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final waterState = ref.watch(waterProvider);
    final currentMl = waterState.todayTotal;
    final achievedToday = currentMl >= _goalMl;

    return Scaffold(
      // ÜST BAR
      appBar: AppBar(
        title: const Text('WaterPulse'),
        centerTitle: true,
        elevation: 0,
        actions: [
          Row(
            children: [
              if (_goalMl > 0)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GoalBadge(
                    achieved: achievedToday,
                    remaining: (_goalMl - currentMl).clamp(0, _goalMl),
                    streak: _streakSummary?['current_streak'] ?? 0,
                  ),
                ),
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
                      builder: (_) => ProfileScreen(initialGoal: _goalMl),
                    ),
                  );

                  // Reload user ID in case they logged in/out
                  if (mounted) {
                    final prefs = await SharedPreferences.getInstance();
                    setState(() {
                      _userId = prefs.getInt('userId') ?? 1;
                    });
                    // Refresh data for new user
                    _loadTodayTotal();
                    _loadMetaPanels();
                    _loadWeekTotals();
                  }

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
                  });
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
        ],
      ),

      // GÖVDE
      body: SafeArea(
        child: _buildBody(context),
      ),
    );
  }
}


// =======================================================
// QUICK ACTION KART WIDGET'I
// =======================================================

// =======================================================
// STREAK + AVATAR KARTI
// =======================================================






// =======================================================
