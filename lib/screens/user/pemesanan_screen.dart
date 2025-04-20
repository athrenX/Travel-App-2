import 'package:flutter/material.dart';
import 'package:travelapp/models/kendaraan.dart';
import 'package:travelapp/models/destinasi.dart';
import 'package:travelapp/models/pemesanan.dart';
import 'package:travelapp/screens/user/pembayaran_screen.dart';
import 'package:intl/intl.dart';

class PemesananScreen extends StatefulWidget {
  final Destinasi destinasi;
  final Kendaraan kendaraan;
  final List<int> selectedSeats;
  final int totalPrice; // This should already be the sum of selected seats only

  const PemesananScreen({
    Key? key,
    required this.destinasi,
    required this.kendaraan,
    required this.selectedSeats,
    required this.totalPrice,
  }) : super(key: key);

  @override
  _PemesananScreenState createState() => _PemesananScreenState();
}

class _PemesananScreenState extends State<PemesananScreen> {
  final _jumlahPesertaController = TextEditingController();
  late double totalHarga;
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
    // Initialize with the total price from selected seats only
    totalHarga = widget.totalPrice.toDouble();
    _jumlahPesertaController.text = widget.selectedSeats.length.toString();
  }

  @override
  void dispose() {
    _jumlahPesertaController.dispose();
    super.dispose();
  }

  void _updateTotalPrice() {
    setState(() {
      final jumlahPeserta = int.tryParse(_jumlahPesertaController.text) ?? 1;
      // Calculate based on price per selected seat only
      final hargaPerKursi = widget.destinasi.harga; // Price per seat
      totalHarga = hargaPerKursi * jumlahPeserta;
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
                subtitle: '${widget.kendaraan.tipe} • ${widget.kendaraan.kapasitas} kursi',
              ),
              const SizedBox(height: 16),

              // Selected Seats Card - Only shows seats you actually selected
              _buildInfoCard(
                icon: Icons.event_seat,
                title: 'Kursi Terpilih',
                content: '${widget.selectedSeats.length} kursi',
                subtitle: _formatSeatNumbers(),
              ),
              const SizedBox(height: 24),

              // Participants Input
              Text(
                'Jumlah Peserta',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _jumlahPesertaController,
                decoration: InputDecoration(
                  hintText: 'Masukkan jumlah peserta',
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
                onChanged: (_) => _updateTotalPrice(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harap masukkan jumlah peserta';
                  }
                  final numValue = int.tryParse(value);
                  if (numValue == null || numValue <= 0) {
                    return 'Jumlah peserta harus lebih dari 0';
                  }
                  if (numValue > widget.selectedSeats.length) {
                    return 'Melebihi jumlah kursi yang dipilih';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Price Summary - Only shows prices for selected seats
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
                      _formatRupiah(totalHarga),
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
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        userId: 'userId',
                        destinasi: widget.destinasi,
                        kendaraan: widget.kendaraan,
                        selectedSeats: widget.selectedSeats,
                        jumlahPeserta: int.parse(_jumlahPesertaController.text),
                        tanggal: DateTime.now(),
                        totalHarga: totalHarga,
                      );

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PembayaranScreen(
                            pemesanan: pemesanan,
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
                ), // Added missing closing parenthesis here
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