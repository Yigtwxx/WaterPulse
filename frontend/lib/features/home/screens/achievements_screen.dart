import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waterpulse/features/home/providers/achievements_provider.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(achievementsProvider);
    final loading = state.isLoading;
    final achievements = state.achievements;
    final currentStreak = state.currentStreak;

    return Scaffold(
      appBar: AppBar(title: const Text('Achievements')),
      body: Container(
        color: const Color(0xfff5f7fb),
        padding: const EdgeInsets.all(16),
        child: RefreshIndicator(
          onRefresh: () => ref.read(achievementsProvider.notifier).loadData(),
          child: ListView(
            children: [
              _StreakTextAchievements(currentStreak: currentStreak),
              const SizedBox(height: 24),
              _StreakMedallions(currentStreak: currentStreak),
              const SizedBox(height: 24),
              Text(
                'All Achievements',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              if (loading)
                const Center(child: CircularProgressIndicator())
              else if (achievements.isEmpty)
                const Text('No achievements yet')
              else
                ...achievements.map((a) {
                  final name = a['name'] ?? 'Unknown';
                  final desc = a['description'] ?? '';
                  final unlocked = a['is_unlocked'] == true;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: Icon(
                        unlocked ? Icons.emoji_events : Icons.lock,
                        color: unlocked ? Colors.orange : Colors.grey,
                      ),
                      title: Text(name),
                      subtitle: Text(desc),
                      trailing: unlocked
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : null,
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}

class _StreakMedallions extends StatelessWidget {
  final int currentStreak;

  const _StreakMedallions({required this.currentStreak});

  @override
  Widget build(BuildContext context) {
    final tiers = [
      _Medallion(label: "1 gün", days: 1, current: currentStreak),
      _Medallion(label: "7 gün", days: 7, current: currentStreak),
      _Medallion(label: "30 gün", days: 30, current: currentStreak),
      _Medallion(label: "90 gün", days: 90, current: currentStreak),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Streak medallions',
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
    final bgColor = unlocked ? const Color(0xFFE5EDFF) : Colors.white;
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
            unlocked ? 'Kazandın' : '${days - current} gün kaldı',
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
      (1, '1 günlük seri'),
      (7, '7 günlük seri'),
      (30, '30 günlük seri'),
      (90, '90 günlük seri'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((entry) {
        final unlocked = currentStreak >= entry.$1;
        final color = unlocked ? const Color(0xFF2563EB) : Colors.grey[500];
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
