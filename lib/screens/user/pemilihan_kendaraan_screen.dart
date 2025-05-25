import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:travelapp/models/destinasi.dart';
import 'package:travelapp/models/kendaraan.dart';
import 'package:travelapp/providers/kendaraan_provider.dart';
import 'package:travelapp/screens/user/pemesanan_screen.dart';
import 'package:travelapp/widgets/kendaraan_card.dart';
// Add this import with your other imports
import 'package:travelapp/screens/user/pilih_kursi_screen.dart';

class PemilihanKendaraanScreen extends StatefulWidget {
  final Destinasi destinasi;

  const PemilihanKendaraanScreen({Key? key, required this.destinasi})
    : super(key: key);

  @override
  State<PemilihanKendaraanScreen> createState() =>
      _PemilihanKendaraanScreenState();
}

class _PemilihanKendaraanScreenState extends State<PemilihanKendaraanScreen> {
  Kendaraan? selectedKendaraan;
  String selectedFilter = 'Semua';
  bool isLoading = false;

  // Enhanced color scheme
  static const Color primaryBlue = Color(0xFF1A73E8);
  static const Color darkBlue = Color(0xFF0D47A1);
  static const Color lightBlue = Color(0xFFE8F0FE);
  static const Color accentColor = Color(0xFF34A853);
  static const Color whiteColor = Colors.white;
  static const Color cardShadowColor = Color(0x1A000000);

  @override
  void initState() {
    super.initState();
    _loadKendaraan();
  }

  Future<void> _loadKendaraan() async {
    setState(() {
      isLoading = true;
    });
    try {
      await Provider.of<KendaraanProvider>(
        context,
        listen: false,
      ).fetchKendaraan();
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
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  List<Kendaraan> _filterKendaraan(List<Kendaraan> list) {
    if (selectedFilter == 'Semua') return list;

    return list
        .where(
          (k) =>
              (selectedFilter == 'Kecil' &&
                  (k.tipe == 'Minibus' || k.kapasitas <= 12)) ||
              (selectedFilter == 'Besar' &&
                  (k.tipe == 'Bus' || k.kapasitas > 12)),
        )
        .toList();
  }

  void _showVehicleImageDialog(Kendaraan kendaraan) {
    showDialog(
      context: context,
      builder:
          (ctx) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Gambar kendaraan - FIXED
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    color: lightBlue,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child:
                        kendaraan.gambar.isNotEmpty
                            ? FadeInImage.assetNetwork(
                              placeholder:
                                  'assets/images/loading.gif', // Add a loading placeholder to your assets
                              image: kendaraan.gambar,
                              fit: BoxFit.cover,
                              imageErrorBuilder:
                                  (context, error, stackTrace) => Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.directions_bus,
                                          size: 60,
                                          color: primaryBlue,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Gambar tidak tersedia',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                            )
                            : Center(
                              child: Icon(
                                Icons.directions_bus,
                                size: 60,
                                color: primaryBlue,
                              ),
                            ),
                  ),
                ),

                // Detail kendaraan
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        kendaraan.jenis,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
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
                      SizedBox(height: 16),
                      Text(
                        formatRupiah(kendaraan.harga),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryBlue,
                        ),
                      ),
                      SizedBox(height: 16),
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
                            minimumSize: Size(double.infinity, 50),
                          ),
                          child: Text('Pilih Kendaraan Ini'),
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
    return Row(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBlue,
      appBar: AppBar(
        title: const Text(
          'Pilih Kendaraan',
          style: TextStyle(
            color: whiteColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
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
            if (isLoading || kendaraanProvider.isLoading) {
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

            final kendaraanList = kendaraanProvider.kendaraanList;

            if (kendaraanList.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/no_vehicle.png',
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
                        'Silakan coba lagi atau periksa koneksi internet Anda',
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

            final filteredList = _filterKendaraan(kendaraanList);

            return Column(
              children: [
                // Destination Card
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
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.place,
                                          size: 18,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            widget.destinasi.lokasi,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[700],
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          size: 18,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 6),
                                        const Text(
                                          'Buka setiap hari',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: accentColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  formatRupiah(widget.destinasi.harga),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: accentColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Filter Section
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: whiteColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: cardShadowColor,
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'FILTER KENDARAAN',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildFilterChip('Semua'),
                              const SizedBox(width: 8),
                              _buildFilterChip('Kecil'),
                              const SizedBox(width: 8),
                              _buildFilterChip('Besar'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Results Count
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${filteredList.length} kendaraan ditemukan',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      if (selectedKendaraan != null)
                        Text(
                          '1 dipilih',
                          style: TextStyle(
                            color: primaryBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ),

                // Vehicle List
                Expanded(
                  child:
                      filteredList.isEmpty
                          ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.filter_alt_off,
                                  size: 60,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Tidak ada kendaraan\ndengan filter "$selectedFilter"',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      selectedFilter = 'Semua';
                                    });
                                  },
                                  child: const Text(
                                    'Reset Filter',
                                    style: TextStyle(
                                      color: primaryBlue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                          : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            itemCount: filteredList.length,
                            itemBuilder: (ctx, index) {
                              final kendaraan = filteredList[index];
                              return KendaraanCardCustom(
                                kendaraan: kendaraan,
                                isSelected:
                                    selectedKendaraan?.id == kendaraan.id,
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
                                builder:
                                    (ctx) => PilihKursiScreen(
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

  Widget _buildFilterChip(String label) {
    final isSelected = selectedFilter == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        setState(() {
          selectedFilter = label;
        });
      },
      labelStyle: TextStyle(
        color: isSelected ? whiteColor : Colors.grey[700],
        fontWeight: FontWeight.bold,
      ),
      selectedColor: primaryBlue,
      backgroundColor: whiteColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? primaryBlue : Colors.grey[300]!,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      visualDensity: VisualDensity.compact,
    );
  }

  String formatRupiah(dynamic price) {
    try {
      double numericPrice;

      if (price is int) {
        numericPrice = price.toDouble();
      } else if (price is double) {
        numericPrice = price;
      } else if (price is String) {
        String cleanPrice =
            price
                .replaceAll('Rp', '')
                .replaceAll('.', '')
                .replaceAll(',', '')
                .trim();
        numericPrice = double.tryParse(cleanPrice) ?? 0.0;
      } else {
        return 'Rp 0';
      }

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
}

class KendaraanCardCustom extends StatelessWidget {
  final Kendaraan kendaraan;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onImageTap;

  // Warna yang didefinisikan dalam class
  static const Color primaryBlue = Color(0xFF1A73E8);
  static const Color lightBlue = Color(0xFFE8F0FE);
  static const Color accentColor = Color(0xFF34A853);
  static const Color whiteColor = Colors.white;

  const KendaraanCardCustom({
    Key? key,
    required this.kendaraan,
    required this.isSelected,
    required this.onTap,
    required this.onImageTap,
  }) : super(key: key);

  // Method untuk format rupiah
  String formatRupiah(dynamic price) {
    try {
      double numericPrice =
          price is int
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

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Gambar kendaraan - FIXED
              GestureDetector(
                onTap: onImageTap,
                child: Container(
                  width: 100,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: lightBlue,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child:
                        kendaraan.gambar.isNotEmpty
                            ? FadeInImage.assetNetwork(
                              placeholder:
                                  'assets/images/loading.gif', // Add a loading placeholder image to your assets
                              image: kendaraan.gambar,
                              fit: BoxFit.cover,
                              imageErrorBuilder:
                                  (context, error, stackTrace) => Icon(
                                    Icons.directions_bus,
                                    size: 40,
                                    color: primaryBlue,
                                  ),
                            )
                            : Icon(
                              Icons.directions_bus,
                              size: 40,
                              color: primaryBlue,
                            ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Detail kendaraan
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      kendaraan.jenis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.category, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(kendaraan.tipe),
                        const SizedBox(width: 16),
                        Icon(Icons.people, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text('${kendaraan.kapasitas} orang'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      formatRupiah(kendaraan.harga),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),

              // Indikator terpilih
              if (isSelected) Icon(Icons.check_circle, color: primaryBlue),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatRupiah(dynamic price) {
  try {
    double numericPrice;

    if (price is int) {
      numericPrice = price.toDouble();
    } else if (price is double) {
      numericPrice = price;
    } else if (price is String) {
      String cleanPrice =
          price
              .replaceAll('Rp', '')
              .replaceAll('.', '')
              .replaceAll(',', '')
              .trim();
      numericPrice = double.tryParse(cleanPrice) ?? 0.0;
    } else {
      return 'Rp 0';
    }

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
