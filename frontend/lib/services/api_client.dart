// frontend/lib/services/api_client.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  // Backend development adresi
  static const String baseUrl = 'http://localhost:8000/api/v1';
  // Eğer Android emülatörde test ediyorsan:
  // static const String baseUrl = 'http://10.0.2.2:8000/api/v1';

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

  // Belirtilen miktarda su ekle (ör: 250 ml, 500 ml)
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
}
