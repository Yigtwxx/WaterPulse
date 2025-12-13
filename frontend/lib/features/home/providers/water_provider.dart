import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waterpulse/services/api_client.dart';

class WaterState {
  final int todayTotal;
  final bool isLoading;
  final String? error;

  WaterState({
    this.todayTotal = 0,
    this.isLoading = false,
    this.error,
  });

  WaterState copyWith({
    int? todayTotal,
    bool? isLoading,
    String? error,
  }) {
    return WaterState(
      todayTotal: todayTotal ?? this.todayTotal,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class WaterNotifier extends StateNotifier<WaterState> {
  final ApiClient _apiClient;

  WaterNotifier(this._apiClient) : super(WaterState());

  Future<void> loadTodayTotal(int userId, {DateTime? date}) async {
    state = state.copyWith(isLoading: true);
    try {
      final total = await _apiClient.getDailyTotal(userId: userId, date: date);
      state = state.copyWith(todayTotal: total, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addWater(int userId, int amount) async {
    try {
      // Optimistic update
      state = state.copyWith(todayTotal: state.todayTotal + amount);
      await _apiClient.addWater(userId: userId, amountMl: amount);
    } catch (e) {
      // Revert on failure
      // state = state.copyWith(todayTotal: state.todayTotal - amount, error: e.toString());
      print('Add water failed but keeping optimistic update: $e');
    }
  }
}

final apiClientProvider = Provider((ref) => ApiClient());

final waterProvider = StateNotifierProvider<WaterNotifier, WaterState>((ref) {
  return WaterNotifier(ref.watch(apiClientProvider));
});
