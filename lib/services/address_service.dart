import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/address_model.dart';
import '../utils/constants.dart';

class AddressService {
  static const baseUrl = AppConstants.baseUrl;

  static Future<List<Address>> fetchAddresses(String token) async {
    final res = await http.get(
      Uri.parse('$baseUrl/addresses'),
      headers: {'Authorization': 'Bearer $token'},
    );

    final List data = jsonDecode(res.body);
    return data.map((e) => Address.fromJson(e)).toList();
  }

  static Future<void> addAddress(
    String token,
    Map<String, dynamic> body,
  ) async {
    await http.post(
      Uri.parse('$baseUrl/addresses'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
  }
}
