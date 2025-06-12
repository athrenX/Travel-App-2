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
  }

  @override
  void dispose() {
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
              !_currentKendaraan.availableSeats.contains(seat));
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
              content:
                  Text("Gagal memuat ketersediaan kursi terbaru: ${e.toString()}")),
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
      ));
      return;
    }

    if (!_currentKendaraan.availableSeats.contains(seatNumber)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            'Kursi $seatNumber tidak tersedia. Silakan refresh.'),
        backgroundColor: unavailableColor,
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
        selectedSeats.length != numberOfPassengers) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Jumlah kursi (${selectedSeats.length}) harus sama dengan jumlah penumpang ($numberOfPassengers) dan tidak boleh kosong.'),
            backgroundColor: unavailableColor,
          ),
        );
      }
      return;
    }

    setState(() { _isHoldingSeats = true; });

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
      print("✅ Pemesanan berhasil dibuat di backend dengan ID: ${createdPemesanan.id}");

      if (mounted) {
        Navigator.of(context).pop(); // Tutup loading

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pemesanan berhasil dibuat! Melanjutkan ke pembayaran.'),
            backgroundColor: Colors.green,
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
        print("🔁 Mencoba melepaskan kursi yang gagal dipesan: $successfullyHeldSeats");
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
  
  // Widget build dan semua widget helper lainnya (seperti _buildSeat, dll)
  // tetap sama seperti yang sudah Anda miliki. Cukup salin dan tempel
  // seluruh isi kelas State ini.
  
  @override
  Widget build(BuildContext context) {
    // ... Seluruh kode UI Anda dari sini ke bawah tidak perlu diubah.
    // ... Cukup pastikan fungsi-fungsi di atas sudah benar.
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
          // Vehicle Info Card
          Container(
            margin: const EdgeInsets.fromLTRB(16, 20, 16, 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
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
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.directions_bus_rounded,
                          color: primaryColor,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _currentKendaraan.jenis,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: darkColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_currentKendaraan.kapasitas} kursi · ${_currentKendaraan.tipe}',
                              style: TextStyle(
                                fontSize: 14,
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
                  padding: const EdgeInsets.all(16),
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
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                formatRupiah(widget.destinasi.harga),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: secondaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.chair_alt_outlined,
                                  size: 18,
                                  color: secondaryColor,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Kursi terpilih: ${selectedSeats.length}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: secondaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Input jumlah peserta
                      TextField(
                        controller: _passengersController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Jumlah Penumpang',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: lightColor,
                          suffixIcon: const Icon(Icons.group),
                        ),
                        onChanged: (text) {
                          setState(() {
                            selectedSeats.clear();
                            _updateTotalPrice();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Legend
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildLegendItem(primaryColor, 'Terpilih'),
                const SizedBox(width: 10),
                _buildLegendItem(lightColor, 'Tersedia'),
                const SizedBox(width: 10),
                _buildLegendItem(heldColor, 'Ditahan'), // Legenda baru
                const SizedBox(width: 10),
                _buildLegendItem(unavailableColor, 'Tidak tersedia'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Seat Selection Area
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
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
                  // Driver Area
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
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
                            fontSize: 15,
                            color: darkColor.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Center(child: _buildSeat(0)),
                        Container(
                          margin: const EdgeInsets.only(top: 16),
                          height: 1,
                          color: Colors.grey[300],
                        ),
                      ],
                    ),
                  ),

                  // Passenger Seats
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          childAspectRatio: 1,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
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
                            !_isHoldingSeats)
                        ? _processBooking
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey[300],
                      elevation: selectedSeats.isNotEmpty ? 2 : 0,
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

  Widget _buildSeat(int seatNumber) {
    bool isDriver = seatNumber == 0;
    bool isAvailable = _currentKendaraan.availableSeats.contains(seatNumber);
    bool isHeld = _currentKendaraan.heldSeats.contains(seatNumber);
    bool isSelected = selectedSeats.contains(seatNumber);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: 52,
      height: 52,
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isDriver
            ? Colors.grey[200]
            : isSelected
                ? primaryColor
                : isHeld
                    ? heldColor.withOpacity(0.4) // Warna untuk ditahan
                    : isAvailable
                        ? lightColor
                        : unavailableColor
                            .withOpacity(0.2), // Warna untuk tidak tersedia
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDriver
              ? Colors.grey
              : isSelected
                  ? primaryColor
                  : isHeld
                      ? heldColor // Border untuk ditahan
                      : isAvailable
                          ? Colors.grey[300]!
                          : unavailableColor, // Border untuk tidak tersedia
          width: 2,
        ),
        boxShadow: [
          if (isSelected)
            BoxShadow(
              color: primaryColor.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap:
              isAvailable && !isDriver && !isHeld ? () => _toggleSeat(seatNumber) : null,
          borderRadius: BorderRadius.circular(10),
          splashColor: primaryColor.withOpacity(0.1),
          highlightColor: primaryColor.withOpacity(0.05),
          child: Center(
            child: isDriver
                ? const Icon(
                    Icons.airline_seat_recline_extra,
                    size: 28,
                    color: darkColor,
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        seatNumber.toString(),
                        style: TextStyle(
                          color: isSelected ? Colors.white : darkColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Icon(
                        Icons.event_seat,
                        size: 20,
                        color: isSelected
                            ? Colors.white
                            : darkColor.withOpacity(0.7),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: color == lightColor ? Colors.grey[300]! : color,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: darkColor.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}