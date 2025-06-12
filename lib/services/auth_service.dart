import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travelapp/models/user.dart';
import 'package:travelapp/config.dart';

class AuthService {
  static const String _baseUrl = AppConfig.baseUrl;

  static Future<Map<String, String>> _getHeaders({String? token}) async {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<void> saveUserAndToken(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', user.token ?? '');
    await prefs.setString('user_data', json.encode(user.toJson()));
    print('User dan token disimpan di SharedPreferences.');
  }

  static Future<User?> getUserAndToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final userDataString = prefs.getString('user_data');

    if (token != null && userDataString != null && token.isNotEmpty && userDataString.isNotEmpty) {
      try {
        final userMap = json.decode(userDataString) as Map<String, dynamic>;
        return User.fromJson(userMap).copyWith(token: token);
      } catch (e) {
        print('Error decoding user data from SharedPreferences: $e');
        await clearUserAndToken();
        return null;
      }
    }
    return null;
  }

  static Future<void> clearUserAndToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
    print('User dan token dihapus dari SharedPreferences.');
  }

  // --- Metode API Autentikasi ---

  static Future<User> register(String nama, String email, String password, String passwordConfirmation) async {
    final url = Uri.parse('$_baseUrl/api/register');
    try {
      final response = await http.post(
        url,
        headers: await _getHeaders(),
        body: json.encode({
          'nama': nama, // PENTING: Kirim sebagai 'nama' sesuai validasi Laravel Anda
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseData['success'] == true) {
          // PENTING: Akses 'data' terlebih dahulu, lalu 'user' dan 'token'
          final userMap = responseData['data']['user'] as Map<String, dynamic>;
          final token = responseData['data']['token'] as String;
          final user = User.fromJson(userMap).copyWith(token: token);
          await saveUserAndToken(user);
          return user;
        } else {
          throw Exception('Failed to register: ${responseData['message'] ?? 'Unknown error.'}');
        }
      } else {
        if (response.statusCode == 422) {
          final errors = responseData['errors'] as Map<String, dynamic>;
          String validationMessage = 'Validation failed: ';
          errors.forEach((key, value) {
            validationMessage += '${key}: ${(value as List).join(', ')}. ';
          });
          throw Exception(validationMessage);
        } else {
          throw Exception('Failed to register. Status code: ${response.statusCode}. Message: ${responseData['message'] ?? response.body}');
        }
      }
    } catch (e) {
      print('Error during registration in AuthService: $e');
      rethrow;
    }
  }

  static Future<User> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/api/login');
    try {
      final response = await http.post(
        url,
        headers: await _getHeaders(),
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        if (responseData['success'] == true) { // PENTING: Backend Anda menggunakan 'success' bukan 'status' untuk login
          // PENTING: Akses 'data' terlebih dahulu, lalu 'user' dan 'token'
          final userMap = responseData['data']['user'] as Map<String, dynamic>;
          final token = responseData['data']['token'] as String;
          final user = User.fromJson(userMap).copyWith(token: token);
          await saveUserAndToken(user);
          return user; // Langsung return user jika sukses
        } else {
          // Jika status code 200 tapi 'success' bukan true
          throw Exception('Failed to login: ${responseData['message'] ?? 'Unknown response status.'}');
        }
      } else {
        // Tangani error berdasarkan status code
        if (response.statusCode == 401) {
          throw Exception('Unauthorized: ${responseData['message'] ?? 'Invalid credentials.'}');
        } else if (response.statusCode == 422) { // Tambahkan penanganan 422 untuk login jika ada
            final errors = responseData['errors'] as Map<String, dynamic>;
            String validationMessage = 'Validation failed: ';
            errors.forEach((key, value) {
                validationMessage += '${key}: ${(value as List).join(', ')}. ';
            });
            throw Exception(validationMessage);
        }
        else {
          throw Exception('Failed to login. Status code: ${response.statusCode}. Message: ${responseData['message'] ?? response.body}');
        }
      }
    } catch (e) {
      print('Error during login in AuthService: $e');
      rethrow;
    }
  }

  static Future<void> logout(String token) async {
    final url = Uri.parse('$_baseUrl/api/logout');
    try {
      await http.post(
        url,
        headers: await _getHeaders(token: token),
      );
    } catch (e) {
      print('Error during logout API call: $e');
    } finally {
      await clearUserAndToken();
    }
  }

  static Future<User> getCurrentUser(String token) async {
    final url = Uri.parse('$_baseUrl/api/user');
    try {
      final response = await http.get(
        url,
        headers: await _getHeaders(token: token),
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        if (responseData['success'] == true) { // PENTING: 'success'
            final userMap = responseData['data']['user'] as Map<String, dynamic>; // PENTING: 'data' lalu 'user'
            return User.fromJson(userMap).copyWith(token: token);
        } else {
            throw Exception('Failed to fetch user data: ${responseData['message'] ?? 'Unknown status.'}');
        }
      } else if (response.statusCode == 401) {
        await clearUserAndToken();
        throw Exception('Unauthenticated: Token is invalid or expired.');
      } else {
        throw Exception('Failed to fetch user data. Status code: ${response.statusCode}, Message: ${responseData['message'] ?? response.body}');
      }
    } catch (e) {
      print('Error fetching current user data in AuthService: $e');
      rethrow;
    }
  }

  static Future<User> updateProfile({
    required String token,
    required String nama, // PENTING: Menerima 'nama'
    String? email,
    File? fotoProfil,
    String? paymentMethod,
  }) async {
    final url = Uri.parse('$_baseUrl/api/update-profile');

    if (fotoProfil != null) {
      var request = http.MultipartRequest('POST', url);
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });
      request.fields['nama'] = nama; // PENTING: Kirim sebagai 'nama'
      if (email != null) request.fields['email'] = email;
      if (paymentMethod != null) request.fields['payment_method'] = paymentMethod;

      request.files.add(await http.MultipartFile.fromPath(
        'foto_profil',
        fotoProfil.path,
      ));

      try {
        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (response.statusCode == 200) {
          if (responseData['success'] == true) { // PENTING: 'success'
            final updatedUserMap = responseData['data']['user'] as Map<String, dynamic>; // PENTING: 'data' lalu 'user'
            final updatedUser = User.fromJson(updatedUserMap).copyWith(token: token);
            await saveUserAndToken(updatedUser);
            return updatedUser;
          } else {
            throw Exception('Failed to update profile (multipart): ${responseData['message']}');
          }
        } else {
          final errors = responseData['errors'] ?? {};
          String errorMessage = 'Failed to update profile (multipart). Status: ${response.statusCode}. ';
          errors.forEach((key, value) {
            errorMessage += '${key}: ${value.join(', ')}. ';
          });
          throw Exception(errorMessage);
        }
      } catch (e) {
        print('Error updating profile (multipart) in AuthService: $e');
        rethrow;
      }
    } else {
      try {
        final response = await http.post(
          url,
          headers: await _getHeaders(token: token),
          body: json.encode({
            'nama': nama, // PENTING: Kirim sebagai 'nama'
            'email': email,
            'payment_method': paymentMethod,
          }),
        );

        final Map<String, dynamic> responseData = json.decode(response.body);

        if (response.statusCode == 200) {
          if (responseData['success'] == true) { // PENTING: 'success'
            final updatedUserMap = responseData['data']['user'] as Map<String, dynamic>; // PENTING: 'data' lalu 'user'
            final updatedUser = User.fromJson(updatedUserMap).copyWith(token: token);
            await saveUserAndToken(updatedUser);
            return updatedUser;
          } else {
            throw Exception('Failed to update profile: ${responseData['message']}');
          }
        } else {
          final errors = responseData['errors'] ?? {};
          String errorMessage = 'Failed to update profile. Status: ${response.statusCode}. ';
          errors.forEach((key, value) {
            errorMessage += '${key}: ${value.join(', ')}. ';
          });
          throw Exception(errorMessage);
        }
      } catch (e) {
        print('Error updating profile in AuthService: $e');
        rethrow;
      }
    }
  }

  static Future<bool> changePassword({
    required String token,
    required String oldPassword,
    required String newPassword,
  }) async {
    final url = Uri.parse('$_baseUrl/api/change-password');
    try {
      final response = await http.post(
        url,
        headers: await _getHeaders(token: token),
        body: json.encode({
          'old_password': oldPassword,
          'new_password': newPassword,
          'new_password_confirmation': newPassword,
        }),
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        if (responseData['success'] == true) { // PENTING: 'success'
          return true;
        } else {
          throw Exception('Failed to change password: ${responseData['message']}');
        }
      } else {
        final errors = responseData['errors'] ?? {};
        String errorMessage = 'Failed to change password. Status: ${response.statusCode}. ';
        errors.forEach((key, value) {
          errorMessage += '${key}: ${value.join(', ')}. ';
        });
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Error changing password in AuthService: $e');
      rethrow;
    }
  }
}