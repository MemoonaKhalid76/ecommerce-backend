import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/constants.dart';

class AuthProvider with ChangeNotifier {
  static const String baseUrl = '${AppConstants.baseUrl}/auth';
  final _storage = const FlutterSecureStorage();

  String? _token;
  Map<String, dynamic>? _user;
  bool _isLoading = false;
  bool _isInitialized = false;

  // ================= GETTERS =================
  bool get isLoggedIn => _token != null;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get token => _token;
  Map<String, dynamic>? get user => _user;

  // 🔐 Auth headers for protected APIs
  Map<String, String> get authHeaders {
    return {
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
  }

  // ================= LOAD AUTH =================
  Future<void> loadAuth() async {
    final prefs = await SharedPreferences.getInstance();
    _token = await _storage.read(key: 'userToken');

    final userData = prefs.getString('userData');
    if (userData != null) {
      _user = jsonDecode(userData);
    }

    _isInitialized = true;
    notifyListeners();
  }

  // ================= REQUEST OTP =================
  Future<String> requestOtp({String? phone, String? email}) async {
    _isLoading = true;
    notifyListeners();

    final res = await http.post(
      Uri.parse('$baseUrl/request-otp'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone, 'email': email}),
    );

    _isLoading = false;
    notifyListeners();

    final data = jsonDecode(res.body);

    if (res.statusCode != 200) {
      throw Exception(data['message'] ?? 'Failed to request OTP');
    }
    
    return data['message'] ?? 'OTP sent!';
  }

  // ================= VERIFY OTP =================
  Future<void> verifyOtp({
    String? phone,
    String? email,
    required String otp,
  }) async {
    _isLoading = true;
    notifyListeners();

    final res = await http.post(
      Uri.parse('$baseUrl/verify-otp'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone, 'email': email, 'otp': otp}),
    );

    final data = jsonDecode(res.body);

    _isLoading = false;
    notifyListeners();

    if (res.statusCode != 200) {
      throw Exception(data['message'] ?? 'OTP verification failed');
    }

    _token = data['token'];
    _user = data['user'];

    final prefs = await SharedPreferences.getInstance();
    await _storage.write(key: 'userToken', value: _token);
    await prefs.setString('userData', jsonEncode(_user));

    notifyListeners();
  }

  // ================= LOGOUT =================
  Future<void> logout() async {
    _token = null;
    _user = null;

    final prefs = await SharedPreferences.getInstance();
    await _storage.delete(key: 'userToken');
    await prefs.remove('userData');

    notifyListeners();
  }
}
