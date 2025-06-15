import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:travelapp/models/destinasi.dart';
import 'package:travelapp/models/kendaraan.dart';
import 'package:travelapp/models/pemesanan.dart';
import 'package:travelapp/screens/user/pembayaran_screen.dart';
import 'package:travelapp/services/kendaraan_service.dart';
import 'package:travelapp/providers/auth_provider.dart';
import 'package:travelapp/providers/order_provider.dart';

class PilihKursiScreen extends StatefulWidget {
  final Destinasi destinasi;
  final Kendaraan kendaraan;

  const PilihKursiScreen({
    super.key,
    required this.destinasi,
    required this.kendaraan,
  });

  @override
  State<PilihKursiScreen> createState() => _PilihKursiScreenState();
}

class _PilihKursiScreenState extends State<PilihKursiScreen>
    with WidgetsBindingObserver {
  List<int> selectedSeats = [];
  late double totalPrice;
  late Kendaraan _currentKendaraan;
  final TextEditingController _passengersController =
      TextEditingController(text: '1');

  bool _isHoldingSeats = false;

  static const Color primaryColor = Color(0xFF3498DB);
  static const Color secondaryColor = Color(0xFFFF9800);
  static const Color darkColor = Color(0xFF2C3E50);
  static const Color lightColor = Color(0xFFF5F7FA);
  static const Color unavailableColor = Color(0xFFE74C3C);
  static const Color heldColor = Color(0xFFF39C12);
  static const Color accentColor = Color(0xFF1ABC9C);

  @override
  void initState() {
    super.initState();
    _currentKendaraan = widget.kendaraan;
    _updateTotalPrice();
    _fetchLatestKendaraanData();
    WidgetsBinding.instance.addObserver(this);

    _passengersController.addListener(_onPassengerCountChanged);
  }

  @override
  void dispose() {
    _passengersController.removeListener(_onPassengerCountChanged);
    _passengersController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _fetchLatestKendaraanData();
    }
  }

  void _onPassengerCountChanged() {
    setState(() {
      final int maxPassengers = int.tryParse(_passengersController.text) ?? 1;
      if (selectedSeats.length > maxPassengers) {
        selectedSeats = selectedSeats.sublist(0, maxPassengers);
      }
      _updateTotalPrice();
    });
  }

  Future<void> _fetchLatestKendaraanData() async {
    print("DEBUG: Fetching latest kendaraan data...");
    try {
      final List<Kendaraan> fetchedList =
          await KendaraanService.getKendaraanByDestinasi(widget.destinasi.id);
      final Kendaraan? latestData = fetchedList.firstWhere(
        (k) => k.id == widget.kendaraan.id,
        orElse: () => widget.kendaraan,
      );

      if (mounted && latestData != null) {
        setState(() {
          _currentKendaraan = latestData;
          selectedSeats.removeWhere((seat) =>
              !_currentKendaraan.availableSeats.contains(seat) ||
              _currentKendaraan.heldSeats.contains(seat));
          _updateTotalPrice();
        });
        print(
            "DEBUG: Data kendaraan diperbarui. Kursi tersedia: ${_currentKendaraan.availableSeats}. Kursi ditahan: ${_currentKendaraan.heldSeats}. Kursi terpilih setelah refresh: $selectedSeats");
      }
    } catch (e) {
      print("Error refreshing kendaraan data: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "Gagal memuat ketersediaan kursi terbaru: ${e.toString()}")),
        );
      }
    }
  }

  void _updateTotalPrice() {
    final int passengerCount = selectedSeats.isNotEmpty ? selectedSeats.length : 0;
    setState(() {
      totalPrice = widget.destinasi.harga.toDouble() * passengerCount;
    });
  }

  String formatRupiah(dynamic price) {
    try {
      double numericPrice = (price ?? 0.0).toDouble();
      final formatter = NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp',
        decimalDigits: 0,
      );
      return formatter.format(numericPrice);
    } catch (e) {
      return 'Rp 0';
    }
  }

  void _toggleSeat(int seatNumber) {
    if (_currentKendaraan.heldSeats.contains(seatNumber)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            'Kursi $seatNumber sedang ditahan. Silakan pilih kursi lain.'),
        backgroundColor: heldColor,
        duration: const Duration(seconds: 2),
      ));
      return;
    }

    if (!_currentKendaraan.availableSeats.contains(seatNumber)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Kursi $seatNumber tidak tersedia. Silakan refresh.'),
        backgroundColor: unavailableColor,
        duration: const Duration(seconds: 2),
      ));
      return;
    }

    setState(() {
      final int maxPassengers = int.tryParse(_passengersController.text) ?? 1;
      if (selectedSeats.contains(seatNumber)) {
        selectedSeats.remove(seatNumber);
      } else {
        if (selectedSeats.length < maxPassengers) {
          selectedSeats.add(seatNumber);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Anda hanya bisa memilih $maxPassengers kursi.'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
      selectedSeats.sort();
      _updateTotalPrice();
    });
  }

  Future<void> _processBooking() async {
    if (_isHoldingSeats) return;

    final int numberOfPassengers = int.tryParse(_passengersController.text) ?? 0;
    if (selectedSeats.isEmpty ||
        selectedSeats.length != numberOfPassengers ||
        numberOfPassengers == 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Jumlah kursi (${selectedSeats.length}) harus sama dengan jumlah penumpang ($numberOfPassengers) dan tidak boleh kosong.'),
            backgroundColor: unavailableColor,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    setState(() {
      _isHoldingSeats = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor)),
      ),
    );

    List<int> successfullyHeldSeats = [];

    try {
      // LANGKAH 1: TAHAN KURSI
      final heldKendaraan = await KendaraanService.holdKendaraanSeats(
        _currentKendaraan.id,
        selectedSeats,
      );
      successfullyHeldSeats = List.from(selectedSeats);
      print("✅ Kursi berhasil ditahan di backend: $successfullyHeldSeats");

      // LANGKAH 2: BUAT PEMESANAN
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.id;

      if (userId == null || !authProvider.isAuthenticated) {
        throw Exception('User tidak terautentikasi. Silakan login kembali.');
      }

      final pemesananUntukDikirim = Pemesanan(
        id: '',
        userId: userId,
        destinasi: widget.destinasi,
        kendaraan: heldKendaraan,
        selectedSeats: selectedSeats,
        jumlahPeserta: selectedSeats.length,
        tanggal: DateTime.now(),
        totalHarga: totalPrice,
        status: 'menunggu pembayaran',
      );

      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      final createdPemesanan = await orderProvider.addOrder(pemesananUntukDikirim);
      print(
          "✅ Pemesanan berhasil dibuat di backend dengan ID: ${createdPemesanan.id}");

      if (mounted) {
        Navigator.of(context).pop(); // Tutup loading

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pemesanan berhasil dibuat! Melanjutkan ke pembayaran.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // LANGKAH 3: NAVIGASI KE PEMBAYARAN
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (ctx) => PembayaranScreen(
              pemesanan: createdPemesanan,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop(); // Tutup loading

      print("❌ Terjadi error pada proses booking: $e");
      String errorMessage = 'Gagal memesan. Silakan coba lagi.';
      if (e.toString().contains('Conflict')) {
        errorMessage = 'Beberapa kursi yang Anda pilih sudah tidak tersedia.';
      } else {
        errorMessage = e.toString().replaceAll('Exception: ', '');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(errorMessage),
          backgroundColor: unavailableColor,
          duration: const Duration(seconds: 4),
        ));
      }

      // LOGIKA PENTING: Lepaskan kursi jika booking gagal setelah ditahan
      if (successfullyHeldSeats.isNotEmpty) {
        print(
            "🔁 Mencoba melepaskan kursi yang gagal dipesan: $successfullyHeldSeats");
        try {
          await KendaraanService.releaseHeldSeats(
              _currentKendaraan.id, successfullyHeldSeats);
          print("✅ Kursi berhasil dilepaskan kembali.");
        } catch (releaseError) {
          print("‼️ Gagal melepaskan kursi secara otomatis: $releaseError");
        }
      }

      await _fetchLatestKendaraanData();
    } finally {
      if (mounted) {
        setState(() {
          _isHoldingSeats = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightColor,
      appBar: AppBar(
        title: const Text(
          'Pilih Kursi',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: Column(
        children: [
          // Vehicle Info Card - Compacted
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 8), // Reduced top/bottom margin
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10, // Slightly less blur
                  offset: const Offset(0, 4), // Slightly less offset
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12), // Reduced padding
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8), // Reduced padding
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.directions_bus_rounded,
                          color: primaryColor,
                          size: 24, // Smaller icon
                        ),
                      ),
                      const SizedBox(width: 12), // Reduced space
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _currentKendaraan.jenis,
                              style: const TextStyle(
                                fontSize: 18, // Slightly smaller font
                                fontWeight: FontWeight.bold,
                                color: darkColor,
                              ),
                            ),
                            const SizedBox(height: 2), // Reduced space
                            Text(
                              '${_currentKendaraan.kapasitas} kursi · ${_currentKendaraan.tipe}',
                              style: TextStyle(
                                fontSize: 13, // Slightly smaller font
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12), // Reduced padding
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Harga per kursi',
                                style: TextStyle(
                                  fontSize: 12, // Reduced font size
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 2), // Reduced space
                              Text(
                                formatRupiah(widget.destinasi.harga),
                                style: const TextStyle(
                                  fontSize: 16, // Reduced font size
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10, // Reduced padding
                              vertical: 6, // Reduced padding
                            ),
                            decoration: BoxDecoration(
                              color: secondaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(18), // Slightly smaller radius
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.chair_alt_outlined,
                                  size: 16, // Reduced icon size
                                  color: secondaryColor,
                                ),
                                const SizedBox(width: 4), // Reduced space
                                Text(
                                  'Terpilih: ${selectedSeats.length}',
                                  style: const TextStyle(
                                    fontSize: 13, // Reduced font size
                                    fontWeight: FontWeight.w600,
                                    color: secondaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12), // Reduced space
                      // Input jumlah peserta - Compacted
                      TextField(
                        controller: _passengersController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Jumlah Penumpang',
                          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12), // Reduced content padding
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10), // Slightly smaller radius
                          ),
                          filled: true,
                          fillColor: lightColor,
                          suffixIcon: const Icon(Icons.group, size: 20), // Smaller icon
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Legend - Compacted
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Reduced vertical padding
            child: Row(
              children: [
                _buildLegendItem(primaryColor, 'Terpilih'),
                const SizedBox(width: 8), // Reduced space
                _buildLegendItem(lightColor, 'Tersedia'),
                const SizedBox(width: 8), // Reduced space
                _buildLegendItem(heldColor.withOpacity(0.4), 'Ditahan'),
                const SizedBox(width: 8), // Reduced space
                _buildLegendItem(unavailableColor.withOpacity(0.2), 'Tidak tersedia'),
              ],
            ),
          ),

          const SizedBox(height: 12), // Reduced space

          // Seat Selection Area - Expanded and Compacted
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Driver Area - Compacted
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12), // Reduced padding
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Area Pengemudi',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14, // Reduced font size
                            color: darkColor.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 8), // Reduced space
                        _buildDriverSeat(), // Use a dedicated widget for driver seat
                        Container(
                          margin: const EdgeInsets.only(top: 12), // Reduced margin
                          height: 1,
                          color: Colors.grey[300],
                        ),
                      ],
                    ),
                  ),

                  // Passenger Seats - Main focus
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12), // Reduced padding
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5, // Coba 5 kolom agar lebih padat
                          childAspectRatio: 0.8, // Slightly taller than wide for better number visibility
                          mainAxisSpacing: 8, // Reduced spacing
                          crossAxisSpacing: 8, // Reduced spacing
                        ),
                        itemCount: _currentKendaraan.kapasitas,
                        itemBuilder: (context, index) {
                          int seatNumber = index + 1;
                          return _buildSeat(seatNumber);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, -3),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Harga:',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatRupiah(totalPrice),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: darkColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: (selectedSeats.length ==
                                (int.tryParse(_passengersController.text) ??
                                    0) &&
                                selectedSeats.isNotEmpty &&
                                !_isHoldingSeats &&
                                (int.tryParse(_passengersController.text) ?? 0) > 0)
                        ? _processBooking
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey[300],
                      elevation: (selectedSeats.length == (int.tryParse(_passengersController.text) ?? 0) &&
                                selectedSeats.isNotEmpty &&
                                (int.tryParse(_passengersController.text) ?? 0) > 0) ? 2 : 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isHoldingSeats
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'LANJUTKAN',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 20,
                                color: (selectedSeats.length ==
                                            (int.tryParse(_passengersController.text) ?? 0) &&
                                        selectedSeats.isNotEmpty)
                                    ? Colors.white
                                    : Colors.grey[400],
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDriverSeat() {
    return Container(
      width: 50, // More compact driver seat
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10), // Slightly smaller radius
        border: Border.all(color: Colors.grey[400]!, width: 2),
      ),
      child: const Center(
        child: Icon(
          Icons.drive_eta,
          size: 28, // Smaller icon
          color: darkColor,
        ),
      ),
    );
  }

  Widget _buildSeat(int seatNumber) {
    bool isAvailable = _currentKendaraan.availableSeats.contains(seatNumber);
    bool isHeld = _currentKendaraan.heldSeats.contains(seatNumber);
    bool isSelected = selectedSeats.contains(seatNumber);

    Color seatColor;
    Color borderColor;
    Color textColor;

    if (isSelected) {
      seatColor = primaryColor;
      borderColor = primaryColor;
      textColor = Colors.white;
    } else if (isHeld) {
      seatColor = heldColor.withOpacity(0.2);
      borderColor = heldColor;
      textColor = heldColor.darken(0.3);
    } else if (isAvailable) {
      seatColor = lightColor;
      borderColor = Colors.grey[300]!;
      textColor = darkColor;
    } else { // Unavailable
      seatColor = unavailableColor.withOpacity(0.1);
      borderColor = unavailableColor;
      textColor = unavailableColor.darken(0.3);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      // Fixed size for seat boxes, will be scaled by GridView's childAspectRatio
      decoration: BoxDecoration(
        color: seatColor,
        borderRadius: BorderRadius.circular(10), // Slightly smaller radius
        border: Border.all(
          color: borderColor,
          width: 1.5, // Slightly thinner border for smaller seats
        ),
        boxShadow: [
          if (isSelected)
            BoxShadow(
              color: primaryColor.withOpacity(0.4),
              blurRadius: 6, // Reduced blur
              offset: const Offset(0, 2), // Reduced offset
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isAvailable && !isHeld ? () => _toggleSeat(seatNumber) : null,
          borderRadius: BorderRadius.circular(8), // Match container radius
          splashColor: primaryColor.withOpacity(0.1),
          highlightColor: primaryColor.withOpacity(0.05),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                seatNumber.toString(),
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14, // Smaller font for seat number
                ),
              ),
              const Icon(
                Icons.event_seat,
                size: 16, // Smaller icon
                color: Colors.transparent, // Icon is just for visual structure, color handled by text/background
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), // Reduced padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20), // Maintain roundness
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 3, // Reduced blur
            offset: const Offset(0, 1), // Reduced offset
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 18, // Smaller color swatch
            height: 18, // Smaller color swatch
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: color == lightColor ? Colors.grey[400]! : color.darken(0.1),
                width: 1.0, // Thinner border
              ),
            ),
          ),
          const SizedBox(width: 6), // Reduced space
          Text(
            text,
            style: TextStyle(
              fontSize: 12, // Reduced font size
              fontWeight: FontWeight.w500,
              color: darkColor.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}

// Extension to darken a color, useful for borders/text with translucent backgrounds
extension ColorBrightness on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}