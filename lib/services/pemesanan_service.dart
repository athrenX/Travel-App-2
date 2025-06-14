import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travelapp/models/pemesanan.dart';
import 'package:travelapp/config.dart'; // Ini sudah benar sekarang

class PemesananService {
  static const String _baseUrl =
      AppConfig.baseUrl; // Menggunakan base URL dari config

  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Pemesanan> createPemesanan(Pemesanan pemesanan) async {
    final url = Uri.parse('$_baseUrl/api/pemesanans');
    try {
      final response = await http.post(
        url,
        headers: await _getHeaders(),
        body: json.encode(pemesanan.toMap()),
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 201) {
        // 201 Created
        if (responseData['status'] == 'success') {
          return Pemesanan.fromMap(responseData['data']);
        } else {
          throw Exception(
            'Failed to create pemesanan: ${responseData['message']}',
          );
        }
      } else if (response.statusCode == 422) {
        // Validation error
        throw Exception('Validation Error: ${responseData['errors']}');
      } else if (response.statusCode == 409) {
        // Conflict
        throw Exception('Conflict: ${responseData['message']}');
      } else {
        throw Exception(
          'Failed to create pemesanan. Status code: ${response.statusCode}, Message: ${responseData['message'] ?? response.body}',
        );
      }
    } catch (e) {
      print('Error in createPemesanan: $e');
      rethrow;
    }
  }

  static Future<List<Pemesanan>> getMyPemesananan() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null || token.isEmpty) {
      throw Exception('Token tidak ditemukan atau belum login.');
    }

    final url = Uri.parse('$_baseUrl/api/my-pemesanans');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("getMyPemesananan status: ${response.statusCode}");
      print("getMyPemesananan body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          final List<dynamic> pemesananList = responseData['data'];
          return pemesananList.map((json) => Pemesanan.fromMap(json)).toList();
        } else {
          throw Exception(
            'Failed to load my pemesanans: ${responseData['message']}',
          );
        }
      } else if (response.statusCode == 403) {
        throw Exception('Akses ditolak (403). Silakan login ulang.');
      } else {
        throw Exception(
          'Failed to load my pemesanans. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error in getMyPemesananan: $e');
      rethrow;
    }
  }

  static Future<Pemesanan> confirmPayment(String pemesananId) async {
    final url = Uri.parse(
      '$_baseUrl/api/pemesanans/$pemesananId/confirm-payment',
    );
    try {
      final response = await http.post(url, headers: await _getHeaders());

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        if (responseData['status'] == 'success') {
          return Pemesanan.fromMap(responseData['data']);
        } else {
          throw Exception(
            'Failed to confirm payment: ${responseData['message']}',
          );
        }
      } else if (response.statusCode == 409) {
        // Conflict (e.g., already paid or expired)
        throw Exception('Conflict: ${responseData['message']}');
      } else if (response.statusCode == 410) {
        // Gone (expired)
        throw Exception('Expired: ${responseData['message']}');
      } else {
        throw Exception(
          'Failed to confirm payment. Status code: ${response.statusCode}, Message: ${responseData['message'] ?? response.body}',
        );
      }
    } catch (e) {
      print('Error in confirmPayment: $e');
      rethrow;
    }
  }

  static Future<Pemesanan> cancelPemesanan(String pemesananId) async {
    final url = Uri.parse('$_baseUrl/api/pemesanans/$pemesananId/cancel');
    try {
      final response = await http.post(url, headers: await _getHeaders());

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        if (responseData['status'] == 'success') {
          return Pemesanan.fromMap(responseData['data']);
        } else {
          throw Exception(
            'Failed to cancel pemesanan: ${responseData['message']}',
          );
        }
      } else if (response.statusCode == 403) {
        // Forbidden
        throw Exception('Forbidden: ${responseData['message']}');
      } else if (response.statusCode == 409) {
        // Conflict
        throw Exception('Conflict: ${responseData['message']}');
      } else {
        throw Exception(
          'Failed to cancel pemesanan. Status code: ${response.statusCode}, Message: ${responseData['message'] ?? response.body}',
        );
      }
    } catch (e) {
      print('Error in cancelPemesanan: $e');
      rethrow;
    }
  }
}
