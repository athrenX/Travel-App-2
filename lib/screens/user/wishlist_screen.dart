import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelapp/models/destinasi.dart';
import 'package:travelapp/providers/destinasi_provider.dart';
import 'package:travelapp/providers/wishlist_provider.dart';
import 'package:travelapp/screens/user/detail_destinasi_screen.dart';
import 'package:travelapp/widgets/destinasi_card.dart';

class WishlistScreen extends StatelessWidget {
  final String userId;
  final VoidCallback resetNavbarToHome;

  const WishlistScreen({
    Key? key,
    required this.userId,
    required this.resetNavbarToHome,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        resetNavbarToHome();
        return true;
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.blue),
              onPressed: () {
                resetNavbarToHome();
                Navigator.pop(context);
              },
            ),
          ),
          title: const Text(
            'Wishlist Saya',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Colors.white,
              shadows: [
                Shadow(
                  offset: Offset(1, 1),
                  blurRadius: 3.0,
                  color: Color.fromARGB(150, 0, 0, 0),
                ),
              ],
            ),
          ),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blue.shade800,
                  Colors.blue.shade800.withOpacity(0.0),
                ],
              ),
            ),
          ),
        ),
        body: _buildWishlistContent(context),
      ),
    );
  }

  Widget _buildWishlistContent(BuildContext context) {
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
                colors: [Colors.blue.shade50, Colors.white],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.favorite_border,
                      size: 80,
                      color: Colors.blue.shade300,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Wishlist Anda Kosong',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'Jelajahi destinasi dan tambahkan favorit Anda ke wishlist',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blueGrey.shade400,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    icon: const Icon(Icons.explore),
                    label: const Text(
                      'Jelajahi Destinasi',
                      style: TextStyle(fontSize: 16),
                    ),
                    onPressed: () {
                      resetNavbarToHome();
                      Navigator.pop(context);
                    },
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
              colors: [Colors.blue.shade100.withOpacity(0.5), Colors.white],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 100), // Give space for AppBar
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Text(
                    '${wishlistDestinasi.length} Destinasi Favorit',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade800,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: wishlistDestinasi.length,
                    itemBuilder: (ctx, index) {
                      final destinasi = wishlistDestinasi[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Container(
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
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

                                // Gradient overlay for better text visibility
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withOpacity(0.7),
                                        ],
                                        stops: const [0.6, 1.0],
                                      ),
                                    ),
                                  ),
                                ),

                                // Content overlay
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
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
                                              Text(
                                                destinasi.nama,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.location_on,
                                                    color: Colors.white70,
                                                    size: 16,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      destinasi.lokasi,
                                                      style: const TextStyle(
                                                        color: Colors.white70,
                                                        fontSize: 14,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Remove from wishlist button
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.2,
                                                ),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
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
                                                    content: Text(
                                                      '${destinasi.nama} dihapus dari wishlist',
                                                    ),
                                                    backgroundColor:
                                                        Colors.blue.shade700,
                                                    behavior:
                                                        SnackBarBehavior
                                                            .floating,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                    ),
                                                    action: SnackBarAction(
                                                      label: 'OK',
                                                      textColor: Colors.white,
                                                      onPressed: () {},
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  10,
                                                ),
                                                child: Icon(
                                                  Icons.favorite,
                                                  color: Colors.red.shade400,
                                                  size: 26,
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
                                      splashColor: Colors.white.withOpacity(
                                        0.1,
                                      ),
                                      highlightColor: Colors.transparent,
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
