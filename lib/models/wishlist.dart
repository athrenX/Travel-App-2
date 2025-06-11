class Wishlist {
  final String id;
  final String usersId;
  final String destinasisId; // **PASTIKAN NAMA INI SESUAI**
  final DateTime createdAt;

  Wishlist({
    required this.id,
    required this.usersId,
    required this.destinasisId,
    required this.createdAt,
  });

  factory Wishlist.fromJson(Map<String, dynamic> json) {
    return Wishlist(
      id: json['id'].toString(),
      usersId: json['users_id'].toString(),
      destinasisId: json['destinasis_id'].toString(),
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
