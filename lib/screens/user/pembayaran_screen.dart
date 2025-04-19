import 'package:flutter/material.dart';
import 'package:travelapp/models/pemesanan.dart';
import 'package:intl/intl.dart'; // Untuk format mata uang
import 'package:travelapp/providers/order_provider.dart';
import 'package:provider/provider.dart'; // Untuk mengakses Provider
import 'package:travelapp/screens/user/home_screen.dart';
import 'package:travelapp/screens/user/order_screen.dart';
import 'package:travelapp/screens/user/order_screen.dart';

class PembayaranScreen extends StatelessWidget {
  final Pemesanan pemesanan;
  PembayaranScreen({required this.pemesanan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue.shade600,
        title: const Text(
          'Pembayaran',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan gambar destinasi
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(pemesanan.destinasi.gambar),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  ),
                ),
                padding: EdgeInsets.all(16),
                alignment: Alignment.bottomLeft,
                child: Text(
                  pemesanan.destinasi.nama,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Detail Pemesanan Card
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade100,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detail Pemesanan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  Divider(color: Colors.blue.shade200),
                  SizedBox(height: 8),
                  _buildDetailRow(
                    icon: Icons.place,
                    label: 'Destinasi',
                    value: pemesanan.destinasi.nama,
                  ),
                  _buildDetailRow(
                    icon: Icons.directions_car,
                    label: 'Kendaraan',
                    value: pemesanan.kendaraan.jenis,
                  ),
                  _buildDetailRow(
                    icon: Icons.person,
                    label: 'Jumlah Peserta',
                    value: '${pemesanan.jumlahPeserta} orang',
                  ),
                  _buildDetailRow(
                    icon: Icons.date_range,
                    label: 'Tanggal',
                    value: _formatDate(pemesanan.tanggal ?? DateTime.now()),
                  ),
                  SizedBox(height: 16),
                  Divider(color: Colors.blue.shade200),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Pembayaran',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                      Text(
                        'Rp ${_formatRupiah(pemesanan.totalHarga)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Metode Pembayaran
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade100,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Metode Pembayaran',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  SizedBox(height: 12),
                  _buildPaymentMethod(
                    'Transfer Bank',
                    Icons.account_balance,
                    isSelected: true,
                  ),
                  _buildPaymentMethod(
                    'Kartu Kredit',
                    Icons.credit_card,
                    isSelected: false,
                  ),
                  _buildPaymentMethod(
                    'E-Wallet',
                    Icons.account_balance_wallet,
                    isSelected: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.blue.shade100,
              blurRadius: 10,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            final orderProvider = Provider.of<OrderProvider>(
              context,
              listen: false,
            );
            print(
              "Menambahkan pesanan: ${pemesanan.destinasi.nama} - ${pemesanan.totalHarga}",
            );
            orderProvider.tambahPemesanan(pemesanan);

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          },

          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade600,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Lanjutkan Pembayaran',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  String _formatRupiah(double number) {
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 0,
    );
    return formatCurrency.format(number);
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue.shade600, size: 20),
          SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod(
    String title,
    IconData icon, {
    required bool isSelected,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? Colors.blue.shade600 : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
        color: isSelected ? Colors.blue.shade50 : Colors.white,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.blue.shade600 : Colors.grey,
            size: 24,
          ),
          SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.blue.shade800 : Colors.black87,
            ),
          ),
          Spacer(),
          if (isSelected)
            Icon(Icons.check_circle, color: Colors.blue.shade600, size: 20),
        ],
      ),
    );
  }
}
