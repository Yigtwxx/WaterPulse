import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:waterpulse/features/auth/providers/auth_provider.dart';
import 'package:waterpulse/services/api_client.dart';
import 'dart:math';

// Unified Aggregated Data Provider (Used by Column, Line, Heatmap)
final aggregatedDataProvider = FutureProvider.family<List<ChartDataPoint>, Tuple2<String, String>>((ref, params) async {
  final range = params.item1; // 'Day', 'Week', 'Month', 'Year'
  final user = ref.watch(authProvider).value;
  if(user == null) return [];

  final now = DateTime.now();
  
  if (range == 'Day') {
    // Hourly data for today
    final startStr = DateFormat('yyyy-MM-dd').format(now);
    final response = await ApiClient.get('/water/logs/${user.id}?date_str=$startStr');
    final logs = response as List<dynamic>;
    
    // Initialize 24 hours
    Map<int, double> hourlyMap = {for (var i = 0; i < 24; i++) i: 0.0};
    
    for (var log in logs) {
      final dt = DateTime.parse(log['timestamp']);
      hourlyMap[dt.hour] = (hourlyMap[dt.hour] ?? 0) + (log['amount_ml'] as int).toDouble();
    }
    
    return hourlyMap.entries.map((e) => ChartDataPoint(
      x: e.key.toDouble(), 
      y: e.value, 
      label: '${e.key}:00'
    )).toList();
    
  } else if (range == 'Week') {
    // Daily data for last 7 days
    final start = now.subtract(const Duration(days: 6));
    final startStr = DateFormat('yyyy-MM-dd').format(start);
    final endStr = DateFormat('yyyy-MM-dd').format(now);
    
    final response = await ApiClient.get('/water/calendar/${user.id}?start_date=$startStr&end_date=$endStr');
    final data = response as List<dynamic>;
    
    Map<String, double> dailyMap = {};
    for (int i = 0; i < 7; i++) {
       final day = start.add(Duration(days: i));
       dailyMap[DateFormat('yyyy-MM-dd').format(day)] = 0.0;
    }

    for (var item in data) {
       dailyMap[item['date']] = (item['total_ml'] as int).toDouble();
    }

    int index = 0;
    List<ChartDataPoint> points = [];
    dailyMap.forEach((date, amount) {
       final dt = DateTime.parse(date);
       points.add(ChartDataPoint(
         x: index.toDouble(), 
         y: amount, 
         label: DateFormat('E').format(dt)
       ));
       index++;
    });
    return points;

  } else if (range == 'Month') {
    // Daily data for last 30 days
    final start = now.subtract(const Duration(days: 29));
    final startStr = DateFormat('yyyy-MM-dd').format(start);
    final endStr = DateFormat('yyyy-MM-dd').format(now);

    final response = await ApiClient.get('/water/calendar/${user.id}?start_date=$startStr&end_date=$endStr');
    final data = response as List<dynamic>;

    Map<String, double> dailyMap = {};
    for (int i = 0; i < 30; i++) {
       final day = start.add(Duration(days: i));
       dailyMap[DateFormat('yyyy-MM-dd').format(day)] = 0.0;
    }

    for (var item in data) {
       dailyMap[item['date']] = (item['total_ml'] as int).toDouble();
    }
    
    int index = 0;
    List<ChartDataPoint> points = [];
    dailyMap.forEach((date, amount) {
      final dt = DateTime.parse(date);
      points.add(ChartDataPoint(
        x: index.toDouble(),
        y: amount,
        label: dt.day.toString()
      ));
      index++;
    });
    return points;

  } else {
    // Monthly data for last 12 months (Year)
    final start = DateTime(now.year, 1, 1);
    final startStr = DateFormat('yyyy-MM-dd').format(start);
    final endStr = DateFormat('yyyy-MM-dd').format(now);

    final response = await ApiClient.get('/water/calendar/${user.id}?start_date=$startStr&end_date=$endStr');
    final data = response as List<dynamic>;

    Map<int, double> monthlyMap = {for (var i = 1; i <= 12; i++) i: 0.0};
    
    for (var item in data) {
      final dt = DateTime.parse(item['date']);
      monthlyMap[dt.month] = (monthlyMap[dt.month] ?? 0) + (item['total_ml'] as int).toDouble();
    }

    return monthlyMap.entries.map((e) => ChartDataPoint(
      x: e.key.toDouble(),
      y: e.value,
      label: DateFormat('MMM').format(DateTime(2024, e.key))
    )).toList();
  }
});

// Raw Logs Provider (Used by Scatter & Box)


class ChartDataPoint {
  final double x;
  final double y;
  final String label;
  ChartDataPoint({required this.x, required this.y, required this.label});
}

class Tuple2<T1, T2> {
  final T1 item1;
  final T2 item2;
  Tuple2(this.item1, this.item2);
  @override bool operator ==(Object other) => other is Tuple2 && other.item1 == item1 && other.item2 == item2;
  @override int get hashCode => Object.hash(item1, item2);
}

class DatasScreen extends ConsumerStatefulWidget {
  const DatasScreen({super.key});
  @override ConsumerState<DatasScreen> createState() => _DatasScreenState();
}

class _DatasScreenState extends ConsumerState<DatasScreen> {
  String _selectedChart = 'Heatmap';
  String _timeRange = 'Week'; // Default to week

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Statistics', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Row(
        children: [
          Container(
            width: 80,
            color: Colors.grey.shade50,
            child: SingleChildScrollView(
              child: Column(children: [
                const SizedBox(height: 20),
                _SidebarItem(icon: Icons.grid_view, label: 'Heatmap', isSelected: _selectedChart == 'Heatmap', onTap: () => setState(() => _selectedChart = 'Heatmap')),

                _SidebarItem(icon: Icons.bar_chart, label: 'Column', isSelected: _selectedChart == 'Column', onTap: () => setState(() => _selectedChart = 'Column')),
                _SidebarItem(icon: Icons.show_chart, label: 'Line', isSelected: _selectedChart == 'Line', onTap: () => setState(() => _selectedChart = 'Line')),

              ]),
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Column(children: [
              // Universal Filter Bar
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: ['Day', 'Week', 'Month', 'Year'].map((range) {
                      final isSelected = _timeRange == range;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ChoiceChip(
                          label: Text(range),
                          selected: isSelected,
                          onSelected: (val) { if(val) setState(() => _timeRange = range); },
                          selectedColor: Colors.indigo.shade100,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.indigo.shade900 : Colors.black87,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildChartContent(),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildChartContent() {
    switch (_selectedChart) {
      case 'Heatmap': return _HeatmapView(range: _timeRange);


      case 'Column': return _AggregatedChartView(type: 'Column', range: _timeRange);
      case 'Line': return _AggregatedChartView(type: 'Line', range: _timeRange);
      default: return const Center(child: Text("Select a chart"));
    }
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _SidebarItem({ required this.icon, required this.label, required this.isSelected, required this.onTap });
  @override Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: isSelected ? BoxDecoration(
          border: Border(left: BorderSide(width: 4, color: Colors.indigo)),
          color: Colors.indigo.withOpacity(0.05)
        ) : null,
        child: Column(children: [
          Icon(icon, color: isSelected ? Colors.indigo : Colors.grey),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 10, color: isSelected ? Colors.indigo : Colors.grey, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        ]),
      ),
    );
  }
}

class _AggregatedChartView extends ConsumerWidget {
  final String type; 
  final String range;
  const _AggregatedChartView({required this.type, required this.range});
  @override Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(aggregatedDataProvider(Tuple2(range, '')));
    return dataAsync.when(
      data: (points) {
        if (points.isEmpty) return const Center(child: Text("No data available"));
        final maxY = max(points.map((e) => e.y).reduce(max) * 1.2, 100.0);
        return BarLineChartBuilder(type: type, points: points, maxY: maxY);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}

class BarLineChartBuilder extends StatelessWidget {
  final String type;
  final List<ChartDataPoint> points;
  final double maxY;
  const BarLineChartBuilder({super.key, required this.type, required this.points, required this.maxY});

  @override Widget build(BuildContext context) {
    return type == 'Column' 
      ? BarChart(
          BarChartData(
            maxY: maxY,
            barGroups: points.asMap().entries.map((e) => BarChartGroupData(
              x: e.key,
              barRods: [BarChartRodData(toY: e.value.y, color: Colors.indigo, borderRadius: BorderRadius.circular(4), width: 16, backDrawRodData: BackgroundBarChartRodData(show: true, toY: maxY, color: Colors.grey.shade100))]
            )).toList(),
            titlesData: _buildTitles(),
            gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: maxY / 5, getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade200, strokeWidth: 1)),
            borderData: FlBorderData(show: false),
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                tooltipBgColor: Colors.indigo.shade900,
                tooltipPadding: const EdgeInsets.all(8),
                tooltipMargin: 8,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                    '${points[group.x].label}\n',
                    const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    children: [TextSpan(text: '${rod.toY.toInt()} ml', style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500))],
                  );
                },
              ),
            ),
          )
        )
      : LineChart(
          LineChartData(
            maxY: maxY, minY: 0,
            clipData: FlClipData.all(),
            lineBarsData: [LineChartBarData(
              spots: points.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.y)).toList(),
              isCurved: true, color: Colors.indigo, barWidth: 4, isStrokeCapRound: true,
              dotData: FlDotData(show: true, getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(radius: 4, color: Colors.white, strokeWidth: 2, strokeColor: Colors.indigo)),
              belowBarData: BarAreaData(show: true, color: Colors.indigo.withOpacity(0.15)),
            )],
            titlesData: _buildTitles(),
            gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: maxY / 5, getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade200, strokeWidth: 1)),
            borderData: FlBorderData(show: false),
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                tooltipBgColor: Colors.indigo.shade900,
                tooltipPadding: const EdgeInsets.all(8),
                tooltipMargin: 8,
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((touchedSpot) {
                    return LineTooltipItem(
                      '${points[touchedSpot.x.toInt()].label}\n',
                      const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      children: [TextSpan(text: '${touchedSpot.y.toInt()} ml', style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500))],
                    );
                  }).toList();
                },
              ),
            ),
          )
        );
  }

  FlTitlesData _buildTitles() {
    return FlTitlesData(
      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 50, interval: maxY / 5 > 0 ? maxY / 5 : 500, getTitlesWidget: (val, meta) => Text('${val.toInt()}', style: TextStyle(color: Colors.grey.shade600, fontSize: 11, fontWeight: FontWeight.w500)))),
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 32, getTitlesWidget: (val, meta) {
        if (val.toInt() >= 0 && val.toInt() < points.length) {
            // Check for label density
            if (points.length > 20 && val.toInt() % 5 != 0) return const SizedBox.shrink();
            if (points.length > 10 && points.length <= 20 && val.toInt() % 2 != 0) return const SizedBox.shrink();
            
            return Padding(padding: const EdgeInsets.only(top: 8), child: Text(points[val.toInt()].label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade700)));
        }
        return const SizedBox.shrink();
      })),
    );
  }
}

class _HeatmapView extends ConsumerWidget {
  final String range;
  const _HeatmapView({required this.range});
  @override Widget build(BuildContext context, WidgetRef ref) {
    // Reuse aggregated data provider logic as it already buckets correctly
    final dataAsync = ref.watch(aggregatedDataProvider(Tuple2(range, '')));
    return dataAsync.when(
      data: (points) {
         int crossAxisCount = 7;
         if (range == 'Day') crossAxisCount = 6; // 4x6=24
         if (range == 'Year') crossAxisCount = 4; // 3x4=12
         
         return GridView.builder(
           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
             crossAxisCount: crossAxisCount,
             crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 1.0
           ),
           itemCount: points.length,
           itemBuilder: (ctx, i) {
             final p = points[i];
             Color color = Colors.grey.shade100;
             if (p.y > 0) color = Colors.indigo.shade100;
             if (p.y > 1000) color = Colors.indigo.shade300;
             if (p.y > 2000) color = Colors.indigo.shade700;
             if (p.y > 3000) color = Colors.indigo.shade900;
             
             return Container(
               decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
               child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                 Text(p.label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: p.y > 2000 ? Colors.white : Colors.black87)),
                 Text("${p.y.toInt()}ml", style: TextStyle(fontSize: 10, color: p.y > 2000 ? Colors.white70 : Colors.black54)),
               ]),
             );
           }
         );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}




