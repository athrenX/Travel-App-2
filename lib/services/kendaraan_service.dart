import 'package:travelapp/models/kendaraan.dart';

class KendaraanService {
  // Simulasi data kendaraan (bisa diganti dengan API call)
  static Future<List<Kendaraan>> getAllKendaraan() async {
    await Future.delayed(Duration(seconds: 1)); // simulasi loading

    return [
      Kendaraan(
        id: 'k1',
        jenis: 'PAJERO',
        kapasitas: 5,
        harga: 300000,
        tipe: 'Kecil',
        gambar: 'assets/images/mobil-offroad.jpg',
      ),
      Kendaraan(
        id: 'k2',
        jenis: 'BUS',
        kapasitas: 15,
        harga: 750000,
        tipe: 'Besar',
        gambar: 'assets/images/bus.jpg',
      ),
    ];
  }

  static Future<Kendaraan?> getKendaraanById(String id) async {
    final all = await getAllKendaraan();
    try {
      return all.firstWhere((k) => k.id == id);
    } catch (e) {
      return null;
    }
  }
}
