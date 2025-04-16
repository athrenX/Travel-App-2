import 'package:flutter/material.dart';
import 'package:travelapp/models/user.dart';
import 'package:travelapp/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;

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

}