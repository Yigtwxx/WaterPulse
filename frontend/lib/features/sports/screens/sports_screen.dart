import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:waterpulse/features/auth/providers/auth_provider.dart';
import 'package:waterpulse/core/utils/snackbar_utils.dart';
import 'package:dio/dio.dart';
import 'dart:ui';

// State for recommendations
final recommendationsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final user = ref.watch(authProvider).value;
  if (user == null) return {};

  final dio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:8000/api/v1')); // Use env base url in real app
  try {
    final response = await dio.get('/users/${user.id}/recommendations');
    return response.data;
  } catch (e) {
    throw Exception('Failed to load recommendations');
  }
});

class SportsScreen extends ConsumerStatefulWidget {
  const SportsScreen({super.key});

  @override
  ConsumerState<SportsScreen> createState() => _SportsScreenState();
}

class _SportsScreenState extends ConsumerState<SportsScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _ageController;
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  String? _selectedGender;
  String? _selectedActivity;

  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _ageController = TextEditingController();
    _weightController = TextEditingController();
    _heightController = TextEditingController();
  }

  // Calculator State
  String _calcActivity = 'Cycling';
  double _calcDuration = 60; // minutes
  int? _calcWaterLoss;
  
  void _calculateWaterLoss() {
    // Water loss factors (ml per minute) - approximate
    final factors = {
      'Cycling': 10.0,
      'Running': 15.0,
      'Walking': 4.0,
      'Swimming': 12.0,
      'Gym': 8.0,
      'Yoga': 3.0,
    };
    
    final factor = factors[_calcActivity] ?? 8.0;
    setState(() {
      _calcWaterLoss = (_calcDuration * factor).round();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fillUserData();
  }

  void _fillUserData() {
    final user = ref.read(authProvider).value;
    if (user != null) {
      _ageController.text = user.age?.toString() ?? '';
      _weightController.text = user.weightKg?.toString() ?? '';
      _heightController.text = user.heightCm?.toString() ?? '';
      _selectedGender = user.gender; // Ensure backend values match literal strings or handle mapping
      _selectedActivity = user.activityLevel;
    }
  }

  @override
  void dispose() {
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    
    try {
      final age = int.tryParse(_ageController.text);
      final weight = double.tryParse(_weightController.text);
      final height = double.tryParse(_heightController.text);

      // Call auth provider to update user values
      // Assuming auth provider has an update method or we call API directly.
      // For proper state management, usually we call a method in the notifier.
      // Here implementing a direct API call or interacting with AuthNotifier if available.
      // Checking AuthNotifier for a generic update method... 
      // If not exists, I'll add one or simple API call for now.
      
      // Since I don't see the AuthNotifier definition fully, I'll assume we can call an update API via Dio and then refresh auth.
      
      final dio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:8000/api/v1'));
      final user = ref.read(authProvider).value;
      
      if (user == null) return;

      final data = {
        "age": age,
        "weight_kg": weight,
        "height_cm": height,
        "gender": _selectedGender,
        "activity_level": _selectedActivity
      };

      await dio.put('/users/${user.id}', data: data);
      
      // Refresh local user state
      await ref.read(authProvider.notifier).refreshUser();
      
      // Refresh recommendations
      ref.invalidate(recommendationsProvider);

      setState(() => _isEditing = false);
      if (mounted) context.showSuccessSnackBar('Profile updated!');

    } catch (e) {
      if (mounted) context.showErrorSnackBar('Update failed: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _applySuggestedGoal(int goal) async {
     setState(() => _isLoading = true);
     try {
       final dio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:8000/api/v1'));
       final user = ref.read(authProvider).value;
       if (user == null) return;

       await dio.put('/users/${user.id}', data: {"daily_goal_ml": goal});
       
       await ref.read(authProvider.notifier).refreshUser();
       ref.invalidate(recommendationsProvider); // Refresh to show "You are using this goal"

       if (mounted) context.showSuccessSnackBar('Daily goal updated to $goal ml');
     } catch (e) {
       if (mounted) context.showErrorSnackBar('Failed to update goal: $e');
     } finally {
       if (mounted) setState(() => _isLoading = false);
     }
  }

  @override
  Widget build(BuildContext context) {
    final recommendationsAsync = ref.watch(recommendationsProvider);
    final user = ref.watch(authProvider).value;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sports & Health'),
        actions: [
          if (user?.subscriptionPlan == 'pro')
            IconButton(
              icon: Icon(_isEditing ? Icons.check : Icons.edit),
              onPressed: () {
                if (_isEditing) {
                  _saveChanges();
                } else {
                  setState(() => _isEditing = true);
                }
              },
            )
        ],
      ),
      body: Stack(
        children: [
          // Main Content (Blurred if not Pro)
          ImageFiltered(
            imageFilter: (user?.subscriptionPlan == 'pro') 
                ? ImageFilter.blur(sigmaX: 0, sigmaY: 0) // No blur if pro
                : ImageFilter.blur(sigmaX: 5, sigmaY: 5), // Blur if not pro
            child: AbsorbPointer(
              absorbing: user?.subscriptionPlan != 'pro', // Disable interaction if not pro
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // BIO DATA CARD
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Your Bio-Data",
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTextField(
                                      label: "Age",
                                      controller: _ageController,
                                      icon: Icons.cake,
                                      enabled: _isEditing,
                                      isNumber: true
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildDropdown(
                                      items: ["male", "female", "other"],
                                      value: _selectedGender,
                                      label: "Gender",
                                      enabled: _isEditing,
                                      icon: Icons.person,
                                      onChanged: (val) => setState(() => _selectedGender = val),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTextField(
                                      label: "Weight (kg)",
                                      controller: _weightController,
                                      icon: Icons.monitor_weight,
                                      enabled: _isEditing,
                                      isNumber: true
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildTextField(
                                      label: "Height (cm)",
                                      controller: _heightController,
                                      icon: Icons.height,
                                      enabled: _isEditing,
                                      isNumber: true
                                    ),
                                  ),
                                ],
                              ),
                               const SizedBox(height: 16),
                              _buildDropdown(
                                items: ["low", "medium", "high"],
                                value: _selectedActivity,
                                label: "Activity Level",
                                enabled: _isEditing,
                                icon: Icons.fitness_center,
                                onChanged: (val) => setState(() => _selectedActivity = val),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
          
                    const SizedBox(height: 24),
          
                    // RECOMMENDATIONS SECTION
                    Text(
                      "Recommended for You",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    
                    recommendationsAsync.when(
                      data: (data) {
                        final bmi = data['bmi'];
                        final status = data['bmi_status'];
                        final recsList = data['recommendations'] as List?;
                        final recs = recsList?.cast<String>() ?? <String>[];
                        final suggestedGoal = data['suggested_goal_ml'] as int?;
          
                        return Column(
                          children: [
                            // BMI Summary
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isDark 
                                    ? [Colors.blueGrey.shade900, Colors.blueGrey.shade800]
                                    : [Colors.blue.shade50, Colors.white],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.blue.withOpacity(0.3))
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    children: [
                                      const Text("BMI", style: TextStyle(fontWeight: FontWeight.bold)),
                                      Text(bmi?.toString() ?? "--", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.blue)),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      const Text("Status", style: TextStyle(fontWeight: FontWeight.bold)),
                                      Text(status ?? "--", style: TextStyle(fontSize: 18, color: _getStatusColor(status))),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Suggested Goal Card
                            if (suggestedGoal != null)
                              Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                   color: isDark ? Colors.blue.withOpacity(0.1) : Colors.blue.shade50,
                                   borderRadius: BorderRadius.circular(16),
                                   border: Border.all(color: Colors.blueAccent.withOpacity(0.5))
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.water_drop, color: Colors.blue),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            "Recommended Goal: $suggestedGoal ml",
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      "Based on your weight and activity level, we recommend this daily intake.",
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                    const SizedBox(height: 12),
                                    if (user != null && user.dailyGoalMl != suggestedGoal)
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          onPressed: () => _applySuggestedGoal(suggestedGoal),
                                          icon: const Icon(Icons.check),
                                          label: const Text("Apply Recommendation"),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blueAccent,
                                            foregroundColor: Colors.white,
                                          ),
                                        ),
                                      )
                                    else 
                                      const Row(
                                        children: [
                                          Icon(Icons.check_circle, color: Colors.green, size: 20),
                                          SizedBox(width: 8),
                                          Text("You are using this goal!", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))
                                        ],
                                      )
                                  ],
                                ),
                              ),
                            // List of Tips
          
                            ...recs.map((rec) =>
                              Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                child: ListTile(
                                  leading: const CircleAvatar(
                                    backgroundColor: Colors.blueAccent,
                                    child: Icon(Icons.tips_and_updates, color: Colors.white, size: 20),
                                  ),
                                  title: Text(rec),
                                ),
                              )
                            ).toList(),
                            
                            const SizedBox(height: 24),
                            _buildCalculatorSection(context, isDark),
                          ],
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, stack) => const Center(child: Text('Could not load recommendations.')),
                    )
                  ],
                ),
              ),
            ),
          ),

          // Lock Overlay (Only if not Pro)
          if (user?.subscriptionPlan != 'pro')
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    color: Colors.black.withOpacity(0.4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.lock_outline, size: 64, color: Colors.white),
                        const SizedBox(height: 16),
                        const Text(
                          "Pro Feature",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Get WaterPulse Pro to access personalized sports & health recommendations!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                        // You could add a button here to navigate to purchase screen
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool enabled = true,
    bool isNumber = false,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: !enabled,
        fillColor: enabled ? null : Colors.grey.withOpacity(0.1),
      ),
      validator: (val) {
        if (isNumber && val != null && val.isNotEmpty && double.tryParse(val) == null) {
          return 'Inv.';
        }
        return null;
      },
    );
  }

  Widget _buildDropdown({
    required List<String> items,
    required String? value,
    required String label,
    required IconData icon,
    required Function(String?) onChanged,
    bool enabled = true,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: enabled ? onChanged : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: !enabled,
        fillColor: enabled ? null : Colors.grey.withOpacity(0.1),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    if (status == 'Normal') return Colors.green;
    if (status == 'Zayıf' || status == 'Fazla Kilolu') return Colors.orange;
    if (status == 'Obez') return Colors.red;
    return Colors.grey;
  }

  Widget _buildCalculatorSection(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Exercise Water Calculator",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          DropdownButtonFormField<String>(
            value: _calcActivity,
            decoration: const InputDecoration(
              labelText: "Activity",
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: ['Cycling', 'Running', 'Walking', 'Swimming', 'Gym', 'Yoga']
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (val) {
              if (val != null) setState(() => _calcActivity = val);
            },
          ),
          const SizedBox(height: 16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Duration: ${_calcDuration.round()} min"),
              Expanded(
                child: Slider(
                  value: _calcDuration,
                  min: 15,
                  max: 180,
                  divisions: (180-15) ~/ 15,
                  label: "${_calcDuration.round()} min",
                  onChanged: (val) => setState(() => _calcDuration = val),
                 ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _calculateWaterLoss,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Calculate Water Loss"),
            ),
          ),
          
          if (_calcWaterLoss != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.water_drop, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Water Loss: $_calcWaterLoss ml",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        const Text("Drink this extra amount."),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
