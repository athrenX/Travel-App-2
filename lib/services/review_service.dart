import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:travelapp/models/review.dart';

class ReviewService {
  static const String _baseUrl = 'http://192.168.1.14:8000/api';

  // Ambil semua review berdasarkan destinasi
  static Future<List<Review>> fetchReviewsByDestinasi(
    String destinasiId,
  ) async {
    final url = Uri.parse('$_baseUrl/reviews?destinasi_id=$destinasiId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => Review.fromJson(item)).toList();
    } else {
      throw Exception('Gagal mengambil data review');
    }
  }

  // Kirim review baru
  static Future<void> postReview(Review review, String token) async {
    final url = Uri.parse('$_baseUrl/reviews');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(review.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Gagal mengirim review');
    }
  }

  // Update review (jika sudah punya endpointnya)
  static Future<void> updateReview(Review review, String token) async {
    final url = Uri.parse('$_baseUrl/reviews/${review.id}');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(review.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal update review');
    }
  }
}
