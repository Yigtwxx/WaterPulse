import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waterpulse/features/auth/providers/auth_provider.dart';
import 'package:waterpulse/features/social/providers/friends_provider.dart';
import 'package:waterpulse/l10n/generated/app_localizations.dart';

class FriendsScreen extends ConsumerWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(friendsProvider);
    final loading = state.isLoading;
    final leaderboard = state.leaderboard;
    final user = ref.watch(authProvider).value;

    final inviteCode = user?.friendCode ?? 'Loading...';
    final TextEditingController controller = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.friendsLeaderboard)),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: Theme.of(context).brightness == Brightness.dark
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
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // COMPACT TOP SECTION
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Row 1: Your Code
                  Row(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.yourCode,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFE5EDFF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                inviteCode,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1D4ED8),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Clipboard.setData(
                                      ClipboardData(text: inviteCode));
                                  ScaffoldMessenger.of(context)
                                    ..hideCurrentSnackBar()
                                    ..showSnackBar(
                                      SnackBar(
                                          content: Text(AppLocalizations.of(context)!.codeCopied)),
                                    );
                                },
                                child: const Icon(Icons.copy,
                                    size: 16, color: Color(0xFF1D4ED8)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Row 2: Add Friend Input
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: TextField(
                            controller: controller,
                            style: const TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(context)!.pasteFriendCode,
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              suffixIcon: IconButton(
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.paste, size: 18),
                                onPressed: () async {
                                  final data =
                                      await Clipboard.getData('text/plain');
                                  if (data?.text != null) {
                                    controller.text = data!.text!;
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 40,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          onPressed: () async {
                            if (controller.text.isEmpty) return;
                            if (user == null) return;

                            try {
                              await ref.read(friendsProvider.notifier).addFriend(user.id, controller.text.trim());
                              if (context.mounted) {
                                ScaffoldMessenger.of(context)
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(
                                    SnackBar(
                                      content: Text('Friend added successfully!'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                controller.clear();
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context)
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(
                                    SnackBar(
                                      content: Text(e.toString().replaceAll('Exception: ', '')),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                              }
                            }
                          },
                          child: Text(AppLocalizations.of(context)!.add,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // FRIENDS LIST HEADER
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                AppLocalizations.of(context)!.friends,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: 10),

            // EXPANDED LIST AREA
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : leaderboard.isEmpty
                      ? Center(
                          child: Text(
                            AppLocalizations.of(context)!.noFriends,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () => ref
                              .read(friendsProvider.notifier)
                              .loadLeaderboard(),
                          child: ListView.separated(
                            itemCount: leaderboard.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final friend = leaderboard[index];
                              final id = friend['id']; // Make sure ID is available from API
                              final name = friend['username'] ?? 'Unknown';
                              final goal = friend['daily_goal_ml'] ?? 2000;
                              final current = friend['today_total_ml'] ?? 0;
                              final streak = friend['mutual_streak_days'] ?? 0;
                              final percent = (current / goal).clamp(0.0, 1.0);

                              return Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardTheme.color,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.02),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    // Avatar
                                    CircleAvatar(
                                      backgroundColor: Colors.blue.shade50,
                                      child: Text(
                                        name[0].toUpperCase(),
                                        style: TextStyle(
                                            color: Colors.blue.shade700,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    
                                    // Info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                name,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 15),
                                              ),
                                              if (streak > 0) ...[
                                                const SizedBox(width: 6),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: Colors.orange.shade50,
                                                    borderRadius: BorderRadius.circular(8),
                                                    border: Border.all(color: Colors.orange.shade200),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      const Text('🔥', style: TextStyle(fontSize: 12)),
                                                      const SizedBox(width: 2),
                                                      Text(
                                                        '$streak',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.orange.shade700,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            child: LinearProgressIndicator(
                                              value: percent,
                                              backgroundColor:
                                                  Colors.grey.shade100,
                                              color: Colors.blueAccent,
                                              minHeight: 6,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    
                                    const SizedBox(width: 12),
                                    
                                    // Actions
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '${(percent * 100).toInt()}%',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blueAccent,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        GestureDetector(
                                          onTap: () async {
                                           if (user == null) return;
                                            try {
                                              await ref.read(friendsProvider.notifier).pokeFriend(user.id, id);
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('👉 Poked $name!'),
                                                    duration: const Duration(seconds: 2),
                                                    backgroundColor: Colors.purpleAccent,
                                                  ),
                                                );
                                              }
                                            } catch (e) {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Failed to poke')),
                                                );
                                              }
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.purple.shade50,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Text('👈', style: TextStyle(fontSize: 12)),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Poke',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.purple.shade700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
