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

  @override
  void initState() {
    super.initState();
    _dailyGoal = widget.initialGoal;
    _savedDailyGoal = widget.initialGoal;
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
        benefits = ["Ad-free Experience", "Advanced Statistics", "Custom Drink Types", "Priority Support"];
        break;
      case "pro":
        title = "Pro Plan";
        price = "\$2.99/mo";
        benefits = ["All Plus Features", "AI Hydration Insights", "Wearable Integration", "Team Challenges"];
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
    return _dailyGoal != _savedDailyGoal;
  }

  Future<void> _saveChanges() async {
    final user = ref.read(authProvider).value;
    if (user == null) return;

    try {
      await _apiClient.updateUser(user.id, {'daily_goal_ml': _dailyGoal});
      // Refresh user data
      ref.refresh(authProvider);
      
      if (mounted) {
        setState(() {
          _savedDailyGoal = _dailyGoal; // Update baseline
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
                      const Color(0xFF0F172A), // Slate 900
                      const Color(0xFF1E293B), // Slate 800
                    ]
                  : [
                      const Color(0xFFEFF6FF), // Blue 50
                      const Color(0xFFFFFFFF), // White
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
                          await ref.read(authProvider.notifier).logout();
                          if (mounted) Navigator.pop(context);
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
                          value: _dailyGoal.toDouble(),
                          min: 1200,
                          max: 4000,
                          divisions: (4000 - 1200) ~/ 200,
                          label: '$_dailyGoal ml',
                          onChanged: (value) {
                            setState(() => _dailyGoal = value.round());
                          },
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          ref.watch(themeProvider) == ThemeMode.dark
                              ? AppLocalizations.of(context)!.darkMode
                              : AppLocalizations.of(context)!.lightMode,
                          style: theme.textTheme.bodyMedium,
                        ),
                        Switch(
                          value: ref.watch(themeProvider) == ThemeMode.dark,
                          activeColor: const Color(0xFF2563EB),
                          onChanged: (value) {
                            ref.read(themeProvider.notifier).toggleTheme();
                          },
                        ),
                      ],
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
                          ref.watch(languageProvider).languageCode == 'tr'
                              ? 'Türkçe'
                              : 'English',
                          style: theme.textTheme.bodyMedium,
                        ),
                        DropdownButton<Locale>(
                          value: ref.watch(languageProvider),
                          onChanged: (Locale? newLocale) {
                            if (newLocale != null) {
                              ref.read(languageProvider.notifier).setLanguage(newLocale);
                            }
                          },
                          items: const [
                            DropdownMenuItem(
                              value: Locale('en'),
                              child: Text('English'),
                            ),
                            DropdownMenuItem(
                              value: Locale('tr'),
                              child: Text('Türkçe'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: _hasChanges
            ? FloatingActionButton.extended(
                onPressed: _saveChanges,
                icon: const Icon(Icons.save),
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
