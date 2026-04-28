import 'dart:convert';
import 'package:http/http.dart' as http;

class SignApiService {
  // 🔴 IMPORTANT: replace with your deployed API URL
  static const String baseUrl = "https://umairzafar01-sign-language-api.hf.space";

  static Future<Map<String, dynamic>?> predict(List<double> features) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/predict"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"data": features}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("API Error: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Request failed: $e");
      return null;
    }
  }
}