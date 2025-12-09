import 'package:flutter/material.dart';

class PremiumUsername extends StatefulWidget {
  final String username;
  final String subscriptionPlan;
  final String? title;
  final TextStyle? style;

  const PremiumUsername({
    super.key,
    required this.username,
    required this.subscriptionPlan,
    this.title,
    this.style,
  });

  @override
  State<PremiumUsername> createState() => _PremiumUsernameState();
}

class _PremiumUsernameState extends State<PremiumUsername>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseStyle = widget.style ?? Theme.of(context).textTheme.titleMedium!;
    final formattedName = widget.title != null ? '[${widget.title}] ${widget.username}' : widget.username;

    if (widget.subscriptionPlan == 'plus') {
      // Plus: Gold styling
      return Text(
        formattedName,
        style: baseStyle.copyWith(
          color: const Color(0xFFFFD700), // Gold
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: const Color(0xFFFFD700).withOpacity(0.5),
              blurRadius: 8,
            ),
          ],
        ),
      );
    } else if (widget.subscriptionPlan == 'pro') {
      // Pro: Animated Purple Gradient
      return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                colors: const [
                  Color(0xFF9C27B0), // Purple
                  Color(0xFFE040FB), // Pink Accent
                  Color(0xFF7C4DFF), // Deep Purple Accent
                  Color(0xFF9C27B0), // Purple again for seamless loop
                ],
                stops: const [0.0, 0.4, 0.6, 1.0],
                begin: Alignment(-1.0 + (_controller.value * 2), 0.0),
                end: Alignment(1.0 + (_controller.value * 2), 0.0),
                tileMode: TileMode.mirror,
              ).createShader(bounds);
            },
            child: Text(
              formattedName,
              style: baseStyle.copyWith(
                color: Colors.white, // Required for ShaderMask
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      );
    }

    // Basic: Default styling
    return Text(
      formattedName,
      style: baseStyle,
    );
  }
}
