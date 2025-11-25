// frontend/lib/ui/widgets/water_progress_bar.dart
//
// Büyük damla şeklinde su ilerleme göstergesi.
// HomeScreen'de:
//   WaterProgressBar(currentMl: _currentMl, goalMl: _goalMl)

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
    // 0.0 - 1.0 arası ilerleme
    final double targetProgress =
        goalMl == 0 ? 0.0 : (currentMl / goalMl).clamp(0.0, 1.0);

    return TweenAnimationBuilder<double>(
      // currentMl değiştikçe buradaki end değeri değişiyor
      tween: Tween<double>(begin: 0.0, end: targetProgress),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, animatedProgress, child) {
        final clamped = animatedProgress.clamp(0.0, 1.0);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Büyük damla alanı
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    // 🔵 DAMLANIN ETRAFINDAKİ MAVİ PARLAMA
                    color: const Color.fromARGB(255, 39, 135, 226)
                        .withOpacity(0.20),
                    blurRadius: 2000,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Arkadaki açık renk damla (boş kısım)
                  const Icon(
                    Icons.water_drop,
                    size: 120,
                    // 🔵 ARKA PLAN DAMLA RENGİ (çok açık mavi)
                    color: Color.fromARGB(255, 157, 197, 251),
                  ),

                  // Alttan yukarı dolan koyu renk damla
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: ClipRect(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        // Ne kadar dolu olacağını belirliyor
                        heightFactor: clamped,
                        child: const Icon(
                          Icons.water_drop,
                          size: 120,
                          // 🔵 DOLU KISIM RENGİ (daha canlı mavi)
                          color: Color.fromARGB(255, 34, 133, 254),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Yazı: "X / Y ml"
            Text(
              '$currentMl / $goalMl ml',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff111827),
                  ),
            ),
          ],
        );
      },
    );
  }
}
