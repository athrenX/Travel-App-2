import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travelapp/models/user.dart';
import 'package:travelapp/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  String? _token;
  bool _isLoading = false;
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get token => _token;
  bool get isAuthenticated =>
      _user != null && _token != null && _user!.id != null;

  String? get paymentMethod => _user?.paymentMethod;
  // Login
  Future<User?> login(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await _authService.login(email, password);
      _user = result['user'];
      _token = result['token'];

      // Simpan ke SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _token!);
      await prefs.setString('user_nama', _user!.nama);
      await prefs.setString('user_email', _user!.email);
      await prefs.setString('user_payment_method', _user!.paymentMethod ?? '');

      return _user;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Register
  Future<bool> register(String nama, String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await _authService.register(nama, email, password);
      _user = result['user'];
      _token = result['token'];

      // Simpan ke SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _token!);
      await prefs.setString('user_nama', _user!.nama);
      await prefs.setString('user_email', _user!.email);

      return true;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      if (_token != null) {
        await _authService.logout(_token!);
      }
    } catch (e) {
      print('❌ Error saat logout: $e');
    } finally {
      _user = null;
      _token = null;

      // Hapus data dari SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      notifyListeners();
    }
  }

  // Get current user dari token
  Future<User?> getCurrentUser() async {
    if (_token == null) return null;

    try {
      _isLoading = true;
      notifyListeners();

      final user = await _authService.getCurrentUser(_token!);
      _user = user;

      // Tambahan penting agar token & user tetap tersimpan di SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _token!);
      await prefs.setString('user_nama', _user!.nama);
      await prefs.setString('user_email', _user!.email);
      if (_user!.paymentMethod != null) {
        await prefs.setString('user_payment_method', _user!.paymentMethod!);
      }

      return _user;
    } catch (e) {
      print('❌ Gagal mengambil user: $e');
      if (e.toString().contains('401') ||
          e.toString().contains('Unauthenticated')) {
        await logout();
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update profil
  Future<void> updateUserProfile({
    required String nama,
    String? email,
    File? fotoProfil,
    String? paymentMethod,
  }) async {
    if (_user == null || _token == null) {
      throw Exception('User tidak terautentikasi');
    }

    try {
      _isLoading = true;
      notifyListeners();

      final updatedUser = await _authService.updateProfile(
        token: _token!,
        nama: nama,
        email: email,
        fotoProfil: fotoProfil,
        paymentMethod: paymentMethod,
      );

      _user = updatedUser;

      // Update SharedPreferences juga
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_nama', _user!.nama);
      if (_user!.email.isNotEmpty) {
        await prefs.setString('user_email', _user!.email);
      }
      if (_user!.paymentMethod != null) {
        await prefs.setString('user_payment_method', _user!.paymentMethod!);
      }

      print('✅ Profil berhasil diupdate: ${_user!.nama}');
      print('✅ ID user setelah update: ${_user?.id}');

      await refreshUser();
    } catch (e) {
      print('❌ Gagal update profil: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Ganti password
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    if (_token == null) {
      throw Exception('Token tidak tersedia');
    }

    try {
      return await _authService.changePassword(
        token: _token!,
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
    } catch (e) {
      print('❌ Gagal ganti password: $e');
      return false;
    }
  }

  // Refresh user (optional)
  Future<void> refreshUser() async {
    if (_token != null) {
      await getCurrentUser();
    }
  }

  // Set user dan token (berguna untuk login persistent jika pakai SharedPreferences)
  void setUser(User user, String token) {
    _user = user;
    _token = token;
    notifyListeners();
  }

  // Restore session dari SharedPreferences
  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('auth_token');

    if (savedToken != null) {
      _token = savedToken;
      try {
        final fetchedUser = await _authService.getCurrentUser(_token!);
        _user = fetchedUser;
      } catch (e) {
        print("Auto login gagal: $e");
        await logout();
      }
    }

    _isInitialized = true;
    notifyListeners();
  }
}
