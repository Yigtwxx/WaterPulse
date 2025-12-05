import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waterpulse/services/api_client.dart';

class FriendsState {
  final bool isLoading;
  final List<dynamic> leaderboard;

  FriendsState({this.isLoading = false, this.leaderboard = const []});
}

class FriendsNotifier extends StateNotifier<FriendsState> {
  final ApiClient _apiClient;

  FriendsNotifier(this._apiClient) : super(FriendsState()) {
    loadLeaderboard();
  }

  Future<void> loadLeaderboard() async {
    state = FriendsState(isLoading: true, leaderboard: state.leaderboard);
    try {
      final data = await _apiClient.compareWithFriends(
        userId: 1,
        friendIds: [2, 3], // Mock friend IDs
        date: DateTime.now(),
      );
      state = FriendsState(isLoading: false, leaderboard: data);
    } catch (e) {
      state = FriendsState(isLoading: false, leaderboard: state.leaderboard);
    }
  }

  Future<void> addFriend(int userId, String friendCode) async {
    try {
      await _apiClient.addFriend(userId, friendCode);
      // Reload leaderboard or update list
      await loadLeaderboard();
    } catch (e) {
      rethrow;
    }
  }
}

final friendsProvider = StateNotifierProvider<FriendsNotifier, FriendsState>((ref) {
  return FriendsNotifier(ApiClient());
});
