class Review {
  final String id;
  final String userId;
  final int destinasiId;
  final String orderId;
  final String userName;
  final int rating;
  final String comment;
  final DateTime createdAt;
  final String?
  userProfilePictureUrl; // Ini akan menerima URL LENGKAP dari backend

  Review({
    required this.id,
    required this.userId,
    required this.destinasiId,
    required this.orderId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.userProfilePictureUrl,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      destinasiId: int.tryParse(json['destinasi_id']?.toString() ?? '0') ?? 0,
      orderId: json['order_id']?.toString() ?? '',
      userName: json['user_name'] ?? '',
      rating: int.tryParse(json['rating']?.toString() ?? '0') ?? 0,
      comment: json['comment'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      // PASTIKAN PARSING user_profile_picture_url DI SINI DENGAN SANGAT HATI-HATI
      userProfilePictureUrl:
          json['user_profile_picture_url']?.toString() ??
          '', // <-- Perbaikan di sini
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "user_id": userId,
      "destinasi_id": destinasiId,
      "order_id": orderId,
      "user_name": userName,
      "rating": rating,
      "comment": comment,
      "created_at": createdAt.toIso8601String(),
      "user_profile_picture_url": userProfilePictureUrl,
    };
  }
}
