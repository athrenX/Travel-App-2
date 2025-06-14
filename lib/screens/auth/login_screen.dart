import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelapp/providers/auth_provider.dart';
import 'package:travelapp/screens/admin/dashboard_screen.dart';
import 'package:travelapp/screens/auth/register_screen.dart';
import 'package:travelapp/screens/user/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travelapp/providers/wishlist_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _displayErrorMessage; // Variabel lokal untuk pesan error yang ditampilkan
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _getDisplayErrorMessage(String rawError) {
    String normalizedError = rawError.toLowerCase().trim();

    if (normalizedError.contains('format email') || normalizedError.contains('email tidak valid')) {
      return 'Format email tidak valid';
    } else if (normalizedError.contains('invalid credentials') || // Pesan dari Laravel
               normalizedError.contains('unauthorized') ||
               normalizedError.contains('these credentials do not match our records') ||
               normalizedError.contains('email atau password salah') ||
               normalizedError.contains('user not found') || // Dari manual check di backend
               normalizedError.contains('wrong password')) { // Dari manual check di backend
      return 'Email atau password salah';
    } else if (normalizedError.contains('email belum terdaftar')) { // Jika ada pesan spesifik ini
      return 'Email belum terdaftar. Silakan daftar terlebih dahulu';
    } else if (normalizedError.contains('akun dinonaktifkan')) {
      return 'Akun Anda telah dinonaktifkan. Hubungi administrator';
    } else if (normalizedError.contains('terlalu banyak percobaan')) {
      return 'Terlalu banyak percobaan login. Coba lagi dalam beberapa menit';
    } else if (normalizedError.contains('koneksi') || normalizedError.contains('network') || normalizedError.contains('timeout')) {
      return 'Periksa koneksi internet Anda dan coba lagi';
    } else if (normalizedError.contains('server') || normalizedError.contains('internal error') || normalizedError.contains('500')) { // Tambahkan 500
      return 'Terjadi gangguan pada server. Coba lagi nanti';
    } else {
      return 'Login gagal. Periksa email dan password Anda.';
    }
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _displayErrorMessage = null; // Reset pesan error sebelum mencoba login
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      try {
        final success = await authProvider.login(
          _emailController.text.trim(),
          _passwordController.text,
        );

        if (success) {
          final user = authProvider.user;
          if (user != null && authProvider.token != null) {
            final wishlistProvider = Provider.of<WishlistProvider>(context, listen: false,);
            wishlistProvider.updateToken(authProvider.token);
            await wishlistProvider.loadWishlist();

            if (mounted) {
              if (user.role == 'admin') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const DashboardScreen()),
                );
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                );
              }
            }
          } else {
            setState(() {
              _displayErrorMessage = 'Gagal mengambil data user setelah login.';
            });
          }
        } else {
          // Jika login gagal (return false dari authProvider.login)
          setState(() {
            _displayErrorMessage = _getDisplayErrorMessage(authProvider.loginErrorMessage ?? 'Login gagal. Error tidak diketahui.');
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _displayErrorMessage = _getDisplayErrorMessage(e.toString().replaceAll('Exception: ', ''));
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isLoading = authProvider.isLoading;
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    final isTablet = size.width > 600;
    final isDesktop = size.width > 1024;
    final isSmallScreen = size.height < 700;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A237E), Color(0xFF3949AB), Color(0xFF3F51B5)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: Container(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 32 : (isTablet ? 40 : 24),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: isSmallScreen ? 20 : size.height * 0.08),
                      Container(
                        padding: EdgeInsets.all(isTablet ? 24 : 16),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).scaffoldBackgroundColor.withOpacity(0.15),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.travel_explore,
                          size: isTablet ? 80 : (isSmallScreen ? 50 : 60),
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 12 : 20),
                      Text(
                        'Travel App',
                        style: TextStyle(
                          fontSize: isTablet ? 40 : (isSmallScreen ? 28 : 32),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 4 : 8),
                      Text(
                        'Jelajahi dunia bersama kami',
                        style: TextStyle(
                          fontSize: isTablet ? 18 : (isSmallScreen ? 14 : 16),
                          color: Theme.of(
                            context,
                          ).scaffoldBackgroundColor.withOpacity(0.8),
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 20 : size.height * 0.06),
                      Container(
                        width:
                            isDesktop
                                ? 500
                                : (isTablet ? 400 : double.infinity),
                        padding: EdgeInsets.all(isTablet ? 32 : 24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: isTablet ? 28 : 24,
                                  fontWeight: FontWeight.bold,
                                  color: theme.primaryColor,
                                ),
                              ),
                              SizedBox(height: isTablet ? 32 : 24),
                              TextFormField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  hintText: 'Masukkan email Anda',
                                  prefixIcon: const Icon(Icons.email_outlined),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: theme.primaryColor,
                                      width: 2,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.red.shade300,
                                    ),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.red.shade500,
                                      width: 2,
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: isTablet ? 20 : 16,
                                    horizontal: 16,
                                  ),
                                ),
                                style: TextStyle(fontSize: isTablet ? 16 : 14),
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Email tidak boleh kosong';
                                  }
                                  final emailRegex = RegExp(
                                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                  );
                                  if (!emailRegex.hasMatch(value)) {
                                    return 'Format email tidak valid';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: isTablet ? 24 : 20),
                              TextFormField(
                                controller: _passwordController,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  hintText: 'Masukkan password Anda',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isPasswordVisible
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: theme.primaryColor,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isPasswordVisible =
                                            !_isPasswordVisible;
                                      });
                                    },
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: theme.primaryColor,
                                      width: 2,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.red.shade300,
                                    ),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.red.shade500,
                                      width: 2,
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: isTablet ? 20 : 16,
                                    horizontal: 16,
                                  ),
                                ),
                                style: TextStyle(fontSize: isTablet ? 16 : 14),
                                obscureText: !_isPasswordVisible,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Password tidak boleh kosong';
                                  }
                                  return null;
                                },
                              ),
                              // Error message (menggunakan _displayErrorMessage)
                              if (_displayErrorMessage != null) ...[
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.red.shade200,
                                    ),
                                  ),
                                  child: Text(
                                    _displayErrorMessage!, // Tampilkan pesan error lokal
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontSize: isTablet ? 15 : 14,
                                    ),
                                  ),
                                ),
                              ],
                              SizedBox(height: isTablet ? 32 : 24),
                              // Login button
                              ElevatedButton(
                                onPressed: isLoading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    vertical: isTablet ? 20 : 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                  shadowColor: theme.primaryColor.withOpacity(
                                    0.5,
                                  ),
                                ),
                                child:
                                    isLoading
                                        ? SizedBox(
                                            height: isTablet ? 24 : 20,
                                            width: isTablet ? 24 : 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color:
                                                  Theme.of(context).scaffoldBackgroundColor,
                                            ),
                                          )
                                        : Text(
                                            'LOGIN',
                                            style: TextStyle(
                                              fontSize: isTablet ? 18 : 16,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1.5,
                                            ),
                                          ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 16 : 20),
                      Container(
                        width:
                            isDesktop
                                ? 500
                                : (isTablet ? 400 : double.infinity),
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RegisterScreen(),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              vertical: isTablet ? 16 : 12,
                            ),
                          ),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              text: 'Belum punya akun? ',
                              style: TextStyle(
                                fontSize: isTablet ? 18 : 16,
                                color: Colors.white70,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Daftar sekarang',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).scaffoldBackgroundColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: isTablet ? 18 : 16,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 20 : 40),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}