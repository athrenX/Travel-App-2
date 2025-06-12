import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart'; // Import provider
import 'package:travelapp/models/destinasi.dart';
import 'package:travelapp/models/kendaraan.dart';
import 'package:travelapp/screens/user/pemesanan_screen.dart';
import 'package:travelapp/services/kendaraan_service.dart'; // Import service
import 'package:travelapp/providers/kendaraan_provider.dart'; // Import KendaraanProvider

class PilihKursiScreen extends StatefulWidget {
  final Destinasi destinasi;
  final Kendaraan kendaraan; // Kendaraan yang sudah dipilih

  const PilihKursiScreen({
    super.key,
    required this.destinasi,
    required this.kendaraan,
  });

  @override
  State<PilihKursiScreen> createState() => _PilihKursiScreenState();
}

class _PilihKursiScreenState extends State<PilihKursiScreen> {
  List<int> selectedSeats = [];
  late double totalPrice;
  late Kendaraan _currentKendaraan; // State lokal untuk menyimpan data kendaraan terbaru
  final TextEditingController _passengersController = TextEditingController(text: '1'); // Default 1 penumpang

  // Enhanced color scheme
  static const Color primaryColor = Color(0xFF3498DB);
  static const Color secondaryColor = Color(0xFFFF9800);
  static const Color darkColor = Color(0xFF2C3E50);
  static const Color lightColor = Color(0xFFF5F7FA);
  static const Color unavailableColor = Color(0xFFE74C3C);
  static const Color accentColor = Color(0xFF1ABC9C);

  @override
  void initState() {
    super.initState();
    _currentKendaraan = widget.kendaraan; // Inisialisasi dengan data dari widget
    _updateTotalPrice(); // Hitung total harga awal
  }

  @override
  void dispose() {
    _passengersController.dispose();
    super.dispose();
  }

  // Method untuk menghitung ulang total harga berdasarkan jumlah kursi yang dipilih
  void _updateTotalPrice() {
    setState(() {
      totalPrice = widget.destinasi.harga.toDouble() * selectedSeats.length;
    });
  }

  // Format rupiah
  String formatRupiah(dynamic price) {
    try {
      double numericPrice = price is int
          ? price.toDouble()
          : price is double
              ? price
              : 0.0;
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
    setState(() {
      final int maxPassengers = int.tryParse(_passengersController.text) ?? 1;

      if (selectedSeats.contains(seatNumber)) {
        selectedSeats.remove(seatNumber);
      } else {
        // Hanya tambahkan kursi jika jumlah kursi terpilih belum mencapai jumlah peserta
        if (selectedSeats.length < maxPassengers) {
          selectedSeats.add(seatNumber);
        } else {
          // Beri tahu pengguna jika melebihi batas
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Anda hanya bisa memilih $maxPassengers kursi.'),
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
      selectedSeats.sort(); // Urutkan kursi yang dipilih
      _updateTotalPrice();
    });
  }

  // Method untuk membangun tampilan kursi
  Widget _buildSeat(
    int seatNumber, {
    bool isDriver = false,
  }) {
    // Kursi tersedia jika ada di _currentKendaraan.availableSeats
    bool isAvailable = _currentKendaraan.availableSeats.contains(seatNumber);
    bool isSelected = selectedSeats.contains(seatNumber);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: 52,
      height: 52,
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color:
            isDriver
                ? Colors.grey[200]
                : isSelected
                    ? primaryColor
                    : isAvailable
                        ? lightColor
                        : unavailableColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isDriver
                  ? Colors.grey
                  : isSelected
                      ? primaryColor
                      : isAvailable
                          ? Colors.grey[300]!
                          : unavailableColor,
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
          onTap: isAvailable && !isDriver ? () => _toggleSeat(seatNumber) : null,
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
                        color:
                            isSelected
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

  // Method untuk handle proses pemesanan dan update kursi di backend
  Future<void> _processBooking() async {
    if (selectedSeats.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap pilih setidaknya satu kursi.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final int numberOfPassengers = int.tryParse(_passengersController.text) ?? 0;
    if (numberOfPassengers == 0 || selectedSeats.length != numberOfPassengers) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Jumlah kursi yang dipilih harus sama dengan jumlah peserta ($numberOfPassengers kursi).'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Tampilkan loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(primaryColor)),
      ),
    );

    try {
      // Panggil API untuk mengupdate kursi
      final updatedKendaraan = await KendaraanService.updateKendaraanSeats(
        _currentKendaraan.id,
        selectedSeats,
      );

      // Setelah berhasil update di backend, update state di provider
      Provider.of<KendaraanProvider>(context, listen: false)
          .updateKendaraanInList(updatedKendaraan);

      if (mounted) {
        Navigator.of(context).pop(); // Tutup dialog loading

        // Lanjutkan ke layar pemesanan
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (ctx) => PemesananScreen(
              destinasi: widget.destinasi,
              kendaraan: updatedKendaraan, // Kirim data kendaraan terbaru
              selectedSeats: selectedSeats,
              totalPrice: totalPrice.toInt(),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Tutup dialog loading
        // Tampilkan pesan error kepada pengguna
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memesan kursi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      // Opsional: Muat ulang data kendaraan jika ada konflik kursi
      if (e.toString().contains('Kursi') && e.toString().contains('tidak tersedia')) {
          _reloadKendaraanData(); // Reload untuk menampilkan status kursi terbaru
      }
    }
  }

  // Fungsi untuk memuat ulang data kendaraan jika terjadi konflik kursi
  Future<void> _reloadKendaraanData() async {
    try {
      final updatedList = await KendaraanService.getKendaraanByDestinasi(widget.destinasi.id);
      final refreshedKendaraan = updatedList.firstWhere((k) => k.id == _currentKendaraan.id, orElse: () => _currentKendaraan);

      setState(() {
        _currentKendaraan = refreshedKendaraan;
        selectedSeats.clear(); // Bersihkan pilihan kursi yang mungkin sudah stale
        _updateTotalPrice();
      });
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data kursi telah diperbarui. Silakan pilih kembali.'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat ulang data kendaraan: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


  // Method untuk membangun item legenda
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
                          labelText: 'Jumlah Penumpang (yang akan memesan)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: lightColor,
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: () {
                              setState(() {
                                selectedSeats.clear(); // Clear selected seats when passenger count changes
                                _updateTotalPrice();
                              });
                            },
                          ),
                        ),
                        onChanged: (text) {
                          // Clear selected seats when passenger count changes
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
                        Center(child: _buildSeat(0, isDriver: true)),
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
                          crossAxisCount: 4, // Ubah menjadi 4 kolom untuk tampilan kursi lebih baik
                          childAspectRatio: 1, // Sesuaikan rasio aspek
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                        ),
                        itemCount: _currentKendaraan.kapasitas, // Gunakan kapasitas dari data kendaraan
                        itemBuilder: (context, index) {
                          int seatNumber = index + 1;
                          return _buildSeat(seatNumber); // isAvailable dicek di _buildSeat
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
                    onPressed: selectedSeats.length == (int.tryParse(_passengersController.text) ?? 0) && selectedSeats.isNotEmpty
                        ? _processBooking
                        : null, // Tombol hanya aktif jika jumlah kursi terpilih sesuai dengan jumlah peserta
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
                    child: Row(
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
                          color: selectedSeats.length == (int.tryParse(_passengersController.text) ?? 0) && selectedSeats.isNotEmpty
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
}