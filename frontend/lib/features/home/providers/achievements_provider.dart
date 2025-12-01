import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waterpulse/services/api_client.dart';

class AchievementsState {
  final bool isLoading;
  final List<dynamic> achievements;
  final int currentStreak;

  AchievementsState({
    this.isLoading = false,
    this.achievements = const [],
    this.currentStreak = 0,
  });
}

class AchievementsNotifier extends StateNotifier<AchievementsState> {
  final ApiClient _apiClient;

  AchievementsNotifier(this._apiClient) : super(AchievementsState()) {
    loadData();
  }

  Future<void> loadData() async {
    state = AchievementsState(
      isLoading: true,
      achievements: state.achievements,
      currentStreak: state.currentStreak,
    );
    try {
      final achievements = await _apiClient.getAchievements(userId: 1);
      final streakData = await _apiClient.getStreakSummary(userId: 1);
      final currentStreak = streakData['current_streak'] ?? 0;
      
      state = AchievementsState(
        isLoading: false,
        achievements: achievements,
        currentStreak: currentStreak,
      );
    } catch (e) {
      state = AchievementsState(
        isLoading: false,
        achievements: state.achievements,
        currentStreak: state.currentStreak,
      );
    }
  }
}

final achievementsProvider = StateNotifierProvider<AchievementsNotifier, AchievementsState>((ref) {
  return AchievementsNotifier(ApiClient());
});
