import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';
import '../utils/constants.dart';

class ApiService {
  static const String baseUrl = AppConstants.baseUrl;

  // =========================
  // 🔹 ALL PRODUCTS (HOME)
  // =========================
  static Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products'));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Product.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  // =========================
  // 🔹 FILTERED PRODUCTS
  // =========================
  static Future<List<Product>> fetchFilteredProducts(
    String category,
    String subCategory,
  ) async {
    // Use Uri constructor to automatically encode query parameters (e.g., '&' in 'Party & Decor')
    final uri = Uri.parse('$baseUrl/products').replace(queryParameters: {
      'category': category,
      'subCategory': subCategory,
    });

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Product.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load filtered products');
    }
  }

  // =========================
  // 🔹 PLACE ORDER (COD)
  // =========================
  // =========================
  // 🔹 PLACE ORDER (COD)
  // =========================
  static Future<void> placeOrder(
    Map<String, dynamic> orderData, {
    String? token,
  }) async {
    final headers = {'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    final response = await http.post(
      Uri.parse('$baseUrl/orders'),
      headers: headers,
      body: jsonEncode(orderData),
    );

    print('ORDER STATUS: ${response.statusCode}');
    print('ORDER BODY: ${response.body}');

    if (response.statusCode != 201) {
      throw Exception('Failed to place order');
    }
  }

  // =========================
  // 🔹 GET MY ORDERS
  // =========================
  static Future<List<dynamic>> fetchMyOrders(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/orders/my'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load orders');
    }
  }
}
