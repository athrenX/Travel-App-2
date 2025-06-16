import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:travelapp/models/review.dart';

class ReviewService {
  static const String _baseUrl = 'http://192.168.1.13:8000/api';

  static Future<List<Review>> fetchReviewsByDestinasi(
    String destinasiId,
    String? token, // <-- Pastikan token diterima
  ) async {
    final url = Uri.parse(
      '$_baseUrl/destinasis/$destinasiId/reviews',
    ); // URL yang benar

    Map<String, String> headers = {'Accept': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token'; // <-- Sertakan token
    } else {
      debugPrint(
        'Warning: Token missing for fetchReviewsByDestinasi. Request might fail if route is protected.',
      );
    }

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => Review.fromJson(item)).toList();
    } else if (response.statusCode == 404) {
      debugPrint(
        'No reviews found for destinasi ID $destinasiId (404 Not Found).',
      );
      return [];
    } else {
      throw Exception(
        'Gagal mengambil data review: ${response.statusCode} ${response.body}',
      );
    }
  }

  static Future<void> postReview(Review review, String token) async {
    final url = Uri.parse('$_baseUrl/reviews');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
      body: json.encode(
        review.toJson(),
      ), // Mengirim seluruh objek review (termasuk userProfilePictureUrl jika ada)
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        'Gagal mengirim review: ${response.statusCode} ${response.body}',
      );
    }
  }

  static Future<String> updateReview(Review review, String token) async {
    final url = Uri.parse('$_baseUrl/reviews/${review.id}');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
      body: json.encode(
        review.toJson(),
      ), // Mengirim seluruh objek review yang diupdate
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      if (responseBody['review'] != null &&
          responseBody['review']['destinasi_id'] != null) {
        return responseBody['review']['destinasi_id'].toString();
      } else {
        throw Exception(
          'Destinasi ID tidak ditemukan di respons update review.',
        );
      }
    } else {
      throw Exception(
        'Gagal update review: ${response.statusCode} ${response.body}',
      );
    }
  }

  static Future<Review?> fetchReviewByOrder(
    String orderId,
    String token,
  ) async {
    final url = Uri.parse('$_baseUrl/reviews/order/$orderId');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['review'];
      if (data != null) {
        return Review.fromJson(data);
      }
    } else if (response.statusCode == 404) {
      debugPrint('Review for order ID $orderId not found (404 Not Found).');
      return null;
    } else {
      throw Exception(
        'Gagal mengambil review berdasarkan order ID: ${response.statusCode} ${response.body}',
      );
    }
    return null;
  }
}
