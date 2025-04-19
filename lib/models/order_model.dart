import 'destinasi.dart';

class Pemesanan {
  final String status;
  final DateTime? tanggal;
  final Destinasi destinasi;
  final int jumlahPeserta;
  final double totalHarga;
  final int durasi;

  Pemesanan({
    required this.status,
    this.tanggal,
    required this.destinasi,
    required this.jumlahPeserta,
    required this.totalHarga,
    required this.durasi,
  });
}
