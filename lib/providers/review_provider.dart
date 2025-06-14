import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/review.dart';

class ReviewProvider with ChangeNotifier {
  final List<Review> _reviews = [];

  List<Review> get reviews => _reviews;

  Future<void> fetchReviewsByDestinasi(String destinasiId, String token) async {
    final url = Uri.parse(
      'http://127.0.0.1:8000/api/reviews/destinasi/$destinasiId',
    );
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      _reviews.clear();
      _reviews.addAll(data.map((r) => Review.fromJson(r)).toList());
      notifyListeners();
    } else {
      throw Exception('Gagal mengambil review');
    }
  }

  Future<void> postReview(Review review, String token) async {
    final url = Uri.parse('http://192.168.1.17:8000/api/reviews');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(review.toJson()),
    );

    if (response.statusCode == 201) {
      final newReview = Review.fromJson(json.decode(response.body));
      _reviews.add(newReview);
      notifyListeners();
    } else {
      throw Exception('Gagal menambahkan review');
    }
  }

  Future<void> updateReview(Review review, String token) async {
    final url = Uri.parse('http://127.0.0.1:8000/api/reviews/${review.id}');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(review.toJson()),
    );

    if (response.statusCode == 200) {
      final index = _reviews.indexWhere((r) => r.id == review.id);
      if (index != -1) {
        _reviews[index] = Review.fromJson(json.decode(response.body));
        notifyListeners();
      }
    } else {
      throw Exception('Gagal memperbarui review');
    }
  }

  void clearReviews() {
    _reviews.clear();
    notifyListeners();
  }

  List<Review> getReviewsByUser(String userId) {
    return _reviews.where((review) => review.userId == userId).toList();
  }

  Review? getReviewByOrder(String orderId) {
    try {
      return _reviews.firstWhere((review) => review.orderId == orderId);
    } catch (e) {
      return null;
    }
  }

  void updateLocalReview(Review updatedReview) {
    final index = _reviews.indexWhere((r) => r.id == updatedReview.id);
    if (index != -1) {
      _reviews[index] = updatedReview;
      notifyListeners();
    }
  }

  bool hasReviewedOrder(String orderId) {
    return _reviews.any((review) => review.orderId == orderId);
  }
}
