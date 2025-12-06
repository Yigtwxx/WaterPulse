import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waterpulse/features/auth/providers/auth_provider.dart';
import 'package:waterpulse/features/settings/providers/theme_provider.dart';
import 'package:waterpulse/features/settings/providers/language_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authProvider);
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(languageProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          if (userAsync.value != null) ...[
            UserAccountsDrawerHeader(
              accountName: Text(userAsync.value!.name ?? 'User'),
              accountEmail: Text(userAsync.value!.email),
              currentAccountPicture: CircleAvatar(
                child: Text(
                  (userAsync.value!.name ?? 'U')[0].toUpperCase(),
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
          ],
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: const Text('Theme'),
            trailing: DropdownButton<ThemeMode>(
              value: themeMode,
              onChanged: (ThemeMode? newMode) {
                if (newMode != null) {
                  ref.read(themeProvider.notifier).setTheme(newMode);
                }
              },
              items: const [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text('System'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text('Light'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text('Dark'),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            trailing: DropdownButton<Locale>(
              value: locale,
              onChanged: (Locale? newLocale) {
                if (newLocale != null) {
                  ref.read(languageProvider.notifier).setLocale(newLocale);
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
          ),
          const Divider(),
          _buildQuickAddSection(context, ref, userAsync.value),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await ref.read(authProvider.notifier).logout();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAddSection(BuildContext context, WidgetRef ref, dynamic user) {
    if (user == null) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Quick Add Buttons',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.water_drop_outlined),
          title: const Text('Button 1 Amount'),
          trailing: Text('${user.quickAdd1Ml} ml'),
          onTap: () => _editQuickAdd(context, ref, user, 1),
        ),
        ListTile(
          leading: const Icon(Icons.water_drop),
          title: const Text('Button 2 Amount'),
          trailing: Text('${user.quickAdd2Ml} ml'),
          onTap: () => _editQuickAdd(context, ref, user, 2),
        ),
      ],
    );
  }

  Future<void> _editQuickAdd(
      BuildContext context, WidgetRef ref, dynamic user, int buttonIndex) async {
    final currentVal = buttonIndex == 1 ? user.quickAdd1Ml : user.quickAdd2Ml;
    final controller = TextEditingController(text: currentVal.toString());

    final newValue = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Button $buttonIndex Amount'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(suffixText: 'ml'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final val = int.tryParse(controller.text);
              if (val != null && val > 0) {
                Navigator.pop(context, val);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newValue != null && newValue != currentVal) {
      final updates = <String, dynamic>{};
      if (buttonIndex == 1) {
        updates['quick_add_1_ml'] = newValue;
      } else {
        updates['quick_add_2_ml'] = newValue;
      }
      
      await ref.read(authProvider.notifier).updateUser(user.id, updates);
    }
  }
  }
}
