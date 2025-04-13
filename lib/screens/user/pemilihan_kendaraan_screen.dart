import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:travelapp/models/destinasi.dart';
import 'package:travelapp/models/kendaraan.dart';
import 'package:travelapp/providers/kendaraan_provider.dart';
import 'package:travelapp/screens/user/pemesanan_screen.dart';
import 'package:travelapp/widgets/kendaraan_card.dart';

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

  // Warna tema biru-putih
  static const Color primaryBlue = Color(0xFF1A5CAB);
  static const Color secondaryBlue = Color(0xFF2D82D7);
  static const Color lightBlue = Color(0xFFE8F3FF);
  static const Color whiteColor = Colors.white;

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
            backgroundColor: Colors.red,
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

  // Filter kendaraan berdasarkan kategori
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

  // Menampilkan dialog dengan gambar kendaraan
  void _showVehicleImageDialog(Kendaraan kendaraan) {
    showDialog(
      context: context,
      builder:
          (ctx) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child:
                      kendaraan.gambar.isNotEmpty
                          ? Image.asset(
                            kendaraan.gambar,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                          : Container(
                            height: 200,
                            width: double.infinity,
                            color: Colors.grey.shade300,
                            child: const Icon(
                              Icons.directions_bus,
                              size: 80,
                              color: Colors.grey,
                            ),
                          ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        kendaraan.jenis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.category,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Tipe: ${kendaraan.tipe}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.people,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Kapasitas: ${kendaraan.kapasitas} orang',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.attach_money,
                            size: 16,
                            color: primaryBlue,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Harga: ${formatRupiah(kendaraan.harga)}',
                            style: const TextStyle(
                              color: primaryBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            setState(() {
                              selectedKendaraan = kendaraan;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            foregroundColor: whiteColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: const Text(
          'Pilih Kendaraan',
          style: TextStyle(color: whiteColor),
        ),
        backgroundColor: primaryBlue,
        elevation: 0,
        iconTheme: const IconThemeData(color: whiteColor),
      ),
      body: RefreshIndicator(
        onRefresh: _loadKendaraan,
        color: primaryBlue,
        child: Consumer<KendaraanProvider>(
          builder: (ctx, kendaraanProvider, _) {
            if (isLoading || kendaraanProvider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: primaryBlue),
              );
            }

            final kendaraanList = kendaraanProvider.kendaraanList;

            if (kendaraanList.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.directions_car,
                      size: 80,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Tidak ada kendaraan tersedia.',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadKendaraan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: whiteColor,
                      ),
                      child: const Text('Coba lagi'),
                    ),
                  ],
                ),
              );
            }

            final filteredList = _filterKendaraan(kendaraanList);

            return Column(
              children: [
                // Informasi Destinasi Card
                Card(
                  margin: const EdgeInsets.all(16),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: whiteColor,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: primaryBlue),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.destinasi.nama,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.map,
                                    color: Colors.grey.shade700,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      widget.destinasi.lokasi,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade700,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  formatRupiah(widget.destinasi.harga),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: primaryBlue,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Filter Kendaraan
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  color: lightBlue,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Filter Kendaraan:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            FilterChip(
                              label: const Text('Semua'),
                              selected: selectedFilter == 'Semua',
                              onSelected: (val) {
                                setState(() {
                                  selectedFilter = 'Semua';
                                });
                              },
                              backgroundColor: whiteColor,
                              selectedColor: primaryBlue.withOpacity(0.2),
                              checkmarkColor: primaryBlue,
                              labelStyle: TextStyle(
                                color:
                                    selectedFilter == 'Semua'
                                        ? primaryBlue
                                        : Colors.black,
                                fontWeight:
                                    selectedFilter == 'Semua'
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                              ),
                            ),
                            const SizedBox(width: 8),
                            FilterChip(
                              label: const Text('Kecil'),
                              selected: selectedFilter == 'Kecil',
                              onSelected: (val) {
                                setState(() {
                                  selectedFilter = 'Kecil';
                                });
                              },
                              backgroundColor: whiteColor,
                              selectedColor: primaryBlue.withOpacity(0.2),
                              checkmarkColor: primaryBlue,
                              labelStyle: TextStyle(
                                color:
                                    selectedFilter == 'Kecil'
                                        ? primaryBlue
                                        : Colors.black,
                                fontWeight:
                                    selectedFilter == 'Kecil'
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                              ),
                            ),
                            const SizedBox(width: 8),
                            FilterChip(
                              label: const Text('Besar'),
                              selected: selectedFilter == 'Besar',
                              onSelected: (val) {
                                setState(() {
                                  selectedFilter = 'Besar';
                                });
                              },
                              backgroundColor: whiteColor,
                              selectedColor: primaryBlue.withOpacity(0.2),
                              checkmarkColor: primaryBlue,
                              labelStyle: TextStyle(
                                color:
                                    selectedFilter == 'Besar'
                                        ? primaryBlue
                                        : Colors.black,
                                fontWeight:
                                    selectedFilter == 'Besar'
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Jumlah kendaraan yang ditemukan
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${filteredList.length} kendaraan ditemukan',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Daftar Kendaraan
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
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Tidak ada kendaraan dengan filter "$selectedFilter".',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          )
                          : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
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

                // Tombol lanjut
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: whiteColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Lanjut ke Pemesanan'),
                      onPressed:
                          selectedKendaraan == null
                              ? null
                              : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (ctx) => PemesananScreen(
                                          destinasi: widget.destinasi,
                                          kendaraan: selectedKendaraan!,
                                        ),
                                  ),
                                );
                              },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        backgroundColor: primaryBlue,
                        foregroundColor: whiteColor,
                        disabledBackgroundColor: Colors.grey.shade300,
                        disabledForegroundColor: Colors.grey.shade500,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
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

  // Fungsi untuk memformat nilai harga ke format Rupiah
  String formatRupiah(dynamic price) {
    try {
      double numericPrice;

      if (price is int) {
        numericPrice = price.toDouble();
      } else if (price is double) {
        numericPrice = price;
      } else if (price is String) {
        // Bersihkan string dari format Rupiah yang mungkin sudah ada
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

      // Gunakan NumberFormat untuk format Rupiah
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

// Custom Kendaraan Card dengan gambar yang bisa di-tap
class KendaraanCardCustom extends StatelessWidget {
  final Kendaraan kendaraan;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onImageTap;

  const KendaraanCardCustom({
    Key? key,
    required this.kendaraan,
    required this.isSelected,
    required this.onTap,
    required this.onImageTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side:
            isSelected
                ? const BorderSide(
                  color: _PemilihanKendaraanScreenState.primaryBlue,
                  width: 2,
                )
                : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gambar kendaraan (dapat di-tap)
              GestureDetector(
                onTap: onImageTap,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    children: [
                      kendaraan.gambar.isNotEmpty
                          ? Image.network(
                            kendaraan.gambar,
                            width: 100,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) => Container(
                                  width: 100,
                                  height: 80,
                                  color: Colors.grey.shade200,
                                  child: const Icon(
                                    Icons.directions_bus,
                                    color: Colors.grey,
                                  ),
                                ),
                          )
                          : Container(
                            width: 100,
                            height: 80,
                            color: Colors.grey.shade200,
                            child: const Icon(
                              Icons.directions_bus,
                              color: Colors.grey,
                            ),
                          ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: _PemilihanKendaraanScreenState.primaryBlue
                                .withOpacity(0.7),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                            ),
                          ),
                          child: const Icon(
                            Icons.zoom_in,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Informasi kendaraan
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.category,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          kendaraan.tipe,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.people, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '${kendaraan.kapasitas} orang',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatRupiah(kendaraan.harga),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _PemilihanKendaraanScreenState.primaryBlue,
                          ),
                        ),
                        if (isSelected)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _PemilihanKendaraanScreenState.primaryBlue,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                SizedBox(width: 2),
                                Text(
                                  'Dipilih',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
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
            ],
          ),
        ),
      ),
    );
  }

  // Format Rupiah untuk Card
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
}
