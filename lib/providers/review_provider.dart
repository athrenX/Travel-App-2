import 'package:flutter/material.dart';
import 'package:travelapp/models/review.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReviewProvider with ChangeNotifier {
  Map<String, List<Review>> _reviews = {};
  List<Review> _allReviews = [];

  String? _errorMessage;
  bool _isLoading = false;

  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  List<Review> getReviewsByDestinasi(String destinasiId) {
    return _reviews[destinasiId] ?? [];
  }

  List<Review> get allReviews => _allReviews;

  Future<void> fetchAllReviews(String token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reviews'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> data = decoded is List ? decoded : decoded['data'];
        _allReviews = data.map((json) => Review.fromJson(json)).toList();
        print('[DEBUG] Total review didapatkan: ${_allReviews.length}');
      } else {
        _errorMessage =
            'Gagal memuat semua review: ${response.statusCode} ${response.body}';
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  final String baseUrl = 'http://192.168.1.14:8000/api';

  Future<void> postReview(
    String userId,
    String destinasiId,
    String orderId,
    String userName,
    String comment,
    int ratingValue,
    String token,
  ) async {
    _isLoading = true;
    // notifyListeners(); // Baris ini sudah dihapus dengan benar

    final url = Uri.parse('$baseUrl/reviews');
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'user_id': userId,
          'destinasi_id': destinasiId,
          'order_id': orderId,
          'user_name': userName,
          'comment': comment,
          'rating': ratingValue,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchReviewsByDestinasi(destinasiId, token);
      } else {
        _errorMessage =
            'Gagal menyimpan review: ${response.statusCode} ${response.body}';
        throw Exception(_errorMessage);
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan jaringan saat menyimpan review: $e';
      throw Exception(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners(); // Ini tetap ada dan benar di sini
    }
  }

  Future<void> updateReview(
    String reviewId,
    String comment,
    int ratingValue,
    String token,
  ) async {
    _isLoading = true;
    // notifyListeners(); // Baris ini sudah dihapus dengan benar

    final url = Uri.parse('$baseUrl/reviews/$reviewId');
    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'comment': comment, 'rating': ratingValue}),
      );

      if (response.statusCode == 200) {
        final updatedReviewData = jsonDecode(response.body)['review'];
        if (updatedReviewData != null &&
            updatedReviewData['destinasi_id'] != null) {
          await fetchReviewsByDestinasi(
            updatedReviewData['destinasi_id'].toString(),
            token,
          );
        } else {
          debugPrint(
            'Warning: destinasi_id not found in update review response. Cannot refresh specific reviews.',
          );
        }
      } else {
        _errorMessage =
            'Gagal update review: ${response.statusCode} ${response.body}';
        throw Exception(_errorMessage);
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan jaringan saat update review: $e';
      throw Exception(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners(); // Ini tetap ada dan benar di sini
    }
  }

  Future<Review?> fetchReviewByOrder(String orderId, String token) async {
    _isLoading = true;
    // notifyListeners(); // Baris ini sudah dihapus dengan benar

    final url = Uri.parse('$baseUrl/reviews/order/$orderId');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['review'];
        if (data != null) {
          return Review.fromJson(data);
        }
      } else if (response.statusCode == 404) {
        debugPrint('Review for order $orderId not found.');
        return null;
      } else {
        _errorMessage =
            'Gagal memuat review berdasarkan order ID: ${response.statusCode} ${response.body}';
        throw Exception(_errorMessage);
      }
    } catch (e) {
      _errorMessage =
          'Terjadi kesalahan jaringan saat memuat review by order: $e';
      throw Exception(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners(); // Ini tetap ada dan benar di sini
    }
    return null;
  }

  Future<void> fetchReviewsByDestinasi(
    String destinasiId,
    String? token,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    // notifyListeners(); // Baris ini sudah dihapus dengan benar

    Map<String, String> headers = {'Accept': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    } else {
      debugPrint(
        'Warning: No authentication token provided for fetching reviews. Request might fail if route is protected.',
      );
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/destinasis/$destinasiId/reviews'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        _reviews[destinasiId] =
            data.map((json) => Review.fromJson(json)).toList();
        debugPrint(
          'Reviews for $destinasiId: ${_reviews[destinasiId]?.length} items',
        );
        _reviews[destinasiId]?.forEach((review) {
          debugPrint(
            '  - Review: ${review.userName}, Rating: ${review.rating}, Comment: ${review.comment}, Profile: ${review.userProfilePictureUrl}',
          ); // Tambahkan debug foto profil
        });
      } else if (response.statusCode == 404) {
        _reviews[destinasiId] = [];
        _errorMessage = 'No reviews found for this destination.';
        debugPrint('No reviews found for $destinasiId. Status: 404');
      } else {
        _errorMessage =
            'Gagal memuat review destinasi: ${response.statusCode} ${response.body}';
        throw Exception(_errorMessage);
      }
    } catch (e) {
      _errorMessage =
          'Terjadi kesalahan jaringan saat memuat review destinasi: $e';
      debugPrint('Network error fetching reviews: $e');
      throw Exception(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners(); // Ini tetap ada dan benar di sini
    }
  }
}
