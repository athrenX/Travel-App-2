import 'package:http/http.dart' as http;
import 'package:travelapp/models/wishlist.dart';
import 'dart:convert';

class WishlistService {
  final String baseUrl;

  WishlistService({required this.baseUrl});

  Future<List<Wishlist>> fetchWishlists(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/wishlists?userId=$userId'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Wishlist.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load wishlists');
    }
  }

  Future<void> addToWishlist(String userId, String destinasiId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/wishlists'),
      body: json.encode({'userId': userId, 'destinasiId': destinasiId}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add to wishlist');
    }
  }

  Future<void> removeFromWishlist(String wishlistId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/wishlists/$wishlistId'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to remove from wishlist');
    }
  }
}
