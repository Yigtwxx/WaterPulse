import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:waterpulse/l10n/generated/app_localizations.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({
    required this.navigationShell,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => _onTap(context, index),
        selectedItemColor: _getColorForIndex(navigationShell.currentIndex),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_rounded),
            label: AppLocalizations.of(context)!.navHome,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.group_rounded),
            label: AppLocalizations.of(context)!.friends,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.emoji_events_rounded),
            label: AppLocalizations.of(context)!.achievements,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.bar_chart_rounded),
            label: AppLocalizations.of(context)!.navDatas,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.fitness_center_rounded),
            label: AppLocalizations.of(context)!.navSports,
          ),
        ],
      ),
    );
  }

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  Color _getColorForIndex(int index) {
    switch (index) {
      case 0:
        return Colors.blue;
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.indigo;
      case 4:
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}
