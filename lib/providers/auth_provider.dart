import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travelapp/models/user.dart';
import 'package:travelapp/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;
  bool _isInitialized = false;
  bool _isAuthenticated = false;
  String? _loginErrorMessage; // Untuk pesan error di UI login/register

  // Getters
  bool get isInitialized => _isInitialized;
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get token => _token;
  bool get isAuthenticated => _isAuthenticated;
  String? get paymentMethod => _user?.paymentMethod;
  String? get loginErrorMessage => _loginErrorMessage;

  AuthProvider() {
    _tryAutoLoginOnLaunch();
  }

  Future<void> _tryAutoLoginOnLaunch() async {
    _isLoading = true;
    _loginErrorMessage = null;
    notifyListeners();

    await tryAutoLogin();

    _isInitialized = true;
    _isLoading = false;
    notifyListeners();
  }

  // Login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _loginErrorMessage = null; // Reset pesan error
    notifyListeners();
    try {
      final loggedInUser = await AuthService.login(email, password);
      _user = loggedInUser;
      _token = loggedInUser.token;

      _isAuthenticated = true;
      return true;
    } catch (e) {
      print('Error di AuthProvider login: $e');
      _user = null;
      _token = null;
      _isAuthenticated = false;
      _loginErrorMessage = e.toString().replaceAll('Exception: ', '');
      return false; // Kembali false jika ada error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Register
  Future<bool> register(
    String nama,
    String email,
    String password,
    String passwordConfirmation,
  ) async {
    _isLoading = true;
    _loginErrorMessage = null; // Reset pesan error
    notifyListeners();
    try {
      final registeredUser = await AuthService.register(
        nama,
        email,
        password,
        passwordConfirmation,
      );
      _user = registeredUser;
      _token = registeredUser.token;

      _isAuthenticated = true;
      return true;
    } catch (e) {
      print('Error di AuthProvider register: $e');
      _user = null;
      _token = null;
      _isAuthenticated = false;
      _loginErrorMessage = e.toString().replaceAll('Exception: ', '');
      return false; // Kembali false jika ada error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout
  Future<void> logout() async {
    _isLoading = true;
    _loginErrorMessage = null; // Reset pesan error
    notifyListeners();
    try {
      if (_token != null) {
        await AuthService.logout(_token!);
      }
    } catch (e) {
      print('Error di AuthProvider logout: $e');
    } finally {
      _user = null;
      _token = null;
      _isAuthenticated = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get current user data (jika token masih valid)
  Future<User?> getCurrentUser() async {
    if (_token == null || _token!.isEmpty) {
      _isAuthenticated = false;
      _loginErrorMessage = null;
      notifyListeners();
      return null;
    }

    _isLoading = true;
    notifyListeners();
    try {
      final fetchedUser = await AuthService.getCurrentUser(_token!);
      _user = fetchedUser;
      _token = fetchedUser.token;
      _isAuthenticated = true;
      return _user;
    } catch (e) {
      print('Error di AuthProvider getCurrentUser: $e');
      if (e.toString().contains('401') ||
          e.toString().contains('Unauthenticated')) {
        await AuthService.clearUserAndToken();
      }
      _user = null;
      _token = null;
      _isAuthenticated = false;
      _loginErrorMessage = e.toString().replaceAll('Exception: ', '');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update profil
  Future<bool> updateUserProfile({
    required String nama,
    String? email,
    File? fotoProfil,
    String? paymentMethod,
  }) async {
    if (_user == null || _token == null || _token!.isEmpty) {
      print('User atau token tidak tersedia untuk update profil.');
      _loginErrorMessage = 'User tidak terautentikasi.';
      return false;
    }

    _isLoading = true;
    _loginErrorMessage = null;
    notifyListeners();
    try {
      final updatedUser = await AuthService.updateProfile(
        token: _token!,
        nama: nama,
        email: email,
        fotoProfil: fotoProfil,
        paymentMethod: paymentMethod,
      );

      _user = updatedUser;
      print('✅ Profil berhasil diupdate di AuthProvider: ${_user!.nama}');
      return true;
    } catch (e) {
      print('❌ Gagal update profil di AuthProvider: $e');
      _loginErrorMessage = e.toString().replaceAll('Exception: ', '');
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
    if (_token == null || _token!.isEmpty) {
      throw Exception('Token tidak tersedia untuk ganti password');
    }

    _isLoading = true;
    _loginErrorMessage = null;
    notifyListeners();
    try {
      final success = await AuthService.changePassword(
        token: _token!,
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      return success;
    } catch (e) {
      print('❌ Gagal ganti password di AuthProvider: $e');
      _loginErrorMessage = e.toString().replaceAll('Exception: ', '');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Restore session dari SharedPreferences
  Future<bool> tryAutoLogin() async {
    _isLoading = true;
    _loginErrorMessage = null;
    notifyListeners();

    try {
      final savedUser = await AuthService.getUserAndToken();

      if (savedUser != null &&
          savedUser.token != null &&
          savedUser.token!.isNotEmpty) {
        _user = savedUser;
        _token = savedUser.token;
        _isAuthenticated = true;
        print('✅ Auto login berhasil untuk user: ${_user!.email}');
        return true;
      } else {
        await AuthService.clearUserAndToken();
        _isAuthenticated = false;
        print('❌ Auto login gagal: Tidak ada user atau token yang valid.');
        return false;
      }
    } catch (e) {
      print("❌ Auto login gagal karena kesalahan: $e");
      await AuthService.clearUserAndToken();
      _isAuthenticated = false;
      _loginErrorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Metode setUser
  void setUser(User user, String token) {
    _user = user;
    _token = token;
    _isAuthenticated = true;
    _loginErrorMessage = null;
    notifyListeners();
  }
}