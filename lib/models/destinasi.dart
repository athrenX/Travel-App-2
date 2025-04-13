class Destinasi {
  final String id;
  final String nama;
  final String kategori; // Gunung atau Pantai
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
      'Lokasi': lokasi,
    };
  }

  factory Destinasi.fromMap(Map<String, dynamic> map) {
    return Destinasi(
      id: map['id'],
      nama: map['nama'],
      kategori: map['kategori'],
      deskripsi: map['deskripsi'],
      harga: map['harga'].toDouble(),
      gambar: map['gambar'],
      rating: map['rating'].toDouble(),
      lat: map['lat'].toDouble(),
      lng: map['lng'].toDouble(),
      galeri: List<String>.from(map['galeri']),
      lokasi: map['lokasi'],
    );
  }
}
