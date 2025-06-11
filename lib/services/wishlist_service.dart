import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:travelapp/models/wishlist.dart';

class WishlistService {
  final String baseUrl;
  final String token;

  WishlistService({required this.baseUrl, required this.token});

  String _timestamp() => DateTime.now().toIso8601String();

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

  Future<List<Wishlist>> fetchWishlist() async {
    try {
      print('[$_timestamp] 📥 Fetching wishlist with token: ${token.substring(0, 20)}...');

      final response = await http.get(
        Uri.parse('$baseUrl/wishlist'),
        headers: _headers,
      );

      print('[$_timestamp] 📥 Response status: ${response.statusCode}');
      print('[$_timestamp] 📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> list = data['data'];
        return list.map((json) => Wishlist.fromJson(json)).toList();
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to load wishlist');
      }
    } catch (e, stackTrace) {
      print('[$_timestamp] ❌ fetchWishlist error: $e');
      print('Stacktrace: $stackTrace');
      rethrow;
    }
  }

  Future<bool> addToWishlist(String destinasisId) async {
    try {
      print('[$_timestamp] ➕ Adding destinasis_id=$destinasisId to wishlist with token: ${token.substring(0, 20)}...');

      final response = await http.post(
        Uri.parse('$baseUrl/wishlist'),
        headers: _headers,
        body: json.encode({'destinasis_id': destinasisId}),
      );

      print('[$_timestamp] 📥 Response status: ${response.statusCode}');
      print('[$_timestamp] 📥 Response body: ${response.body}');

      if (response.statusCode == 201) {
        return true;
      } else if (response.statusCode == 409) {
        // Conflict: already exists
        return false;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to add to wishlist');
      }
    } catch (e, stackTrace) {
      print('[$_timestamp] ❌ addToWishlist error: $e');
      print('Stacktrace: $stackTrace');
      rethrow;
    }
  }

  Future<bool> removeFromWishlist(String destinasisId) async {
    try {
      print('[$_timestamp] ➖ Removing destinasis_id=$destinasisId from wishlist with token: ${token.substring(0, 20)}...');

      final response = await http.delete(
        Uri.parse('$baseUrl/wishlist/$destinasisId'),
        headers: _headers,
      );

      print('[$_timestamp] 📥 Response status: ${response.statusCode}');
      print('[$_timestamp] 📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        return true;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to remove from wishlist');
      }
    } catch (e, stackTrace) {
      print('[$_timestamp] ❌ removeFromWishlist error: $e');
      print('Stacktrace: $stackTrace');
      rethrow;
    }
  }
}
