import 'package:travelapp/models/user.dart';

class AuthService {
  Future<User> login(String email, String password) async {
    // Simulasi login dengan delay untuk simulasi panggilan API
    await Future.delayed(Duration(seconds: 1));
    
    // Cek untuk admin
    if (email == 'admin@admin.com' && password == 'admin123') {
      return User(
        id: '1',
        nama: 'Admin',
        email: email,
        password: password,
        role: 'admin',
      );
    } 
    // Cek untuk user
    else if (email == 'user@example.com' && password == '123456') {
      return User(
        id: '2',
        nama: 'User Biasa',
        email: email,
        password: password,
        role: 'user',
      );
    } 
    // Jika kombinasi email dan password tidak valid
    else {
      throw Exception('Email atau password tidak valid');
    }
  }

  Future<User> register(String nama, String email, String password) async {
    // Simulasi register dengan delay
    await Future.delayed(Duration(seconds: 1));
    
    // Simpan user baru dengan role default 'user'
    return User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nama: nama,
      email: email,
      password: password, // Biasanya password di-hash dulu
      role: 'user',
    );
  }
}