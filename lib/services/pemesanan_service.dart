// lib/services/pemesanan_service.dart

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
    final token = prefs.getString(
      'auth_token',
    ); // Pastikan kunci token yang disimpan adalah 'auth_token'
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Pemesanan> createPemesanan(Pemesanan pemesanan) async {
    final url = Uri.parse(
      '$_baseUrl/api/pemesanans',
    ); // Menggunakan /api/pemesanans
    try {
      final response = await http.post(
        url,
        headers: await _getHeaders(),
        body: json.encode(pemesanan.toMap()),
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 201) {
        if (responseData['status'] == 'success') {
          return Pemesanan.fromMap(responseData['data']);
        } else {
          throw Exception(
            'Failed to create pemesanan: ${responseData['message']}',
          );
        }
      } else if (response.statusCode == 422) {
        throw Exception('Validation Error: ${responseData['errors']}');
      } else if (response.statusCode == 409) {
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

    final url = Uri.parse(
      '$_baseUrl/api/my-pemesanans',
    ); // Menggunakan /api/my-pemesanans
    try {
      final response = await http.get(
        url,
        headers: await _getHeaders(), // Menggunakan _getHeaders()
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

  // >>> BARU: Metode untuk mengambil semua pesanan (khusus admin)
  static Future<List<Pemesanan>> getAllPemesananForAdmin() async {
    final url = Uri.parse(
      '$_baseUrl/api/pemesanans',
    ); // Menggunakan /api/pemesanans untuk admin
    try {
      final response = await http.get(url, headers: await _getHeaders());

      print("getAllPemesananForAdmin status: ${response.statusCode}");
      print("getAllPemesananForAdmin body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          final List<dynamic> pemesananList = responseData['data'];
          return pemesananList.map((json) => Pemesanan.fromMap(json)).toList();
        } else {
          throw Exception(
            'Failed to load all pemesanans for admin: ${responseData['message']}',
          );
        }
      } else if (response.statusCode == 403) {
        throw Exception('Akses ditolak (403). Anda bukan admin.');
      } else {
        throw Exception(
          'Failed to load all pemesanans for admin. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error in getAllPemesananForAdmin: $e');
      rethrow;
    }
  }

  static Future<Pemesanan> confirmPayment(String pemesananId) async {
    final url = Uri.parse(
      '$_baseUrl/api/pemesanans/$pemesananId/confirm-payment',
    ); // Menggunakan /api/pemesanans
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
        throw Exception('Conflict: ${responseData['message']}');
      } else if (response.statusCode == 410) {
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
    final url = Uri.parse(
      '$_baseUrl/api/pemesanans/$pemesananId/cancel',
    ); // Menggunakan /api/pemesanans
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
        throw Exception('Forbidden: ${responseData['message']}');
      } else if (response.statusCode == 409) {
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

  // >>> BARU: Metode untuk admin memperbarui status pemesanan
  static Future<Pemesanan> updatePemesananStatus(
    String pemesananId,
    String newStatus,
  ) async {
    final url = Uri.parse(
      '$_baseUrl/api/pemesanans/$pemesananId',
    ); // Menggunakan /api/pemesanans
    try {
      final response = await http.put(
        url,
        headers: await _getHeaders(),
        body: json.encode({'status': newStatus}),
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        if (responseData['status'] == 'success') {
          return Pemesanan.fromMap(responseData['data']);
        } else {
          throw Exception(
            'Failed to update order status: ${responseData['message']}',
          );
        }
      } else if (response.statusCode == 422) {
        // Validation error
        throw Exception('Validation Error: ${responseData['errors']}');
      } else if (response.statusCode == 403) {
        // Forbidden (not admin)
        throw Exception(
          'Akses ditolak (403). Anda tidak memiliki izin untuk memperbarui status ini.',
        );
      } else {
        throw Exception(
          'Failed to update order status. Status code: ${response.statusCode}, Message: ${responseData['message'] ?? response.body}',
        );
      }
    } catch (e) {
      print('Error in updatePemesananStatus: $e');
      rethrow;
    }
  }
}
