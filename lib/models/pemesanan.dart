import 'package:travelapp/models/destinasi.dart';
import 'package:travelapp/models/kendaraan.dart';

class Pemesanan {
  final String id;
  final String userId;
  final Destinasi destinasi;
  final Kendaraan kendaraan;
  final List<int> selectedSeats;
  final int jumlahPeserta;
  final DateTime tanggal; // Tanggal pemesanan
  final double totalHarga; // Total harga akhir
  final String status; // <-- TAMBAHKAN INI

  Pemesanan({
    required this.id,
    required this.userId,
    required this.destinasi,
    required this.kendaraan,
    required this.selectedSeats,
    required this.jumlahPeserta,
    required this.tanggal,
    required this.totalHarga,
    this.status = 'Pending', // <-- Tambahkan default value jika tidak diinisialisasi
  });

  // Anda bisa menambahkan toMap() dan fromMap() jika diperlukan untuk persistensi data atau pengiriman ke API lain
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'destinasi_id': destinasi.id,
      'kendaraan_id': kendaraan.id,
      'selected_seats': selectedSeats,
      'jumlah_peserta': jumlahPeserta,
      'tanggal': tanggal.toIso8601String(),
      'total_harga': totalHarga,
      'status': status, // <-- TAMBAHKAN INI
    };
  }

  // Jika Anda akan memuat Pemesanan dari JSON, Anda mungkin perlu factory constructor seperti ini:
  factory Pemesanan.fromMap(Map<String, dynamic> map) {
    return Pemesanan(
      id: map['id'].toString(),
      userId: map['user_id'] ?? '',
      destinasi: Destinasi.fromMap(map['destinasi']), // Asumsi 'destinasi' adalah Map
      kendaraan: Kendaraan.fromMap(map['kendaraan']), // Asumsi 'kendaraan' adalah Map
      selectedSeats: List<int>.from(map['selected_seats'] ?? []),
      jumlahPeserta: map['jumlah_peserta'] ?? 0,
      tanggal: DateTime.parse(map['tanggal']),
      totalHarga: map['total_harga']?.toDouble() ?? 0.0,
      status: map['status'] ?? 'Pending',
    );
  }
}