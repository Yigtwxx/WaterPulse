import 'package:flutter/material.dart';

class GoalBadge extends StatelessWidget {
  final bool achieved;
  final int remaining;

  final int streak;

  const GoalBadge({super.key, this.achieved = false, this.remaining = 0, this.streak = 0});

  @override
  Widget build(BuildContext context) {
    final text = achieved
        ? 'Bugünkü hedef tamam! ($streak günlük seri)'
        : 'Hedefe ${remaining} ml kaldı';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color:
            achieved ? const Color(0xFF2563EB).withOpacity(0.10) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2563EB)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            achieved ? Icons.verified : Icons.access_time,
            color: const Color(0xFF2563EB),
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF1E40AF),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
