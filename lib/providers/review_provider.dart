import 'package:flutter/material.dart';
import 'package:travelapp/models/review.dart';
import 'package:http/http.dart' as http;
import 'package:travelapp/services/review_service.dart';
import 'dart:convert';

class ReviewProvider with ChangeNotifier {
  Map<String, List<Review>> _reviews = {};
  String? _errorMessage;
  bool _isLoading = false;

  // Getter untuk semua review

  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  // GET Review khusus destinasi tertentu
  List<Review> getReviewsByDestinasi(String destinasiId) {
    return _reviews[destinasiId] ?? [];
  }

  final String baseUrl = 'http://192.168.1.14:8000/api'; // ganti sesuai backend

  // POST Review baru
  Future<void> postReview(Review review, String token) async {
    final url = Uri.parse('$baseUrl/reviews');
    final response = await http.post(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
      body: {
        'user_id': review.userId,
        'destinasi_id': review.destinasiId.toString(),
        'order_id': review.orderId,
        'user_name': review.userName,
        'rating': review.rating.toString(),
        'comment': review.comment,
      },
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Gagal menyimpan review');
    }
    notifyListeners();
  }

  // PUT Update Review
  Future<void> updateReview(Review review, String token) async {
    final url = Uri.parse('$baseUrl/reviews/${review.id}');
    final response = await http.put(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
      body: {'rating': review.rating.toString(), 'comment': review.comment},
    );
    if (response.statusCode != 200) {
      throw Exception('Gagal update review');
    }
    notifyListeners();
  }

  // GET Review by Order ID
  Future<Review?> fetchReviewByOrder(String orderId, String token) async {
    final url = Uri.parse('$baseUrl/reviews/order/$orderId');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['review'];
      if (data != null) {
        return Review.fromJson(data);
      }
    }
    return null;
  }

  Future<void> fetchReviewsByDestinasi(String destinasiId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/destinasis/$destinasiId/reviews'),
    );
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      _reviews[destinasiId] =
          data.map((json) => Review.fromJson(json)).toList();
      notifyListeners();
    }
  }

  // Lokasi penyimpanan review lokal bisa menggunakan Map/Cache sesuai kebutuhan.
}
