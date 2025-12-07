import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waterpulse/features/auth/providers/auth_provider.dart';
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
  final int? _userId;

  AchievementsNotifier(this._apiClient, this._userId) : super(AchievementsState()) {
    if (_userId != null) {
      loadData();
    }
  }

  Future<void> loadData() async {
    if (_userId == null) return;
    
    state = AchievementsState(
      isLoading: true,
      achievements: state.achievements,
      currentStreak: state.currentStreak,
    );
    try {
      final achievements = await _apiClient.getAchievements(userId: _userId!);
      final streakData = await _apiClient.getStreakSummary(userId: _userId!);
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
  final userAsync = ref.watch(authProvider);
  final userId = userAsync.value?.id;
  return AchievementsNotifier(ApiClient(), userId);
});
