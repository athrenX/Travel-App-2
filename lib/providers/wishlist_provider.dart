import 'package:flutter/material.dart';
import 'package:travelapp/models/wishlist.dart';

class WishlistProvider with ChangeNotifier {
  final List<Wishlist> _wishlists = [];

  List<Wishlist> get wishlists => _wishlists;

  // Add to wishlist
  void addToWishlist(String userId, String destinasiId) {
    _wishlists.add(
      Wishlist(
        id: DateTime.now().toString(),
        userId: userId,
        destinasiId: destinasiId,
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  // Remove from wishlist
  void removeFromWishlist(String destinasiId) {
    _wishlists.removeWhere((item) => item.destinasiId == destinasiId);
    notifyListeners();
  }

  // Check if item is in wishlist
  bool isInWishlist(String destinasiId) {
    return _wishlists.any((item) => item.destinasiId == destinasiId);
  }

  // Get wishlist items count
  int get wishlistCount => _wishlists.length;

  // Get wishlist items by user
  List<Wishlist> getWishlistsByUser(String userId) {
    return _wishlists.where((item) => item.userId == userId).toList();
  }
}
