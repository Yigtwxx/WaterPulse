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

  Future<void> loadLeaderboard([int? userId]) async {
    state = FriendsState(isLoading: true, leaderboard: state.leaderboard);
    try {
      final uid = userId ?? 1; // Default to 1 if not provided, or better get from Auth
      final data = await _apiClient.getFriends(uid);
      state = FriendsState(isLoading: false, leaderboard: data);
    } catch (e) {
      state = FriendsState(isLoading: false, leaderboard: state.leaderboard);
    }
  }

  Future<void> addFriend(int userId, String friendCode) async {
    try {
      await _apiClient.addFriend(userId, friendCode);
      // Reload leaderboard or update list
      await loadLeaderboard(userId);
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> pokeFriend(int senderId, int receiverId) async {
    try {
      await _apiClient.pokeFriend(senderId, receiverId);
    } catch (e) {
      rethrow;
    }
  }
}

final friendsProvider = StateNotifierProvider<FriendsNotifier, FriendsState>((ref) {
  return FriendsNotifier(ApiClient());
});
