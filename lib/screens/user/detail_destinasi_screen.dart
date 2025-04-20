import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelapp/models/destinasi.dart';
import 'package:travelapp/providers/wishlist_provider.dart';
import 'package:travelapp/screens/user/pemilihan_kendaraan_screen.dart';
import 'package:travelapp/screens/auth/login_screen.dart'; // Ensure this import points to the correct path
import 'package:travelapp/providers/auth_provider.dart'; // Add this import for AuthProvider
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng2;

class DetailDestinasiScreen extends StatefulWidget {
  final Destinasi destinasi;

  const DetailDestinasiScreen({Key? key, required this.destinasi})
    : super(key: key);

  @override
  State<DetailDestinasiScreen> createState() => _DetailDestinasiScreenState();
}

class _DetailDestinasiScreenState extends State<DetailDestinasiScreen> {
  final MapController _mapController = MapController();
  double _currentZoom = 13.0;
  final ScrollController _scrollController = ScrollController();
  bool _isInWishlist = false;

  @override
  void initState() {
    super.initState();
    // Check if the destination is in wishlist when screen loads
    final wishlistProvider = Provider.of<WishlistProvider>(
      context,
      listen: false,
    );
    _isInWishlist = wishlistProvider.isInWishlist(widget.destinasi.id);
  }

  @override
  Widget build(BuildContext context) {
    final destinasi = widget.destinasi;
    final theme = Theme.of(context);
    final wishlistProvider = Provider.of<WishlistProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

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
                    tag: 'destinasi-${destinasi.nama}',
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder:
                              (_) => Dialog(
                                child: Image.asset(
                                  destinasi.gambar,
                                  fit: BoxFit.contain,
                                ),
                              ),
                        );
                      },
                      child: Image.asset(destinasi.gambar, fit: BoxFit.cover),
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
              title: Text(
                destinasi.nama,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const CircleAvatar(
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.share, color: Colors.white),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Share feature coming soon!')),
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
                onPressed: () {
                  if (authProvider.isAuthenticated) {
                    setState(() {
                      _isInWishlist = !_isInWishlist;
                    });

                    if (_isInWishlist) {
                      wishlistProvider.addToWishlist(
                        authProvider.user!.id,
                        destinasi.id,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${destinasi.nama} ditambahkan ke wishlist',
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    } else {
                      wishlistProvider.removeFromWishlist(destinasi.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${destinasi.nama} dihapus dari wishlist',
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  } else {
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  destinasi.nama,
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
                                        destinasi.kategori.toLowerCase() ==
                                                'gunung'
                                            ? Colors.green.shade50
                                            : Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color:
                                          destinasi.kategori.toLowerCase() ==
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
                                    destinasi.kategori,
                                    style: TextStyle(
                                      color:
                                          destinasi.kategori.toLowerCase() ==
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
                          Container(
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
                                const SizedBox(width: 4),
                                Text(
                                  destinasi.rating.toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            'Rp ${destinasi.harga.toString()}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.directions_car),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => PemilihanKendaraanScreen(
                                    destinasi: destinasi,
                                  ),
                            ),
                          );
                        },
                        label: const Text('Pilih Kendaraan'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          backgroundColor: Colors.blue.shade800,
                          foregroundColor: Colors.white,
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
                    ],
                  ),
                ),

                // Description Section
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Deskripsi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        destinasi.deskripsi,
                        textAlign: TextAlign.justify,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                          height: 1.5,
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
                      const Text(
                        'Galeri Foto',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: destinasi.galeri.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder:
                                        (_) => Dialog(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              AppBar(
                                                backgroundColor:
                                                    Colors.transparent,
                                                elevation: 0,
                                                leading: IconButton(
                                                  icon: const Icon(Icons.close),
                                                  onPressed:
                                                      () => Navigator.pop(
                                                        context,
                                                      ),
                                                ),
                                                title: Text(
                                                  'Foto ${index + 1}',
                                                ),
                                              ),
                                              Image.asset(
                                                destinasi.galeri[index],
                                                fit: BoxFit.contain,
                                              ),
                                            ],
                                          ),
                                        ),
                                  );
                                },
                                child: Hero(
                                  tag: 'gallery-${destinasi.nama}-$index',
                                  child: Container(
                                    width: 180,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.asset(
                                        destinasi.galeri[index],
                                        fit: BoxFit.cover,
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
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Lokasi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
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
                                    destinasi.lat,
                                    destinasi.lng,
                                  ),
                                  initialZoom: _currentZoom,
                                  maxZoom: 18,
                                  minZoom: 3,
                                  interactionOptions:
                                      const InteractionOptions(),
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate:
                                        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                    subdomains: const ['a', 'b', 'c'],
                                  ),
                                  MarkerLayer(
                                    markers: [
                                      Marker(
                                        width: 80.0,
                                        height: 80.0,
                                        point: latlng2.LatLng(
                                          destinasi.lat,
                                          destinasi.lng,
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.blue.shade800,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                destinasi.nama,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                            const Icon(
                                              Icons.location_on,
                                              color: Colors.red,
                                              size: 32,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Positioned(
                                bottom: 16,
                                right: 16,
                                child: Column(
                                  children: [
                                    FloatingActionButton.small(
                                      heroTag: 'zoomIn',
                                      onPressed: () {
                                        setState(() {
                                          _currentZoom = (_currentZoom + 1)
                                              .clamp(3.0, 18.0);
                                          _mapController.move(
                                            _mapController.camera.center,
                                            _currentZoom,
                                          );
                                        });
                                      },
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.blue.shade800,
                                      elevation: 2,
                                      child: const Icon(Icons.add),
                                    ),
                                    const SizedBox(height: 8),
                                    FloatingActionButton.small(
                                      heroTag: 'zoomOut',
                                      onPressed: () {
                                        setState(() {
                                          _currentZoom = (_currentZoom - 1)
                                              .clamp(3.0, 18.0);
                                          _mapController.move(
                                            _mapController.camera.center,
                                            _currentZoom,
                                          );
                                        });
                                      },
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.blue.shade800,
                                      elevation: 2,
                                      child: const Icon(Icons.remove),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Reviews Section
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Review Pengguna',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
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
                        child: Column(
                          children: [
                            ReviewCard(
                              name: 'Ayu',
                              rating: 5,
                              comment: 'Sangat indah dan memuaskan!',
                              date: '2 hari yang lalu',
                            ),
                            const Divider(height: 1),
                            ReviewCard(
                              name: 'Budi',
                              rating: 4,
                              comment: 'Cocok buat healing. Recommended!',
                              date: '1 minggu yang lalu',
                            ),
                          ],
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

  const ReviewCard({
    Key? key,
    required this.name,
    required this.rating,
    required this.comment,
    required this.date,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue.shade100,
                child: Text(
                  name[0],
                  style: TextStyle(
                    color: Colors.blue.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
                        Text(
                          date,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
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
