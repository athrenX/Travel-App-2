import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:travelapp/main.dart';
import 'package:travelapp/providers/auth_provider.dart';
import 'package:travelapp/providers/destinasi_provider.dart';
import 'package:travelapp/screens/auth/login_screen.dart';
import 'package:travelapp/widgets/destinasi_card.dart';
import 'package:travelapp/screens/user/detail_destinasi_screen.dart'; // Ensure this import points to the correct file

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => DestinasiProvider())],
      child: MyApp(),
    ),
  );
}

Widget build(BuildContext context) {
  return MaterialApp(
    title: 'Java Wonderland',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      primarySwatch: Colors.blue,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
    home: Scaffold(
      appBar: AppBar(
        title: const Text('Java Wonderland'),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ), // Tetapkan warna ikon
            onPressed: () => _handleLogout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: const HomeScreen(),
    ),
  );
}

void _handleLogout(BuildContext context) {
  showDialog(
    context: context,
    builder:
        (context) => AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah anda yakin ingin keluar?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                // Get the AuthProvider and call logout
                await Provider.of<AuthProvider>(
                  context,
                  listen: false,
                ).logout();

                // Navigate to login screen and clear navigation stack
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                  (route) => false,
                );
              },
              child: const Text('Logout'),
            ),
          ],
        ),
  );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
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

  @override
  void initState() {
    super.initState();
    // Hide loader after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        showLoader = false;
      });
    });

    // Show popup after 3 seconds
    _popupTimer = Timer(const Duration(seconds: 3), () {
      setState(() {
        showPopup = true;
      });
    });

    // Hide popup after 10 seconds
    _popupHideTimer = Timer(const Duration(seconds: 10), () {
      setState(() {
        showPopup = false;
      });
    });

    // Auto scroll carousel
    _carouselTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_currentCarouselIndex < 2) {
        _currentCarouselIndex++;
      } else {
        _currentCarouselIndex = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentCarouselIndex,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _popupTimer?.cancel();
    _popupHideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade800,
        title: const Text(
          'JAVA WONDERLAND',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
            tooltip: 'Cari',
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {},
            tooltip: 'Akun',
          ),
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ), // Tetapkan warna ikon
            onPressed: () => _handleLogout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main content
          FutureBuilder(
            future:
                Provider.of<DestinasiProvider>(
                  context,
                  listen: false,
                ).fetchDestinasi(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  showLoader) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      // Carousel
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Stack(
                          children: [
                            PageView(
                              controller: _pageController,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentCarouselIndex = index;
                                });
                              },
                              children: [
                                _buildCarouselItem(
                                  'assets/images/gambar_bromo.jpeg',
                                  'Gunung Bromo',
                                ),
                                _buildCarouselItem(
                                  'assets/images/gunung_sindoro.jpeg',
                                  'Gunung Sindoro',
                                ),
                                _buildCarouselItem(
                                  'assets/images/anyer.jpg',
                                  'Pantai Anyer',
                                ),
                                _buildCarouselItem(
                                  'assets/images/PANGANDARAN.webp',
                                  'Pantai Pangandaran',
                                ),
                                _buildCarouselItem(
                                  'assets/images/kawahIjen.webp',
                                  'Kawah Ijen',
                                ),
                                _buildCarouselItem(
                                  'assets/images/karimun jawa.webp',
                                  'Pantai Karimun Jawa',
                                ),
                              ],
                            ),
                            Positioned(
                              bottom: 10,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(6, (index) {
                                  return Container(
                                    width: 10,
                                    height: 10,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color:
                                          _currentCarouselIndex == index
                                              ? Colors.white
                                              : Colors.white.withOpacity(0.5),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Destinations section
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 24),
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
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children:
                                    ['Semua', 'Gunung', 'Pantai'].map((
                                      category,
                                    ) {
                                      final isSelected =
                                          _selectedCategory == category;
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                        ),
                                        child: ChoiceChip(
                                          label: Text(category),
                                          selected: isSelected,
                                          onSelected: (_) {
                                            setState(() {
                                              _selectedCategory = category;
                                            });
                                          },
                                          selectedColor: Colors.blue.shade700,
                                          backgroundColor: Colors.grey.shade200,
                                          labelStyle: TextStyle(
                                            color:
                                                isSelected
                                                    ? Colors.white
                                                    : Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                              ),
                            ),
                            Consumer<DestinasiProvider>(
                              builder: (ctx, destinasiProvider, child) {
                                final destinasiList =
                                    destinasiProvider.destinasiList.where((
                                      destinasi,
                                    ) {
                                      if (_selectedCategory == 'Semua')
                                        return true;
                                      return destinasi.kategori.toLowerCase() ==
                                          _selectedCategory.toLowerCase();
                                    }).toList();

                                if (destinasiList.isEmpty) {
                                  return Center(
                                    child: Text('Tidak ada data destinasi'),
                                  );
                                }

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount:
                                        destinasiList.length > 6
                                            ? 6
                                            : destinasiList.length,
                                    itemBuilder: (ctx, index) {
                                      final destinasi = destinasiList[index];
                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (ctx) =>
                                                      DetailDestinasiScreen(
                                                        destinasi: destinasi,
                                                      ),
                                            ),
                                          );
                                        },
                                        child: DestinasiCard(
                                          destinasi: destinasi,
                                        ),
                                      );
                                    },
                                  ),
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
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
                );
              }
            },
          ),

          // Loading overlay
          if (showLoader)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(child: _buildCustomLoader()),
            ),

          // Popup notification
          if (showPopup)
            Positioned(
              left: 20,
              bottom: 80, // Position above bottom navigation bar
              child: _buildPopupNotification(),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() {
            _currentNavIndex = index;
          });
        },
        selectedItemColor: Colors.blue.shade800,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Pesanan',
          ),
        ],
      ),
    );
  }

  Widget _buildCarouselItem(String imagePath, String title) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(imagePath, fit: BoxFit.cover),
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
          child: Column(
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
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
          Icon(Icons.card_giftcard, color: Colors.white, size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
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
