import 'package:flutter/material.dart';
import 'package:travelapp/models/user.dart';
import 'package:travelapp/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;

  bool get isAuthenticated => user != null;

  Future<User?> login(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      final user = await _authService.login(email, password);
      _user = user;

      return user;
    } catch (e) {
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<User?> register(String nama, String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      final user = await _authService.register(nama, email, password);
      _user = user;

      return user;
    } catch (e) {
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _user = null;
    notifyListeners();
  }

  Future<User?> getCurrentUser() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Sementara ambil dari _user yang sudah diset saat login/register
      // Kalau kamu mau ambil dari penyimpanan lokal atau API, bisa diubah nanti
      return _user;
    } catch (e) {
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Tambahkan method untuk update profil
  Future<void> updateUserProfile({
    required String name,
    required String email,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Jika ingin melakukan update ke server:
      // await _authService.updateProfile(name, email);

      // Update data user secara lokal
      if (_user != null) {
        _user = _user!.copyWith(nama: name, email: email);
      }

      notifyListeners();
    } catch (e) {
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Tambahkan method untuk ganti password
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Implementasi ganti password ke server
      // Contoh:
      // final result = await _authService.changePassword(oldPassword, newPassword);
      // return result;

      // Untuk sementara anggap berhasil
      return true;
    } catch (e) {
      print('Error changing password: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
