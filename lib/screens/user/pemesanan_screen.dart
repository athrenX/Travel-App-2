import 'package:flutter/material.dart';
import 'package:travelapp/models/kendaraan.dart';
import 'package:travelapp/models/destinasi.dart';
import 'package:travelapp/models/pemesanan.dart'; // Pastikan model ini ada
import 'package:travelapp/screens/user/pembayaran_screen.dart'; // Pastikan layar ini ada
import 'package:intl/intl.dart';
import 'package:provider/provider.dart'; // Import provider jika Anda ingin menggunakan order_provider di sini

class PemesananScreen extends StatefulWidget {
  final Destinasi destinasi;
  final Kendaraan kendaraan;
  final List<int> selectedSeats;
  final int totalPrice; // Ini adalah total harga berdasarkan kursi terpilih

  const PemesananScreen({
    super.key,
    required this.destinasi,
    required this.kendaraan,
    required this.selectedSeats,
    required this.totalPrice, // Ini sudah benar
  });

  @override
  _PemesananScreenState createState() => _PemesananScreenState();
}

class _PemesananScreenState extends State<PemesananScreen> {
  final _jumlahPesertaController = TextEditingController();
  late double calculatedTotalPrice; // Ganti totalHarga menjadi calculatedTotalPrice
  final _formKey = GlobalKey<FormState>();

  // Color scheme
  static const Color primaryColor = Color(0xFF4361EE);
  static const Color secondaryColor = Color(0xFF3F37C9);
  static const Color accentColor = Color(0xFF4CC9F0);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color textColor = Color(0xFF212529);

  @override
  void initState() {
    super.initState();
    // Gunakan totalPrice yang sudah dihitung dari PilihKursiScreen
    calculatedTotalPrice = widget.totalPrice.toDouble();
    _jumlahPesertaController.text = widget.selectedSeats.length.toString(); // Jumlah peserta sama dengan kursi terpilih
  }

  @override
  void dispose() {
    _jumlahPesertaController.dispose();
    super.dispose();
  }

  // Method ini tidak perlu lagi mengubah total harga, karena sudah dihitung dari selectedSeats
  // Jumlah peserta sekarang adalah JUMLAH KURSI YANG DIPILIH
  void _updateTotalPriceBasedOnPassengers() {
    // Karena jumlah peserta harus sama dengan jumlah kursi terpilih,
    // kita hanya perlu memastikan tampilan textfield _jumlahPesertaController.text sesuai.
    // calculatedTotalPrice sudah akurat dari widget.totalPrice
    setState(() {
      final int numParticipants = int.tryParse(_jumlahPesertaController.text) ?? 0;
      if (numParticipants != widget.selectedSeats.length) {
        // Ini seharusnya tidak terjadi jika validasi _processBooking di PilihKursiScreen berjalan baik
        // Namun, jika ada kasus, bisa ditangani di sini (misal: reset jumlah peserta ke jumlah kursi terpilih)
        _jumlahPesertaController.text = widget.selectedSeats.length.toString();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Jumlah peserta disesuaikan dengan jumlah kursi yang dipilih.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
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

  String _formatSeatNumbers() {
    widget.selectedSeats.sort();
    return widget.selectedSeats.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final hargaPerKursi = widget.destinasi.harga;

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
              // Destination Card
              _buildInfoCard(
                icon: Icons.location_on,
                title: 'Destinasi Wisata',
                content: widget.destinasi.nama,
                subtitle: widget.destinasi.lokasi,
              ),
              const SizedBox(height: 16),

              // Vehicle Card
              _buildInfoCard(
                icon: Icons.directions_bus,
                title: 'Kendaraan',
                content: widget.kendaraan.jenis,
                subtitle:
                    '${widget.kendaraan.tipe} • ${widget.kendaraan.kapasitas} orang',
              ),
              const SizedBox(height: 16),

              // Selected Seats Card
              _buildInfoCard(
                icon: Icons.event_seat,
                title: 'Kursi Terpilih',
                content: _formatSeatNumbers(),
                subtitle: 'Jumlah kursi: ${widget.selectedSeats.length}',
              ),
              const SizedBox(height: 24),

              // Participants Input
              Text(
                'Jumlah Peserta (sesuai jumlah kursi yang dipilih)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _jumlahPesertaController,
                readOnly: true, // Tidak bisa diubah, karena sudah sesuai kursi terpilih
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  suffixIcon: const Icon(Icons.people_alt_outlined),
                ),
                keyboardType: TextInputType.number,
                // onChanged: (_) => _updateTotalPrice(), // Ini tidak lagi diperlukan karena readOnly
                validator: (value) {
                  if (value == null || value.isEmpty || int.tryParse(value) == 0) {
                    return 'Jumlah peserta tidak valid'; // Harusnya tidak terpicu
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Price Summary
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
                      widget.selectedSeats.length.toString(),
                    ),
                    const Divider(height: 24),
                    _buildPriceRow(
                      'Total Harga',
                      _formatRupiah(calculatedTotalPrice), // Gunakan calculatedTotalPrice
                      isTotal: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final pemesanan = Pemesanan(
                        id: DateTime.now().millisecondsSinceEpoch.toString(), // ID sementara
                        userId: 'userId_example', // Ganti dengan user ID sebenarnya dari AuthProvider
                        destinasi: widget.destinasi,
                        kendaraan: widget.kendaraan,
                        selectedSeats: widget.selectedSeats,
                        jumlahPeserta: int.parse(_jumlahPesertaController.text),
                        tanggal: DateTime.now(), // Sesuaikan dengan tanggal pemesanan sebenarnya
                        totalHarga: calculatedTotalPrice,
                      );

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => PembayaranScreen(
                                  pemesanan:
                                      pemesanan, // Mengirim data pemesanan ke PembayaranScreen
                              ),
                        ),
                      );
                    }
                  },
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

  // Widget _buildInfoCard dan _buildPriceRow tidak berubah
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