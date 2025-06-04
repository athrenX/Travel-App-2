import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelapp/providers/auth_provider.dart';
import 'package:travelapp/screens/admin/dashboard_screen.dart';
import 'package:travelapp/screens/auth/register_screen.dart';
import 'package:travelapp/screens/user/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _getErrorMessage(String error) {
    // Normalisasi error message
    String normalizedError = error.toLowerCase().trim();

    // Mapping error messages ke bahasa Indonesia yang user-friendly
    if (normalizedError.contains('invalid email') ||
        normalizedError.contains('email not valid') ||
        normalizedError.contains('format email')) {
      return 'Format email tidak valid';
    } else if (normalizedError.contains('user not found') ||
        normalizedError.contains('akun tidak ditemukan') ||
        normalizedError.contains('email tidak terdaftar')) {
      return 'Email belum terdaftar. Silakan daftar terlebih dahulu';
    } else if (normalizedError.contains('wrong password') ||
        normalizedError.contains('password salah') ||
        normalizedError.contains('incorrect password') ||
        normalizedError.contains('invalid password')) {
      return 'Password yang Anda masukkan salah';
    } else if (normalizedError.contains('account disabled') ||
        normalizedError.contains('akun dinonaktifkan')) {
      return 'Akun Anda telah dinonaktifkan. Hubungi administrator';
    } else if (normalizedError.contains('too many attempts') ||
        normalizedError.contains('terlalu banyak percobaan')) {
      return 'Terlalu banyak percobaan login. Coba lagi dalam beberapa menit';
    } else if (normalizedError.contains('network') ||
        normalizedError.contains('connection') ||
        normalizedError.contains('koneksi')) {
      return 'Periksa koneksi internet Anda dan coba lagi';
    } else if (normalizedError.contains('server') ||
        normalizedError.contains('internal error')) {
      return 'Terjadi gangguan pada server. Coba lagi nanti';
    } else if (normalizedError.contains('timeout')) {
      return 'Koneksi timeout. Periksa jaringan Anda';
    } else if (normalizedError.contains('unauthorized') ||
        normalizedError.contains('tidak diizinkan')) {
      return 'Email atau password tidak valid';
    } else {
      // Jika error tidak dikenali, tampilkan pesan generic
      return 'Login gagal. Periksa email dan password Anda';
    }
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _errorMessage = null;
      });

      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final user = await authProvider.login(
          _emailController.text.trim(),
          _passwordController.text,
        );

        if (user != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', authProvider.token ?? '');
          await prefs.setString('user_nama', user.nama);
          await prefs.setString('user_email', user.email);

          // Arahkan ke screen yang sesuai dengan role
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
        } else {
          // Jika user null tapi tidak ada exception
          setState(() {
            _errorMessage = 'Email atau password tidak valid';
          });
        }
      } catch (e) {
        setState(() {
          String rawError = e.toString().replaceAll('Exception: ', '');
          _errorMessage = _getErrorMessage(rawError);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = Provider.of<AuthProvider>(context).isLoading;
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    // Responsive breakpoints
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
                      // Top spacing - responsive
                      SizedBox(height: isSmallScreen ? 20 : size.height * 0.08),

                      // Logo dan Judul - responsive sizing
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

                      // Form login - responsive width
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

                              // Email field
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
                                  // Validasi format email
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

                              // Password field
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

                              // Error message
                              if (_errorMessage != null) ...[
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
                                    _errorMessage!,
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
                                                Theme.of(
                                                  context,
                                                ).scaffoldBackgroundColor,
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

                      // Register button - responsive
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
                                        Theme.of(
                                          context,
                                        ).scaffoldBackgroundColor,
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

                      // Bottom spacing
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
