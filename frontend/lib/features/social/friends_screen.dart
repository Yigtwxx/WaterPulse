import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waterpulse/features/social/providers/friends_provider.dart';

class FriendsScreen extends ConsumerWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(friendsProvider);
    final loading = state.isLoading;
    final leaderboard = state.leaderboard;

    final inviteCode = 'WP-1234-AB'; // demo code
    final TextEditingController controller = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Friends & Leaderboard')),
      body: Container(
        color: const Color(0xfff5f7fb),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // COMPACT TOP SECTION
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
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
                        'Your Code:',
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
                            color: const Color(0xFFE5EDFF),
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
                                      const SnackBar(
                                          content: Text('Code copied')),
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
                              hintText: 'Paste friend code',
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
                          onPressed: () {
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Friend request sent: ${controller.text}'),
                                ),
                              );
                            controller.clear();
                          },
                          child: const Text('Add',
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
                'Friends',
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
                            'No friends added yet.',
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
                              // friend structure depends on API response
                              // Assuming: { "username": "...", "daily_goal_ml": ..., "today_total_ml": ... }
                              final name = friend['username'] ?? 'Unknown';
                              final goal = friend['daily_goal_ml'] ?? 2000;
                              final current = friend['today_total_ml'] ?? 0;
                              final percent = (current / goal).clamp(0.0, 1.0);

                              return Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
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
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15),
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
                                    Text(
                                      '${(percent * 100).toInt()}%',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueAccent,
                                      ),
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
