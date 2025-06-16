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
  // Hapus static const Color, gunakan Theme.of(context)
  // static const Color primaryColor = Color(0xFF4361EE);
  // static const Color accentColor = Color(0xFF4CC9F0);
  // static const Color backgroundColor = Color(0xFFF8F9FA);
  // static const Color textColor = Color(0xFF212529);

  late String _selectedPaymentMethod;

  @override
  void initState() {
    super.initState();
    // Gunakan WidgetsBinding.instance.addPostFrameCallback untuk memastikan context siap
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      setState(() {
        _selectedPaymentMethod =
            user?.paymentMethod ?? 'Bank Transfer'; // default jika belum ada
      });
    });
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
    return DateFormat('dd MMMM, HH:mm', 'id_ID').format(date);
  }

  String _formatSeatNumbers(List<int> seats) {
    final sortedSeats = List<int>.from(seats);
    sortedSeats.sort();
    return sortedSeats.join(', ');
  }

  Future<void> _handlePaymentConfirmation() async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary), // Gunakan primaryColor dari tema
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
          SnackBar(
            content: Text(
              'Pembayaran berhasil! Pemesanan Anda telah dikonfirmasi.',
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSecondary), // Sesuaikan dengan warna teks di SnackBar
            ),
            backgroundColor: Colors.green, // Warna sukses bisa tetap hijau atau dari tema
          ),
        );

        // Update pemesanan di OrderProvider
        Provider.of<OrderProvider>(context, listen: false).fetchOrders();

        // Navigasi ke halaman pembayaran sukses, SERTAKAN paymentMethod
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder:
                (ctx) => PembayaranSuksesScreen(
                  pemesanan: updatedPemesanan,
                  paymentMethod: _selectedPaymentMethod, // <--- INI PERBAIKANNYA
                ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Tutup dialog loading
        String errorMessage = 'Gagal memproses pembayaran: ${e.toString()}';
        if (e.toString().contains('Expired')) {
          errorMessage = 'Waktu pembayaran telah habis. Pemesanan Anda dibatalkan.';
        } else if (e.toString().contains('Conflict')) {
          errorMessage = 'Pembayaran gagal karena status pemesanan tidak valid atau kursi sudah dilepas.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage, style: textTheme.bodyMedium?.copyWith(color: colorScheme.onError)), // Sesuaikan dengan warna teks di SnackBar
            backgroundColor: colorScheme.error, // Gunakan errorColor dari tema
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pemesanan = widget.pemesanan;
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
          'Konfirmasi Pembayaran',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onPrimary), // Teks judul
        ),
        centerTitle: true,
        backgroundColor: colorScheme.primary, // Warna AppBar
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        iconTheme: IconThemeData(color: colorScheme.onPrimary), // Warna ikon AppBar
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Ringkasan Pemesanan', textTheme.titleMedium?.copyWith(color: textTheme.bodyLarge?.color)), // Sesuaikan warna teks
            _buildInfoCard(
              icon: Icons.confirmation_number,
              title: 'ID Pemesanan',
              content: pemesanan.id,
              colorScheme: colorScheme,
              textTheme: textTheme,
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              icon: Icons.calendar_today,
              title: 'Tanggal Pemesanan',
              content: _formatDate(pemesanan.tanggal),
              colorScheme: colorScheme,
              textTheme: textTheme,
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              icon: Icons.location_on,
              title: 'Destinasi',
              content: destinasi.nama,
              subtitle: destinasi.lokasi,
              colorScheme: colorScheme,
              textTheme: textTheme,
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              icon: Icons.directions_bus,
              title: 'Kendaraan',
              content: kendaraan.jenis,
              subtitle:
                  '${kendaraan.tipe} - Kapasitas: ${kendaraan.kapasitas} orang',
              colorScheme: colorScheme,
              textTheme: textTheme,
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              icon: Icons.event_seat,
              title: 'Kursi Terpilih',
              content: _formatSeatNumbers(pemesanan.selectedSeats),
              subtitle: 'Jumlah Peserta: ${pemesanan.jumlahPeserta}',
              colorScheme: colorScheme,
              textTheme: textTheme,
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('Detail Pembayaran', textTheme.titleMedium?.copyWith(color: textTheme.bodyLarge?.color)),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface, // Gunakan surface color dari tema
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withOpacity(0.05), // Gunakan shadow color dari tema
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
                    colorScheme: colorScheme, // Teruskan colorScheme
                    textTheme: textTheme, // Teruskan textTheme
                  ),
                  Divider(height: 24, color: theme.dividerColor), // Divider warna dari tema
                  _buildPriceRow(
                    'Status',
                    pemesanan.status.toUpperCase(),
                    valueColor: Colors.orange, // Warna status mungkin tetap spesifik
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  ),
                  if (pemesanan.expiredAt != null &&
                      pemesanan.status.toLowerCase() == 'menunggu pembayaran') ...[
                    Divider(height: 24, color: theme.dividerColor),
                    _buildPriceRow(
                      'Batas Waktu Pembayaran',
                      _formatDate(pemesanan.expiredAt!),
                      valueColor: colorScheme.error, // Gunakan error color dari tema
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('Metode Pembayaran', textTheme.titleMedium?.copyWith(color: textTheme.bodyLarge?.color)),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface, // Gunakan surface color dari tema
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withOpacity(0.05), // Gunakan shadow color dari tema
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
                    style: textTheme.bodyMedium?.copyWith(
                      color: textTheme.bodyLarge?.color?.withOpacity(0.8), // Sesuaikan warna teks
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
                    title: Text('Bank Transfer', style: textTheme.bodyMedium), // Teks RadioListTile
                    secondary: Icon(Icons.account_balance, color: colorScheme.onSurface), // Ikon
                    activeColor: colorScheme.primary, // Warna radio button saat aktif
                  ),
                  RadioListTile<String>(
                    value: 'E-Wallet',
                    groupValue: _selectedPaymentMethod,
                    onChanged:
                        (val) => setState(() => _selectedPaymentMethod = val!),
                    title: Text('E-Wallet', style: textTheme.bodyMedium),
                    secondary: Icon(Icons.wallet, color: colorScheme.onSurface),
                    activeColor: colorScheme.primary,
                  ),
                  RadioListTile<String>(
                    value: 'Kartu Kredit',
                    groupValue: _selectedPaymentMethod,
                    onChanged:
                        (val) => setState(() => _selectedPaymentMethod = val!),
                    title: Text('Kartu Kredit', style: textTheme.bodyMedium),
                    secondary: Icon(Icons.credit_card, color: colorScheme.onSurface),
                    activeColor: colorScheme.primary,
                  ),
                  const SizedBox(height: 10),
                  // Info transfer bisa conditional
                  if (_selectedPaymentMethod == 'Bank Transfer') ...[
                    Text(
                      'Anda bisa melakukan transfer ke rekening berikut:',
                      style: textTheme.bodySmall?.copyWith(
                        color: textTheme.bodyMedium?.color?.withOpacity(0.7), // Sesuaikan warna teks
                      ),
                    ),
                    _buildBankInfo(
                      'BCA',
                      '1234567890',
                      'An. PT. Wisata Jaya',
                      colorScheme, // Teruskan colorScheme
                      textTheme, // Teruskan textTheme
                    ),
                    _buildBankInfo(
                      'Mandiri',
                      '0987654321',
                      'An. PT. Wisata Jaya',
                      colorScheme,
                      textTheme,
                    ),
                  ] else if (_selectedPaymentMethod == 'E-Wallet') ...[
                    Text(
                      'QRIS/E-Wallet (OVO, DANA, ShopeePay):',
                      style: textTheme.bodySmall?.copyWith(
                        color: textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Image.asset(
                        'assets/images/Fake_QR.png', // Pastikan asset ini ada dan benar
                        height: 200,
                        width: 200,
                        fit: BoxFit.contain,
                        errorBuilder:
                            (context, error, stackTrace) => Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.qr_code,
                                      size: 120,
                                      color: colorScheme.onSurface.withOpacity(0.5), // Themed icon
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'QR code tidak ditemukan',
                                      style: textTheme.bodyMedium?.copyWith(
                                        fontSize: 14,
                                        color: colorScheme.error, // Themed text
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
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: 13,
                          color: textTheme.bodyMedium?.color?.withOpacity(0.6), // Themed text
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ] else if (_selectedPaymentMethod == 'Kartu Kredit') ...[
                    Text(
                      'Masukkan detail kartu kredit pada langkah berikutnya setelah konfirmasi pembayaran.',
                      style: textTheme.bodySmall?.copyWith(
                        color: textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 32),

            if (pemesanan.status.toLowerCase() == 'menunggu pembayaran')
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _handlePaymentConfirmation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary, // Warna tombol
                    foregroundColor: colorScheme.onPrimary, // Warna teks tombol
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    'SAYA SUDAH MEMBAYAR',
                    style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            const SizedBox(height: 10),
            if (pemesanan.status.toLowerCase() == 'menunggu pembayaran')
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
                                    title: Text('Batalkan Pemesanan?', style: textTheme.titleMedium),
                                    content: Text(
                                      'Apakah Anda yakin ingin membatalkan pemesanan ini? Kursi akan dikembalikan ke tersedia.',
                                      style: textTheme.bodyMedium,
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed:
                                            () => Navigator.of(ctx).pop(false),
                                        child: Text('Tidak', style: textTheme.labelLarge?.copyWith(color: colorScheme.primary)),
                                      ),
                                      TextButton(
                                        onPressed:
                                            () => Navigator.of(ctx).pop(true),
                                        child: Text('Ya', style: textTheme.labelLarge?.copyWith(color: colorScheme.error)),
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
                            (ctx) => Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      colorScheme.error,
                                    ),
                                  ),
                                ),
                      );
                      try {
                        await PemesananService.cancelPemesanan(pemesanan.id);
                        if (mounted) {
                          Navigator.of(context).pop();
                          Provider.of<OrderProvider>(
                            context,
                            listen: false,
                          ).fetchOrders();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Pemesanan berhasil dibatalkan.', style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSecondary)),
                              backgroundColor: Colors.green,
                            ),
                          );
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
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Gagal membatalkan pemesanan: ${e.toString()}',
                                style: textTheme.bodyMedium?.copyWith(color: colorScheme.onError)),
                              backgroundColor: colorScheme.error,
                            ),
                          );
                        }
                      }
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.error,
                    side: BorderSide(color: colorScheme.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'BATALKAN PEMESANAN',
                    style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ),

            if (pemesanan.status.toLowerCase() != 'menunggu pembayaran')
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
                    foregroundColor: colorScheme.primary,
                    side: BorderSide(color: colorScheme.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'KEMBALI KE HOME',
                    style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, TextStyle? style) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Text(
        title,
        style: style,
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
    String? subtitle,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
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
              color: colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.labelMedium?.copyWith(
                    color: textTheme.bodyLarge?.color?.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: textTheme.bodyLarge?.color,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: textTheme.bodySmall?.copyWith(
                      color: textTheme.bodyLarge?.color?.withOpacity(0.6),
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
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: textTheme.labelLarge?.copyWith(
            fontSize: isTotal ? 16 : 14,
            color: isTotal ? colorScheme.primary : textTheme.bodyLarge?.color?.withOpacity(0.7),
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: textTheme.titleMedium?.copyWith(
            fontSize: isTotal ? 18 : 14,
            color: valueColor ?? (isTotal ? colorScheme.primary : textTheme.bodyLarge?.color),
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
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.account_balance, size: 20, color: textTheme.bodyLarge?.color?.withOpacity(0.6)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$bankName: $accountNumber',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: textTheme.bodyLarge?.color,
                ),
              ),
              Text(
                'A/n: $accountName',
                style: textTheme.bodySmall?.copyWith(color: textTheme.bodyLarge?.color?.withOpacity(0.7)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}