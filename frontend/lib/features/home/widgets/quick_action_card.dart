import 'package:flutter/material.dart';
import 'package:waterpulse/config/app_theme.dart';

class QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const QuickActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF1E293B) : AppTheme.neonColor,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Sol ikon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark 
                      ? Colors.blue.withOpacity(0.2) 
                      : Colors.blue.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon, 
                  color: isDark ? const Color(0xFF60A5FA) : Colors.blueAccent
                ),
              ),
              const SizedBox(width: 12),

              // Başlık + açıklama
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),

              // Sağdaki ">" oku
              Icon(
                Icons.chevron_right, 
                color: isDark ? Colors.grey[500] : Colors.grey
              ),
            ],
          ),
        ),
      ),
    );
  }
}
