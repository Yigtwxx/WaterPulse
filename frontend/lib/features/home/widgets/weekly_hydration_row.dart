import 'package:flutter/material.dart';

class WeeklyHydrationRow extends StatelessWidget {
  final bool loading;
  final List<Map<String, dynamic>> weekTotals;

  const WeeklyHydrationRow({
    super.key,
    required this.loading,
    required this.weekTotals,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Align(
        alignment: Alignment.centerRight,
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2.4),
        ),
      );
    }

    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 6));
    final map = {
      for (var e in weekTotals)
        (e["date"] as DateTime).toIso8601String().split('T').first: e["total"]
    };

    final List<Widget> dots = [];
    for (int i = 0; i < 7; i++) {
      final day = start.add(Duration(days: i));
      final key = day.toIso8601String().split('T').first;
      final total = (map[key] as int?) ?? 0;
      final isToday = day.year == now.year &&
          day.month == now.month &&
          day.day == now.day;
      dots.add(_DayCircle(
        label: _dayLabel(day),
        total: total,
        highlight: isToday,
      ));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: dots
            .expand((w) => [w, const SizedBox(width: 8)])
            .toList()
          ..removeLast(),
      ),
    );
  }

  String _dayLabel(DateTime d) {
    const names = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    return names[d.weekday - 1];
  }
}

class _DayCircle extends StatelessWidget {
  final String label;
  final int total;
  final bool highlight;

  const _DayCircle({
    required this.label,
    required this.total,
    required this.highlight,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reached = total > 0;
    
    final primary = Theme.of(context).primaryColor;
    
    final borderColor =
        highlight ? primary : primary;
    
    // Dark mode: Transparent BG, White Border. Light Mode: White BG, Primary Border.
    final bg = reached
        ? borderColor.withOpacity(0.08)
        : (isDark ? Colors.transparent : Colors.white);

    final effectiveBorderColor = isDark && !reached ? Colors.white : borderColor;

    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bg,
        border: Border.all(
          color: isDark && !reached 
              ? Colors.white 
              : borderColor.withOpacity(reached ? 0.8 : 0.35),
          width: highlight ? 2.2 : 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.12),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: isDark ? Colors.white : Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            total > 0
                ? '${(total / 1000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}L'
                : '0L',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark 
                  ? Colors.white.withOpacity(0.9) 
                  : (reached ? Theme.of(context).primaryColor : Colors.grey[500]),
            ),
          ),
        ],
      ),
    );
  }
}
