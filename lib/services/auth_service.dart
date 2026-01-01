import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class AuthService {
  static const String baseUrl = '${AppConstants.baseUrl}/auth';

  // 🔹 REQUEST OTP
  static Future<void> requestOtp({String? phone, String? email}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/request-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone, 'email': email}),
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Failed to send OTP');
    }
  }

  // 🔹 VERIFY OTP
  static Future<Map<String, dynamic>> verifyOtp({
    String? phone,
    String? email,
    required String otp,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone, 'email': email, 'otp': otp}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'OTP verification failed');
    }

    return data;
  }
}
