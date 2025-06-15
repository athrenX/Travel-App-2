import 'package:flutter/material.dart';
import 'package:travelapp/models/pemesanan.dart';
import 'package:travelapp/services/pemesanan_service.dart';
import 'package:provider/provider.dart';
import 'package:travelapp/providers/order_provider.dart';
import 'package:travelapp/providers/auth_provider.dart';
import 'package:intl/intl.dart';
import 'package:travelapp/screens/user/pembayaran_sukses_screen.dart';
import 'package:travelapp/screens/user/home_screen.dart';

class PembayaranScreen extends StatefulWidget {
  final Pemesanan pemesanan;

  const PembayaranScreen({super.key, required this.pemesanan});

  @override
  State<PembayaranScreen> createState() => _PembayaranScreenState();
}

class _PembayaranScreenState extends State<PembayaranScreen> {
  static const Color primaryColor = Color(0xFF4361EE);
  static const Color accentColor = Color(0xFF4CC9F0);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color textColor = Color(0xFF212529);

  late String _selectedPaymentMethod;
  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    _selectedPaymentMethod =
        user?.paymentMethod ?? 'Bank Transfer'; // default jika belum ada
  }

  String _formatRupiah(double number) {
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatCurrency.format(number);
  }

  String _formatDate(DateTime date) {
    // Perbaiki karakter unicode yang salah, pastikan hanya karakter ASCII atau karakter yang valid dalam string.
    return DateFormat('dd MMMM HH:mm', 'id_ID').format(date);
  }

  String _formatSeatNumbers(List<int> seats) {
    final sortedSeats = List<int>.from(seats);
    sortedSeats.sort();
    return sortedSeats.join(', ');
  }

  Future<void> _handlePaymentConfirmation() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            ),
          ),
    );

    try {
      final updatedPemesanan = await PemesananService.confirmPayment(
        widget.pemesanan.id,
      );

      if (mounted) {
        Navigator.of(context).pop(); // Tutup dialog loading

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Pembayaran berhasil! Pemesanan Anda telah dikonfirmasi.',
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Update pemesanan di OrderProvider
        Provider.of<OrderProvider>(context, listen: false).fetchOrders();

        // Navigasi kembali ke layar daftar pesanan atau layar konfirmasi akhir
        // Navigasi ke halaman pembayaran sukses
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder:
                (ctx) => PembayaranSuksesScreen(
                  pemesanan: updatedPemesanan,
                  paymentMethod: _selectedPaymentMethod,
                ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Tutup dialog loading
        String errorMessage = 'Gagal memproses pembayaran: ${e.toString()}';
        if (e.toString().contains('Expired')) {
          errorMessage =
              'Waktu pembayaran telah habis. Pemesanan Anda dibatalkan.';
        } else if (e.toString().contains('Conflict')) {
          errorMessage =
              'Pembayaran gagal karena status pemesanan tidak valid atau kursi sudah dilepas.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pemesanan = widget.pemesanan;
    final destinasi = pemesanan.destinasi;
    final kendaraan = pemesanan.kendaraan;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Konfirmasi Pembayaran',
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Ringkasan Pemesanan'),
            _buildInfoCard(
              icon: Icons.confirmation_number,
              title: 'ID Pemesanan',
              content: pemesanan.id,
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              icon: Icons.calendar_today,
              title: 'Tanggal Pemesanan',
              content: _formatDate(pemesanan.tanggal),
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              icon: Icons.location_on,
              title: 'Destinasi',
              content: destinasi.nama,
              subtitle: destinasi.lokasi,
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              icon: Icons.directions_bus,
              title: 'Kendaraan',
              content: kendaraan.jenis,
              subtitle:
                  '${kendaraan.tipe} - Kapasitas: ${kendaraan.kapasitas} orang',
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              icon: Icons.event_seat,
              title: 'Kursi Terpilih',
              content: _formatSeatNumbers(pemesanan.selectedSeats),
              subtitle: 'Jumlah Peserta: ${pemesanan.jumlahPeserta}',
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('Detail Pembayaran'),
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
                    'Total yang harus dibayar',
                    _formatRupiah(pemesanan.totalHarga),
                    isTotal: true,
                  ),
                  const Divider(height: 24),
                  _buildPriceRow(
                    'Status',
                    pemesanan.status.toUpperCase(),
                    valueColor: Colors.orange,
                  ),
                  if (pemesanan.expiredAt != null &&
                      pemesanan.status == 'menunggu pembayaran') ...[
                    const Divider(height: 24),
                    _buildPriceRow(
                      'Batas Waktu Pembayaran',
                      _formatDate(pemesanan.expiredAt!),
                      valueColor: Colors.red.shade700,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('Metode Pembayaran'),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pilih metode pembayaran:',
                    style: TextStyle(
                      fontSize: 15,
                      color: textColor.withOpacity(0.8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // --- PILIHAN RADIO ---
                  RadioListTile<String>(
                    value: 'Bank Transfer',
                    groupValue: _selectedPaymentMethod,
                    onChanged:
                        (val) => setState(() => _selectedPaymentMethod = val!),
                    title: const Text('Bank Transfer'),
                    secondary: const Icon(Icons.account_balance),
                  ),
                  RadioListTile<String>(
                    value: 'E-Wallet',
                    groupValue: _selectedPaymentMethod,
                    onChanged:
                        (val) => setState(() => _selectedPaymentMethod = val!),
                    title: const Text('E-Wallet'),
                    secondary: const Icon(Icons.wallet),
                  ),
                  RadioListTile<String>(
                    value: 'Kartu Kredit',
                    groupValue: _selectedPaymentMethod,
                    onChanged:
                        (val) => setState(() => _selectedPaymentMethod = val!),
                    title: const Text('Kartu Kredit'),
                    secondary: const Icon(Icons.credit_card),
                  ),
                  const SizedBox(height: 10),
                  // Info transfer bisa conditional
                  if (_selectedPaymentMethod == 'Bank Transfer') ...[
                    Text(
                      'Anda bisa melakukan transfer ke rekening berikut:',
                      style: TextStyle(
                        fontSize: 13,
                        color: textColor.withOpacity(0.7),
                      ),
                    ),
                    _buildBankInfo('BCA', '1234567890', 'An. PT. Wisata Jaya'),
                    _buildBankInfo(
                      'Mandiri',
                      '0987654321',
                      'An. PT. Wisata Jaya',
                    ),
                  ] else if (_selectedPaymentMethod == 'E-Wallet') ...[
                    Text(
                      'QRIS/E-Wallet (OVO, DANA, ShopeePay):',
                      style: TextStyle(
                        fontSize: 13,
                        color: textColor.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Image.asset(
                        'assets/images/Fake_QR.png',
                        height: 200, // Ukuran besar
                        width: 200, // Ukuran besar
                        fit: BoxFit.contain,
                        errorBuilder:
                            (context, error, stackTrace) => Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.qr_code,
                                  size: 120,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'QR code tidak ditemukan',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Center(
                      child: Text(
                        'Scan QR ini untuk pembayaran cepat',
                        style: TextStyle(
                          fontSize: 13,
                          color: textColor.withOpacity(0.6),
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ), // ganti dengan asset QRIS kamu
                  ] else if (_selectedPaymentMethod == 'Kartu Kredit') ...[
                    Text(
                      'Masukkan detail kartu kredit pada langkah berikutnya setelah konfirmasi pembayaran.',
                      style: TextStyle(
                        fontSize: 13,
                        color: textColor.withOpacity(0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 32),

            if (pemesanan.status == 'menunggu pembayaran')
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _handlePaymentConfirmation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'SAYA SUDAH MEMBAYAR',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            const SizedBox(height: 10),
            if (pemesanan.status == 'menunggu pembayaran')
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () async {
                    final confirmCancel =
                        await showDialog<bool>(
                          context: context,
                          builder:
                              (ctx) => AlertDialog(
                                title: const Text('Batalkan Pemesanan?'),
                                content: const Text(
                                  'Apakah Anda yakin ingin membatalkan pemesanan ini? Kursi akan dikembalikan ke tersedia.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.of(ctx).pop(false),
                                    child: const Text('Tidak'),
                                  ),
                                  TextButton(
                                    onPressed:
                                        () => Navigator.of(ctx).pop(true),
                                    child: const Text('Ya'),
                                  ),
                                ],
                              ),
                        ) ??
                        false;

                    if (confirmCancel) {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder:
                            (ctx) => const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.red,
                                ),
                              ),
                            ),
                      );
                      try {
                        await PemesananService.cancelPemesanan(pemesanan.id);
                        if (mounted) {
                          Navigator.of(context).pop(); // Close loading
                          Provider.of<OrderProvider>(
                            context,
                            listen: false,
                          ).fetchOrders();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Pemesanan berhasil dibatalkan.'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          // Kembali ke HomeScreen, lalu tab Pesanan
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HomeScreen(initialTab: 2),
                            ),
                            (route) => false,
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          Navigator.of(context).pop(); // Close loading
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Gagal membatalkan pemesanan: ${e.toString()}',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'BATALKAN PEMESANAN',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

            SizedBox(height: 10),
            if (pemesanan.status == 'menunggu pembayaran')
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/home',
                      (route) => false,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryColor,
                    side: BorderSide(color: primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'KEMBALI KE HOME',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: textColor,
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

  Widget _buildPriceRow(
    String label,
    String value, {
    bool isTotal = false,
    Color? valueColor,
  }) {
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
            color: valueColor ?? (isTotal ? primaryColor : textColor),
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildBankInfo(
    String bankName,
    String accountNumber,
    String accountName,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.account_balance, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$bankName: $accountNumber',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Text(
                'A/n: $accountName',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
