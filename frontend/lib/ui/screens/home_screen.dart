// frontend/lib/ui/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:waterpulse/config/app_strings.dart';
import 'package:waterpulse/services/local_db/dao/api_client.dart';
import 'package:waterpulse/ui/widgets/water_progress_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiClient apiClient = ApiClient();
  int _currentMl = 0;
  final int _goalMl = 2400;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadTodayTotal();
  }

  Future<void> _loadTodayTotal() async {
    setState(() => _loading = true);
    try {
      final total = await apiClient.getTodayTotal(userId: 1);
      setState(() => _currentMl = total);
    } catch (e) {
      // Hata durumunda şimdilik sessiz geçiyoruz
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _addWater(int amount) async {
    setState(() => _loading = true);
    try {
      await apiClient.addWater(userId: 1, amountMl: amount);
      await _loadTodayTotal();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not add water')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            WaterProgressBar(
                              currentMl: _currentMl,
                              goalMl: _goalMl,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: () => _addWater(250),
                                  child: const Text('+250 ml'),
                                ),
                                ElevatedButton(
                                  onPressed: () => _addWater(500),
                                  child: const Text('+500 ml'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Goal: $_goalMl ml',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      AppStrings.suggestions,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const ListTile(
                        leading: Icon(Icons.water_drop),
                        title: Text(AppStrings.suggestionText),
                      ),
                    ),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.query_stats),
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
