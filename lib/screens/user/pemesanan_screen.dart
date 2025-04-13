import 'package:flutter/material.dart';
import 'package:travelapp/models/kendaraan.dart';
import 'package:travelapp/models/destinasi.dart';
import 'package:travelapp/models/pemesanan.dart';
import 'package:travelapp/screens/user/pembayaran_screen.dart';

class PemesananScreen extends StatefulWidget {
  final Destinasi destinasi;
  final Kendaraan kendaraan;

  PemesananScreen({required this.destinasi, required this.kendaraan});

  @override
  _PemesananScreenState createState() => _PemesananScreenState();
}

class _PemesananScreenState extends State<PemesananScreen> {
  final _jumlahPesertaController = TextEditingController();
  late double totalHarga;

  @override
  void initState() {
    super.initState();
    totalHarga = widget.kendaraan.harga; // Start with the vehicle price
  }

  void _updateTotalPrice() {
    setState(() {
      final jumlahPeserta = int.tryParse(_jumlahPesertaController.text) ?? 0;
      totalHarga = widget.kendaraan.harga * jumlahPeserta;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pemesanan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Destinasi: ${widget.destinasi.nama}', style: TextStyle(fontSize: 20)),
            SizedBox(height: 8),
            Text('Kendaraan: ${widget.kendaraan.jenis}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 16),
            TextField(
              controller: _jumlahPesertaController,
              decoration: InputDecoration(labelText: 'Jumlah Peserta'),
              keyboardType: TextInputType.number,
              onChanged: (_) => _updateTotalPrice(),
            ),
            SizedBox(height: 16),
            Text('Total Harga: Rp $totalHarga'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final pemesanan = Pemesanan(
                  id: '1',
                  userId: 'userId',
                  destinasiId: widget.destinasi.id,
                  kendaraanId: widget.kendaraan.id,
                  jumlahPeserta: int.parse(_jumlahPesertaController.text),
                  tanggal: DateTime.now(),
                  totalHarga: totalHarga,
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PembayaranScreen(pemesanan: pemesanan),
                  ),
                );
              },
              child: Text('Lanjut ke Pembayaran'),
            ),
          ],
        ),
      ),
    );
  }
}
