import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import 'package:http_parser/http_parser.dart' as http_parser;

class AuthService {
  // Ganti dengan IP server Laravel Anda
  final String baseUrl = 'http://192.168.1.8:8000/api';

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print('🔐 Attempting login for: $email');

      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}),
      );

      print('📥 Login response status: ${response.statusCode}');
      print('📥 Login response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'user': User.fromJson(data['data']['user'] ?? data['user']),
          'token': data['data']['token'] ?? data['token'],
        };
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Login gagal');
      }
    } catch (e) {
      print('❌ Login error: $e');
      rethrow;
    }
  }

  // Register method yang mengembalikan user dan token
  Future<Map<String, dynamic>> register(
    String nama,
    String email,
    String password,
  ) async {
    try {
      print('📝 Attempting register for: $email');

      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'nama': nama, 'email': email, 'password': password}),
      );

      print('📥 Register response status: ${response.statusCode}');
      print('📥 Register response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return {
          'user': User.fromJson(data['data']['user'] ?? data['user']),
          'token': data['data']['token'] ?? data['token'],
        };
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Registrasi gagal');
      }
    } catch (e) {
      print('❌ Register error: $e');
      rethrow;
    }
  }

  // Get current user
  Future<User> getCurrentUser(String token) async {
    try {
      print('👤 Getting current user with token: ${token.substring(0, 20)}...');

      final response = await http.get(
        Uri.parse('$baseUrl/user'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📥 getCurrentUser response status: ${response.statusCode}');
      print('📥 getCurrentUser response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data['user'] ?? data);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthenticated');
      } else {
        throw Exception('Failed to get current user');
      }
    } catch (e) {
      print('❌ Get current user error: $e');
      rethrow;
    }
  }

  // Logout
  Future<void> logout(String token) async {
    try {
      print('🚪 Attempting logout...');

      final response = await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📥 Logout response status: ${response.statusCode}');

      if (response.statusCode != 200) {
        print('⚠️ Logout warning: ${response.body}');
      }
    } catch (e) {
      print('❌ Logout error: $e');
      // Don't rethrow logout errors - allow logout to proceed
    }
  }

  // Update profile dengan authentication header
  Future<User> updateProfile({
    required String token,
    String? nama,
    String? email,
    File? fotoProfil,
    String? paymentMethod,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/update-profile');
      final request = http.MultipartRequest('POST', uri);

      // Headers dengan authentication
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      // Log data yang dikirim
      print('🔄 Sending updateProfile request =>');
      print('   ➤ nama: $nama');
      print('   ➤ email: $email');
      print('   ➤ foto: ${fotoProfil?.path}');
      print('   ➤ token: ${token.substring(0, 20)}...');

      // Field nama
      if (nama != null && nama.isNotEmpty) {
        request.fields['nama'] = nama;
      }

      // Field email
      if (email != null && email.isNotEmpty) {
        request.fields['email'] = email;
      }
      // Field payment_method
      if (paymentMethod != null && paymentMethod.isNotEmpty) {
        request.fields['payment_method'] = paymentMethod;
      }

      // Upload file foto_profil
      if (fotoProfil != null && await fotoProfil.exists()) {
        try {
          final fileName = fotoProfil.path.split(Platform.pathSeparator).last;
          final fileBytes = await fotoProfil.readAsBytes();

          // Validasi file
          if (fileBytes.isEmpty) {
            print('⚠️ File foto kosong');
          } else {
            print('📁 File size: ${fileBytes.length} bytes');

            // Determine content type based on file extension
            String contentType = 'image/jpeg';
            if (fileName.toLowerCase().endsWith('.png')) {
              contentType = 'image/png';
            } else if (fileName.toLowerCase().endsWith('.jpg') ||
                fileName.toLowerCase().endsWith('.jpeg')) {
              contentType = 'image/jpeg';
            }

            final file = http.MultipartFile.fromBytes(
              'foto_profil',
              fileBytes,
              filename: fileName,
              contentType: http_parser.MediaType.parse(contentType),
            );
            request.files.add(file);
          }
        } catch (e) {
          print('❌ Error reading file: $e');
        }
      }

      // Kirim request
      print('📤 Sending request to: $uri');
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: $responseBody');

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);

        // Handle different response formats
        if (data.containsKey('user')) {
          return User.fromJson(data['user']);
        } else if (data.containsKey('data')) {
          return User.fromJson(data['data']);
        } else {
          return User.fromJson(data);
        }
      } else {
        try {
          final error = jsonDecode(responseBody);
          String errorMessage = error['message'] ?? 'Gagal memperbarui profil';

          // Handle validation errors
          if (error.containsKey('errors')) {
            final errors = error['errors'] as Map<String, dynamic>;
            final errorList = <String>[];
            errors.forEach((key, value) {
              if (value is List) {
                errorList.addAll(value.cast<String>());
              } else {
                errorList.add(value.toString());
              }
            });
            errorMessage = errorList.join(', ');
          }

          throw Exception(errorMessage);
        } catch (e) {
          if (e is Exception) rethrow;
          throw Exception(
            'Gagal update profil. Status: ${response.statusCode}',
          );
        }
      }
    } catch (e) {
      print('❌ Update profile error: $e');
      rethrow;
    }
  }

  // Change password
  // Change password
  Future<bool> changePassword({
    required String token,
    required String oldPassword,
    required String newPassword,
  }) async {
    final response = await http.post(
      Uri.parse(
        '$baseUrl/change-password',
      ), // ini sudah benar (tanpa /api lagi)
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
      body: {
        'old_password': oldPassword,
        'new_password': newPassword,
        'new_password_confirmation': newPassword, // 🔥 Tambahkan ini!
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('❌ Change Password Response: ${response.body}');
      return false;
    }
  }
}
