class User {
  final String? id;
  final String nama;
  final String email;
  final String? role;
  final String? fotoProfil;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? paymentMethod;

  User({
    this.id,
    required this.nama,
    required this.email,
    this.role,
    this.fotoProfil,
    this.createdAt,
    this.updatedAt,
    this.paymentMethod,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString(), // Fixed: Convert to string, not trying to parse as int
      nama: json['nama']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString(),
      fotoProfil: json['foto_profil']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      paymentMethod: json['payment_method']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'email': email,
      'role': role,
      'foto_profil': fotoProfil,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'payment_method': paymentMethod,
    };
  }

  User copyWith({
    String? id,
    String? nama,
    String? email,
    String? role,
    String? fotoProfil,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      email: email ?? this.email,
      role: role ?? this.role,
      fotoProfil: fotoProfil ?? this.fotoProfil,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper method to check if user has valid ID
  bool get hasValidId => id != null && id!.isNotEmpty;

  @override
  String toString() {
    return 'User{id: $id, nama: $nama, email: $email, role: $role, fotoProfil: $fotoProfil}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.nama == nama &&
        other.email == email &&
        other.role == role &&
        other.fotoProfil == fotoProfil;
  }

  @override
  int get hashCode {
    return Object.hash(id, nama, email, role, fotoProfil);
  }
}