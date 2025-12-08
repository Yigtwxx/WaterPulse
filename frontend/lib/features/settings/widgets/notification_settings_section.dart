
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waterpulse/features/auth/providers/auth_provider.dart';
import 'package:waterpulse/services/notification_service.dart';

class NotificationSettingsSection extends ConsumerStatefulWidget {
  const NotificationSettingsSection({super.key});

  @override
  ConsumerState<NotificationSettingsSection> createState() => _NotificationSettingsSectionState();
}

class _NotificationSettingsSectionState extends ConsumerState<NotificationSettingsSection> {
  // Local state for sliders before saving
  bool _notificationsEnabled = true;
  double _interval = 105;
  RangeValues _timeRange = const RangeValues(9, 23);
  double _aggressiveness = 1.0; // 0: Gentle, 1: Normal, 2: Aggressive

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).value;
    if (user != null) {
      _notificationsEnabled = user.notificationsEnabled ?? true;
      _interval = (user.notificationInterval ?? 105).toDouble();
      _timeRange = RangeValues(
        (user.notificationStartHour ?? 9).toDouble(),
        (user.notificationEndHour ?? 23).toDouble(),
      );
      
      final agg = user.notificationAggressiveness ?? 'normal';
      if (agg == 'gentle') _aggressiveness = 0.0;
      else if (agg == 'aggressive') _aggressiveness = 2.0;
      else _aggressiveness = 1.0;
    }
  }

  String _getAggressivenessLabel(double value) {
    if (value < 0.5) return 'Gentle 🍃';
    if (value > 1.5) return 'Aggressive ⚡';
    return 'Normal 💧';
  }
  
  String _getAggressivenessValue(double value) {
    if (value < 0.5) return 'gentle';
    if (value > 1.5) return 'aggressive';
    return 'normal';
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).value;
    if (user == null) return const SizedBox.shrink();

    final isPro = user.subscriptionPlan == 'plus' || user.subscriptionPlan == 'pro';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8), // Removed top padding
          child: Text(
            'Smart Notifications',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        SwitchListTile(
          title: const Text('Enable Notifications'),
          value: _notificationsEnabled,
          onChanged: (val) {
            setState(() => _notificationsEnabled = val);
            _saveSettings(); // Auto-save toggle
          },
        ),
        if (_notificationsEnabled) ...[
          // === Interval ===
          ListTile(
            title: const Text('Reminder Interval'),
            subtitle: Text('${_interval.toInt()} minutes'),
            trailing: !isPro
                ? ElevatedButton(
                    onPressed: () {
                        // Show upgrade dialog ideally
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Upgrade to Plus to customize!'))
                        );
                    }, // Upgrade flow
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                    child: const Text('UPGRADE'),
                  )
                : null,
          ),
          if (isPro)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Slider(
                value: _interval,
                min: 30,
                max: 240,
                divisions: 21,
                label: '${_interval.toInt()} min',
                onChanged: (val) {
                    setState(() => _interval = val);
                },
                onChangeEnd: (_) => _saveSettings(),
              ),
            ),
            
          // === Active Hours ===
          ListTile(
            title: const Text('Active Hours'),
            subtitle: Text(
                '${_timeRange.start.toInt()}:00 - ${_timeRange.end.toInt()}:00'),
          ),
          if (isPro)
             Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: RangeSlider(
                values: _timeRange,
                min: 0,
                max: 24,
                divisions: 24,
                labels: RangeLabels(
                  '${_timeRange.start.toInt()}:00',
                  '${_timeRange.end.toInt()}:00',
                ),
                onChanged: (val) {
                    if (val.end - val.start >= 1) {
                        setState(() => _timeRange = val);
                    }
                },
                onChangeEnd: (_) => _saveSettings(),
              ),
            )
          else 
             Padding(
               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
               child: Text(
                 'Upgrade to customize active hours (Default 09:00 - 23:00)',
                 style: TextStyle(fontSize: 12, color: Colors.grey[600]),
               ),
             ),
             
          // === Aggressiveness ===
          ListTile(
            title: const Text('Aggressiveness'),
            subtitle: Text(_getAggressivenessLabel(_aggressiveness)),
          ),
          if (isPro)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Slider(
                value: _aggressiveness,
                min: 0,
                max: 2,
                divisions: 2,
                label: _getAggressivenessLabel(_aggressiveness),
                onChanged: (val) {
                    setState(() => _aggressiveness = val);
                },
                onChangeEnd: (_) => _saveSettings(),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Upgrade to customize aggressiveness (Default: Normal)',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ),
        ],
      ],
    );
  }

  Future<void> _saveSettings() async {
    final user = ref.read(authProvider).value;
    if (user == null) return;

    final updates = {
      'notifications_enabled': _notificationsEnabled,
      'notification_interval': _interval.toInt(),
      'notification_start_hour': _timeRange.start.toInt(),
      'notification_end_hour': _timeRange.end.toInt(),
      'notification_aggressiveness': _getAggressivenessValue(_aggressiveness),
    };

    // Save to backend
    await ref.read(authProvider.notifier).updateUser(user.id, updates);
    
    // Reschedule
    if (_notificationsEnabled) {
        await NotificationService().scheduleReminders(
            intervalMinutes: _interval.toInt(),
            startHour: _timeRange.start.toInt(),
            endHour: _timeRange.end.toInt(),
            // aggressiveness: _getAggressivenessValue(_aggressiveness), // Pass if needed logic
        );
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Notifications updated'), duration: Duration(seconds: 1)),
        );
    } else {
        await NotificationService().cancelAll();
    }
  }
}
