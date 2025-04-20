class Wishlist {
  final String id;
  final String userId;
  final String destinasiId;
  final DateTime createdAt;

  Wishlist({
    required this.id,
    required this.userId,
    required this.destinasiId,
    required this.createdAt,
  });

  factory Wishlist.fromJson(Map<String, dynamic> json) {
    return Wishlist(
      id: json['id'],
      userId: json['userId'],
      destinasiId: json['destinasiId'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'destinasiId': destinasiId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
