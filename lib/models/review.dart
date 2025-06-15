class Review {
  final String id;
  final String userId;
  final int destinasiId;
  final String orderId;
  final String userName;
  final int rating;
  final String comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.userId,
    required this.destinasiId,
    required this.orderId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      destinasiId: int.parse(json['destinasi_id'].toString()),
      orderId: json['order_id'].toString(),
      userName: json['user_name'],
      rating: int.parse(json['rating'].toString()),
      comment: json['comment'],
      createdAt: DateTime.parse(json['created_at']),
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
      "created_at": createdAt.toIso8601String(), // Format tanggal ke string ISO
    };
  }
}
