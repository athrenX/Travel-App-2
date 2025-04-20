class Kendaraan {
  final String id;
  final String jenis;
  final int kapasitas;
  final double harga;
  final String tipe;
  final String gambar;
  final String fasilitas;
  final List<int> availableSeats;

  Kendaraan({
    required this.id,
    required this.jenis,
    required this.kapasitas,
    required this.harga,
    required this.tipe,
    required this.gambar,
    this.fasilitas = 'AC, Audio',
    List<int>? availableSeats,
  }) : availableSeats = availableSeats ?? 
        List.generate(kapasitas, (index) => index + 1)..removeWhere((seat) => [4, 13].contains(seat));

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'jenis': jenis,
      'kapasitas': kapasitas,
      'harga': harga,
      'tipe': tipe,
      'gambar': gambar,
      'fasilitas': fasilitas,
      'availableSeats': availableSeats,
    };
  }

  factory Kendaraan.fromMap(Map<String, dynamic> map) {
    return Kendaraan(
      id: map['id'],
      jenis: map['jenis'],
      kapasitas: map['kapasitas'],
      harga: map['harga'] is int ? map['harga'].toDouble() : map['harga'],
      tipe: map['tipe'],
      gambar: map['gambar'],
      fasilitas: map['fasilitas'] ?? 'AC, Audio',
      availableSeats: List<int>.from(map['availableSeats'] ?? []),
    );
  }
}