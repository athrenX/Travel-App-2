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
      pemesananId: json['pemesanan_id'],
      metode: json['metode'],
      status: json['status'],
    );
  }
}
