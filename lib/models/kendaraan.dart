// Model data untuk kendaraan
class Kendaraan {
  final String id;
  final String jenis; // Jenis kendaraan (Besar/Kecil)
  final int kapasitas; // Kapasitas penumpang
  final double harga; // Harga kendaraan per paket
  final String tipe;
  final String gambar; // Gambar kendaraan

  Kendaraan({
    required this.id,
    required this.jenis,
    required this.kapasitas,
    required this.harga,
    required this.tipe,
    required this.gambar,
  });

  // Fungsi untuk mengubah data kendaraan menjadi format Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'jenis': jenis,
      'kapasitas': kapasitas,
      'harga': harga,
      'tipe': tipe,
      'gambar': gambar,
    };
  }

  // Fungsi untuk mengubah Map menjadi objek Kendaraan
  factory Kendaraan.fromMap(Map<String, dynamic> map) {
    return Kendaraan(
      id: map['id'],
      jenis: map['jenis'],
      kapasitas: map['kapasitas'],
      harga: map['harga'],
      tipe: map['tipe'],
      gambar: map['gambar'],
    );
  }
}
