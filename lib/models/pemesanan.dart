import 'destinasi.dart';
import 'kendaraan.dart';

class Pemesanan {
  final String id;
  final String userId;
  final Destinasi destinasi; // Menyimpan objek Destinasi
  final Kendaraan kendaraan; // Menyimpan objek Kendaraan
  final int jumlahPeserta;
  final DateTime tanggal;
  final double totalHarga;
  String status; // Tambahkan properti status

  Pemesanan({
    required this.id,
    required this.userId,
    required this.destinasi,
    required this.kendaraan,
    required this.jumlahPeserta,
    required this.tanggal,
    required this.totalHarga,
    this.status = "Sedang Diproses", // Status default
  });

  // Menambahkan metode toMap untuk mengonversi ke map dengan data destinasi dan kendaraan
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'destinasiId': destinasi.id, // Menggunakan id destinasi
      'kendaraanId': kendaraan.id, // Menggunakan id kendaraan
      'jumlahPeserta': jumlahPeserta,
      'tanggal': tanggal.toIso8601String(),
      'totalHarga': totalHarga,
      'status': status, // Menambahkan status pada toMap
    };
  }

  // Menambahkan factory constructor untuk membuat objek Pemesanan dari map
  factory Pemesanan.fromMap(
    Map<String, dynamic> map,
    Destinasi destinasi,
    Kendaraan kendaraan,
  ) {
    return Pemesanan(
      id: map['id'],
      userId: map['userId'],
      destinasi: destinasi, // Mengambil objek Destinasi
      kendaraan: kendaraan, // Mengambil objek Kendaraan
      jumlahPeserta: map['jumlahPeserta'],
      tanggal: DateTime.parse(map['tanggal']),
      totalHarga: map['totalHarga'],
      status:
          map['status'] ??
          "Sedang Diproses", // Menambahkan status default jika tidak ada
    );
  }
}
