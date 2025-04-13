//model data untuk pemesanan
class Pemesanan {
  final String id;
  final String userId;
  final String destinasiId;
  final String kendaraanId;
  final int jumlahPeserta;
  final DateTime tanggal;
  final double totalHarga;

  Pemesanan({
    required this.id,
    required this.userId,
    required this.destinasiId,
    required this.kendaraanId,
    required this.jumlahPeserta,
    required this.tanggal,
    required this.totalHarga,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'destinasiId': destinasiId,
      'kendaraanId': kendaraanId,
      'jumlahPeserta': jumlahPeserta,
      'tanggal': tanggal.toIso8601String(),
      'totalHarga': totalHarga,
    };
  }

  factory Pemesanan.fromMap(Map<String, dynamic> map) {
    return Pemesanan(
      id: map['id'],
      userId: map['userId'],
      destinasiId: map['destinasiId'],
      kendaraanId: map['kendaraanId'],
      jumlahPeserta: map['jumlahPeserta'],
      tanggal: DateTime.parse(map['tanggal']),
      totalHarga: map['totalHarga'],
    );
  }
}
