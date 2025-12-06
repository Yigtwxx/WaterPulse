// frontend/lib/ui/widgets/water_progress_bar.dart
//
// Büyük damla şeklinde su ilerleme göstergesi.
// HomeScreen'de:
//   WaterProgressBar(currentMl: _currentMl, goalMl: _goalMl)

import 'package:flutter/material.dart';

class WaterProgressBar extends StatefulWidget {
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
  State<WaterProgressBar> createState() => _WaterProgressBarState();
}

class _WaterProgressBarState extends State<WaterProgressBar>
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
                    // 🔵 damlanın etrafındaki mavi parlama
                    color: const Color.fromARGB(255, 39, 135, 226)
                        .withOpacity(0.20),
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
                    painter: _WaterDropPainter(clamped),
                  ),

                  // Üstten gelen küçük damlacıklar (overlay)
                  if (widget.rainActive || _running)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: _SplashOverlay(animation: _rainController),
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

  const _SplashOverlay({required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return CustomPaint(
          painter: _SplashPainter(animation.value),
        );
      },
    );
  }
}

// --- MEVCUT DAMLA PAINTER'IN (HİÇ BOZMADIM, SADECE AYNEN KULLANIYORUZ) ---
class _WaterDropPainter extends CustomPainter {
  final double progress; // 0.0 - 1.0

  _WaterDropPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // ==== TEARDROP ŞEKLİ ====
    final Path dropPath = Path();

    // Üst sivri uç
    dropPath.moveTo(w * 0.52, 0);

    // Sol yan
    dropPath.cubicTo(
      w * 0.15, h * 0.18, // sol üst kontrol
      w * 0.02, h * 0.55, // sol gövde genişlik
      w * 0.16, h * 0.86, // alt sol
    );

    // Alt
    dropPath.cubicTo(
      w * 0.30, h * 1.12, // alt sol
      w * 0.70, h * 1.12, // alt sağ
      w * 0.84, h * 0.86, // alt sağ yukarı
    );

    // Sağ yan
    dropPath.cubicTo(
      w * 0.98, h * 0.55, // sağ gövde genişlik
      w * 0.85, h * 0.18, // sağ üst kontrol
      w * 0.52, 0, // tepe
    );

    dropPath.close();

    // Arka plan rengi (boş kısım)
    final Paint bgPaint = Paint()
      ..color = const Color.fromARGB(255, 157, 197, 251)
      ..style = PaintingStyle.fill;

    canvas.drawPath(dropPath, bgPaint);

    // === SU DOLU KISIM (soft & tatlı fill efekti) ===
    canvas.save();
    canvas.clipPath(dropPath);

    final double clamped = progress.clamp(0.0, 1.0);

    // Damla biraz aşağı taştığı için (h * 1.15) ile hesap
    final double levelY = (h * 1.15) * (1.0 - clamped);

    // Su dalgasının genişliği ve yüksekliği (yumuşak, küçük bir kavis)
    final double leftX = -w * 0.2;
    final double rightX = w * 1;
    final double bottomY = h * 1.2;
    final double midX = (leftX + rightX) / 2;

    // progress yükseldikçe dalga biraz daha düzleşsin (çok oynamasın)
    final double baseWave = 6.0;
    final double waveHeight = baseWave * (1.0 - clamped);

    final Path waterPath = Path()
      ..moveTo(leftX, bottomY)
      ..lineTo(leftX, levelY)
      ..quadraticBezierTo(
        midX, levelY - waveHeight, // ortada hafif yukarı bombeli
        rightX, levelY,
      )
      ..lineTo(rightX, bottomY)
      ..close();

    // Gradient ile daha soft görünüm
    final Rect waterBounds =
        Rect.fromLTRB(leftX, levelY - waveHeight, rightX, bottomY);

    final Paint waterPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF5FAFFE), // üst kısım daha açık mavi
          Color.fromARGB(255, 34, 133, 254), // alt kısım mevcut mavi
        ],
      ).createShader(waterBounds);

    canvas.drawPath(waterPath, waterPaint);

    canvas.restore();

    // === BEYAZ PARLAMA (Highlight) ===
    final Paint highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final Path highlightPath = Path()
      ..moveTo(w * 0.2, h * 0.70)
      ..quadraticBezierTo(
        w * 0.30, h * 0.92,
        w * 0.55, h * 0.92,
      );

    canvas.drawPath(highlightPath, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant _WaterDropPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Halka splash painter
class _SplashPainter extends CustomPainter {
  final double t;

  _SplashPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxR = size.width * 0.42;

    final Paint ring = Paint()
      ..color = const Color(0xFF3B82F6).withOpacity((1 - t).clamp(0.0, 1.0))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0 * (1 - t).clamp(0.3, 1.0);

    final double r1 = maxR * t;
    final double r2 = maxR * (t * 0.8 + 0.2);

    canvas.drawCircle(center, r1, ring);
    canvas.drawCircle(center, r2, ring..color = ring.color.withOpacity(ring.color.opacity * 0.8));
  }

  @override
  bool shouldRepaint(covariant _SplashPainter oldDelegate) {
    return oldDelegate.t != t;
  }
}
