import 'dart:io';

import 'package:travelapp/models/destinasi.dart';

class DestinasiService {
  // Simulasi data destinasi (bisa kamu ganti dengan data dari API nanti)
  static Future<List<Destinasi>> getAllDestinasi() async {
    await Future.delayed(Duration(seconds: 1)); // Simulasi delay jaringan

    return [
      Destinasi(
        id: '1',
        nama: 'Gunung Bromo',
        kategori: 'Gunung',
        deskripsi:
            'Gunung berapi aktif dengan pemandangan matahari terbit yang indah.',
        harga: 500000,
        gambar: 'assets/images/gambar_bromo.jpeg',
        rating: 4.8,
        lat: -7.9425,
        lng: 112.9530,
        lokasi: "Jawa Timur",
        galeri: [
          'assets/images/gambar_bromo.jpeg',
          'assets/images/MendakiBromo.jpg',
          'assets/images/gambar_bromo.jpeg',
        ],
      ),
      Destinasi(
        id: '2',
        nama: 'Kawah Ijen',
        kategori: 'Gunung',
        deskripsi: 'Gunung dengan jalur pendakian populer di Jawa Timur.',
        harga: 450000,
        gambar: 'assets/images/kawahIjen.webp',
        rating: 4.6,
        lat: -7.4502,
        lng: 110.4355,
        lokasi: "Jawa Timur",
        galeri: [
          'assets/images/kawahIjen.webp',
          'assets/images/kawahIjen.webp',
          'assets/images/kawahIjen.webp',
        ],
      ),
      Destinasi(
        id: '3',
        nama: 'Gunung Sindoro',
        kategori: 'Gunung',
        deskripsi:
            'Gunung dengan pemandangan alam yang memesona dan udara sejuk.',
        harga: 470000,
        gambar: 'assets/images/gunung_sindoro.jpeg',
        rating: 4.5,
        lat: -7.3000,
        lng: 109.9925,
        lokasi: "Jawa Tengah",
        galeri: [
          'assets/images/gunung_sindoro.jpeg',
          'assets/images/gunung_sindoro.jpeg',
          'assets/images/gunung_sindoro.jpeg',
        ],
      ),
      Destinasi(
        id: '4',
        nama: 'Pantai Anyer',
        kategori: 'Pantai',
        deskripsi: 'Pantai populer di Banten dengan ombak yang tenang.',
        harga: 300000,
        gambar: 'assets/images/anyer.jpg',
        rating: 4.3,
        lat: -6.2956,
        lng: 105.8530,
        lokasi: "Banten",
        galeri: [
          'assets/images/anyer.jpg',
          'assets/images/anyer.jpg',
          'assets/images/anyer.jpg',
        ],
      ),
      Destinasi(
        id: '5',
        nama: 'Pantai Pangandaran',
        kategori: 'Pantai',
        deskripsi: 'Pantai eksotis dengan sunset yang menawan.',
        harga: 320000,
        gambar: 'assets/images/PANGANDARAN.webp',
        rating: 4.4,
        lat: -7.6921,
        lng: 108.6545,
        lokasi: "Jawa Barat",
        galeri: [
          'assets/images/PANGANDARAN.webp',
          'assets/images/PANGANDARAN.webp',
          'assets/images/PANGANDARAN.webp',
        ],
      ),
      Destinasi(
        id: '6',
        nama: 'Karimun Jawa',
        kategori: 'Pantai',
        deskripsi: 'Kepulauan tropis dengan keindahan bawah laut.',
        harga: 700000,
        gambar: 'assets/images/karimun jawa.webp',
        rating: 4.7,
        lat: -5.8628,
        lng: 110.4474,
        lokasi: "Jawa Tengah",
        galeri: [
          'assets/images/karimun jawa.webp',
          'assets/images/karimun jawa.webp',
          'assets/images/karimun jawa.webp',
        ],
      ),
    ];
  }

  static deleteDestinasi(String id) {}

  static uploadImage(File file) {}

  static addDestinasi(Destinasi newDestinasi) {}

  static updateDestinasi(Destinasi updatedDestinasi) {}
}
