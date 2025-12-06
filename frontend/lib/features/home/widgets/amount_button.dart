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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Dark Mode Colors:
    // Background: A different blue (e.g., Color(0xFF2563EB)) to stand out from background
    // Text: White
    // Border: Same bright blue or transparent
    
    // Light Mode Colors (Original):
    // Background: White
    // Text: BlueAccent
    // Border: Neon/Blue

    final Color bgColor = enabled
        ? (isDark ? const Color(0xFF1E40AF) : Colors.white) // Darker Blue in Dark Mode
        : (isDark ? Colors.grey[800]! : Colors.grey[200]!);

    final Color borderColor = enabled
        ? (isDark ? const Color(0xFF3B82F6) : AppTheme.neonColor)
        : Colors.grey;

    final Color textColor = enabled
        ? (isDark ? Colors.white : Colors.blueAccent)
        : Colors.grey;

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
              color: bgColor,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: borderColor,
              ),
              boxShadow: enabled
                  ? [
                      BoxShadow(
                        color: isDark 
                            ? Colors.black.withOpacity(0.3) 
                            : Colors.blueAccent.withOpacity(0.08),
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
                  color: textColor,
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
