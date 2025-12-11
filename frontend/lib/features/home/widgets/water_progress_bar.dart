// frontend/lib/ui/widgets/water_progress_bar.dart
//
// Büyük damla şeklinde su ilerleme göstergesi.
// HomeScreen'de:
//   WaterProgressBar(currentMl: _currentMl, goalMl: _goalMl)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waterpulse/features/settings/providers/water_color_provider.dart';

class WaterProgressBar extends ConsumerStatefulWidget {
  final int currentMl;
  final int goalMl;
  final bool rainActive;

  const WaterProgressBar({
    super.key,
    required this.currentMl,
    required this.goalMl,
    this.rainActive = false,
  });

  @override
  ConsumerState<WaterProgressBar> createState() => _WaterProgressBarState();
}

class _WaterProgressBarState extends ConsumerState<WaterProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rainController;
  bool _running = false;

  @override
  void initState() {
    super.initState();
    _rainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _syncRain();
  }

  @override
  void dispose() {
    _rainController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant WaterProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rainActive != widget.rainActive) {
      _syncRain();
    }
  }

  void _syncRain() {
    if (widget.rainActive) {
      _rainController.forward(from: 0);
      _running = true;
    } else {
      if (_running) {
        _rainController.stop();
        _running = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 0.0 - 1.0 arası ilerleme
    final double targetProgress = widget.goalMl == 0
        ? 0.0
        : (widget.currentMl / widget.goalMl).clamp(0.0, 1.0);

    // Watch the color provider
    final waterColor = ref.watch(waterColorProvider);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: targetProgress),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, animatedProgress, child) {
        final clamped = animatedProgress.clamp(0.0, 1.0);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 💧 Büyük damla alanı + glow + yukarıdan gelen damlacıklar
            Container(
              width: 160,
              height: 160,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    // 🔵 damlanın etrafındaki parlama (seçilen renkte)
                    color: waterColor.withOpacity(0.20),
                    blurRadius: 1500,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Ana damla + içinin dolma efekti (senin painter)
                  CustomPaint(
                    size: const Size(130, 150),
                    painter: _WaterDropPainter(clamped, waterColor),
                  ),

                  // Üstten gelen küçük damlacıklar (overlay)
                  // Pass color to splash overlay too if desired, keeping splash blue for now or match?
                  // Let's keep rain distinct or maybe match it later. Keeping original rain for now.
                  if (widget.rainActive || _running)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: _SplashOverlay(animation: _rainController, color: waterColor),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Yazı: "X / Y ml"
            Text(
              '${widget.currentMl} / ${widget.goalMl} ml',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : const Color(0xff111827),
                  ),
            ),
          ],
        );
      },
    );
  }
}

/// Su eklendiğinde çıkan yumuşak halka efekti
class _SplashOverlay extends StatelessWidget {
  final Animation<double> animation;
  final Color color;

  const _SplashOverlay({required this.animation, required this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return CustomPaint(
          painter: _SplashPainter(animation.value, color),
        );
      },
    );
  }
}

// --- MEVCUT DAMLA PAINTER ---
class _WaterDropPainter extends CustomPainter {
  final double progress; // 0.0 - 1.0
  final Color waterColor;

  _WaterDropPainter(this.progress, this.waterColor);

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // ==== 1. TEARDROP ŞEKLİ (Clean Shape with Rounded Bottom) ====
    final Path dropPath = Path();
    dropPath.moveTo(w * 0.5, 0); // Top Peak
    
    // Left curve 
    dropPath.cubicTo(
      w * 0.05, h * 0.40, // control 1 (Neck - wider and higher)
      w * 0.02, h * 0.95, // control 2 (Belly - much wider)
      w * 0.5, h * 1.0    // target (Bottom Center)
    );

    // Right curve
    dropPath.cubicTo(
      w * 0.98, h * 0.95, // control 1 (Belly - much wider)
      w * 0.95, h * 0.40, // control 2 (Neck - wider and higher)
      w * 0.5, 0          // back to top
    );
    dropPath.close();

    // ==== 2. ARKA PLAN (Boş Kısım) ====
    // Gradient stroke for the container for a premium look
    final Paint borderPaint = Paint()
      ..color = Colors.grey.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    final Paint bgPaint = Paint()
      ..color = Colors.grey.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    canvas.drawPath(dropPath, bgPaint);
    canvas.drawPath(dropPath, borderPaint);

    // ==== 3. SU DOLU KISIM (Glossy Gradient) ====
    canvas.save();
    canvas.clipPath(dropPath);

    final double clamped = progress.clamp(0.0, 1.0);
    // Calculate water level (bottom up)
    final double levelY = h * (1.0 - clamped);

    // Düz bir su seviyesi yerine hafif dalgalı veya düz seçenek
    // Reference image is static, so let's make it a flat fill with gradient to look like the icon when full
    // But since it is a progress bar, we fill up to levelY.
    
    final Rect fillRect = Rect.fromLTRB(0, levelY, w, h);
    
    final Paint waterPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.lerp(waterColor, Colors.white, 0.4)!, // Lighter top
          waterColor, // Main color at bottom
        ],
      ).createShader(Rect.fromLTRB(0, 0, w, h)); // Gradient over full height for consistency

    // Draw the water rect (clipped to path)
    canvas.drawRect(fillRect, waterPaint);

    canvas.restore();

    // ==== 4. PARLAMA (Reflection/Glitch) ====
    // White pill/crescent on the bottom-left as per image
    final Path highlightPath = Path();
    // A simple curved line on the bottom left
    highlightPath.moveTo(w * 0.25, h * 0.65);
    highlightPath.quadraticBezierTo(
      w * 0.22, h * 0.75, 
      w * 0.35, h * 0.82
    );

    final Paint highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(highlightPath, highlightPaint);
    
    // Extra subtle shine on top right
    final Paint topShinePaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;
      
    canvas.drawCircle(Offset(w * 0.7, h * 0.3), w * 0.1, topShinePaint);
  }

  @override
  bool shouldRepaint(covariant _WaterDropPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.waterColor != waterColor;
  }
}

/// Halka splash painter
class _SplashPainter extends CustomPainter {
  final double t;
  final Color color;

  _SplashPainter(this.t, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxR = size.width * 0.5;

    final Paint ring = Paint()
      ..color = color.withOpacity((1 - t).clamp(0.0, 0.4))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0 * (1 - t);

    canvas.drawCircle(center, maxR * t, ring);
  }

  @override
  bool shouldRepaint(covariant _SplashPainter oldDelegate) {
    return oldDelegate.t != t || oldDelegate.color != color;
  }
}
