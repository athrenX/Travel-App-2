import 'package:flutter/material.dart';
import 'package:travelapp/models/pemesanan.dart';
import 'package:intl/intl.dart';
import 'package:travelapp/screens/user/home_screen.dart';

class PembayaranSuksesScreen extends StatelessWidget {
  final Pemesanan pemesanan;
  final String paymentMethod;
  const PembayaranSuksesScreen({
    super.key,
    required this.pemesanan,
    required this.paymentMethod,
  });

  static const Color primaryColor = Color(0xFF4361EE);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color textColor = Color(0xFF212529);

  String _formatRupiah(double number) {
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatCurrency.format(number);
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMMM yyyy, HH:mm', 'id_ID').format(date);
  }

  String _formatSeatNumbers(List<int> seats) {
    final sortedSeats = List<int>.from(seats);
    sortedSeats.sort();
    return sortedSeats.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final destinasi = pemesanan.destinasi;
    final kendaraan = pemesanan.kendaraan;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Pembayaran Sukses',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: primaryColor,
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false, // agar tidak bisa kembali
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.verified, color: Colors.green, size: 80),
              const SizedBox(height: 16),
              const Text(
                'Pembayaran Berhasil!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Terima kasih telah melakukan pembayaran.\nPemesanan Anda telah dikonfirmasi.',
                style: TextStyle(
                  fontSize: 16,
                  color: textColor.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Detail Pembayaran
              _buildDetailRow('ID Pemesanan', pemesanan.id),
              _buildDetailRow(
                'Tanggal Pemesanan',
                _formatDate(pemesanan.tanggal),
              ),
              _buildDetailRow('Destinasi', destinasi.nama),
              _buildDetailRow('Lokasi', destinasi.lokasi),
              _buildDetailRow('Kendaraan', kendaraan.jenis),
              _buildDetailRow(
                'Kursi',
                _formatSeatNumbers(pemesanan.selectedSeats),
              ),
              _buildDetailRow(
                'Total Dibayar',
                _formatRupiah(pemesanan.totalHarga),
              ),
              _buildDetailRow(
                'Metode Pembayaran',
                paymentMethod,
              ), // <--- TAMBAHKAN INI
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.assignment),
                  label: const Text('LIHAT PESANAN SAYA'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HomeScreen(initialTab: 2),
                      ),
                      (route) => false,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: textColor.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
            ),
          ),
        ],
      ),
    );
  }
}
