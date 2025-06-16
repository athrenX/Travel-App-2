import 'package:flutter/material.dart';
import 'package:travelapp/models/wishlist.dart';
import 'package:travelapp/services/wishlist_service.dart';

class WishlistProvider extends ChangeNotifier {
  WishlistService? _wishlistService;
  String? _token;

  List<Wishlist> _wishlist = [];
  List<Wishlist> get wishlist => _wishlist;

  WishlistProvider();

  // Update token dan buat service baru setiap token berubah
  void updateToken(String? token) {
    _token = token;
    if (_token != null) {
      _wishlistService = WishlistService(

        baseUrl: 'http://192.168.1.13:8000/api',

        token: _token!,
      );
      loadWishlist().catchError((e) {
        print('Gagal load wishlist setelah update token: $e');
      });
    } else {
      _wishlistService = null;
      _wishlist = [];
    }
    notifyListeners();
  }

  Future<void> loadWishlist() async {
    if (_wishlistService == null) throw Exception('Token belum tersedia');
    try {
      final fetchedWishlist = await _wishlistService!.fetchWishlist();
      _wishlist = fetchedWishlist;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addWishlist(String destinasisId) async {
    if (_wishlistService == null) throw Exception('Token belum tersedia');
    try {
      final success = await _wishlistService!.addToWishlist(destinasisId);
      if (success) await loadWishlist();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeWishlist(String destinasisId) async {
    if (_wishlistService == null) throw Exception('Token belum tersedia');
    try {
      final success = await _wishlistService!.removeFromWishlist(destinasisId);
      if (success) {
        _wishlist.removeWhere((item) => item.destinasisId == destinasisId);
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  bool isInWishlist(String destinasisId) {
    return _wishlist.any((item) => item.destinasisId == destinasisId);
  }

  List<Wishlist> getWishlistsByUser(String userId) {
    return _wishlist.where((item) => item.usersId == userId).toList();
  }
}
