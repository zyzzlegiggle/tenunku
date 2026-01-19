import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  // For Android Emulator use 10.0.2.2, for iOS use 127.0.0.1 (if physical device, need IP)
  // Since user environment suggests Windows/Chrome, we might need localhost or specific IP.
  // Let's try localhost first for web/windows, but 10.0.2.2 for Android.
  // A common trick is to check the platform.
  // For simplicity now:
  static const String baseUrl = 'http://127.0.0.1:3000';

  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final url = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
