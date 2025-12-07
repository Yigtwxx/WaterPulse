// frontend/lib/ui/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waterpulse/config/app_theme.dart';
import 'package:waterpulse/features/auth/providers/auth_provider.dart';
import 'package:waterpulse/features/settings/providers/language_provider.dart';
import 'package:waterpulse/features/settings/providers/theme_provider.dart';
import 'package:waterpulse/l10n/generated/app_localizations.dart';
import 'package:waterpulse/services/api_client.dart';
import 'package:waterpulse/ui/screens/payment_screen.dart';
import 'package:waterpulse/features/settings/providers/water_color_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key, required this.initialGoal});

  final int initialGoal;

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final ApiClient _apiClient = ApiClient();
  late int _dailyGoal;
  late int _savedDailyGoal; // Track the saved state
  bool _notificationsEnabled = true;

  // Local state for settings
  late String _selectedTheme;
  late Locale _selectedLocale;
  late Color _selectedWaterColor;
  late int _quickAdd1;
  late int _quickAdd2;

  @override
  void initState() {
    super.initState();
    _dailyGoal = widget.initialGoal;
    _savedDailyGoal = widget.initialGoal;
    
    // Initialize local state from providers
    _selectedTheme = ref.read(themeProvider);
    _selectedLocale = ref.read(languageProvider);
    _selectedWaterColor = ref.read(waterColorProvider); // .value not needed for StateNotifier? Provider returns state.
    
    final user = ref.read(authProvider).value;
    _quickAdd1 = user?.quickAdd1Ml ?? 250;
    _quickAdd2 = user?.quickAdd2Ml ?? 500;
  }

  Future<void> _updateSubscription(String plan) async {
    final user = ref.read(authProvider).value;
    if (user == null) return;

    try {
      await _apiClient.updateUser(user.id, {'subscription_plan': plan});
      // Refresh user data
      ref.refresh(authProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update subscription: $e')),
        );
      }
    }
  }

  Future<void> _showVerificationDialog() async {
    final user = ref.read(authProvider).value;
    if (user == null) return;

    final TextEditingController codeController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Verify Email', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Please enter the 6-digit code sent to your email."),
            const SizedBox(height: 16),
            TextField(
              controller: codeController,
              decoration: InputDecoration(
                labelText: "Verification Code",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: TextInputType.number,
              maxLength: 6,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              try {
                await _apiClient.sendVerificationCode(user.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Verification code sent!')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to send code: $e')),
                  );
                }
              }
            },
            child: const Text('Send Code'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final code = codeController.text.trim();
              if (code.length != 6) return;

              try {
                await _apiClient.verifyEmail(user.id, code);
                if (mounted) {
                  Navigator.pop(context);
                  ref.refresh(authProvider);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Email verified successfully!')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Verification failed: $e')),
                  );
                }
              }
            },
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }

  void _showSubscriptionDetails(String plan, Color planColor) {
    String title = "";
    String price = "";
    List<String> benefits = [];

    switch (plan) {
      case "basic":
        title = "Basic Plan";
        price = "Free";
        benefits = ["Standard Hydration Tracking", "Daily Goals", "Basic Stats"];
        break;
      case "plus":
        title = "Plus Plan";
        price = "\$1.99/mo";
        benefits = [
          "All Basic Features",
          "Daha az reklam",
          "Akıllı bildirimler",
          "Bazı temalara erişim",
          "Bazı damlacık renklerin erişim",
          "Özel renkli isim",
        ];
        break;
      case "pro":
        title = "Pro Plan";
        price = "\$2.99/mo";
        benefits = [
          "Reklamsız kullanım",
          "All Plus Features",
          "Özel değerlendirme",
          "Spor kısmına tam erişim",
          "Özel renkli isim",
          "Özel damlacık renklerine tam erişim",
          "Özel damlacık renklerine tam erişim"
          ];
        break;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: planColor)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(price, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: planColor)),
            const SizedBox(height: 16),
            ...benefits.map((b) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: planColor, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(b, style: TextStyle(color: planColor))),
                ],
              ),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: planColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PaymentScreen(
                    plan: plan,
                    price: price,
                    planColor: planColor,
                  ),
                ),
              );
            },
            child: const Text("Select Plan"),
          ),
        ],
      ),
    );
  }

  bool get _hasChanges {
    final user = ref.read(authProvider).value;
    if (user == null) return false;

    if (_dailyGoal != _savedDailyGoal) return true;
    if (_selectedTheme != ref.read(themeProvider)) return true;
    if (_selectedLocale != ref.read(languageProvider)) return true;
    if (_selectedWaterColor != ref.read(waterColorProvider)) return true;
    if (_quickAdd1 != (user.quickAdd1Ml)) return true;
    if (_quickAdd2 != (user.quickAdd2Ml)) return true;
    
    return false;
  }

  Future<void> _saveChanges() async {
    final user = ref.read(authProvider).value;
    if (user == null) return;

    try {
      // 1. Update User Data (Backend)
      final updates = <String, dynamic>{
        'daily_goal_ml': _dailyGoal,
        'quick_add_1_ml': _quickAdd1,
        'quick_add_2_ml': _quickAdd2,
      };
      await ref.read(authProvider.notifier).updateUser(user.id, updates);

      // 2. Update Local Settings (Providers)
      if (_selectedTheme != ref.read(themeProvider)) {
        await ref.read(themeProvider.notifier).setTheme(_selectedTheme);
      }
      if (_selectedLocale != ref.read(languageProvider)) {
        await ref.read(languageProvider.notifier).setLanguage(_selectedLocale);
      }
      if (_selectedWaterColor != ref.read(waterColorProvider)) {
        await ref.read(waterColorProvider.notifier).setColor(_selectedWaterColor);
      }
      
      if (mounted) {
        setState(() {
          _savedDailyGoal = _dailyGoal; // Update baseline
          // Providers are updated, so _hasChanges should now be false on rebuild
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Changes saved successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save changes: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final userAsync = ref.watch(authProvider);
    final user = userAsync.value;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final username = user.name ?? user.email;
    final subscriptionPlan = user.subscriptionPlan;
    final isVerified = user.isVerified;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _dailyGoal);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.profile),
          centerTitle: true,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, _dailyGoal),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [
                      Theme.of(context).scaffoldBackgroundColor,
                      Theme.of(context).cardColor,
                    ]
                  : [
                      Theme.of(context).scaffoldBackgroundColor,
                      Theme.of(context).cardColor,
                    ],

            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ==== ÜST KISIM: AVATAR + İSİM ====
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const _WaterAvatar(),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              username,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    AppLocalizations.of(context)!.keepHydrating(username),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text('💧'),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (!isVerified)
                        IconButton(
                          onPressed: _showVerificationDialog,
                          icon: const Icon(Icons.verified_user_outlined, color: Colors.orange),
                          tooltip: "Verify Email",
                        ),
                        IconButton(
                          onPressed: () async {
                            final shouldLogout = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(AppLocalizations.of(context)!.logout),
                                content: const Text('Are you sure you want to log out?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: Text(AppLocalizations.of(context)!.cancel),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: Text(
                                      AppLocalizations.of(context)!.logout,
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );

                            if (shouldLogout == true) {
                              await ref.read(authProvider.notifier).logout();
                              if (mounted) Navigator.pop(context);
                            }
                          },
                          icon: const Icon(Icons.logout, color: Colors.red),
                          tooltip: AppLocalizations.of(context)!.logout,
                        ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  // ==== SETTINGS BÖLÜMÜ ====
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      AppLocalizations.of(context)!.settings,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ==== SUBSCRIPTION BÖLÜMÜ ====
                  _ProfileCard(
                    title: "Subscription",
                    subtitle: "Choose your plan",
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _SubscriptionOption(
                          label: "Basic",
                          isSelected: subscriptionPlan == "basic",
                          color: Colors.blue,
                          onTap: () => _showSubscriptionDetails("basic", Colors.blue),
                        ),
                        const SizedBox(width: 12),
                        _SubscriptionOption(
                          label: "Plus",
                          isSelected: subscriptionPlan == "plus",
                          color: const Color(0xFFFFD700), // Gold
                          onTap: () => _showSubscriptionDetails("plus", const Color(0xFFFFD700)),
                        ),
                        const SizedBox(width: 12),
                        _SubscriptionOption(
                          label: "Pro",
                          isSelected: subscriptionPlan == "pro",
                          isPro: true,
                          color: Colors.purple, // Purple
                          onTap: () => _showSubscriptionDetails("pro", Colors.purple),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ==== GÜNLÜK HEDEF KARTI ====
                  _ProfileCard(
                    title: AppLocalizations.of(context)!.dailyGoal,
                    subtitle: AppLocalizations.of(context)!.dailyGoalSubtitle,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$_dailyGoal ml',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2563EB),
                          ),
                        ),
                        Slider(
                          value: _dailyGoal.toDouble().clamp(1200, 6000),
                          min: 1200,
                          max: 6000,
                          divisions: (6000 - 1200) ~/ 200,
                          label: '$_dailyGoal ml',
                          onChanged: (value) {
                            setState(() => _dailyGoal = value.round());
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  
                  // ==== QUICK ADD BUTTONS ====
                  _ProfileCard(
                    title: "Quick Add Buttons",
                    subtitle: "Customize your water shortcuts",
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: _quickAdd1.toString(),
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "Button 1 (ml)",
                              suffixText: "ml",
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              final val = int.tryParse(value);
                              if (val != null && val > 0) {
                                setState(() => _quickAdd1 = val);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            initialValue: _quickAdd2.toString(),
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "Button 2 (ml)",
                              suffixText: "ml",
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              final val = int.tryParse(value);
                              if (val != null && val > 0) {
                                setState(() => _quickAdd2 = val);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ==== BİLDİRİM AYARLARI ====
                  _ProfileCard(
                    title: AppLocalizations.of(context)!.reminders,
                    subtitle: AppLocalizations.of(context)!.remindersSubtitle,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _notificationsEnabled
                              ? AppLocalizations.of(context)!.remindersOn
                              : AppLocalizations.of(context)!.remindersOff,
                          style: theme.textTheme.bodyMedium,
                        ),
                        Switch(
                          value: _notificationsEnabled,
                          activeColor: const Color(0xFF2563EB),
                          onChanged: (value) {
                            setState(() => _notificationsEnabled = value);
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ==== TEMA AYARLARI ====
                  _ProfileCard(
                    title: AppLocalizations.of(context)!.theme,
                    subtitle: AppLocalizations.of(context)!.themeSubtitle,
                    child: SizedBox(
                      height: 120, // Increased height for split view
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          {
                            'name': 'Standard',
                            'lightKey': 'light',
                            'darkKey': 'dark',
                            'lightColor': const Color(0xFFBFDBFE), // Blue 200
                            'darkColor': const Color(0xFF0F172A), // Slate 900
                            'freeLight': true,
                            'freeDark': true,
                          },
                          {
                            'name': 'Forest',
                            'lightKey': 'forest_light',
                            'darkKey': 'forest_dark',
                            'lightColor': const Color(0xFFA7F3D0), // Emerald 200
                            'darkColor': const Color(0xFF064E3B), // Emerald 900
                            'freeLight': false,
                            'freeDark': false,
                          },
                          {
                            'name': 'Sunset',
                            'lightKey': 'sunset_light',
                            'darkKey': 'sunset_dark',
                            'lightColor': const Color(0xFFFED7AA), // Orange 200
                            'darkColor': const Color(0xFF7C2D12), // Orange 900
                            'freeLight': false,
                            'freeDark': false,
                          },
                          {
                            'name': 'Pink',
                            'lightKey': 'pink_light',
                            'darkKey': 'pink_dark',
                            'lightColor': const Color(0xFFFBCFE8), // Pink 200
                            'darkColor': const Color(0xFF831843), // Pink 900
                            'freeLight': false,
                            'freeDark': false,
                          },
                          {
                            'name': 'Galactic',
                            'lightKey': 'galactic_light',
                            'darkKey': 'galactic_dark',
                            'lightColor': const Color(0xFFDDD6FE), // Violet 200
                            'darkColor': const Color(0xFF4C1D95), // Violet 900
                            'freeLight': false,
                            'freeDark': false,
                          },
                        ].asMap().entries.map((entry) {
                          final index = entry.key;
                          final group = entry.value;
                          final name = group['name'] as String;
                          final lightKey = group['lightKey'] as String;
                          final darkKey = group['darkKey'] as String;
                          final lightColor = group['lightColor'] as Color;
                          final darkColor = group['darkColor'] as Color;
                          final freeLight = group['freeLight'] as bool;
                          final freeDark = group['freeDark'] as bool;
                          final isPro = subscriptionPlan == 'pro';
                          final isPlus = subscriptionPlan == 'plus';

                          Widget buildHalf({
                            required String key,
                            required Color color,
                            required bool isFree,
                            required bool isTop,
                          }) {
                            // Unlock if free (standard), Pro, or Plus (first 3 themes: index 0, 1, 2)
                            final isUnlocked = isFree || isPro || (isPlus && index < 3);
                            final isSelected = _selectedTheme == key;

                            return Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  if (!isUnlocked) {
                                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Upgrade to Pro to unlock this theme! 🔒'),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                    return;
                                  }
                                  setState(() => _selectedTheme = key);
                                },
                                child: Container(
                                  color: color,
                                  child: Stack(
                                    children: [
                                      if (isSelected)
                                        Center(
                                          child: CircleAvatar(
                                            radius: 8,
                                            backgroundColor: Theme.of(context).primaryColor,
                                            child: const Icon(Icons.check, size: 10, color: Colors.white),
                                          ),
                                        ),
                                      if (!isUnlocked)
                                        Center(
                                          child: Icon(Icons.lock, size: 14, color: isTop ? Colors.grey : Colors.white54),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }

                          return Container(
                            width: 80,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ],
                            ),
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                                  child: SizedBox(
                                    height: 45, // Fixed height for top half
                                    child: Row(
                                      children: [
                                        buildHalf(key: lightKey, color: lightColor, isFree: freeLight, isTop: true),
                                      ],
                                    ),
                                  ),
                                ),
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
                                  child: SizedBox(
                                    height: 45, // Fixed height for bottom half
                                    child: Row(
                                      children: [
                                        buildHalf(key: darkKey, color: darkColor, isFree: freeDark, isTop: false),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 28,
                                  decoration: const BoxDecoration(
                                    border: Border(top: BorderSide(color: Colors.black12)),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    name,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).textTheme.bodySmall?.color,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ==== DİL AYARLARI ====
                  _ProfileCard(
                    title: AppLocalizations.of(context)!.language,
                    subtitle: AppLocalizations.of(context)!.languageSubtitle,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedLocale.languageCode == 'tr'
                              ? 'Türkçe'
                              : 'English',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.withOpacity(0.3)),
                          ),
                          child: DropdownButton<Locale>(
                            value: _selectedLocale,
                            underline: const SizedBox(), // Hide default underline
                            icon: const Icon(Icons.keyboard_arrow_down_rounded),
                            isDense: true,
                            borderRadius: BorderRadius.circular(12),
                            onChanged: (Locale? newLocale) {
                              if (newLocale != null) {
                                setState(() => _selectedLocale = newLocale);
                              }
                            },
                            items: const [
                              DropdownMenuItem(
                                value: Locale('en'),
                                child: Text('English', style: TextStyle(fontWeight: FontWeight.w500)),
                              ),
                              DropdownMenuItem(
                                value: Locale('tr'),
                                child: Text('Türkçe', style: TextStyle(fontWeight: FontWeight.w500)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16), // Added spacing

                  // ==== WATER COLOR AYARLARI ====
                  _ProfileCard(
                    title: AppLocalizations.of(context)!.waterColor,
                    subtitle: AppLocalizations.of(context)!.waterColorSubtitle,
                    child: SizedBox(
                      height: 50,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          const Color(0xFF2285FE), // Default vibrant blue
                          const Color(0xFF00E5FF), // Cyan Accent
                          const Color(0xFF1DE9B6), // Teal Accent
                          const Color(0xFF76FF03), // Light Green Accent
                          const Color(0xFFFFEA00), // Yellow Accent
                          const Color(0xFFFF9100), // Orange Accent
                          const Color(0xFFFF3D00), // Deep Orange Accent
                          const Color(0xFFFF1744), // Red Accent
                          const Color(0xFFF50057), // Pink Accent
                          const Color(0xFFD500F9), // Purple Accent
                          const Color(0xFF651FFF), // Deep Purple Accent
                        ].asMap().entries.map((entry) {
                          final int index = entry.key;
                          final Color color = entry.value;
                          // Unlock if Pro, index 0 (default), or Plus (first 3 colors)
                          final bool isUnlocked = (subscriptionPlan == 'pro') || (index == 0) || (subscriptionPlan == 'plus' && index < 3);

                          return Stack(
                            children: [
                              Opacity(
                                opacity: isUnlocked ? 1.0 : 0.5,
                                child: _ColorOption(
                                  color: color,
                                  isSelected: _selectedWaterColor.value == color.value,
                                  onTap: () {
                                    if (!isUnlocked) {
                                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Upgrade to Pro to unlock custom colors! 🔒'),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                      return;
                                    }
                                    setState(() => _selectedWaterColor = color);
                                  },
                                ),
                              ),
                              if (!isUnlocked)
                                Positioned.fill(
                                  child: IgnorePointer(
                                    child: Center(
                                      child: Icon(Icons.lock, size: 16, color: Colors.white.withOpacity(0.8)),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                ],
              ),
            ),
          ),
        ),
        floatingActionButton: _hasChanges
            ? FloatingActionButton.extended(
                onPressed: _saveChanges,
                label: Text(AppLocalizations.of(context)!.save),
                backgroundColor: const Color(0xFF2563EB),
              )
            : null,
      ),
    );
  }
}

class _WaterAvatar extends StatelessWidget {
  const _WaterAvatar();

  @override
  Widget build(BuildContext context) {
    return const CircleAvatar(
      radius: 36,
      backgroundColor: Color(0xFFE0F2FE),
      child: Text(
        "💧",
        style: TextStyle(fontSize: 32),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _ProfileCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1), // Added border
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
            title,
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _SubscriptionOption extends StatefulWidget {
  final String label;
  final bool isSelected;
  final bool isPro;
  final Color color;
  final VoidCallback onTap;

  const _SubscriptionOption({
    required this.label,
    required this.isSelected,
    this.isPro = false,
    required this.color,
    required this.onTap,
  });

  @override
  State<_SubscriptionOption> createState() => _SubscriptionOptionState();
}

class _SubscriptionOptionState extends State<_SubscriptionOption> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? widget.color.withOpacity(0.1)
                : _isHovered
                    ? widget.color.withOpacity(0.05)
                    : Colors.transparent,
            border: Border.all(
              color: widget.isSelected || _isHovered ? widget.color : Colors.grey.shade300,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: widget.color.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          child: Row(
            children: [
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.color, // Always use the plan color
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (widget.isPro) ...[
                const SizedBox(width: 4),
                Icon(Icons.star, size: 14, color: widget.color), // Icon also matches color
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ColorOption extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorOption({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(color: Theme.of(context).primaryColor, width: 3)
              : Border.all(color: Colors.transparent),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: isSelected
            ? const Icon(Icons.check, color: Colors.white, size: 24)
            : null,
      ),
    );
  }
}
