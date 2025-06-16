import 'package:flutter/material.dart';
import 'package:travelapp/models/pemesanan.dart';
import 'package:intl/intl.dart';
import 'package:travelapp/screens/user/home_screen.dart';

class PembayaranSuksesScreen extends StatelessWidget {
  final Pemesanan pemesanan;
  final String paymentMethod; // Parameter baru yang diperlukan

  const PembayaranSuksesScreen({
    super.key,
    required this.pemesanan,
    required this.paymentMethod, // Tetap diperlukan di sini
  });

  // Hapus static const Color, gunakan Theme.of(context)
  // static const Color primaryColor = Color(0xFF4361EE);
  // static const Color backgroundColor = Color(0xFFF8F9FA);
  // static const Color textColor = Color(0xFF212529);

  String _formatRupiah(double number) {
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatCurrency.format(number);
  }

  String _formatDate(DateTime date) {
    // Perbaikan karakter unicode yang salah dari 'MMMM紝, HH:mm' menjadi 'dd MMMM, HH:mm'
    return DateFormat('dd MMMM, HH:mm', 'id_ID').format(date);
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

    // Akses tema di sini
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.background, // Gunakan background color dari tema
      appBar: AppBar(
        title: Text(
          'Pembayaran Sukses',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onPrimary), // Teks judul
        ),
        backgroundColor: colorScheme.primary, // Warna AppBar
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false, // agar tidak bisa kembali
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        iconTheme: IconThemeData(color: colorScheme.onPrimary), // Warna ikon AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.verified, color: Colors.green, size: 80), // Ikon verified bisa tetap hijau
              const SizedBox(height: 16),
              Text(
                'Pembayaran Berhasil!',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green, // Warna sukses bisa tetap hijau
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Terima kasih telah melakukan pembayaran.\nPemesanan Anda telah dikonfirmasi.',
                style: textTheme.bodyMedium?.copyWith(
                  color: textTheme.bodyLarge?.color?.withOpacity(0.7), // Warna teks deskripsi
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Detail Pembayaran
              _buildDetailRow(
                'ID Pemesanan',
                pemesanan.id,
                textTheme, // Teruskan textTheme
                colorScheme, // Teruskan colorScheme
              ),
              _buildDetailRow(
                'Tanggal Pemesanan',
                _formatDate(pemesanan.tanggal),
                textTheme,
                colorScheme,
              ),
              _buildDetailRow(
                'Destinasi',
                destinasi.nama,
                textTheme,
                colorScheme,
              ),
              _buildDetailRow(
                'Lokasi',
                destinasi.lokasi,
                textTheme,
                colorScheme,
              ),
              _buildDetailRow(
                'Kendaraan',
                kendaraan.jenis,
                textTheme,
                colorScheme,
              ),
              _buildDetailRow(
                'Kursi',
                _formatSeatNumbers(pemesanan.selectedSeats),
                textTheme,
                colorScheme,
              ),
              _buildDetailRow(
                'Total Dibayar',
                _formatRupiah(pemesanan.totalHarga),
                textTheme,
                colorScheme,
              ),
              _buildDetailRow(
                'Metode Pembayaran',
                paymentMethod, // Menggunakan parameter paymentMethod
                textTheme,
                colorScheme,
              ), // <--- TAMBAHKAN INI
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.assignment),
                  label: Text('LIHAT PESANAN SAYA', style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)), // Teks tombol
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary, // Warna tombol
                    foregroundColor: colorScheme.onPrimary, // Warna teks ikon tombol
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  onPressed: () {
                    // Navigasi ke HomeScreen dengan tab Pesanan (index 2)
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HomeScreen(initialTab: 2),
                      ),
                      (route) => false, // Hapus semua rute di bawahnya
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

  Widget _buildDetailRow(String label, String value, TextTheme textTheme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: textTheme.bodyLarge?.color?.withOpacity(0.7), // Warna teks label
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: textTheme.bodyLarge?.color), // Warna teks nilai
            ),
          ),
        ],
      ),
    );
  }
}