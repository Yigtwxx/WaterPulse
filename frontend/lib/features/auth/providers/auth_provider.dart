import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waterpulse/models/user_model.dart';
import 'package:waterpulse/services/api_client.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  AuthNotifier() : super(const AsyncValue.loading()) {
    _checkAuthStatus();
  }

  final _apiClient = ApiClient();
  static const _prefsKeyUserId = 'auth_user_id';

  Future<void> _checkAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt(_prefsKeyUserId);

      if (userId != null) {
        final userData = await _apiClient.getUser(userId);
        final user = User.fromJson(userData);
        state = AsyncValue.data(user);
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e, st) {
      // If fetching user fails (e.g. no internet, or user deleted), logout
      await logout();
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final userData = await _apiClient.login(email, password);
      final user = User.fromJson(userData);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_prefsKeyUserId, user.id);

      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> register(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      final userData = await _apiClient.createUser(data);
      final user = User.fromJson(userData);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_prefsKeyUserId, user.id);

      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKeyUserId);
    state = const AsyncValue.data(null);
  }

  Future<void> loginAsGuest() async {
    state = const AsyncValue.loading();
    try {
      // Create a random guest user
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final randomId = (1000 + (timestamp % 9000)).toString(); // Simple random suffix
      final email = "guest_$timestamp@waterpulse.app";
      final password = "guest_$timestamp"; // Secure enough for a guest

      final userData = await _apiClient.createUser({
        "email": email,
        "password": password,
        "name": "Guest",
        "surname": "User",
        "daily_goal_ml": 2000,
        "preferred_cup_ml": 250,
        "language": "en",
        "subscription_plan": "basic"
      });

      final user = User.fromJson(userData);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_prefsKeyUserId, user.id);

      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> updateUser(int userId, Map<String, dynamic> updates) async {
    try {
      final updatedData = await _apiClient.updateUser(userId, updates);
      final updatedUser = User.fromJson(updatedData);
      state = AsyncValue.data(updatedUser);
    } catch (e) {
      rethrow;
    }
  }
}
