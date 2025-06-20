import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelapp/models/destinasi.dart';
import 'package:travelapp/providers/wishlist_provider.dart';
import 'package:travelapp/screens/user/pilih_waktu_keberangkatan_screen.dart'; // Import the new screen
import 'package:travelapp/screens/auth/login_screen.dart';
import 'package:travelapp/providers/auth_provider.dart';
// Import ReviewProvider dan model Review
import 'package:travelapp/providers/review_provider.dart';
import 'package:travelapp/models/review.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng2;
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:flutter/scheduler.dart'; // Penting untuk WidgetsBinding.instance.addPostFrameCallback
import 'package:geolocator/geolocator.dart';

// Asumsi Anda memiliki DestinasiProvider jika ingin me-refresh detail destinasi
// import 'package:travelapp/providers/destinasi_provider.dart';

class DetailDestinasiScreen extends StatefulWidget {
  final Destinasi destinasi;

  const DetailDestinasiScreen({super.key, required this.destinasi});

  @override
  State<DetailDestinasiScreen> createState() => _DetailDestinasiScreenState();
}

class _DetailDestinasiScreenState extends State<DetailDestinasiScreen> {
  final MapController _mapController = MapController();
  latlng2.LatLng? _currentPosition;
  double _currentZoom = 13.0;
  final ScrollController _scrollController = ScrollController();
  bool _isInWishlist = false;

  late Destinasi
  _displayDestinasi; // Variabel untuk menyimpan objek destinasi yang bisa diperbarui

  String formatRupiah(num nominal) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(nominal);
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (mounted) {
        // Pengecekan mounted
        setState(() {
          _currentPosition = latlng2.LatLng(
            position.latitude,
            position.longitude,
          );
        });
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  // Fungsi untuk memuat semua data yang relevan: review, wishlist, dan mungkin detail destinasi
  Future<void> _loadAllData() async {
    final reviewProvider = Provider.of<ReviewProvider>(context, listen: false);
    final wishlistProvider = Provider.of<WishlistProvider>(
      context,
      listen: false,
    );
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final String? token = authProvider.token;

    // Pastikan token tersedia sebelum memuat review
    if (token == null || token.isEmpty) {
      debugPrint('Authentication token is missing. Cannot fetch reviews.');
      // Opsi: tampilkan snackbar atau arahkan ke login jika tidak otentikasi
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Anda perlu login untuk melihat ulasan.'),
          ),
        );
      }
      return; // Hentikan proses jika token tidak ada
    }

    await reviewProvider.fetchReviewsByDestinasi(widget.destinasi.id, token);

    // TODO: Refresh data destinasi untuk mendapatkan rating terbaru (Jika Anda memiliki DestinasiProvider)
    // Destinasi? updatedDestinasi;
    // try {
    //   // Asumsi ada DestinasiProvider dan method fetchDestinasiById yang mengembalikan Destinasi
    //   final destinasiProvider = Provider.of<DestinasiProvider>(context, listen: false);
    //   updatedDestinasi = await destinasiProvider.fetchDestinasiById(widget.destinasi.id);
    //   if (mounted) {
    //     setState(() {
    //       _displayDestinasi = updatedDestinasi!; // Update destinasi yang ditampilkan
    //     });
    //   }
    // } catch (e) {
    //   debugPrint('Failed to refresh destinasi data: $e');
    //   // Handle error fetching updated destinasi
    // }

    if (mounted) {
      setState(() {
        _isInWishlist = wishlistProvider.isInWishlist(widget.destinasi.id);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _displayDestinasi = widget.destinasi;
    _getCurrentLocation();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAllData();
    });
  }

  void _onScreenResumed() {
    _loadAllData();
  }

  @override
  Widget build(BuildContext context) {
    final reviewProvider = Provider.of<ReviewProvider>(context); // listen: true
    final List<Review> reviews = reviewProvider.getReviewsByDestinasi(
      widget.destinasi.id,
    );

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final currentDestinasi = _displayDestinasi;
    final theme = Theme.of(context);
    final wishlistProvider = Provider.of<WishlistProvider>(context);

    final screenWidth = MediaQuery.of(context).size.width;

    final int totalReview = reviews.length;

    final List<Review> latestReviews = List.from(reviews)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final shownReviews = latestReviews.take(4).toList();

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            floating: false,
            pinned: true,
            backgroundColor: Colors.blue.shade800,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'destinasi-${currentDestinasi.nama}',
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder:
                              (_) => Dialog(
                                child: Image.network(
                                  currentDestinasi.gambar,
                                  fit: BoxFit.contain,
                                ),
                              ),
                        );
                      },
                      child: Image.network(
                        currentDestinasi.gambar,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.7),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const CircleAvatar(
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.share, color: Colors.white),
                ),
                onPressed: () {
                  Share.share(
                    'Yuk jelajahi ${currentDestinasi.nama} di Java Wonderland! 🌍\n\n'
                    'Lokasi: ${currentDestinasi.lokasi}\n'
                    'Kategori: ${currentDestinasi.kategori}\n'
                    'Harga: Rp ${currentDestinasi.harga}\n\n'
                    'Deskripsi: ${currentDestinasi.deskripsi}',
                    subject: 'Rekomendasi Wisata Java Wonderland',
                  );
                },
              ),
              IconButton(
                icon: CircleAvatar(
                  backgroundColor: Colors.white24,
                  child: Icon(
                    _isInWishlist ? Icons.favorite : Icons.favorite_border,
                    color: _isInWishlist ? Colors.red : Colors.white,
                  ),
                ),
                onPressed: () async {
                  if (!authProvider.isAuthenticated) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            'Silakan login untuk mengakses wishlist',
                          ),
                          duration: const Duration(seconds: 2),
                          action: SnackBarAction(
                            label: 'Login',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoginScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    }
                    return;
                  }

                  try {
                    if (wishlistProvider.isInWishlist(currentDestinasi.id)) {
                      await wishlistProvider.removeWishlist(
                        currentDestinasi.id,
                      );
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${currentDestinasi.nama} dihapus dari wishlist',
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    } else {
                      await wishlistProvider.addWishlist(currentDestinasi.id);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${currentDestinasi.nama} ditambahkan ke wishlist',
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    }
                    if (mounted) {
                      setState(() {
                        _isInWishlist = wishlistProvider.isInWishlist(
                          currentDestinasi.id,
                        );
                      });
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Terjadi kesalahan: ${e.toString()}'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  }
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          // Content
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Header Info
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentDestinasi.nama,
                                  style: theme.textTheme.headlineMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade800,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  decoration: BoxDecoration(
                                    color:
                                        currentDestinasi.kategori
                                                    .toLowerCase() ==
                                                'gunung'
                                            ? Colors.green.shade50
                                            : Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color:
                                          currentDestinasi.kategori
                                                      .toLowerCase() ==
                                                  'gunung'
                                              ? Colors.green.shade300
                                              : Colors.blue.shade300,
                                      width: 1,
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  child: Text(
                                    currentDestinasi.kategori,
                                    style: TextStyle(
                                      color:
                                          currentDestinasi.kategori
                                                      .toLowerCase() ==
                                                  'gunung'
                                              ? Colors.green.shade700
                                              : Colors.blue.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            flex: 1,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 20,
                                  ),
                                  Flexible(
                                    child: Text(
                                      currentDestinasi.rating.toStringAsFixed(
                                        1,
                                      ),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Price and Book Button
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:
                      screenWidth < 400
                          ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Harga per orang',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    formatRupiah(currentDestinasi.harga),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade800,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.directions_car),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                PilihWaktuKeberangkatanScreen(
                                                  destinasi: currentDestinasi,
                                                ),
                                      ),
                                    ).then((_) => _onScreenResumed());
                                  },
                                  label: const Text('Pesan'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                    backgroundColor: Colors.blue.shade800,
                                    foregroundColor:
                                        Theme.of(
                                          context,
                                        ).scaffoldBackgroundColor,
                                    textStyle: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                ),
                              ),
                            ],
                          )
                          : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Harga per orang',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      formatRupiah(currentDestinasi.harga),
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade800,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                flex: 2,
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.directions_car),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                PilihWaktuKeberangkatanScreen(
                                                  destinasi: currentDestinasi,
                                                ),
                                      ),
                                    ).then((_) => _onScreenResumed());
                                  },
                                  label: const Text('Pesan'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    backgroundColor: Colors.blue.shade800,
                                    foregroundColor:
                                        Theme.of(
                                          context,
                                        ).scaffoldBackgroundColor,
                                    textStyle: TextStyle(
                                      fontSize: screenWidth < 350 ? 14 : 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                ),

                // Description Section
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.description_outlined,
                            size: 20,
                            color: Colors.grey[700],
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Deskripsi',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey[200]!,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          currentDestinasi.deskripsi,
                          textAlign: TextAlign.justify,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF4A5568),
                            height: 1.6,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Gallery Section
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.photo_library_outlined,
                            size: 20,
                            color: Colors.grey[700],
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Galeri Foto',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 160,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: currentDestinasi.galeri.length,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          physics: const BouncingScrollPhysics(),
                          clipBehavior: Clip.none,
                          separatorBuilder:
                              (_, __) => const SizedBox(width: 16),
                          itemBuilder: (context, index) {
                            final imageUrl = currentDestinasi.galeri[index];
                            return GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  barrierColor: Colors.black87,
                                  builder:
                                      (_) => Dialog(
                                        backgroundColor: Colors.transparent,
                                        insetPadding: const EdgeInsets.all(20),
                                        child: Stack(
                                          children: [
                                            Hero(
                                              tag:
                                                  'gallery-${currentDestinasi.nama}-$index',
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          16,
                                                        ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.3),
                                                        blurRadius: 20,
                                                        spreadRadius: 5,
                                                      ),
                                                    ],
                                                  ),
                                                  child: Image.network(
                                                    imageUrl,
                                                    fit: BoxFit.contain,
                                                    width: double.infinity,
                                                    height: double.infinity,
                                                    loadingBuilder: (
                                                      context,
                                                      child,
                                                      loadingProgress,
                                                    ) {
                                                      if (loadingProgress ==
                                                          null)
                                                        return child;
                                                      return Center(
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            SizedBox(
                                                              width: 32,
                                                              height: 32,
                                                              child: CircularProgressIndicator(
                                                                strokeWidth: 3,
                                                                valueColor:
                                                                    AlwaysStoppedAnimation<
                                                                      Color
                                                                    >(
                                                                      Theme.of(
                                                                        context,
                                                                      ).primaryColor,
                                                                    ),
                                                                value:
                                                                    loadingProgress.expectedTotalBytes !=
                                                                            null
                                                                        ? loadingProgress.cumulativeBytesLoaded /
                                                                            loadingProgress.expectedTotalBytes!
                                                                        : null,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              height: 8,
                                                            ),
                                                            Text(
                                                              'Memuat...',
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                color:
                                                                    Colors
                                                                        .grey[600],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                    errorBuilder:
                                                        (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) => Container(
                                                          decoration: BoxDecoration(
                                                            color:
                                                                Colors
                                                                    .grey[100],
                                                            border: Border.all(
                                                              color:
                                                                  Colors
                                                                      .grey[300]!,
                                                              width: 1,
                                                            ),
                                                          ),
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .broken_image_outlined,
                                                                size: 48,
                                                                color:
                                                                    Colors
                                                                        .grey[400],
                                                              ),
                                                              const SizedBox(
                                                                height: 8,
                                                              ),
                                                              Text(
                                                                'Gagal memuat',
                                                                style: TextStyle(
                                                                  fontSize: 12,
                                                                  color:
                                                                      Colors
                                                                          .grey[500],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            // Overlay gradient untuk efek visual yang lebih menarik
                                            Positioned(
                                              bottom: 0,
                                              left: 0,
                                              right: 0,
                                              child: Container(
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    begin:
                                                        Alignment.bottomCenter,
                                                    end: Alignment.topCenter,
                                                    colors: [
                                                      Colors.black.withOpacity(
                                                        0.3,
                                                      ),
                                                      Colors.transparent,
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                );
                              },
                              child: Hero(
                                tag: 'gallery-${currentDestinasi.nama}-$index',
                                child: Container(
                                  width: 180,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.15),
                                        blurRadius: 12,
                                        offset: const Offset(0, 6),
                                        spreadRadius: 0,
                                      ),
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                        spreadRadius: 0,
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.grey[50]!,
                                            Colors.grey[100]!,
                                          ],
                                        ),
                                      ),
                                      child: Stack(
                                        children: [
                                          Image.network(
                                            imageUrl,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,
                                            loadingBuilder: (
                                              context,
                                              child,
                                              loadingProgress,
                                            ) {
                                              if (loadingProgress == null)
                                                return child;
                                              return Center(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    SizedBox(
                                                      width: 32,
                                                      height: 32,
                                                      child: CircularProgressIndicator(
                                                        strokeWidth: 3,
                                                        valueColor:
                                                            AlwaysStoppedAnimation<
                                                              Color
                                                            >(
                                                              Theme.of(
                                                                context,
                                                              ).primaryColor,
                                                            ),
                                                        value:
                                                            loadingProgress
                                                                        .expectedTotalBytes !=
                                                                    null
                                                                ? loadingProgress
                                                                        .cumulativeBytesLoaded /
                                                                    loadingProgress
                                                                        .expectedTotalBytes!
                                                                : null,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      'Memuat...',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                            errorBuilder:
                                                (
                                                  context,
                                                  error,
                                                  stackTrace,
                                                ) => Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[100],
                                                    border: Border.all(
                                                      color: Colors.grey[300]!,
                                                      width: 1,
                                                    ),
                                                  ),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .broken_image_outlined,
                                                        size: 48,
                                                        color: Colors.grey[400],
                                                      ),
                                                      const SizedBox(height: 8),
                                                      Text(
                                                        'Gagal memuat',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              Colors.grey[500],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                          ),
                                          // Overlay gradient untuk efek visual yang lebih menarik
                                          Positioned(
                                            bottom: 0,
                                            left: 0,
                                            right: 0,
                                            child: Container(
                                              height: 40,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.bottomCenter,
                                                  end: Alignment.topCenter,
                                                  colors: [
                                                    Colors.black.withOpacity(
                                                      0.3,
                                                    ),
                                                    Colors.transparent,
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
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

                // Location Map
                Container(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    0,
                    16,
                    16,
                  ), // Added padding for map
                  height: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        spreadRadius: 1,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: latlng2.LatLng(
                              currentDestinasi.lat, // Gunakan currentDestinasi
                              currentDestinasi.lng, // Gunakan currentDestinasi
                            ),
                            initialZoom: _currentZoom,
                            maxZoom: 18,
                            minZoom: 3,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                              subdomains: const ['a', 'b', 'c'],
                            ),
                            MarkerLayer(
                              markers: [
                                // Marker destinasi utama
                                Marker(
                                  width: 150,
                                  height: 100,
                                  point: latlng2.LatLng(
                                    currentDestinasi
                                        .lat, // Gunakan currentDestinasi
                                    currentDestinasi
                                        .lng, // Gunakan currentDestinasi
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade800,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.25,
                                              ),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        constraints: const BoxConstraints(
                                          maxWidth: 140,
                                        ),
                                        child: Text(
                                          currentDestinasi
                                              .nama, // Gunakan currentDestinasi
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Icon(
                                        Icons.location_on,
                                        color: Colors.red,
                                        size: 32,
                                      ),
                                    ],
                                  ),
                                ),
                                // Marker posisi user (jika ada)
                                if (_currentPosition != null)
                                  Marker(
                                    width: 60,
                                    height: 60,
                                    point: _currentPosition!,
                                    child: const Icon(
                                      Icons.my_location,
                                      color: Colors.blue,
                                      size: 38,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),

                        // Tombol navigasi ke lokasi destinasi (kanan bawah)
                        Positioned(
                          bottom: 16,
                          right: 16,
                          child: FloatingActionButton.small(
                            heroTag: 'btnToDestination',
                            onPressed: () {
                              _mapController.move(
                                latlng2.LatLng(
                                  currentDestinasi
                                      .lat, // Gunakan currentDestinasi
                                  currentDestinasi
                                      .lng, // Gunakan currentDestinasi
                                ),
                                15.0,
                              );
                              if (mounted) {
                                // Pengecekan mounted
                                setState(() {
                                  _currentZoom = 15.0;
                                });
                              }
                            },
                            backgroundColor: Colors.blue.shade800,
                            child: const Icon(Icons.location_on),
                            tooltip: 'Arahkan ke lokasi destinasi',
                          ),
                        ),

                        // Tombol navigasi ke posisi user (kiri bawah)
                        if (_currentPosition != null)
                          Positioned(
                            bottom: 16,
                            left: 16,
                            child: FloatingActionButton.small(
                              heroTag: 'btnToUserLocation',
                              onPressed: () {
                                _mapController.move(_currentPosition!, 15.0);
                                if (mounted) {
                                  // Pengecekan mounted
                                  setState(() {
                                    _currentZoom = 15.0;
                                  });
                                }
                              },
                              backgroundColor: Colors.green.shade700,
                              child: const Icon(Icons.my_location),
                              tooltip: 'Arahkan ke posisi saya',
                            ),
                          ),

                        // Tombol Zoom In / Zoom Out (kanan atas)
                        Positioned(
                          top: 16,
                          right: 16,
                          child: Column(
                            children: [
                              FloatingActionButton.small(
                                heroTag: 'zoomIn',
                                onPressed: () {
                                  if (mounted) {
                                    // Pengecekan mounted
                                    setState(() {
                                      _currentZoom = (_currentZoom + 1).clamp(
                                        3.0,
                                        18.0,
                                      );
                                      _mapController.move(
                                        _mapController.camera.center,
                                        _currentZoom,
                                      );
                                    });
                                  }
                                },
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.blue.shade800,
                                child: const Icon(Icons.add),
                              ),
                              const SizedBox(height: 8),
                              FloatingActionButton.small(
                                heroTag: 'zoomOut',
                                onPressed: () {
                                  if (mounted) {
                                    // Pengecekan mounted
                                    setState(() {
                                      _currentZoom = (_currentZoom - 1).clamp(
                                        3.0,
                                        18.0,
                                      );
                                      _mapController.move(
                                        _mapController.camera.center,
                                        _currentZoom,
                                      );
                                    });
                                  }
                                },
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.blue.shade800,
                                child: const Icon(Icons.remove),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Reviews Section
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 28),
                          const SizedBox(width: 4),
                          Text(
                            currentDestinasi.rating.toStringAsFixed(1),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              color: Colors.blue.shade800,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '($totalReview review)',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              spreadRadius: 1,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        // Perbaikan sintaksis ternary operator di sini
                        child:
                            reviewProvider.isLoading
                                ? const Padding(
                                  padding: EdgeInsets.all(24.0),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                                : shownReviews.isEmpty
                                ? const Padding(
                                  padding: EdgeInsets.all(24),
                                  child: Center(
                                    child: Text(
                                      'Belum ada review untuk destinasi ini.',
                                      style: TextStyle(
                                        color: Color(0xFF757575),
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                )
                                : Column(
                                  children:
                                      shownReviews
                                          .map(
                                            (review) => Column(
                                              children: [
                                                ReviewCard(
                                                  name: review.userName,
                                                  rating: review.rating,
                                                  comment: review.comment,
                                                  date: DateFormat(
                                                    'd MMM, yyyy',
                                                    'id_ID',
                                                  ).format(review.createdAt),
                                                  userProfilePictureUrl:
                                                      review
                                                          .userProfilePictureUrl, // <-- WAJIB!
                                                ),
                                                if (shownReviews.indexOf(
                                                      review,
                                                    ) <
                                                    shownReviews.length - 1)
                                                  const Divider(height: 1),
                                              ],
                                            ),
                                          )
                                          .toList(),
                                ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        },
        backgroundColor: Colors.blue.shade800,
        child: const Icon(Icons.arrow_upward),
      ),
    );
  }
}

class ReviewCard extends StatelessWidget {
  final String name;
  final int rating;
  final String comment;
  final String date;
  final String? userProfilePictureUrl;

  const ReviewCard({
    super.key,
    required this.name,
    required this.rating,
    required this.comment,
    required this.date,
    this.userProfilePictureUrl,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint('Render ReviewCard: $name, $userProfilePictureUrl');
    // Cek URL valid (http/https) dan tidak kosong
    final bool hasProfileImage =
        userProfilePictureUrl != null &&
        userProfilePictureUrl!.isNotEmpty &&
        (userProfilePictureUrl!.startsWith('http://') ||
            userProfilePictureUrl!.startsWith('https://'));

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.blue.shade100,
                backgroundImage:
                    hasProfileImage
                        ? NetworkImage(userProfilePictureUrl!)
                        : null,
                child:
                    !hasProfileImage
                        ? Text(
                          (name.isNotEmpty ? name[0] : '?').toUpperCase(),
                          style: TextStyle(
                            color: Colors.blue.shade800,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        )
                        : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        ...List.generate(
                          5,
                          (index) => Icon(
                            index < rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            date,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(comment, style: const TextStyle(fontSize: 14, height: 1.4)),
        ],
      ),
    );
  }
}
