import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:travelapp/providers/auth_provider.dart';
import 'package:travelapp/screens/user/home_screen.dart';
import 'package:travelapp/screens/admin/dashboard_screen.dart';
import 'package:travelapp/screens/auth/login_screen.dart';
import 'package:travelapp/models/user.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _planeController;
  late AnimationController _textController;
  late AnimationController _loadingController;

  late Animation<double> _planeAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;

  String _debugText = "Initializing...";

  @override
  void initState() {
    super.initState();
    print("🚀 SplashScreen initState called");
    _initAnimations();
    _startAnimations();
    _checkLoginStatus();
  }

  void _initAnimations() {
    print("🎭 Initializing animations");
    setState(() {
      _debugText = "Setting up animations...";
    });

    // Plane animation
    _planeController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _planeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _planeController, curve: Curves.bounceOut),
    );

    // Text animations
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_textController);

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    // Loading animation
    _loadingController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
  }

  void _startAnimations() {
    // Start plane animation
    _planeController.forward().then((_) {});

    // Start text animation after delay
    Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        _textController.forward().then((_) {});
      }
    });

    // Start loading animation
    Timer(const Duration(milliseconds: 1000), () {
      if (mounted) {
        _loadingController.repeat();
      }
    });
  }

  Future<void> _checkLoginStatus() async {
    // Wait for splash display
    await Future.delayed(const Duration(seconds: 3));

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final nama = prefs.getString('user_nama');
    final email = prefs.getString('user_email');
    final role = prefs.getString('user_role');

    print("🔑 Token: ${token != null ? 'Found' : 'Not found'}");
    setState(() {
      _debugText = "Login check complete...";
    });

    if (token != null && nama != null && email != null) {
      final user = User(id: null, nama: nama, email: email, role: role);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.setUser(user, token);

      print(
        "👤 User found, navigating to ${role == 'admin' ? 'Dashboard' : 'Home'}",
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (_) =>
                  (role == 'admin')
                      ? const DashboardScreen()
                      : const HomeScreen(),
        ),
      );
    } else {
      print("🔓 No user found, navigating to Login");
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    print("🗑️ SplashScreen disposed");
    _planeController.dispose();
    _textController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("🏗️ SplashScreen build called");

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4FC3F7), Color(0xFF29B6F6), Color(0xFF03A9F4)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Debug info
              Container(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _debugText,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),

              // Main content
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Animated Travel Icon
                      AnimatedBuilder(
                        animation: _planeController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _planeAnimation.value,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.flight_takeoff,
                                size: 60,
                                color: Color(0xFF03A9F4),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 40),

                      // Animated Text
                      AnimatedBuilder(
                        animation: _textController,
                        builder: (context, child) {
                          return SlideTransition(
                            position: _textSlideAnimation,
                            child: FadeTransition(
                              opacity: _textFadeAnimation,
                              child: const Column(
                                children: [
                                  Text(
                                    'Welcome to',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w300,
                                      color: Colors.white,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Travel App',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 2.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 40),

                      // Animated Loading Indicator
                      AnimatedBuilder(
                        animation: _loadingController,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _loadingController.value * 2 * 3.14159,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                              ),
                              child: const Icon(
                                Icons.flight,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
