// import 'package:flutter/material.dart';
// import 'dart:async';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:provider/provider.dart';
// import 'package:travelapp/providers/auth_provider.dart';
// import 'package:travelapp/providers/wishlist_provider.dart';
// import 'package:travelapp/screens/user/home_screen.dart';
// import 'package:travelapp/screens/admin/dashboard_screen.dart';
// import 'package:travelapp/screens/auth/login_screen.dart';
// import 'package:travelapp/models/user.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen>
//     with TickerProviderStateMixin {
//   late AnimationController _planeController;
//   late AnimationController _textController;
//   late AnimationController _loadingController;

//   late Animation<double> _planeAnimation;
//   late Animation<double> _textFadeAnimation;
//   late Animation<Offset> _textSlideAnimation;

//   String _debugText = "Initializing...";

//   @override
//   void initState() {
//     super.initState();
//     print("🚀 SplashScreen initState called");
//     _initAnimations();
//     _startAnimations();
//     _checkLoginStatus();
//   }

//   void _initAnimations() {
//     print("🎭 Initializing animations");
//     setState(() {
//       _debugText = "Setting up animations...";
//     });

//     _planeController = AnimationController(
//       duration: const Duration(seconds: 2),
//       vsync: this,
//     );

//     _planeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _planeController, curve: Curves.bounceOut),
//     );

//     _textController = AnimationController(
//       duration: const Duration(milliseconds: 1000),
//       vsync: this,
//     );

//     _textFadeAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(_textController);

//     _textSlideAnimation = Tween<Offset>(
//       begin: const Offset(0, 0.3),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));

//     _loadingController = AnimationController(
//       duration: const Duration(seconds: 1),
//       vsync: this,
//     );
//   }

//   void _startAnimations() {
//     _planeController.forward();
//     Timer(const Duration(milliseconds: 500), () {
//       if (mounted) _textController.forward();
//     });
//     Timer(const Duration(milliseconds: 1000), () {
//       if (mounted) _loadingController.repeat();
//     });
//   }

//   Future<void> _checkLoginStatus() async {
//     // Minimal tampil splash 3 detik
//     await Future.delayed(const Duration(seconds: 3));

//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('auth_token');
//     final nama = prefs.getString('user_nama');
//     final email = prefs.getString('user_email');
//     final role = prefs.getString('user_role');

//     print("🔑 Token: ${token != null ? 'Found' : 'Not found'}");

//     setState(() {
//       _debugText = "Login check complete...";
//     });

//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     final wishlistProvider = Provider.of<WishlistProvider>(
//       context,
//       listen: false,
//     );

//     if (token != null && nama != null && email != null) {
//       // Set user dan token di provider
//       final user = User(id: null, nama: nama, email: email, role: role);
//       authProvider.setUser(user, token);

//       // Refresh data user dari API agar data lengkap
//       try {
//         await authProvider.getCurrentUser();
//       } catch (e) {
//         print('❌ Error saat refresh user: $e');
//       }

//       // Update token wishlist dan load wishlist user
//       wishlistProvider.updateToken(token);
//       try {
//         await wishlistProvider.loadWishlist();
//       } catch (e) {
//         print('❌ Error saat load wishlist: $e');
//       }

//       if (!mounted) return;
//       print(
//         "👤 User found, navigating to ${role == 'admin' ? 'Dashboard' : 'Home'}",
//       );
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder:
//               (_) =>
//                   (role == 'admin')
//                       ? const DashboardScreen()
//                       : const HomeScreen(),
//         ),
//       );
//     } else {
//       print("🔓 No user found, navigating to Login");
//       if (!mounted) return;
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => const LoginScreen()),
//       );
//     }
//   }

//   @override
//   void dispose() {
//     print("🗑️ SplashScreen disposed");
//     _planeController.dispose();
//     _textController.dispose();
//     _loadingController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     print("🏗️ SplashScreen build called");

//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [Color(0xFF4FC3F7), Color(0xFF29B6F6), Color(0xFF03A9F4)],
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 child: Text(
//                   _debugText,
//                   style: const TextStyle(color: Colors.white, fontSize: 12),
//                 ),
//               ),
//               Expanded(
//                 child: Center(
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       AnimatedBuilder(
//                         animation: _planeController,
//                         builder: (context, child) {
//                           return Transform.scale(
//                             scale: _planeAnimation.value,
//                             child: Container(
//                               width: 120,
//                               height: 120,
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 shape: BoxShape.circle,
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.black.withOpacity(0.2),
//                                     blurRadius: 15,
//                                     offset: const Offset(0, 8),
//                                   ),
//                                 ],
//                               ),
//                               child: const Icon(
//                                 Icons.flight_takeoff,
//                                 size: 60,
//                                 color: Color(0xFF03A9F4),
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                       const SizedBox(height: 40),
//                       AnimatedBuilder(
//                         animation: _textController,
//                         builder: (context, child) {
//                           return SlideTransition(
//                             position: _textSlideAnimation,
//                             child: FadeTransition(
//                               opacity: _textFadeAnimation,
//                               child: const Column(
//                                 children: [
//                                   Text(
//                                     'Welcome to',
//                                     style: TextStyle(
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.w300,
//                                       color: Colors.white,
//                                       letterSpacing: 1.2,
//                                     ),
//                                   ),
//                                   SizedBox(height: 8),
//                                   Text(
//                                     'Travel App',
//                                     style: TextStyle(
//                                       fontSize: 32,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.white,
//                                       letterSpacing: 2.0,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                       const SizedBox(height: 40),
//                       AnimatedBuilder(
//                         animation: _loadingController,
//                         builder: (context, child) {
//                           return Transform.rotate(
//                             angle: _loadingController.value * 2 * 3.14159,
//                             child: Container(
//                               width: 30,
//                               height: 30,
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 border: Border.all(
//                                   color: Colors.white,
//                                   width: 3,
//                                 ),
//                               ),
//                               child: const Icon(
//                                 Icons.flight,
//                                 size: 16,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:travelapp/providers/auth_provider.dart';
import 'package:travelapp/providers/wishlist_provider.dart';
import 'package:travelapp/screens/user/home_screen.dart';
import 'package:travelapp/screens/admin/dashboard_screen.dart';
import 'package:travelapp/screens/auth/login_screen.dart';
import 'package:travelapp/models/user.dart';
import 'dart:math' as Math;
import 'package:travelapp/services/auth_service.dart'; // <--- Tambahkan baris ini

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _loadingController;
  late AnimationController _backgroundController;

  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotationAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _backgroundAnimation;

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

    // Logo animations
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );

    _logoRotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeInOut),
      ),
    );

    // Text animations
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeInOut),
    );

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutBack),
    );

    // Loading animation
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Background animation
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );

    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.linear),
    );
  }

  void _startAnimations() {
    _logoController.forward();
    _backgroundController.repeat();

    Timer(const Duration(milliseconds: 500), () {
      if (mounted) _textController.forward();
    });

    Timer(const Duration(milliseconds: 1200), () {
      if (mounted) _loadingController.repeat();
    });
  }

  Future<void> _checkLoginStatus() async {
    // Minimal tampil splash 3 detik
    await Future.delayed(const Duration(seconds: 3));

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final nama = prefs.getString('user_nama');
    final email = prefs.getString('user_email');
    // HAPUS BARIS INI: final role = prefs.getString('user_role'); // Tidak relevan lagi

    print("🔑 Token: ${token != null ? 'Found' : 'Not found'}");

    setState(() {
      _debugText = "Login check complete...";
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final wishlistProvider = Provider.of<WishlistProvider>(
      context,
      listen: false,
    );

    // Pastikan kita punya nama dan email untuk inisialisasi awal AuthProvider
    // Meskipun getCurrentUser akan mengambil data lengkap, kita butuh User object awal
    // untuk setUser, yang mana membutuhkan nama dan email.
    // Untuk role, kita akan ambil dari authProvider.user setelah getCurrentUser().
    if (token != null && nama != null && email != null) {
      // Inisialisasi AuthProvider dengan data dasar yang ada di SharedPreferences
      // Role di sini sementara bisa null atau default, karena akan diperbarui oleh getCurrentUser()
      final userFromPrefs = User(
        id: null,
        nama: nama,
        email: email,
        role: null,
      ); // role diset null sementara
      authProvider.setUser(userFromPrefs, token);

      // Refresh data user dari API agar data lengkap dan terbaru
      try {
        await authProvider
            .getCurrentUser(); // Ini akan memperbarui authProvider._user
        print(
          '✅ Data user berhasil diperbarui dari API: ${authProvider.user?.email}, Role: ${authProvider.user?.role}',
        );
      } catch (e) {
        print('❌ Error saat refresh user dari API: $e');
        await AuthService.clearUserAndToken();
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
        return; // Penting: Hentikan eksekusi jika gagal refresh user
      }

      // Update token wishlist dan load wishlist user
      wishlistProvider.updateToken(token);
      try {
        await wishlistProvider.loadWishlist();
        print('✅ Wishlist berhasil dimuat.');
      } catch (e) {
        print('❌ Error saat load wishlist: $e');
      }

      if (!mounted) return;

      // AMBIL ROLE TERBARU DAN PALING AKURAT DARI AUTHPROVIDER.USER
      final currentRole = authProvider.user?.role;
      print(
        'DEBUG-NAV: Nilai string role dari provider yang digunakan untuk navigasi: "$currentRole"',
      );
      print(
        'DEBUG-NAV: Apakah role sama dengan "admin"? ${currentRole == 'admin'}',
      );

      print(
        "👤 User found, navigating to ${currentRole == 'admin' ? 'Dashboard' : 'Home'}", // Gunakan currentRole
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (_) =>
                  (currentRole == 'admin') // Gunakan currentRole di sini
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
    _logoController.dispose();
    _textController.dispose();
    _loadingController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("🏗️ SplashScreen build called");

    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(
                    const Color(0xFF667eea),
                    const Color(0xFF764ba2),
                    (_backgroundAnimation.value * 0.3).clamp(0.0, 1.0),
                  )!,
                  Color.lerp(
                    const Color(0xFF764ba2),
                    const Color(0xFFf093fb),
                    (_backgroundAnimation.value * 0.5).clamp(0.0, 1.0),
                  )!,
                  Color.lerp(
                    const Color(0xFFf093fb),
                    const Color(0xFFf5576c),
                    (_backgroundAnimation.value * 0.7).clamp(0.0, 1.0),
                  )!,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: Stack(
              children: [
                // Floating particles effect
                ...List.generate(6, (index) {
                  return Positioned(
                    left:
                        (index * 60.0 + 20) % MediaQuery.of(context).size.width,
                    top:
                        (index * 80.0 + 50) %
                        MediaQuery.of(context).size.height,
                    child: AnimatedBuilder(
                      animation: _backgroundController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(
                            20 *
                                Math.sin(
                                  _backgroundAnimation.value * 2 * Math.pi +
                                      index,
                                ),
                            20 *
                                Math.cos(
                                  _backgroundAnimation.value * 2 * Math.pi +
                                      index,
                                ),
                          ),
                          child: Opacity(
                            opacity:
                                0.1 +
                                (0.1 *
                                        Math.sin(
                                          _backgroundAnimation.value *
                                                  2 *
                                                  Math.pi +
                                              index,
                                        ))
                                    .abs(),
                            child: Container(
                              width: 40 + (index * 5),
                              height: 40 + (index * 5),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.1),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }),

                // Main content
                SafeArea(
                  child: Column(
                    children: [
                      // Debug text (you can remove this in production)
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          _debugText,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),

                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Logo with animations
                              AnimatedBuilder(
                                animation: _logoController,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: _logoScaleAnimation.value,
                                    child: Transform.rotate(
                                      angle: _logoRotationAnimation.value * 0.5,
                                      child: Container(
                                        width: 140,
                                        height: 140,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Colors.white,
                                              Colors.white.withOpacity(0.9),
                                            ],
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.15,
                                              ),
                                              blurRadius: 25,
                                              offset: const Offset(0, 10),
                                              spreadRadius: 5,
                                            ),
                                            BoxShadow(
                                              color: Colors.white.withOpacity(
                                                0.3,
                                              ),
                                              blurRadius: 15,
                                              offset: const Offset(0, -5),
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        ),
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            // Background pattern
                                            Container(
                                              width: 100,
                                              height: 100,
                                              child: CustomPaint(
                                                painter: TravelLogoPainter(),
                                              ),
                                            ),
                                            // Main travel icon
                                            Icon(
                                              Icons.public,
                                              size: 70,
                                              color: Color(0xFF667eea),
                                            ),
                                            // Accent icons
                                            Positioned(
                                              top: 20,
                                              right: 20,
                                              child: Icon(
                                                Icons.location_on,
                                                size: 20,
                                                color: Color(0xFFf5576c),
                                              ),
                                            ),
                                            Positioned(
                                              bottom: 25,
                                              left: 25,
                                              child: Icon(
                                                Icons.camera_alt,
                                                size: 16,
                                                color: Color(0xFF764ba2),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(height: 50),

                              // App title with animation
                              AnimatedBuilder(
                                animation: _textController,
                                builder: (context, child) {
                                  return SlideTransition(
                                    position: _textSlideAnimation,
                                    child: FadeTransition(
                                      opacity: _textFadeAnimation,
                                      child: Column(
                                        children: [
                                          Text(
                                            'Discover the World',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w300,
                                              color: Colors.white.withOpacity(
                                                0.9,
                                              ),
                                              letterSpacing: 1.5,
                                              shadows: [
                                                Shadow(
                                                  color: Colors.black
                                                      .withOpacity(0.2),
                                                  offset: const Offset(0, 2),
                                                  blurRadius: 4,
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            'Travel App',
                                            style: TextStyle(
                                              fontSize: 36,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              letterSpacing: 2.5,
                                              shadows: [
                                                Shadow(
                                                  color: Colors.black
                                                      .withOpacity(0.3),
                                                  offset: const Offset(0, 3),
                                                  blurRadius: 6,
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Container(
                                            height: 3,
                                            width: 80,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(2),
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.white.withOpacity(0.3),
                                                  Colors.white,
                                                  Colors.white.withOpacity(0.3),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(height: 60),

                              // Enhanced loading animation
                              AnimatedBuilder(
                                animation: _loadingController,
                                builder: (context, child) {
                                  return Container(
                                    width: 50,
                                    height: 50,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        // Rotating outer ring
                                        Transform.rotate(
                                          angle:
                                              _loadingController.value *
                                              2 *
                                              Math.pi,
                                          child: Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.white.withOpacity(
                                                  0.3,
                                                ),
                                                width: 2,
                                              ),
                                            ),
                                            child: CustomPaint(
                                              painter: LoadingRingPainter(
                                                progress:
                                                    _loadingController.value,
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Center compass icon
                                        Transform.rotate(
                                          angle:
                                              -_loadingController.value *
                                              2 *
                                              Math.pi *
                                              0.5,
                                          child: Icon(
                                            Icons.explore,
                                            size: 24,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Bottom tagline
                      Padding(
                        padding: const EdgeInsets.only(bottom: 40),
                        child: AnimatedBuilder(
                          animation: _textController,
                          builder: (context, child) {
                            return FadeTransition(
                              opacity: _textFadeAnimation,
                              child: Text(
                                'Your Adventure Starts Here',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white.withOpacity(0.8),
                                  letterSpacing: 1.0,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Custom painter for travel logo background
class TravelLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Color(0xFF667eea).withOpacity(0.1)
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 3;

    // Draw concentric circles
    for (int i = 1; i <= 3; i++) {
      canvas.drawCircle(center, radius * i / 3, paint);
    }

    // Draw cross lines
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter for loading ring
class LoadingRingPainter extends CustomPainter {
  final double progress;

  LoadingRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -Math.pi / 2,
      2 * Math.pi * 0.75,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Add this import at the top of the file
