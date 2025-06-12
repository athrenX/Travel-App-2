import 'dart:convert'; // Tambahkan ini jika belum ada

class Kendaraan {
  final String id;
  final String jenis;
  final int kapasitas;
  final double harga;
  final String tipe;
  final String gambar;
  final String fasilitas;
  final List<int> availableSeats; // Ini akan berisi kursi yang TERSEDIA

  Kendaraan({
    required this.id,
    required this.jenis,
    required this.kapasitas,
    required this.harga,
    required this.tipe,
    required this.gambar,
    this.fasilitas = 'AC, Audio', // Default value jika tidak ada dari API
    required this.availableSeats, // Pastikan ini required
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'jenis': jenis,
      'kapasitas': kapasitas,
      'harga': harga,
      'tipe': tipe,
      'gambar': gambar,
      'fasilitas': fasilitas,
      'available_seats': availableSeats, // Sesuai dengan nama kolom di DB
    };
  }

  factory Kendaraan.fromMap(Map<String, dynamic> map) {
    // Pastikan ID kendaraan di-cast ke String
    final String id = map['id'].toString();

    // Pastikan harga di-parse dengan benar
    final double harga = map['harga'] is int
        ? map['harga'].toDouble()
        : map['harga'] is String
            ? double.tryParse(map['harga'].toString()) ?? 0.0
            : map['harga']?.toDouble() ?? 0.0;


    // Parsing available_seats: data dari Laravel adalah List<int> atau null
    List<int> parsedAvailableSeats = [];
    if (map['available_seats'] != null) {
      if (map['available_seats'] is List) {
        // Jika sudah list, langsung konversi ke List<int>
        parsedAvailableSeats = List<int>.from(map['available_seats']);
      } else if (map['available_seats'] is String) {
        // Jika berupa string JSON, decode dulu
        try {
          final decoded = jsonDecode(map['available_seats']);
          if (decoded is List) {
            parsedAvailableSeats = List<int>.from(decoded);
          }
        } catch (e) {
          print("Error decoding available_seats string: $e");
          // Fallback ke list kosong jika gagal decode
          parsedAvailableSeats = [];
        }
      }
    }


    return Kendaraan(
      id: id,
      jenis: map['jenis'] ?? '',
      kapasitas: map['kapasitas'] ?? 0,
      harga: harga,
      tipe: map['tipe'] ?? '',
      gambar: map['gambar'] ?? '',
      fasilitas: map['fasilitas'] ?? 'AC, Audio',
      availableSeats: parsedAvailableSeats, // Gunakan yang sudah di-parse
    );
  }
}