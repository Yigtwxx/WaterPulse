// frontend/lib/ui/widgets/water_progress_bar.dart
//
// Büyük damla şeklinde su ilerleme göstergesi.
// HomeScreen'de:
//   WaterProgressBar(currentMl: _currentMl, goalMl: _goalMl)

import 'package:flutter/material.dart';

class WaterProgressBar extends StatefulWidget {
  final int currentMl;
  final int goalMl;

  const WaterProgressBar({
    super.key,
    required this.currentMl,
    required this.goalMl,
  });

  @override
  State<WaterProgressBar> createState() => _WaterProgressBarState();
}

class _WaterProgressBarState extends State<WaterProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rainController;

  @override
  void initState() {
    super.initState();
    _rainController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(); // sürekli yukarıdan damlacık gelsin
  }

  @override
  void dispose() {
    _rainController.dispose();
    super.dispose();
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
                  Positioned.fill(
                    child: IgnorePointer(
                      child: _RainOverlay(animation: _rainController),
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
                    color: const Color(0xff111827),
                  ),
            ),
          ],
        );
      },
    );
  }
}

/// Yukarıdan sürekli gelen minik damlacıklar
class _RainOverlay extends StatelessWidget {
  final Animation<double> animation;

  const _RainOverlay({required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return CustomPaint(
          painter: _RaindropsPainter(animation.value),
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

    // ==== GÜNCELLENMİŞ ASİMETRİK VE YUVARLAK DAMLA ====
    final Path dropPath = Path();

    // 1. Başlangıç: Üst sivri uç
    dropPath.moveTo(w * 0.45, 0);

    // 2. Sol taraf: Hafifçe dışa açılıp aşağı inen gövde
    dropPath.cubicTo(
      w * 0.05, h * 0.20, // Kontrol 1: Sol üst
      0, h * 0.55, // Kontrol 2: Sol orta (daha geniş)
      w * 0.10, h * 0.80, // Bitiş: Alt kıvrımın başlangıcı
    );

    // 3. Alt taraf: DAHA YUVARLAK VE GENİŞ TABAN
    dropPath.cubicTo(
      w * 0.20, h * 1.15, // Kontrol 1: Sol alt (aşağı ve geniş)
      w * 0.80, h * 1.15 , // Kontrol 2: Sağ alt (aşağı ve geniş)
      w * 0.92, h * 0.80, // Bitiş: Sağ kıvrımın başlangıcı
    );

    // 4. Sağ taraf: Tepeye dönüş
    dropPath.cubicTo(
      w * 1.0, h * 0.5, // Kontrol 1: Sağ orta
      w * 0.75, h * 0.4, // Kontrol 2: Tepeye yakın
      w * 0.45, 0, // Bitiş: Başlangıç
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
    final double waveHeight = baseWave * (0.4 + 0.6 * (1.0 - clamped));

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

/// Küçük damlaları çizen painter
class _RaindropsPainter extends CustomPainter {
  final double t; // 0.0 - 1.0 arasında loop eden zaman

  _RaindropsPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final Paint dropPaint = Paint()
      ..color = const Color.fromARGB(255, 34, 133, 254).withOpacity(0.65)
      ..style = PaintingStyle.fill;

    // 3 küçük damla, faz kaydırmalı (her biri farklı faz)
    final List<double> offsets = [0.0, 0.33, 0.66];
    final List<double> xs = [w * 0.35, w * 0.50, w * 0.65];

    for (int i = 0; i < offsets.length; i++) {
      final double phase = (t + offsets[i]) % 1.0;

      // Yukarıdan aşağıya y pozisyonu (biraz damlanın ortalarında kaybolsun)
      final double startY = -20;
      final double endY = h * 0.45;
      final double y = startY + (endY - startY) * phase;

      final double x = xs[i];

      // Küçük damlanın boyutu (hafif nefes efekti)
      final double minR = 3.0;
      final double maxR = 6.0;
      final double r = minR + (maxR - minR) * (0.5 + 0.5 * (1 - (phase - 0.5).abs() * 2));

      // küçük daire/damla
      canvas.drawCircle(Offset(x, y), r, dropPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RaindropsPainter oldDelegate) {
    return oldDelegate.t != t;
  }
}
