import 'package:flutter/material.dart';
import 'package:travelapp/models/kendaraan.dart';
import 'package:travelapp/models/destinasi.dart';
import 'package:travelapp/models/pemesanan.dart';
import 'package:travelapp/screens/user/pembayaran_screen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:travelapp/providers/order_provider.dart';
import 'package:travelapp/providers/auth_provider.dart';

class PemesananScreen extends StatefulWidget {
  // PemesananScreen sekarang menerima objek Pemesanan lengkap
  final Pemesanan pemesanan;

  const PemesananScreen({
    super.key,
    required this.pemesanan,
  });

  @override
  _PemesananScreenState createState() => _PemesananScreenState();
}

class _PemesananScreenState extends State<PemesananScreen> {
  late double calculatedTotalPrice;
  final _formKey = GlobalKey<FormState>();

  static const Color primaryColor = Color(0xFF4361EE);
  static const Color secondaryColor = Color(0xFF3F37C9);
  static const Color accentColor = Color(0xFF4CC9F0);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color textColor = Color(0xFF212529);

  @override
  void initState() {
    super.initState();
    calculatedTotalPrice = widget.pemesanan.totalHarga;
  }

  @override
  void dispose() {
    super.dispose();
  }

  String _formatRupiah(double number) {
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatCurrency.format(number);
  }

  String _formatSeatNumbers() {
    final seats = List<int>.from(widget.pemesanan.selectedSeats); // Buat salinan untuk diurutkan
    seats.sort();
    return seats.join(', ');
  }

  Future<void> _continueToPayment() async {
    // Pada titik ini, pemesanan sudah dibuat di backend dengan status 'menunggu pembayaran'.
    // Kita hanya perlu navigasi ke PembayaranScreen.
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PembayaranScreen(
            pemesanan: widget.pemesanan,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Gunakan data dari objek pemesanan
    final destinasi = widget.pemesanan.destinasi;
    final kendaraan = widget.pemesanan.kendaraan;
    final selectedSeats = widget.pemesanan.selectedSeats;
    final jumlahPeserta = widget.pemesanan.jumlahPeserta;
    final hargaPerKursi = destinasi.harga;


    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Detail Pemesanan',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoCard(
                icon: Icons.location_on,
                title: 'Destinasi Wisata',
                content: destinasi.nama,
                subtitle: destinasi.lokasi,
              ),
              const SizedBox(height: 16),

              _buildInfoCard(
                icon: Icons.directions_bus,
                title: 'Kendaraan',
                content: kendaraan.jenis,
                subtitle:
                    '${kendaraan.tipe} • ${kendaraan.kapasitas} orang',
              ),
              const SizedBox(height: 16),

              _buildInfoCard(
                icon: Icons.event_seat,
                title: 'Kursi Terpilih',
                content: _formatSeatNumbers(),
                subtitle: 'Jumlah kursi: ${selectedSeats.length}',
              ),
              const SizedBox(height: 24),

              Text(
                'Jumlah Peserta',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '$jumlahPeserta orang',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const Icon(Icons.people_alt_outlined),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildPriceRow(
                      'Harga per Kursi',
                      _formatRupiah(hargaPerKursi),
                    ),
                    const Divider(height: 24),
                    _buildPriceRow(
                      'Jumlah Kursi',
                      selectedSeats.length.toString(),
                    ),
                    const Divider(height: 24),
                    _buildPriceRow(
                      'Total Harga',
                      _formatRupiah(calculatedTotalPrice),
                      isTotal: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _continueToPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'LANJUT KE PEMBAYARAN',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: textColor.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: textColor.withOpacity(0.6),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            color: isTotal ? primaryColor : textColor.withOpacity(0.7),
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            color: isTotal ? primaryColor : textColor,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}