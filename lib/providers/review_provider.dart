import 'package:flutter/material.dart';
import 'package:travelapp/models/review.dart';

class ReviewProvider with ChangeNotifier {
  final List<Review> _reviews = [];

  List<Review> get reviews => _reviews;

  void addReview(Review review) {
    _reviews.add(review);
    notifyListeners();
  }

  List<Review> getReviewsByDestinasi(String destinasiId) {
    return _reviews
        .where((review) => review.destinasiId == destinasiId)
        .toList();
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

  void updateReview(Review updatedReview) {
    final index = _reviews.indexWhere((r) => r.id == updatedReview.id);
    if (index != -1) {
      _reviews[index] = updatedReview;
      notifyListeners();
    }
  }

  // For testing - can be removed later
  void initializeSampleReviews() {
    _reviews.addAll([
      Review(
        id: '1',
        userId: 'user1',
        destinasiId: 'dest1',
        orderId: 'order1',
        userName: 'Ayu',
        rating: 5,
        comment: 'Sangat indah dan memuaskan!',
        createdAt: DateTime.now().subtract(Duration(days: 2)),
      ),
      Review(
        id: '2',
        userId: 'user2',
        destinasiId: 'dest1',
        orderId: 'order2',
        userName: 'Budi',
        rating: 4,
        comment: 'Cocok buat healing. Recommended!',
        createdAt: DateTime.now().subtract(Duration(days: 7)),
      ),
    ]);
    notifyListeners();
  }
}
