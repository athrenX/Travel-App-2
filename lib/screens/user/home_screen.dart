// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:travelapp/models/destinasi.dart';
import 'package:travelapp/providers/auth_provider.dart';
import 'package:travelapp/providers/destinasi_provider.dart';
import 'package:travelapp/providers/order_provider.dart';
import 'package:travelapp/providers/wishlist_provider.dart';
import 'package:travelapp/screens/auth/login_screen.dart';
import 'package:travelapp/screens/user/detail_destinasi_screen.dart';
import 'package:travelapp/screens/user/order_screen.dart';
import 'package:travelapp/screens/user/profil_screen.dart';
import 'package:travelapp/screens/user/wishlist_screen.dart';
import 'package:flutter/services.dart';
import 'dart:io';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool showLoader = true;
  bool showPopup = false;
  int _currentCarouselIndex = 0;
  int _currentNavIndex = 0;
  final PageController _pageController = PageController();
  Timer? _carouselTimer;
  Timer? _popupTimer;
  Timer? _popupHideTimer;
  String _selectedCategory = 'Semua';

  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final FocusNode _searchFocusNode = FocusNode();
  bool _showClearButton = false;

  @override
  void initState() {
    super.initState();

    // Ambil data destinasi untuk list/grid
    Future.microtask(() {
      final provider = Provider.of<DestinasiProvider>(context, listen: false);
      final token = Provider.of<AuthProvider>(context, listen: false).token!;
      provider.fetchCarouselDestinasi(token);

      provider.fetchDestinasi(); // untuk list destinasi
      // untuk carousel, kirim token
    });

    // Timer untuk loading dan popup
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => showLoader = false);
    });

    _popupTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => showPopup = true);
    });

    _popupHideTimer = Timer(const Duration(seconds: 10), () {
      if (mounted) setState(() => showPopup = false);
    });

    // Timer untuk auto-slide carousel
    _carouselTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          _currentCarouselIndex = (_currentCarouselIndex + 1) % 6;
        });

        if (_pageController.hasClients) {
          _pageController.animateToPage(
            _currentCarouselIndex,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
          );
        }
      }
    });

    // Listener untuk pencarian
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
        _showClearButton = _searchController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _popupTimer?.cancel();
    _popupHideTimer?.cancel();
    _pageController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _searchQuery = '';
      } else {
        Future.delayed(const Duration(milliseconds: 100), () {
          FocusScope.of(context).requestFocus(_searchFocusNode);
        });
      }
    });
  }

  Future<bool> _onWillPop() async {
    // Jika dalam mode pencarian, keluar dari mode pencarian
    if (_isSearching) {
      _toggleSearch();
      return false;
    }

    // Jika sedang di halaman bukan Home, kembali ke tab Home
    if (_currentNavIndex != 0) {
      setState(() {
        _currentNavIndex = 0;
      });
      return false;
    }

    // ❗ Tambahan: Jika tab sekarang Home, tapi navigator bisa pop (misalnya buka detail)
    if (Navigator.of(context).canPop()) {
      return true;
    }

    // Jika sudah di Home dan tidak ada stack lain, tampilkan dialog keluar
    final shouldExit = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder:
          (BuildContext dialogContext) => AlertDialog(
            title: const Text('Keluar Aplikasi'),
            content: const Text(
              'Apakah Anda yakin ingin keluar dari aplikasi?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Tidak'),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Ya'),
              ),
            ],
          ),
    );

    if (shouldExit == true) {
      try {
        if (Platform.isAndroid) {
          SystemNavigator.pop();
        } else {
          exit(0);
        }
      } catch (e) {
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      }
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: _currentNavIndex == 0 ? _buildAppBar() : null,
        body: Stack(
          children: [
            IndexedStack(
              index: _currentNavIndex,
              children: [
                // Home Tab - tanpa Scaffold wrapper
                _isSearching ? _buildSearchResults() : _buildHomeContent(),
                // Wishlist Tab
                WishlistScreen(
                  resetNavbarToHome: () {
                    setState(() {
                      _currentNavIndex = 0; // kembali ke tab home
                    });
                  },
                ),
                // Order Tab
                OrderScreen(),
                // Profile Tab
                ProfileScreen(),
              ],
            ),
            if (showLoader)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(child: _buildCustomLoader()),
              ),
            if (showPopup && !_isSearching && _currentNavIndex == 0)
              Positioned(
                left: 20,
                bottom: 80,
                child: _buildPopupNotification(),
              ),
          ],
        ),
        bottomNavigationBar: Consumer<OrderProvider>(
          builder: (context, orderProvider, child) {
            return BottomNavigationBar(
              currentIndex: _currentNavIndex,
              onTap: (index) {
                if (index == 1 && !authProvider.isAuthenticated) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Silakan login untuk melihat wishlist'),
                      duration: Duration(seconds: 2),
                      action: SnackBarAction(
                        label: 'Login',
                        onPressed:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => LoginScreen()),
                            ),
                      ),
                    ),
                  );
                  return;
                }
                if (index == 2) {
                  Provider.of<OrderProvider>(
                    context,
                    listen: false,
                  ).resetPesananBaru();
                }
                setState(() {
                  _currentNavIndex = index;
                });
              },
              selectedItemColor: Colors.blue.shade800,
              unselectedItemColor: Colors.grey,
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(
                  icon: Icon(Icons.favorite),
                  label: 'Wishlist',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_cart_rounded),
                  label: 'Pesanan',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profil',
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // AppBar yang sudah disederhanakan - hanya tombol pencarian
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title:
          _isSearching
              ? TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                decoration: const InputDecoration(
                  hintText: 'Cari destinasi wisata...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 15,
                  ),
                ),
              )
              : const Text(
                'JAVA WONDERLAND',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
      backgroundColor: Colors.blue.shade800,
      leading:
          _isSearching
              ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _toggleSearch,
              )
              : null,
      actions: [
        if (!_isSearching)
          IconButton(icon: const Icon(Icons.search), onPressed: _toggleSearch),
      ],
    );
  }

  // Widget tampilan hasil pencarian
  Widget _buildSearchResults() {
    return Consumer<DestinasiProvider>(
      builder: (ctx, destinasiProvider, child) {
        final allDestinasi = destinasiProvider.destinasiList;

        // Filter destinasi berdasarkan query pencarian
        final filteredDestinasi =
            allDestinasi.where((destinasi) {
              final name = destinasi.nama.toLowerCase();
              final location = destinasi.lokasi.toLowerCase();
              final category = destinasi.kategori.toLowerCase();
              final query = _searchQuery.toLowerCase();

              return name.contains(query) ||
                  location.contains(query) ||
                  category.contains(query);
            }).toList();

        if (_searchQuery.isEmpty) {
          // Tampilan saat belum ada query pencarian
          return Container(
            color: Colors.white,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'Ketik untuk mencari destinasi wisata',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Cari berdasarkan nama, lokasi, atau kategori',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          );
        }

        if (filteredDestinasi.isEmpty) {
          // Tampilan saat tidak ada hasil yang cocok
          return Container(
            color: Colors.white,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sentiment_dissatisfied,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tidak ada hasil untuk "$_searchQuery"',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Coba kata kunci lain atau periksa ejaan',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          );
        }

        // Tampilan hasil pencarian
        return Container(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hasil Pencarian',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ditemukan ${filteredDestinasi.length} hasil untuk "$_searchQuery"',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                    itemCount: filteredDestinasi.length,
                    itemBuilder: (ctx, index) {
                      final destinasi = filteredDestinasi[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (ctx) => DetailDestinasiScreen(
                                    destinasi: destinasi,
                                  ),
                            ),
                          );
                        },
                        child: _buildDestinationCard(destinasi),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCarouselItem(Destinasi destinasi) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          destinasi.gambar,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey.shade300,
              child: Icon(
                Icons.image_not_supported,
                size: 50,
                color: Colors.grey,
              ),
            );
          },
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
            ),
          ),
        ),
        Positioned(
          bottom: 24,
          left: 0,
          right: 0,
          child: Text(
            destinasi.nama,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  // Widget untuk tampilan home utama
  Widget _buildHomeContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          children: [
            // Carousel
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                children: [
                  Consumer<DestinasiProvider>(
                    builder: (context, destinasiProvider, _) {
                      final carouselItems = destinasiProvider.carouselDestinasi;
                      print(
                        '🎢 Carousel UI build. Jumlah item: ${carouselItems.length}',
                      );

                      if (carouselItems.isEmpty) {
                        return Center(child: CircularProgressIndicator());
                      }

                      return PageView.builder(
                        controller: _pageController,
                        itemCount: carouselItems.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentCarouselIndex = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          return _buildCarouselItem(carouselItems[index]);
                        },
                      );
                    },
                  ),
                  Positioned(
                    bottom: 10,
                    left: 0,
                    right: 0,
                    child: Consumer<DestinasiProvider>(
                      builder: (context, destinasiProvider, _) {
                        final total =
                            destinasiProvider.carouselDestinasi.length;

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(total, (index) {
                            return Container(
                              width: 10,
                              height: 10,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    _currentCarouselIndex == index
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.3),
                              ),
                            );
                          }),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Destinations section with card grid
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Text(
                      'Pilihan Destinasi',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  // Category filters
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:
                            ['Semua', 'Gunung', 'Pantai'].map((category) {
                              final isSelected = _selectedCategory == category;
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _selectedCategory = category;
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        isSelected
                                            ? Colors.blue.shade800
                                            : Colors.grey.shade200,
                                    foregroundColor:
                                        isSelected
                                            ? Theme.of(
                                              context,
                                            ).scaffoldBackgroundColor
                                            : Colors.black87,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                    elevation: isSelected ? 4 : 1,
                                  ),
                                  child: Text(
                                    category,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                  ),

                  Consumer<DestinasiProvider>(
                    builder: (ctx, destinasiProvider, child) {
                      final destinasiList =
                          destinasiProvider.destinasiList.where((destinasi) {
                            if (_selectedCategory == 'Semua') return true;
                            return destinasi.kategori.toLowerCase() ==
                                _selectedCategory.toLowerCase();
                          }).toList();

                      if (destinasiList.isEmpty) {
                        return SizedBox(
                          height: 200,
                          child: Center(
                            child: Text(
                              'Tidak ada destinasi ${_selectedCategory == "Semua" ? "" : _selectedCategory}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        );
                      }

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.85,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 15,
                            ),
                        itemCount:
                            destinasiList.length > 8 ? 8 : destinasiList.length,
                        itemBuilder: (ctx, index) {
                          final destinasi = destinasiList[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (ctx) => DetailDestinasiScreen(
                                        destinasi: destinasi,
                                      ),
                                ),
                              );
                            },
                            child: _buildDestinationCard(destinasi),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),

            // Activities section
            Container(
              color: Colors.grey.shade100,
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Text(
                      'Aktivitas Populer',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _buildActivityCardHorizontal(
                          'assets/images/jemur.jpg',
                          'Berjemur',
                        ),
                        _buildActivityCardHorizontal(
                          'assets/images/Snorkling_Pangandaran.jpg',
                          'Snorkeling',
                        ),
                        _buildActivityCardHorizontal(
                          'assets/images/jetski.jpg',
                          'Jetski',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Footer with copyright
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              width: double.infinity,
              child: const Text(
                '© 2025 Destinasi Wisata Indonesia',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDestinationCard(dynamic destinasi) {
    print('URL gambar: ${destinasi.gambar}');
    return Consumer<WishlistProvider>(
      builder: (context, wishlistProvider, child) {
        final isInWishlist = wishlistProvider.isInWishlist(destinasi.id);
        final authProvider = Provider.of<AuthProvider>(context, listen: false);

        return Card(
          elevation: 3,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image container dengan tinggi yang tetap
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: SizedBox(
                      height: 110,
                      width: double.infinity,
                      child: Image.network(
                        destinasi.gambar,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade300,
                            child: Icon(
                              Icons.landscape,
                              size: 50,
                              color: Colors.grey.shade500,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    top: 5,
                    right: 5,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).scaffoldBackgroundColor.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          isInWishlist ? Icons.favorite : Icons.favorite_border,
                          color: isInWishlist ? Colors.red : Colors.grey,
                          size: 20,
                        ),
                        onPressed: () {
                          if (authProvider.isAuthenticated) {
                            if (isInWishlist) {
                              wishlistProvider.removeFromWishlist(destinasi.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${destinasi.nama} dihapus dari wishlist',
                                  ),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            } else {
                              wishlistProvider.addToWishlist(
                                '${authProvider.user?.id ?? ''}',
                                destinasi.id,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${destinasi.nama} ditambahkan ke wishlist',
                                  ),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Silakan login untuk menambahkan ke wishlist',
                                ),
                                duration: Duration(seconds: 2),
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
                    ),
                  ),
                ],
              ),
              // Content container dengan padding yang lebih kecil
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        destinasi.nama,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 12,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              destinasi.lokasi,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 2),
                          Text(
                            '${destinasi.rating}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActivityCardHorizontal(String imagePath, String title) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(60),
            child: Image.asset(
              imagePath,
              height: 120,
              width: 120,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCustomLoader() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue, Colors.blue.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Center(
        child: SizedBox(
          width: 30,
          height: 30,
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
        ),
      ),
    );
  }

  Widget _buildPopupNotification() {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade800,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.card_giftcard, color: Colors.white, size: 36),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Promo Spesial!',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Diskon 20% untuk pemesanan minggu ini!',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              setState(() {
                showPopup = false;
              });
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
