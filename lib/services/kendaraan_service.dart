import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travelapp/models/kendaraan.dart';
import 'package:travelapp/config.dart';

class KendaraanService {
  static const String _baseUrl = AppConfig.baseUrl;

  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<List<Kendaraan>> getKendaraanByDestinasi(String destinasiId) async {
    final url = Uri.parse('$_baseUrl/api/kendaraan/by-destinasi/$destinasiId');
    try {
      final response = await http.get(url, headers: await _getHeaders());
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          final List<dynamic> kendaraanData = responseData['data'];
          return kendaraanData.map((json) => Kendaraan.fromMap(json)).toList();
        } else {
          throw Exception('Failed to load vehicles: ${responseData['message']}');
        }
      } else {
        throw Exception('Failed to load vehicles. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getKendaraanByDestinasi: $e');
      rethrow;
    }
  }

  static Future<Kendaraan> holdKendaraanSeats(String kendaraanId, List<int> seatsToHold) async {
    final url = Uri.parse('$_baseUrl/api/kendaraan/$kendaraanId/hold-seats');
    try {
      final response = await http.post(
        url,
        headers: await _getHeaders(),
        body: json.encode({'seats_to_hold': seatsToHold}),
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        if (responseData['status'] == 'success') {
          return Kendaraan.fromMap(responseData['data']);
        } else {
          throw Exception('Failed to hold seats: ${responseData['message']}');
        }
      } else if (response.statusCode == 409) { // Conflict (kursi tidak tersedia)
        throw Exception('Conflict: ${responseData['message']}');
      } else {
        throw Exception('Failed to hold seats. Status code: ${response.statusCode}, Message: ${responseData['message'] ?? response.body}');
      }
    } catch (e) {
      print('Error in holdKendaraanSeats: $e');
      rethrow;
    }
  }

  static Future<Kendaraan> releaseHeldSeats(String kendaraanId, List<int> seatsToRelease) async {
    final url = Uri.parse('$_baseUrl/api/kendaraan/$kendaraanId/release-held-seats');
    try {
      final response = await http.post(
        url,
        headers: await _getHeaders(),
        body: json.encode({'seats_to_release': seatsToRelease}),
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        if (responseData['status'] == 'success') {
          return Kendaraan.fromMap(responseData['data']);
        } else {
          throw Exception('Failed to release held seats: ${responseData['message']}');
        }
      } else {
        throw Exception('Failed to release held seats. Status code: ${response.statusCode}, Message: ${responseData['message'] ?? response.body}');
      }
    } catch (e) {
      print('Error in releaseHeldSeats: $e');
      rethrow;
    }
  }
}