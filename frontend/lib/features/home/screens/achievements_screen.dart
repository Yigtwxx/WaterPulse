import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waterpulse/features/home/providers/achievements_provider.dart';
import 'package:waterpulse/features/home/providers/water_provider.dart';
import 'package:waterpulse/features/auth/providers/auth_provider.dart';
import 'package:waterpulse/features/social/providers/friends_provider.dart';
import 'package:waterpulse/l10n/generated/app_localizations.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(achievementsProvider);
    final waterState = ref.watch(waterProvider);
    final friendsState = ref.watch(friendsProvider);
    
    final loading = state.isLoading;
    final backendAchievements = state.achievements;
    final currentStreak = state.currentStreak;
    final todayTotal = waterState.todayTotal;
    final dailyGoal = ref.read(authProvider).value?.dailyGoalMl ?? 2400;
    
    final friendCount = friendsState.leaderboard.length > 1 ? friendsState.leaderboard.length - 1 : 0;

    final allAchievements = [
      {'key': 'first_log', 'default': AppLocalizations.of(context)!.achFirstLog},
      {'key': '500ml', 'default': AppLocalizations.of(context)!.ach500ml},
      {'key': 'goal_reached', 'default': AppLocalizations.of(context)!.achGoalReached},
      {'key': 'marathon', 'default': AppLocalizations.of(context)!.achMarathon},
      {'key': 'hippo', 'default': AppLocalizations.of(context)!.achHippo}, 
      {'key': 'tsunami', 'default': AppLocalizations.of(context)!.achTsunami},
      {'key': 'goal_1_day', 'default': AppLocalizations.of(context)!.achGoal1Day},
      {'key': 'goal_7_days', 'default': AppLocalizations.of(context)!.achGoal7Days},
      {'key': 'goal_30_days', 'default': AppLocalizations.of(context)!.achGoal30Days},
      {'key': 'goal_90_days', 'default': AppLocalizations.of(context)!.achGoal90Days},
      {'key': 'social_1', 'default': AppLocalizations.of(context)!.achSocial1},
      {'key': 'social_5', 'default': AppLocalizations.of(context)!.achSocial5},
      {'key': 'friend_streak_3', 'default': AppLocalizations.of(context)!.achFriendStreak3},
      {'key': 'early_bird', 'default': AppLocalizations.of(context)!.achEarlyBird},
      {'key': 'night_owl', 'default': AppLocalizations.of(context)!.achNightOwl},
      {'key': 'weekend_warrior', 'default': AppLocalizations.of(context)!.achWeekendWarrior},
    ];

    // Merge backend status
    final displayList = allAchievements.map((def) {
      // Find matching backend achievement
      final match = backendAchievements.firstWhere(
        (ba) {
             final desc = (ba['description'] ?? '').toString().toLowerCase();
             final target = def['default'].toString().toLowerCase();
             return desc.contains(target);
        },
        orElse: () => {},
      );
      
      final backendUnlocked = match.isNotEmpty;
      double progress = 0.0;
      
      final key = def['key'];
      switch(key) {
          case 'first_log':
             progress = (currentStreak > 0 || todayTotal > 0) ? 1.0 : 0.0;
             break;
          case '500ml':
             progress = (todayTotal / 500).clamp(0.0, 1.0);
             break;
          case 'goal_reached':
             progress = (todayTotal / dailyGoal).clamp(0.0, 1.0);
             break;
          case 'goal_1_day':
             progress = (currentStreak / 1).clamp(0.0, 1.0);
             break;
          case 'goal_7_days':
             progress = (currentStreak / 7).clamp(0.0, 1.0);
             break;
          case 'goal_30_days':
             progress = (currentStreak / 30).clamp(0.0, 1.0);
             break;
          case 'goal_90_days':
             progress = (currentStreak / 90).clamp(0.0, 1.0);
             break;
          case 'marathon':
             progress = (todayTotal / 3000).clamp(0.0, 1.0);
             break;
          case 'hippo':
             progress = (todayTotal / 4000).clamp(0.0, 1.0);
             break;
          case 'tsunami':
             progress = (todayTotal / 5000).clamp(0.0, 1.0);
             break;
          case 'social_1':
             progress = (friendCount / 1).clamp(0.0, 1.0);
             break;
          case 'social_5':
             progress = (friendCount / 5).clamp(0.0, 1.0);
             break;
          case 'friend_streak_3':
             progress = 0.0; 
             break;
          default:
             progress = 0.0;
      }

      // If backend says unlocked, force 100%
      if (backendUnlocked) {
        progress = 1.0;
      }

      // Effectively unlocked if backend says so OR progress is 100%
      final isUnlocked = backendUnlocked || progress >= 1.0;
      
      return {
        'key': def['key'],
        'default': def['default'],
        'is_unlocked': isUnlocked,
        'progress': progress,
      };
    }).toList();

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.achievements)),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: Theme.of(context).brightness == Brightness.dark
                ? [
                    const Color(0xFF0F172A),
                    const Color(0xFF1E293B),
                  ]
                : [
                    const Color(0xFFEFF6FF),
                    const Color(0xFFFFFFFF),
                  ],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: RefreshIndicator(
          onRefresh: () => ref.read(achievementsProvider.notifier).loadData(),
          child: ListView(
            children: [
              // Total Cups Won Indicator (Top Left)
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.emoji_events, color: Colors.amber, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        // Count unlocked achievements (is_unlocked == true)
                        "Total Cups Won: ${displayList.where((e) => e['is_unlocked'] as bool).length}", // TODO: Localize
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // _StreakTextAchievements and _StreakMedallions removed as per user request
              // _StreakTextAchievements(currentStreak: currentStreak),
              // const SizedBox(height: 24),
              // _StreakMedallions(currentStreak: currentStreak),
              // const SizedBox(height: 24),
              Text(
                AppLocalizations.of(context)!.allAchievements,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              if (loading && backendAchievements.isEmpty)
                const Center(child: CircularProgressIndicator())
              else
                ...displayList.map((a) {
                  final key = a['key'] as String;
                  final unlocked = a['is_unlocked'] as bool;
                  final progress = a['progress'] as double;
                  final (name, desc) = _localizeAchievement(context, key);
                  
                  return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: unlocked
                            ? [
                                BoxShadow(
                                  color: Colors.orange.withOpacity(0.4),
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                )
                              ]
                            : null,
                      ),
                      child: Card(
                        margin: EdgeInsets.zero,
                        elevation: unlocked ? 4 : 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: unlocked
                              ? const BorderSide(color: Colors.orange, width: 1.5)
                              : BorderSide.none,
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                color: unlocked ? Colors.orange.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                                shape: BoxShape.circle,
                            ),
                            child: Icon(
                              unlocked ? Icons.emoji_events : Icons.lock,
                              color: unlocked ? Colors.orange : Colors.grey,
                            ),
                          ),
                          title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(desc),
                          trailing: unlocked
                              ? const Icon(Icons.check_circle, color: Colors.green, size: 28)
                              : SizedBox(
                                  width: 48,
                                  height: 48,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                        CircularProgressIndicator(
                                            value: progress,
                                            backgroundColor: Colors.grey[200],
                                            color: Colors.blueAccent,
                                            strokeWidth: 4,
                                        ),
                                        Text(
                                            "${(progress * 100).toInt()}%",
                                            style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey
                                            ),
                                        )
                                    ],
                                  ),
                              ),
                        ),
                      ),
                    );
                }),
            ],
          ),
        ),
      ),
    );
  }

  (String, String) _localizeAchievement(BuildContext context, String key) {
    final loc = AppLocalizations.of(context)!;
    switch (key) {
      case 'first_log':
        return (loc.achFirstLog, loc.achFirstLogDesc);
      case '500ml':
        return (loc.ach500ml, loc.ach500mlDesc);
      case 'goal_reached':
        return (loc.achGoalReached, loc.achGoalReachedDesc);
      case 'goal_1_day':
        return (loc.achGoal1Day, loc.achGoal1DayDesc);
      case 'goal_7_days':
        return (loc.achGoal7Days, loc.achGoal7DaysDesc);
      case 'goal_30_days':
        return (loc.achGoal30Days, loc.achGoal30DaysDesc);
      case 'goal_90_days':
        return (loc.achGoal90Days, loc.achGoal90DaysDesc);
      case 'early_bird':
        return (loc.achEarlyBird, loc.achEarlyBirdDesc);
      case 'night_owl':
        return (loc.achNightOwl, loc.achNightOwlDesc);
      case 'weekend_warrior':
        return (loc.achWeekendWarrior, loc.achWeekendWarriorDesc);
      case 'marathon':
        return (loc.achMarathon, loc.achMarathonDesc);
      case 'hippo':
        return (loc.achHippo, loc.achHippoDesc);
      case 'tsunami':
        return (loc.achTsunami, loc.achTsunamiDesc);
      case 'social_1':
        return (loc.achSocial1, loc.achSocial1Desc);
      case 'social_5':
        return (loc.achSocial5, loc.achSocial5Desc);
      case 'friend_streak_3':
        return (loc.achFriendStreak3, loc.achFriendStreak3Desc);
      default:
        return ("Unknown", "Unknown achievement");
    }
  }
}

class _StreakMedallions extends StatelessWidget {
  final int currentStreak;

  const _StreakMedallions({required this.currentStreak});

  @override
  Widget build(BuildContext context) {
    final tiers = [
      _Medallion(
          label: AppLocalizations.of(context)!.dayStreak(1),
          days: 1,
          current: currentStreak),
      _Medallion(
          label: AppLocalizations.of(context)!.dayStreak(7),
          days: 7,
          current: currentStreak),
      _Medallion(
          label: AppLocalizations.of(context)!.dayStreak(30),
          days: 30,
          current: currentStreak),
      _Medallion(
          label: AppLocalizations.of(context)!.dayStreak(90),
          days: 90,
          current: currentStreak),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.streakMedallions,
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: tiers,
        ),
      ],
    );
  }
}

class _Medallion extends StatelessWidget {
  final String label;
  final int days;
  final int current;

  const _Medallion({
    required this.label,
    required this.days,
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    final unlocked = current >= days;
    final progress = (current / days).clamp(0.0, 1.0);
    final color = unlocked ? const Color(0xFF2563EB) : Colors.grey;
    final bgColor = unlocked
        ? (Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1E293B)
            : const Color(0xFFE5EDFF))
        : Theme.of(context).cardTheme.color;
    final borderColor = unlocked ? color.withOpacity(0.9) : color.withOpacity(0.3);

    return Container(
      width: 90,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: borderColor,
          width: 1.2,
        ),
        boxShadow: [
          if (unlocked)
            BoxShadow(
              color: color.withOpacity(0.5),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 4,
                  backgroundColor: Colors.grey.withOpacity(0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Icon(
                unlocked ? Icons.verified : Icons.lock_clock,
                color: color,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          Text(
            unlocked
                ? AppLocalizations.of(context)!.won
                : AppLocalizations.of(context)!.daysLeft(days - current),
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _StreakTextAchievements extends StatelessWidget {
  final int currentStreak;

  const _StreakTextAchievements({required this.currentStreak});

  @override
  Widget build(BuildContext context) {
    final items = [
      (1, AppLocalizations.of(context)!.dayStreak(1)),
      (7, AppLocalizations.of(context)!.dayStreak(7)),
      (30, AppLocalizations.of(context)!.dayStreak(30)),
      (90, AppLocalizations.of(context)!.dayStreak(90)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((entry) {
        final unlocked = currentStreak >= entry.$1;
        final color = unlocked
            ? const Color(0xFF2563EB)
            : (Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[400]
                : Colors.grey[500]);
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              Icon(
                unlocked ? Icons.verified : Icons.lock_outline,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 6),
              Text(
                entry.$2,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: color, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
