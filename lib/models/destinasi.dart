class Destinasi {
  final String id;
  final String nama;
  final String kategori;
  final String deskripsi;
  final double harga;
  final String gambar;
  final double rating;
  final double lat;
  final double lng;
  final String lokasi;
  final List<String> galeri;

  Destinasi({
    required this.id,
    required this.nama,
    required this.kategori,
    required this.deskripsi,
    required this.harga,
    required this.gambar,
    required this.rating,
    required this.lat,
    required this.lng,
    required this.galeri,
    required this.lokasi,
  });

  // HANYA GUNAKAN SATU FACTORY CONSTRUCTOR YANG SUDAH DIPERBAIKI INI
  factory Destinasi.fromJson(Map<String, dynamic> json) {
    // Parsing yang aman untuk semua tipe data
    return Destinasi(
      id: json['id']?.toString() ?? '', // WAJIB: konversi ID ke String
      nama: json['nama'] ?? '',
      kategori: json['kategori'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      // Parsing harga yang aman, bisa dari int, double, atau string
      harga: double.tryParse(json['harga']?.toString() ?? '0.0') ?? 0.0,
      gambar: json['gambar'] ?? '',
      rating: double.tryParse(json['rating']?.toString() ?? '0.0') ?? 0.0,
      lat: double.tryParse(json['lat']?.toString() ?? '0.0') ?? 0.0,
      lng: double.tryParse(json['lng']?.toString() ?? '0.0') ?? 0.0,
      lokasi: json['lokasi'] ?? '',
      // Parsing galeri yang aman, pastikan itu adalah list
      galeri: (json['galeri'] is List)
          ? List<String>.from(json['galeri'].map((item) => item.toString()))
          : [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'kategori': kategori,
      'deskripsi': deskripsi,
      'harga': harga,
      'gambar': gambar,
      'rating': rating,
      'lat': lat,
      'lng': lng,
      'galeri': galeri,
      'lokasi': lokasi, // Pastikan key 'lokasi' (bukan 'Lokasi')
    };
  }
}