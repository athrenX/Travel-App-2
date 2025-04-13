class User {
  final String id;
  final String nama;
  final String email;
  final String password;
  final String role;

  User({
    required this.id,
    required this.nama,
    required this.email,
    required this.password,
    required this.role,
  });

  // Add a factory constructor to create User from a Map (for future use with APIs)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      nama: json['nama'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      role: json['role'] ?? 'user',
    );
  }

  // Convert user to a Map (for future use with APIs)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'email': email,
      'password': password,
      'role': role,
    };
  }

  // Create a copy of this User with optional new values
  User copyWith({
    String? id,
    String? nama,
    String? email,
    String? password,
    String? role,
  }) {
    return User(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
    );
  }
}
