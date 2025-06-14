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
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng2;
import 'package:travelapp/services/location_service.dart';
import 'package:travelapp/models/location.dart';
import 'package:travelapp/providers/activity_provider.dart';
import 'package:travelapp/models/Activity.dart';
import 'package:geolocator/geolocator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class MapFromApi extends StatefulWidget {
  final LocationService locationService;
  final int locationId;
  final double? height;
  final double? initialZoom;
  final VoidCallback? onMapTap;

  const MapFromApi({
    super.key,
    required this.locationService,
    required this.locationId,
    this.height = 300,
    this.initialZoom = 15.0,
    this.onMapTap,
    final double minZoom = 5.0,
    final double maxZoom = 19.0,
  });

  @override
  State<MapFromApi> createState() => _MapFromApiState();
}

class _MapFromApiState extends State<MapFromApi> {
  late MapController _mapController;
  double _currentZoom = 15.0;
  Location? _cachedLocation;
  bool _isLoading = true;
  String? _errorMessage;
  bool _showRecenterButton = false;
  latlng2.LatLng? _currentPosition;
  bool _isGettingLocation = false;

  @override
  void initState() {
    super.initState();

    _mapController = MapController();
    _currentZoom = widget.initialZoom ?? 15.0;
    _loadLocation();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
    });
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() => _isGettingLocation = false);
        return;
      }
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = latlng2.LatLng(
          position.latitude,
          position.longitude,
        );
        _isGettingLocation = false;
      });
    } catch (e) {
      setState(() => _isGettingLocation = false);
      debugPrint('Error getting location: $e');
    }
  }

  Future<void> _loadLocation() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final location = await widget.locationService.fetchLocation(
        widget.locationId,
      );
      if (mounted) {
        setState(() {
          _cachedLocation = location;
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = error.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState();
    } else if (_errorMessage != null) {
      return _buildErrorState(_errorMessage!);
    } else if (_cachedLocation == null) {
      return _buildEmptyState();
    }

    return _buildMapContent(context, _cachedLocation!);
  }

  Widget _buildZoomControls() {
    return Positioned(
      top: 16,
      right: 16,
      child: Column(
        children: [
          // Zoom In Button
          _buildZoomButton(
            icon: Icons.add,
            onTap: _currentZoom < 19 ? _zoomIn : null,
            isTop: true,
          ),
          // Divider
          Container(width: 40, height: 1, color: Colors.grey.shade300),
          // Zoom Out Button
          _buildZoomButton(
            icon: Icons.remove,
            onTap: _currentZoom > 1 ? _zoomOut : null,
            isTop: false,
          ),
        ],
      ),
    );
  }

  Widget _buildZoomButton({
    required IconData icon,
    required VoidCallback? onTap,
    required bool isTop,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(isTop ? 8 : 0),
        topRight: Radius.circular(isTop ? 8 : 0),
        bottomLeft: Radius.circular(isTop ? 0 : 8),
        bottomRight: Radius.circular(isTop ? 0 : 8),
      ),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isTop ? 8 : 0),
          topRight: Radius.circular(isTop ? 8 : 0),
          bottomLeft: Radius.circular(isTop ? 0 : 8),
          bottomRight: Radius.circular(isTop ? 0 : 8),
        ),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300, width: 0.5),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(isTop ? 8 : 0),
              topRight: Radius.circular(isTop ? 8 : 0),
              bottomLeft: Radius.circular(isTop ? 0 : 8),
              bottomRight: Radius.circular(isTop ? 0 : 8),
            ),
          ),
          child: Icon(
            icon,
            color: onTap != null ? Colors.black87 : Colors.grey.shade400,
            size: 20,
          ),
        ),
      ),
    );
  }

  void _zoomIn() {
    final double minZoom = 5.0;
    final double maxZoom = 19.0;

    if (_currentZoom < maxZoom) {
      final newZoom = (_currentZoom + 1).clamp(minZoom, maxZoom);
      _mapController.move(_mapController.camera.center, newZoom);
      setState(() {
        _currentZoom = newZoom;
      });
    }
  }

  void _zoomOut() {
    final double minZoom = 8.0;
    final double maxZoom = 10.0;
    if (_currentZoom > minZoom) {
      final newZoom = (_currentZoom - 1).clamp(minZoom, maxZoom);
      _mapController.move(_mapController.camera.center, newZoom);
      setState(() {
        _currentZoom = newZoom;
      });
    }
  }

  Widget _buildLoadingState() {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading map...',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade400, size: 48),
            const SizedBox(height: 16),
            Text(
              'Failed to load location',
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                error,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red.shade600, fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadLocation,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, color: Colors.grey.shade400, size: 48),
            const SizedBox(height: 16),
            Text(
              'No location data available',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadLocation,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapContent(BuildContext context, Location location) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: latlng2.LatLng(
                        location.latitude,
                        location.longitude,
                      ),
                      initialZoom: _currentZoom,
                      onTap:
                          widget.onMapTap != null
                              ? (tapPosition, point) => widget.onMapTap!()
                              : null,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                      ),
                      onMapEvent: (event) {
                        if (event is MapEventMove && mounted) {
                          setState(() {
                            _currentZoom = event.camera.zoom;
                            final center = event.camera.center;
                            final isNotAtMarker =
                                (center.latitude - _cachedLocation!.latitude)
                                        .abs() >
                                    0.0002 ||
                                (center.longitude - _cachedLocation!.longitude)
                                        .abs() >
                                    0.0002;
                            _showRecenterButton = isNotAtMarker;
                          });
                        }
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.app',
                        maxZoom: 19,
                        errorTileCallback: (tile, error, stackTrace) {
                          debugPrint('Tile loading error: $error');
                        },
                      ),
                      MarkerLayer(
                        markers: [
                          // Marker destinasi utama
                          Marker(
                            key: ValueKey(
                              'marker_${location.latitude}_${location.longitude}',
                            ),
                            point: latlng2.LatLng(
                              location.latitude,
                              location.longitude,
                            ),
                            width: 100,
                            height: 60,
                            alignment: Alignment.bottomCenter,
                            child: _buildCustomMarker(),
                          ),
                          // Marker posisi user (jika sudah dapat)
                          if (_currentPosition != null)
                            Marker(
                              key: const ValueKey('marker_user_location'),
                              point: _currentPosition!,
                              width: 60,
                              height: 60,
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.my_location,
                                color: Colors.blue,
                                size: 38,
                                shadows: [
                                  Shadow(color: Colors.black26, blurRadius: 6),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  _buildZoomControls(),

                  // Tombol recenter ke destinasi utama (kanan bawah)
                  if (_showRecenterButton)
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: FloatingActionButton.small(
                        backgroundColor: Colors.blue.shade800,
                        foregroundColor: Colors.white,
                        heroTag: 'btnRecenter',
                        onPressed: () {
                          if (_cachedLocation != null) {
                            _mapController.move(
                              latlng2.LatLng(
                                _cachedLocation!.latitude,
                                _cachedLocation!.longitude,
                              ),
                              _currentZoom,
                            );
                            setState(() {
                              _showRecenterButton = false;
                            });
                          }
                        },
                        child: const Icon(Icons.navigation),
                        tooltip: "Arahkan ke lokasi utama",
                      ),
                    ),

                  // Tombol ke posisi user (kiri bawah)
                  if (_currentPosition != null)
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: FloatingActionButton.small(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                        heroTag: 'btnToCurrentLocation',
                        onPressed: () {
                          _mapController.move(_currentPosition!, _currentZoom);
                        },
                        child: const Icon(Icons.my_location),
                        tooltip: "Arahkan ke posisi saya",
                      ),
                    ),
                ],
              ),
            ),

            _buildLocationInfo(location),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomMarker() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label di atas marker
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Text(
            'Toko Kami',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 4),
        // Marker icon
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.red.shade600,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(Icons.store, color: Colors.white, size: 18),
        ),
      ],
    );
  }

  Widget _buildLocationInfo(Location location) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            location.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),

          Text(
            location.alamat,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            children: [
              Icon(Icons.my_location, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                    fontFamily: 'monospace',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
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
  late LocationService locationService;

  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final FocusNode _searchFocusNode = FocusNode();
  bool _showClearButton = false;

  @override
  void initState() {
    super.initState();
    locationService = LocationService(baseUrl: 'http://192.168.1.17:8000');
    // Ambil data destinasi untuk list/grid
    Future.microtask(() {
      final provider = Provider.of<DestinasiProvider>(context, listen: false);
      final token = Provider.of<AuthProvider>(context, listen: false).token!;
      provider.fetchCarouselDestinasi(token);
      final activityProvider = Provider.of<ActivityProvider>(
        context,
        listen: false,
      );
      activityProvider.fetchActivities();

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
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userName = authProvider.user?.nama ?? 'User';

    return AppBar(
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade700, Colors.blue.shade900],
          ),
        ),
      ),
      title: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child:
            _isSearching
                ? Container(
                  key: const ValueKey('search'),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    autofocus: true,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      hintText: 'Cari destinasi wisata...',
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.white.withOpacity(0.8),
                        size: 22,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                    ),
                  ),
                )
                : Row(
                  key: const ValueKey('title'),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.waving_hand,
                        color: Colors.amber.shade300,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Selamat datang, $userName',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Temukan destinasi wisata impianmu',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.8),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
      ),
      leading:
          _isSearching
              ? Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: _toggleSearch,
                  splashRadius: 20,
                ),
              )
              : null,
      actions: [
        if (!_isSearching)
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: _toggleSearch,
              splashRadius: 20,
              tooltip: 'Cari destinasi',
            ),
          ),
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
            Column(
              children: [
                // Popular Activities Section
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.grey.shade50, Colors.white],
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 32,
                    horizontal: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title with improved styling
                      Center(
                        child: Column(
                          children: [
                            Text(
                              'Aktivitas Populer',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey.shade800,
                                letterSpacing: 0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: 60,
                              height: 3,
                              decoration: BoxDecoration(
                                color: Colors.blue.shade600,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      Consumer<ActivityProvider>(
                        builder: (context, activityProvider, child) {
                          if (activityProvider.isLoading) {
                            return Container(
                              height: 200,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.blue.shade600,
                                      ),
                                      strokeWidth: 3,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Memuat aktivitas...',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          if (activityProvider.error != null) {
                            return Container(
                              padding: const EdgeInsets.all(24),
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.red.shade200,
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.red.shade600,
                                    size: 32,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Terjadi Kesalahan',
                                    style: TextStyle(
                                      color: Colors.red.shade800,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Error: ${activityProvider.error}',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.red.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          final activities = activityProvider.activities;
                          if (activities.isEmpty) {
                            return Container(
                              height: 160,
                              padding: const EdgeInsets.all(24),
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.inbox_outlined,
                                    color: Colors.grey.shade500,
                                    size: 32,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Tidak Ada Aktivitas',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Belum ada aktivitas yang tersedia',
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          }

                          // Grid with improved styling
                          const int crossAxisCount = 3;
                          const double childAspectRatio = 0.75;

                          return LayoutBuilder(
                            builder: (context, constraints) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: crossAxisCount,
                                        mainAxisSpacing: 16,
                                        crossAxisSpacing: 12,
                                        childAspectRatio: childAspectRatio,
                                      ),
                                  itemCount: activities.length,
                                  itemBuilder: (context, index) {
                                    final activity = activities[index];
                                    final imageUrl =
                                        (activity.image != null &&
                                                activity.image!.isNotEmpty)
                                            ? activity.image!
                                            : 'assets/images/mendaki.png';
                                    return _buildActivityCardHorizontal(
                                      imageUrl,
                                      activity.title,
                                    );
                                  },
                                ),
                              );
                            },
                          );
                        },
                      ),

                      const SizedBox(height: 32),

                      // Store Location Title with improved styling
                      Center(
                        child: Column(
                          children: [
                            Text(
                              'Lokasi Toko',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey.shade800,
                                letterSpacing: 0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: 50,
                              height: 3,
                              decoration: BoxDecoration(
                                color: Colors.green.shade600,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Map Section with improved styling
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      height: 300,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: MapFromApi(
                        locationService: locationService,
                        locationId: 1,
                      ),
                    ),
                  ),
                ),

                // Bottom spacing
                const SizedBox(height: 20),
              ],
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
                              wishlistProvider.removeWishlist(destinasi.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${destinasi.nama} dihapus dari wishlist',
                                  ),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            } else {
                              wishlistProvider.addWishlist(destinasi.id);

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

  Widget _buildActivityCardHorizontal(String imageUrl, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            imageUrl,
            width: 140,
            height: 100,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 140,
                height: 100,
                color: Colors.grey.shade300,
                child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ],
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
