// frontend/lib/ui/widgets/water_progress_bar.dart
import 'package:flutter/material.dart';

class WaterProgressBar extends StatelessWidget {
  final int currentMl;
  final int goalMl;

  const WaterProgressBar({
    super.key,
    required this.currentMl,
    required this.goalMl,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (currentMl / goalMl).clamp(0.0, 1.0);

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 150,
                width: 150,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 10,
                  backgroundColor: Colors.blue.withValues(alpha: 0.15),

                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.water_drop,
                    size: 40,
                    color: Color(0xFF3B82F6),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$currentMl / $goalMl ml',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
