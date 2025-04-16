class Kendaraan {
  final String id;
  final String jenis;
  final int kapasitas;
  final double harga;
  final String tipe;
  final String gambar;
  final String fasilitas; // Tambahkan properti ini

  Kendaraan({
    required this.id,
    required this.jenis,
    required this.kapasitas,
    required this.harga,
    required this.tipe,
    required this.gambar,
    this.fasilitas = 'AC, Audio', // Berikan nilai default
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'jenis': jenis,
      'kapasitas': kapasitas,
      'harga': harga,
      'tipe': tipe,
      'gambar': gambar,
      'fasilitas': fasilitas, // Tambahkan ke map
    };
  }

  factory Kendaraan.fromMap(Map<String, dynamic> map) {
    return Kendaraan(
      id: map['id'],
      jenis: map['jenis'],
      kapasitas: map['kapasitas'],
      harga: map['harga'],
      tipe: map['tipe'],
      gambar: map['gambar'],
      fasilitas: map['fasilitas'] ?? 'AC, Audio', // Handle jika null
    );
  }
}