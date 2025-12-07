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
import 'package:waterpulse/features/home/widgets/water_facts_widget.dart';
import 'package:waterpulse/ui/screens/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waterpulse/l10n/generated/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waterpulse/features/home/providers/water_provider.dart';
import 'package:waterpulse/features/auth/providers/auth_provider.dart';
import 'package:waterpulse/features/home/providers/achievements_provider.dart';

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
    // Data loading is triggered in build via ref.listen or initial check
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final user = ref.read(authProvider).value;
    if (user != null) {
      setState(() => _userId = user.id);
      ref.read(waterProvider.notifier).loadTodayTotal(_userId);
      _loadMetaPanels();
      _loadWeekTotals();
    }
  }

  Future<void> _loadTodayTotal() async {
    await ref.read(waterProvider.notifier).loadTodayTotal(_userId);
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
    
    await ref.read(waterProvider.notifier).addWater(_userId, amount);

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
          SnackBar(content: Text('${AppLocalizations.of(context)!.selectDate}: $formatted')),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
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
                  foregroundColor: Theme.of(context).primaryColor,
                  backgroundColor: Theme.of(context).cardColor,
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
                color: Theme.of(context).cardTheme.color,
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
                  // authProvider'dan güncel değerleri al
                  Consumer(
                    builder: (context, ref, _) {
                      final user = ref.watch(authProvider).value;
                      final val1 = user?.quickAdd1Ml ?? 250;
                      final val2 = user?.quickAdd2Ml ?? 500;

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 130,
                            child: AmountButton(
                              label: '+$val1 ml',
                              onTap: loading ? null : () => _addWater(val1),
                            ),
                          ),
                          const SizedBox(width: 30),
                          SizedBox(
                            width: 130,
                            child: AmountButton(
                              label: '+$val2 ml',
                              onTap: loading ? null : () => _addWater(val2),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // Hedef metni (tam ortalı)
                  Text(
                    '${AppLocalizations.of(context)!.homeGoal}: $_goalMl ml',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(
                            color: isDark ? Colors.grey[400] : Colors.grey[600]),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ==========================
            // 2) WATER FACTS BÖLÜMÜ
            // ==========================
            Text(
              AppLocalizations.of(context)!.suggestions,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            const WaterFactsWidget(),

            const SizedBox(height: 24),

            // ==========================
            // 3) QUICK ACTIONS (Achievements / Friends)
            // ==========================
            Text(
              AppLocalizations.of(context)!.quickActions,
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
                    title: AppLocalizations.of(context)!.friends,
                    subtitle: AppLocalizations.of(context)!.friendsSubtitle,
                    onTap: _onFriendsTap,
                  ),
                  QuickActionCard(
                    icon: Icons.emoji_events_outlined,
                    title: AppLocalizations.of(context)!.achievements,
                    subtitle: AppLocalizations.of(context)!.achievementsSubtitle,
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
              AppLocalizations.of(context)!.streakAvatar,
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
            
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authProvider, (previous, next) {
      if (next.value != null && (previous?.value?.id != next.value!.id)) {
        _loadData();
      }
    });

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

                  // Reload user data
                  if (mounted) {
                    // Refresh auth provider to get latest user data if changed
                    // ref.refresh(authProvider); // Optional if Profile updates backend
                    // _loadData(); // Removed to prevent resetting water data (race condition or redundant fetch)
                  }

                  // Eğer profil ekranı bir değer döndürmediyse (back tuşu vs.)
                  if (!mounted) return;
                  if (newGoal == null) {
                    // Check if user is logged out (authProvider value is null)
                    final currentUser = ref.read(authProvider).value;
                    if (currentUser == null) {
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                           SnackBar(
                            content: Text(AppLocalizations.of(context)!.loggedOutSuccess),
                            backgroundColor: Colors.green,
                          ),
                        );
                    }
                    // If not logged out, just ignore the null return (back button without changes)
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
} // End _HomeScreenState

// =======================================================
// QUICK ACTION KART WIDGET'I
// =======================================================

// =======================================================
// STREAK + AVATAR KARTI
// =======================================================






// =======================================================
