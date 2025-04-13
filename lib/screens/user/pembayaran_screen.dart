import 'package:flutter/material.dart';
import 'package:travelapp/models/pemesanan.dart';

class PembayaranScreen extends StatelessWidget {
  final Pemesanan pemesanan;

  PembayaranScreen({required this.pemesanan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pembayaran'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Destinasi: ${pemesanan.destinasiId}', style: TextStyle(fontSize: 20)),
            SizedBox(height: 8),
            Text('Kendaraan: ${pemesanan.kendaraanId}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 16),
            Text('Total Harga: Rp ${pemesanan.totalHarga}'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Handle payment logic
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pembayaran Berhasil')));
              },
              child: Text('Bayar'),
            ),
          ],
        ),
      ),
    );
  }
}
