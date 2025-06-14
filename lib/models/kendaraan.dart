import 'dart:convert';

class Kendaraan {
  final String id; // Pastikan ini String
  final String jenis;
  final int kapasitas;
  final double harga;
  final String tipe;
  final String gambar;
  final String fasilitas;
  final List<int> availableSeats;
  final List<int> heldSeats;

  Kendaraan({
    required this.id,
    required this.jenis,
    required this.kapasitas,
    required this.harga,
    required this.tipe,
    required this.gambar,
    this.fasilitas = 'AC, Audio',
    required this.availableSeats,
    required this.heldSeats,
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
      'available_seats': availableSeats,
      'held_seats': heldSeats,
    };
  }

  factory Kendaraan.fromMap(Map<String, dynamic> map) {
    final String id = map['id']?.toString() ?? ''; // PENTING: .toString()
    final double harga = map['harga'] is int
        ? map['harga'].toDouble()
        : map['harga'] is String
            ? double.tryParse(map['harga'].toString()) ?? 0.0
            : map['harga']?.toDouble() ?? 0.0;

    List<int> parsedAvailableSeats = [];
    if (map['available_seats'] != null) {
      dynamic rawSeats = map['available_seats'];
      if (rawSeats is String) {
        try {
          rawSeats = jsonDecode(rawSeats);
        } catch (e) {
          print("Error decoding available_seats string in Kendaraan.fromMap: $e");
          rawSeats = [];
        }
      }
      if (rawSeats is List) {
        parsedAvailableSeats = rawSeats.map((e) {
          if (e is int) return e;
          if (e is String) return int.tryParse(e) ?? 0;
          return 0;
        }).where((e) => e != 0).toList();
      }
    }

    List<int> parsedHeldSeats = [];
    if (map['held_seats'] != null) {
      dynamic rawHeldSeats = map['held_seats'];
      if (rawHeldSeats is String) {
        try {
          rawHeldSeats = jsonDecode(rawHeldSeats);
        } catch (e) {
          print("Error decoding held_seats string in Kendaraan.fromMap: $e");
          rawHeldSeats = [];
        }
      }
      if (rawHeldSeats is List) {
        parsedHeldSeats = rawHeldSeats.map((e) {
          if (e is int) return e;
          if (e is String) return int.tryParse(e) ?? 0;
          return 0;
        }).where((e) => e != 0).toList();
      }
    }

    return Kendaraan(
      id: id,
      jenis: map['jenis']?.toString() ?? '',
      kapasitas: map['kapasitas'] ?? 0,
      harga: harga,
      tipe: map['tipe']?.toString() ?? '',
      gambar: map['gambar']?.toString() ?? '',
      fasilitas: map['fasilitas']?.toString() ?? 'AC, Audio',
      availableSeats: parsedAvailableSeats,
      heldSeats: parsedHeldSeats,
    );
  }
}