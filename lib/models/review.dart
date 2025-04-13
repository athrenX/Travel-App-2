class Review {
  final int id;
  final int userId;
  final int destinasiId;
  final String komentar;
  final int rating;

  Review({
    required this.id,
    required this.userId,
    required this.destinasiId,
    required this.komentar,
    required this.rating,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      userId: json['user_id'],
      destinasiId: json['destinasi_id'],
      komentar: json['komentar'],
      rating: json['rating'],
    );
  }
}