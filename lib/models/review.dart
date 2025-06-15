class Review {
  final int id;
  final String userName;
  final int rating;
  final String comment;
  final DateTime createdAt;
  final String? userProfilePictureUrl;
  final String? destinasiName;
  final String? destinasiGambar;
  final String? userFullName;

  Review({
    required this.id,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.userProfilePictureUrl,
    this.destinasiName,
    this.destinasiGambar,
    this.userFullName,
  });

  // fromJson yang robust dan clean
  factory Review.fromJson(Map<String, dynamic> json) {
    // Ambil foto_profil dari nested user (jika ada)
    String? fotoProfil;
    if (json['user'] != null && json['user']['foto_profil'] != null) {
      fotoProfil = json['user']['foto_profil'];
    }
    String? fullProfileUrl;
    if (fotoProfil != null && fotoProfil.isNotEmpty) {
      // Cek sudah http atau belum
      if (fotoProfil.startsWith('http')) {
        fullProfileUrl = fotoProfil;
      } else {
        fullProfileUrl = 'http://192.168.1.14:8000/storage/$fotoProfil';
      }
    } else {
      fullProfileUrl = null;
    }

    return Review(
      id: json['id'],
      userName: json['user_name'] ?? (json['user']?['nama'] ?? '-'),
      rating: json['rating'],
      comment: json['comment'],
      createdAt: DateTime.parse(json['created_at']),
      userProfilePictureUrl:
          json['user_profile_picture_url'] ??
          (json['user'] != null && json['user']['foto_profil'] != null
              ? 'http://192.168.1.14:8000/storage/' +
                  json['user']['foto_profil']
              : null),
      destinasiName: json['destinasi']?['nama'],
      destinasiGambar: json['destinasi']?['gambar'],
      userFullName: json['user']?['nama'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_name': userName,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
      'user_profile_picture_url': userProfilePictureUrl,
      'destinasi_name': destinasiName,
      'destinasi_gambar': destinasiGambar,
      'user_full_name': userFullName,
    };
  }
}
