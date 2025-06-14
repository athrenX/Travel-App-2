// lib/models/pemesanan.dart

import 'package:travelapp/models/destinasi.dart';
import 'package:travelapp/models/kendaraan.dart';
import 'package:travelapp/models/user.dart';

class Pemesanan {
  final String id; // PENTING: Ini adalah ID pemesanan
  final String userId; // PENTING: User ID
  final Destinasi destinasi;
  final Kendaraan kendaraan;
  final List<int> selectedSeats;
  final int jumlahPeserta;
  final DateTime tanggal;
  final double totalHarga;
  final String status;
  final User? user;
  final DateTime? expiredAt;

  Pemesanan({
    required this.id,
    required this.userId,
    required this.destinasi,
    required this.kendaraan,
    required this.selectedSeats,
    required this.jumlahPeserta,
    required this.tanggal,
    required this.totalHarga,
    this.status = 'pending',
    this.user,
    this.expiredAt,
  });

  // =============================================================
  // PASTIKAN HANYA ADA SATU METHOD 'toMap' SEPERTI DI BAWAH INI
  // =============================================================
  Map<String, dynamic> toMap() {
    return {
      // ID tidak perlu dikirim saat membuat pemesanan baru.
      'user_id': userId,
      'destinasi_id': destinasi.id,
      'kendaraan_id': kendaraan.id,
      'selected_seats': selectedSeats,
      'jumlah_peserta': jumlahPeserta,
      'total_harga': totalHarga,
      'status': status,
      // 'expired_at' juga akan di-set oleh backend, jadi tidak perlu dikirim.
    };
  }

  factory Pemesanan.fromMap(Map<String, dynamic> map) {
    final destinasiData = map['destinasi'];
    final kendaraanData = map['kendaraan'];
    final userData = map['user'];

    if (destinasiData == null || kendaraanData == null) {
      throw Exception("Data destinasi atau kendaraan tidak lengkap dalam respons pemesanan.");
    }

    return Pemesanan(
      id: map['id']?.toString() ?? '',
      userId: map['user_id']?.toString() ?? '',
      destinasi: Destinasi.fromJson(destinasiData as Map<String, dynamic>),
      kendaraan: Kendaraan.fromMap(kendaraanData as Map<String, dynamic>),
      selectedSeats: List<int>.from(map['selected_seats'] ?? []),
      jumlahPeserta: map['jumlah_peserta'] ?? 0,
      tanggal: DateTime.tryParse(map['tanggal_pemesanan']?.toString() ?? '') ?? DateTime.now(),
      totalHarga: (map['total_harga'] ?? 0.0).toDouble(),
      status: map['status']?.toString() ?? 'pending',
      user: userData != null ? User.fromJson(userData as Map<String, dynamic>) : null,
      expiredAt: map['expired_at'] != null ? DateTime.tryParse(map['expired_at'].toString()) : null,
    );
  }
}

// Class Pembayaran bisa tetap di sini atau dipisah jika diperlukan
class Pembayaran {
  final int id;
  final int pemesananId;
  final String metode;
  final bool status;

  Pembayaran({
    required this.id,
    required this.pemesananId,
    required this.metode,
    required this.status,
  });

  factory Pembayaran.fromJson(Map<String, dynamic> json) {
    return Pembayaran(
      id: json['id'],
      pemesananId: json['pemesasan_id'],
      metode: json['metode'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pemesasan_id': pemesananId,
      'metode': metode,
      'status': status,
    };
  }
}