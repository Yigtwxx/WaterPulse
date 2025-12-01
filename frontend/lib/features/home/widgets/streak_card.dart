import 'package:flutter/material.dart';

class StreakCard extends StatelessWidget {
  final bool loading;
  final Map<String, dynamic>? summary;
  final List<dynamic> skins;
  final bool goalAchievedToday;
  final int currentMl;
  final int dailyGoal;

  const StreakCard({
    super.key,
    required this.loading,
    required this.summary,
    required this.skins,
    required this.goalAchievedToday,
    required this.currentMl,
    required this.dailyGoal,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentStreak = summary?['current_streak'] ?? 0;
    final bestStreak = summary?['best_streak'] ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: loading
          ? const SizedBox(
              height: 80,
              child: Center(child: CircularProgressIndicator()),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _StatTile(
                        label: 'Current streak',
                        value: '$currentStreak days',
                        icon: Icons.local_fire_department_outlined,
                        color: Colors.orange.shade400,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatTile(
                        label: 'Best streak',
                        value: '$bestStreak days',
                        icon: Icons.military_tech_outlined,
                        color: Colors.indigo.shade400,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  dailyGoal > 0 ? 'Today: $currentMl / $dailyGoal ml' : 'Today: $currentMl ml',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: Colors.grey[700], fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Text(
                  'Avatar skins',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                if (skins.isEmpty)
                  Text(
                    'No skins yet',
                    style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: skins
                        .map((s) => _SkinChip(
                              name: s['name']?.toString() ?? 'Skin',
                              colorHex: s['color']?.toString(),
                              unlocked: s['is_unlocked'] == true,
                              active: s['is_active'] == true,
                            ))
                        .toList(),
                  ),
              ],
            ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
              
            ),
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.grey[700])),
                Text(
                  value,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _SkinChip extends StatelessWidget {
  final String name;
  final String? colorHex;
  final bool unlocked;
  final bool active;

  const _SkinChip({
    required this.name,
    required this.colorHex,
    required this.unlocked,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = _colorFromHex(colorHex) ?? Colors.blueAccent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: baseColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: active ? baseColor : baseColor.withOpacity(0.35),
          width: active ? 1.6 : 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            active ? Icons.check_circle : Icons.opacity_outlined,
            size: 16,
            color: baseColor,
          ),
          const SizedBox(width: 6),
          Text(
            name,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: unlocked ? Colors.grey[800] : Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Color? _colorFromHex(String? hex) {
    if (hex == null) return null;
    final cleaned = hex.replaceAll('#', '');
    if (cleaned.length == 6) {
      return Color(int.parse('0xFF$cleaned'));
    }
    return null;
  }
}
