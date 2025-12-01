import 'package:flutter/material.dart';
import 'package:waterpulse/services/api_client.dart';

class DatasScreen extends StatefulWidget {
  const DatasScreen({super.key});

  @override
  State<DatasScreen> createState() => _DatasScreenState();
}

class _DatasScreenState extends State<DatasScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Hydration Stats',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.indigo,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.indigo,
          tabs: const [
            Tab(text: 'Day'),
            Tab(text: 'Week'),
            Tab(text: 'Month'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _BackendHeatmap(type: 'day'),
          _BackendHeatmap(type: 'week'),
          _BackendHeatmap(type: 'month'),
        ],
      ),
    );
  }
}

class _BackendHeatmap extends StatelessWidget {
  final String type;
  const _BackendHeatmap({required this.type});

  @override
  Widget build(BuildContext context) {
    // Using userId=1 as default, matching other parts of the app
    final userId = 1;
    final url = '${ApiClient.baseUrl}/stats/heatmap/$type/$userId?t=${DateTime.now().millisecondsSinceEpoch}';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (type == 'day')
            const Text(
              "Today's Hourly Intake",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
            ),
          if (type == 'week')
            const Text(
              "Weekly Intake",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
            ),
          if (type == 'month')
            const Text(
              "Monthly Intake Trend",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
            ),
          const SizedBox(height: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.network(
                url,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Text(
                      'Failed to load heatmap',
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
