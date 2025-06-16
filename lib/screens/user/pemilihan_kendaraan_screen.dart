import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:travelapp/models/destinasi.dart';
import 'package:travelapp/models/kendaraan.dart';
import 'package:travelapp/providers/kendaraan_provider.dart';
import 'package:travelapp/screens/user/pilih_kursi_screen.dart';
import 'package:travelapp/widgets/kendaraan_card.dart'; // <--- PASTIKAN PATH INI BENAR!

class PemilihanKendaraanScreen extends StatefulWidget {
  final Destinasi destinasi;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;

  const PemilihanKendaraanScreen({
    super.key,
    required this.destinasi,
    required this.selectedDate,
    required this.selectedTime,
  });

  @override
  State<PemilihanKendaraanScreen> createState() =>
      _PemilihanKendaraanScreenState();
}

class _PemilihanKendaraanScreenState extends State<PemilihanKendaraanScreen> {
  Kendaraan? selectedKendaraan;
  bool _hasInitialized = false;

  static const Color primaryBlue = Color(0xFF1A73E8);
  static const Color darkBlue = Color(0xFF0D47A1);
  static const Color lightBlue = Color(0xFFE8F0FE);
  static const Color whiteColor = Colors.white;
  static const Color cardShadowColor = Color(0x1A000000);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasInitialized) {
        _loadKendaraan();
        _hasInitialized = true;
      }
    });
  }

  Future<void> _loadKendaraan() async {
    try {
      await Provider.of<KendaraanProvider>(
        context,
        listen: false,
      ).fetchKendaraanByDestinasi(widget.destinasi.id);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data kendaraan: ${error.toString()}'),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  // Fungsi _filterKendaraan (tidak digunakan, tapi dibiarkan sebagai placeholder jika ada logika lain)
  List<Kendaraan> _filterKendaraan(List<Kendaraan> list) {
    return list; // Mengembalikan semua kendaraan karena filter tipe sudah dihapus
  }

  void _showVehicleImageDialog(Kendaraan kendaraan) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                color: lightBlue,
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: kendaraan.gambar.isNotEmpty
                    ? FadeInImage.assetNetwork(
                        placeholder:
                            'assets/images/loading.gif', // Pastikan path placeholder benar
                        image: kendaraan.gambar,
                        fit: BoxFit.cover,
                        imageErrorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.directions_bus,
                              size: 60,
                              color: primaryBlue,
                            ),
                          );
                        },
                      )
                    : const Center(
                        child: Icon(
                          Icons.directions_bus,
                          size: 60,
                          color: primaryBlue,
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    kendaraan.jenis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    Icons.category,
                    'Tipe: ${kendaraan.tipe}',
                  ),
                  _buildDetailRow(
                    Icons.people,
                    'Kapasitas: ${kendaraan.kapasitas} orang',
                  ),
                  _buildDetailRow(
                    Icons.speed,
                    'Fasilitas: ${kendaraan.fasilitas}',
                  ),
                  const SizedBox(height: 16),
                  Material(
                    elevation: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          selectedKendaraan = kendaraan;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: whiteColor,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('Pilih Kendaraan Ini'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[800],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBlue,
      appBar: AppBar(
        title: const Text(
          'Pilih Kendaraan',
          style: TextStyle(fontWeight: FontWeight.bold, color: whiteColor),
        ),
        backgroundColor: primaryBlue,
        elevation: 0,
        iconTheme: const IconThemeData(color: whiteColor),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadKendaraan,
        color: primaryBlue,
        backgroundColor: whiteColor,
        displacement: 40,
        strokeWidth: 3,
        child: Consumer<KendaraanProvider>(
          builder: (ctx, kendaraanProvider, _) {
            if (kendaraanProvider.isLoading && !_hasInitialized) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      color: primaryBlue,
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Memuat kendaraan...',
                      style: TextStyle(color: Colors.grey[700], fontSize: 16),
                    ),
                  ],
                ),
              );
            }

            final displayedList = _filterKendaraan(
              kendaraanProvider.kendaraanList,
            );

            if (displayedList.isEmpty && !kendaraanProvider.isLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/bus.jpg', // Pastikan path asset ini benar
                      height: 150,
                      color: primaryBlue.withOpacity(0.5),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Tidak ada kendaraan tersedia',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: darkBlue,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'Silakan coba lagi atau periksa koneksi internet Anda atau tambahkan kendaraan via admin panel.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _loadKendaraan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: whiteColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('MUAT ULANG'),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                // Display selected date and time
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: whiteColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: cardShadowColor,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: primaryBlue.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.location_on,
                                  color: primaryBlue,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  widget.destinasi.nama,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: darkBlue,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Divider(height: 1, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 18,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Tanggal: ${DateFormat('dd MMMM', 'id_ID').format(widget.selectedDate)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 18,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Waktu: ${widget.selectedTime.format(context)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Vehicle List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: displayedList.length,
                    itemBuilder: (ctx, index) {
                      final kendaraan = displayedList[index];
                      return KendaraanCardCustom( // <--- Ini widget yang dimaksud
                        kendaraan: kendaraan,
                        isSelected: selectedKendaraan?.id == kendaraan.id,
                        onTap: () {
                          setState(() {
                            selectedKendaraan = kendaraan;
                          });
                        },
                        onImageTap: () {
                          _showVehicleImageDialog(kendaraan);
                        },
                      );
                    },
                  ),
                ),

                // Continue Button
                if (selectedKendaraan != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: whiteColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: SafeArea(
                      child: SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (ctx) => PilihKursiScreen(
                                  destinasi: widget.destinasi,
                                  kendaraan: selectedKendaraan!,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            foregroundColor: whiteColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'LANJUT KE PEMESANAN',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}