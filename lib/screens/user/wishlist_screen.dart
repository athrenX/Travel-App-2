import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelapp/providers/auth_provider.dart';
import 'package:travelapp/providers/destinasi_provider.dart';
import 'package:travelapp/providers/wishlist_provider.dart';
import 'package:travelapp/screens/user/detail_destinasi_screen.dart';
import 'package:travelapp/widgets/destinasi_card.dart';

class WishlistScreen extends StatefulWidget {
  final VoidCallback resetNavbarToHome;

  const WishlistScreen({super.key, required this.resetNavbarToHome});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  @override
  void initState() {
    super.initState();
    // Cek autentikasi setelah widget selesai di-build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _checkAuthentication();
      }
    });
  }

  void _checkAuthentication() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (!authProvider.isAuthenticated) {
      // Redirect ke halaman login jika belum login
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  void _handleBackNavigation(BuildContext context) {
    widget.resetNavbarToHome(); // cukup ubah index navbar
    Navigator.pop(context); // kembali ke HomeScreen dengan natural
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Jika belum login, tampilkan loading atau kosong
        if (!authProvider.isInitialized || authProvider.isLoading) {
          return Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blue.shade50, Colors.indigo.shade50],
                ),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Memuat...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (!authProvider.isAuthenticated) {
          return Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blue.shade50, Colors.indigo.shade50],
                ),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_outline, size: 64, color: Colors.blueGrey),
                    SizedBox(height: 16),
                    Text(
                      'Silakan login terlebih dahulu',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Jika sudah login, ambil userId dari AuthProvider
        final userId = authProvider.user?.id;

        if (userId == null) {
          return Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.red.shade50, Colors.orange.shade50],
                ),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.redAccent,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Error: User ID tidak ditemukan',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: false, // Menghilangkan tombol back
            title: const Text(
              'Wishlist Saya',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 26,
                color: Colors.white,
                letterSpacing: 0.5,
                shadows: [
                  Shadow(
                    offset: Offset(0, 2),
                    blurRadius: 8.0,
                    color: Color.fromARGB(120, 0, 0, 0),
                  ),
                ],
              ),
            ),
            centerTitle: true,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blue.shade700,
                    Colors.indigo.shade600,
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          body: _buildWishlistContent(context, userId),
        );
      },
    );
  }

  Widget _buildWishlistContent(BuildContext context, String userId) {
    return Consumer2<WishlistProvider, DestinasiProvider>(
      builder: (context, wishlistProvider, destinasiProvider, _) {
        final userWishlists = wishlistProvider.getWishlistsByUser(userId);
        final wishlistDestinasi =
            destinasiProvider.destinasiList.where((destinasi) {
              return userWishlists.any(
                (wishlist) => wishlist.destinasiId == destinasi.id,
              );
            }).toList();

        if (wishlistDestinasi.isEmpty) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blue.shade50.withOpacity(0.8),
                  Colors.indigo.shade50.withOpacity(0.6),
                  Colors.white,
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.15),
                          blurRadius: 30,
                          spreadRadius: 10,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.blue.shade100,
                            Colors.indigo.shade100,
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.favorite_border_rounded,
                        size: 80,
                        color: Colors.blue.shade600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Wishlist Anda Kosong',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: Text(
                      'Jelajahi destinasi menakjubkan dan tambahkan favorit Anda ke wishlist untuk perjalanan impian',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blueGrey.shade500,
                        height: 1.5,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.blue.shade600, Colors.indigo.shade600],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      icon: const Icon(Icons.explore_rounded, size: 24),
                      label: const Text(
                        'Jelajahi Destinasi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      onPressed: () => _handleBackNavigation(context),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.blue.shade50.withOpacity(0.3),
                Colors.indigo.shade50.withOpacity(0.2),
                Colors.white,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 120), // Give space for AppBar
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(
                          context,
                        ).scaffoldBackgroundColor.withOpacity(0.9),
                        Colors.blue.shade50.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade600,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.favorite,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${wishlistDestinasi.length} Destinasi Favorit',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    itemCount: wishlistDestinasi.length,
                    itemBuilder: (ctx, index) {
                      final destinasi = wishlistDestinasi[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Container(
                          height: 220,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                                spreadRadius: 2,
                              ),
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.1),
                                blurRadius: 30,
                                offset: const Offset(0, 15),
                                spreadRadius: -5,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                // Destination Card Content
                                Hero(
                                  tag: 'destinasi-${destinasi.id}',
                                  child: DestinasiCard(
                                    destinasi: destinasi,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) =>
                                                  DetailDestinasiScreen(
                                                    destinasi: destinasi,
                                                  ),
                                        ),
                                      );
                                    },
                                  ),
                                ),

                                // Enhanced gradient overlay
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withOpacity(0.2),
                                          Colors.black.withOpacity(0.8),
                                        ],
                                        stops: const [0.0, 0.5, 1.0],
                                      ),
                                    ),
                                  ),
                                ),

                                // Content overlay with enhanced design
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withOpacity(0.8),
                                        ],
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Destination info
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const SizedBox(height: 8),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .scaffoldBackgroundColor
                                                      .withOpacity(0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  border: Border.all(
                                                    color: Theme.of(context)
                                                        .scaffoldBackgroundColor
                                                        .withOpacity(0.3),
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const Icon(
                                                      Icons.location_on_rounded,
                                                      color: Colors.white,
                                                      size: 16,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Flexible(
                                                      child: Text(
                                                        destinasi.lokasi,
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                        maxLines: 1,
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        const SizedBox(width: 16),

                                        // Enhanced remove from wishlist button
                                        Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                Theme.of(
                                                  context,
                                                ).scaffoldBackgroundColor,
                                                Colors.grey.shade50,
                                              ],
                                            ),
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.2,
                                                ),
                                                blurRadius: 8,
                                                offset: const Offset(0, 4),
                                              ),
                                              BoxShadow(
                                                color: Theme.of(context)
                                                    .scaffoldBackgroundColor
                                                    .withOpacity(0.8),
                                                blurRadius: 8,
                                                offset: const Offset(-2, -2),
                                              ),
                                            ],
                                          ),
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              customBorder:
                                                  const CircleBorder(),
                                              onTap: () {
                                                wishlistProvider
                                                    .removeFromWishlist(
                                                      destinasi.id,
                                                    );
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Row(
                                                      children: [
                                                        const Icon(
                                                          Icons.check_circle,
                                                          color: Colors.white,
                                                          size: 20,
                                                        ),
                                                        const SizedBox(
                                                          width: 12,
                                                        ),
                                                        Expanded(
                                                          child: Text(
                                                            '${destinasi.nama} dihapus dari wishlist',
                                                            style:
                                                                const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    backgroundColor:
                                                        Colors.blue.shade600,
                                                    behavior:
                                                        SnackBarBehavior
                                                            .floating,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            15,
                                                          ),
                                                    ),
                                                    margin:
                                                        const EdgeInsets.all(
                                                          16,
                                                        ),
                                                    action: SnackBarAction(
                                                      label: 'OK',
                                                      textColor:
                                                          Theme.of(
                                                            context,
                                                          ).scaffoldBackgroundColor,
                                                      onPressed: () {},
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  5,
                                                ),
                                                child: Icon(
                                                  Icons.favorite_rounded,
                                                  color: Colors.red.shade500,
                                                  size: 28,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Clickable overlay
                                Positioned.fill(
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      splashColor: Theme.of(context)
                                          .scaffoldBackgroundColor
                                          .withOpacity(0.1),
                                      highlightColor: Theme.of(context)
                                          .scaffoldBackgroundColor
                                          .withOpacity(0.05),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    DetailDestinasiScreen(
                                                      destinasi: destinasi,
                                                    ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
