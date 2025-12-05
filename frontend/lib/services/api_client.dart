// frontend/lib/services/api_client.dart
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  // Override with `--dart-define=API_BASE_URL=http://192.168.1.5:8000/api/v1`
  static String get baseUrl => _resolveBaseUrl();

  static String _resolveBaseUrl() {
    const override = String.fromEnvironment('API_BASE_URL');
    if (override.isNotEmpty) return override;

    // Use IPv4 loopback explicitly to avoid localhost/IPv6 resolution issues.
    const localBase = 'http://127.0.0.1:8000/api/v1';

    if (kIsWeb) return localBase;

    // Android emülatörde localhost için 10.0.2.2 kullanılır
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000/api/v1';
    }

    // Masaüstü/iOS için direkt localhost yeterli
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux) {
      return localBase;
    }

    // Fallback
    return localBase;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final uri = Uri.parse('$baseUrl/users/login');
    final body = jsonEncode({
      'email': email,
      'password': password,
    });

    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    } else {
      throw Exception('Login failed');
    }
  }

  Future<Map<String, dynamic>> createUser(Map<String, dynamic> userData) async {
    final uri = Uri.parse('$baseUrl/users/');
    final body = jsonEncode(userData);

    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    } else {
      final body = jsonDecode(res.body);
      if (body is Map && body.containsKey('detail')) {
        throw Exception(body['detail']);
      }
      throw Exception('Failed to create user: ${res.body}');
    }
  }

  // Bugünkü toplam su miktarını getir
  Future<int> getTodayTotal({int userId = 1}) async {
    final uri = Uri.parse('$baseUrl/water/daily-total/$userId');
    final res = await http.get(uri);

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['total_ml'] as int;
    } else {
      throw Exception('Failed to load daily total');
    }
  }
  Future<void> addWater({int userId = 1, required int amountMl}) async {
    final uri = Uri.parse('$baseUrl/water/log');
    final body = jsonEncode({
      'user_id': userId,
      'amount_ml': amountMl,
    });

    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to add water');
    }
  }

  Future<List<dynamic>> getCalendarTotals({
    required int userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final start = startDate.toIso8601String().split('T').first;
    final end = endDate.toIso8601String().split('T').first;
    final uri = Uri.parse(
      '$baseUrl/water/calendar/$userId?start_date=$start&end_date=$end',
    );
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    throw Exception('Failed to load calendar totals');
  }

  Future<Map<String, dynamic>> getStreakSummary({int userId = 1}) async {
    final uri = Uri.parse('$baseUrl/streaks/$userId/summary');
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to load streak summary');
  }

  Future<List<dynamic>> getAchievements({int userId = 1}) async {
    final uri = Uri.parse('$baseUrl/achievements/$userId');
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    throw Exception('Failed to load achievements');
  }

  Future<List<dynamic>> getAvatarSkins({int userId = 1}) async {
    final uri = Uri.parse('$baseUrl/avatar/skins/$userId');
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    throw Exception('Failed to load avatar skins');
  }

  Future<List<dynamic>> compareWithFriends({
    required int userId,
    required List<int> friendIds,
    required DateTime date,
  }) async {
    final uri = Uri.parse('$baseUrl/friends/compare');
    final body = jsonEncode({
      'user_id': userId,
      'friend_ids': friendIds,
      'date': date.toIso8601String().split('T').first,
    });

    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    throw Exception('Failed to compare friends');
  }

  Future<Map<String, dynamic>> updateUser(int userId, Map<String, dynamic> data) async {
    final uri = Uri.parse('$baseUrl/users/$userId');
    final body = jsonEncode(data);

    final res = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to update user');
    }
  }

  Future<Map<String, dynamic>> getUser(int userId) async {
    final uri = Uri.parse('$baseUrl/users/$userId');
    final res = await http.get(uri);

    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load user');
    }
  }
  Future<void> sendVerificationCode(int userId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/send-verification-code?user_id=$userId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to send verification code: ${response.body}');
    }
  }

  Future<void> verifyEmail(int userId, String code) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/verify-email?user_id=$userId&code=$code'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to verify email: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> addFriend(int userId, String friendCode) async {
    final uri = Uri.parse('$baseUrl/friends/add');
    final body = jsonEncode({
      'user_id': userId,
      'friend_code': friendCode,
    });

    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    } else {
      final body = jsonDecode(res.body);
      if (body is Map && body.containsKey('detail')) {
        throw Exception(body['detail']);
      }
      throw Exception('Failed to add friend');
    }
  }
}
