import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travelapp/models/destinasi.dart';

class DestinasiService {
  static const String _baseUrl = "http://192.168.1.4:8000";

  static Future<List<Destinasi>> getAllDestinasi() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final uri = Uri.parse("$_baseUrl/api/destinasis");

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    print('📥 RESPONSE STATUS: ${response.statusCode}');
    print('📥 RESPONSE BODY: ${response.body}');

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List data = body['data'];

      return data.map((json) {
        // Perbaikan gambar (hindari double base URL)
        final rawGambar = json['gambar'].toString().trim();
        final gambarUrl =
            rawGambar.startsWith('http')
                ? rawGambar
                : '$_baseUrl/storage/$rawGambar';

        print('✅ Final URL gambar: $gambarUrl');

        // Perbaikan galeri
        final List<String> galeriUrls =
            List<String>.from(json['galeri'] ?? []).map((g) {
              final item = g.toString().trim();
              return item.startsWith('http') ? item : '$_baseUrl/storage/$item';
            }).toList();

        return Destinasi(
          id: json['id'].toString(),
          nama: json['nama'],
          kategori: json['kategori'],
          deskripsi: json['deskripsi'],
          harga: double.parse(json['harga'].toString()),
          gambar: gambarUrl,
          rating:
              json['rating'] != null
                  ? double.tryParse(json['rating'].toString()) ?? 0.0
                  : 0.0,
          lat: double.parse(json['lat'].toString()),
          lng: double.parse(json['lng'].toString()),
          lokasi: json['lokasi'],
          galeri: galeriUrls,
        );
      }).toList();
    } else if (response.statusCode == 401) {
      throw Exception('🔐 Token tidak valid. Silakan login ulang.');
    } else {
      throw Exception(
        "❌ Gagal memuat destinasi. Status: ${response.statusCode}",
      );
    }
  }

  static deleteDestinasi(String id) {}
  static uploadImage(File file) {}
  static addDestinasi(Destinasi newDestinasi) {}
  static updateDestinasi(Destinasi updatedDestinasi) {}
}
