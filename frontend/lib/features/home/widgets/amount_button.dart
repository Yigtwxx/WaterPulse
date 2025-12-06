import 'package:flutter/material.dart';
import 'package:waterpulse/config/app_theme.dart';

class AmountButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;

  const AmountButton({
    super.key,
    required this.label,
    this.onTap,
  });

  @override
  State<AmountButton> createState() => _AmountButtonState();
}

class _AmountButtonState extends State<AmountButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    final scale = _pressed ? 0.95 : 1.0;

    return AnimatedScale(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOutCubic,
      scale: scale,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(30),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(30),
          onHighlightChanged: (v) {
            if (enabled) {
              setState(() => _pressed = v);
            }
          },
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 32.0, vertical: 10.0),
            decoration: BoxDecoration(
              color: enabled ? Colors.white : Colors.grey[200],
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: enabled ? AppTheme.neonColor : Colors.grey,
              ),
              boxShadow: enabled
                  ? [
                      BoxShadow(
                        color: Colors.blueAccent.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Center(
              child: Text(
                widget.label,
                style: TextStyle(
                  color: enabled ? Colors.blueAccent : Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
