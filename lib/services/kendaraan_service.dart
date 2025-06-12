import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travelapp/models/kendaraan.dart';

class KendaraanService {
  static const String _baseUrl =
      "http://192.168.1.20:8000"; // SESUAIKAN DENGAN IP XAMPP ANDA

  // Method ini harus STATIC
  static Future<List<Kendaraan>> getKendaraanByDestinasi(
    String destinasiId,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception('Autentikasi diperlukan. Silakan login kembali.');
    }

    final uri = Uri.parse('$_baseUrl/api/kendaraan/by-destinasi/$destinasiId');

    try {
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          final List<dynamic> data = responseData['data'];
          return data.map((json) => Kendaraan.fromMap(json)).toList();
        } else {
          throw Exception(
            responseData['message'] ?? 'Gagal mengambil kendaraan.',
          );
        }
      } else if (response.statusCode == 404) {
        throw Exception('Tidak ada kendaraan untuk destinasi ini.');
      } else if (response.statusCode == 401) {
        throw Exception(
          'Token tidak valid atau kadaluarsa. Silakan login ulang.',
        );
      } else {
        throw Exception(
          'Gagal memuat kendaraan. Status: ${response.statusCode}, Body: ${response.body}',
        );
      }
    } catch (e) {
      print('Error fetching kendaraan by destinasi: $e');
      throw Exception('Terjadi kesalahan jaringan atau server: $e');
    }
  }

  // Method ini harus STATIC
  static Future<Kendaraan> updateKendaraanSeats(
    String kendaraanId,
    List<int> bookedSeats,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception('Autentikasi diperlukan. Silakan login kembali.');
    }

    final uri = Uri.parse('$_baseUrl/api/kendaraan/$kendaraanId/update-seats');

    try {
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'booked_seats': bookedSeats}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          return Kendaraan.fromMap(responseData['data']);
        } else {
          throw Exception(responseData['message'] ?? 'Gagal mengupdate kursi.');
        }
      } else if (response.statusCode == 409) {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        throw Exception(
          errorData['message'] ??
              'Kursi yang Anda pilih sudah terisi. Silakan refresh dan coba lagi.',
        );
      } else if (response.statusCode == 422) {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        String errorMessage = 'Validasi gagal.';
        if (errorData['errors'] != null) {
          errorData['errors'].forEach((key, value) {
            errorMessage += '\n- ${value.join(', ')}';
          });
        }
        throw Exception(errorMessage);
      } else if (response.statusCode == 401) {
        throw Exception(
          'Token tidak valid atau kadaluarsa. Silakan login ulang.',
        );
      } else {
        throw Exception(
          'Gagal mengupdate kursi. Status: ${response.statusCode}, Body: ${response.body}',
        );
      }
    } catch (e) {
      print('Error updating seats: $e');
      rethrow;
    }
  }
}
