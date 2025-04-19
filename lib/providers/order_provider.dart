import 'package:flutter/material.dart';
import '../models/pemesanan.dart';

class OrderProvider with ChangeNotifier {
  final List<Pemesanan> _orders = [];
  bool _adaPesananBaru = false; // Properti untuk menandakan ada pesanan baru

  List<Pemesanan> get orders => _orders;
  bool get adaPesananBaru => _adaPesananBaru;

  // Method untuk menambahkan pesanan
  void tambahPemesanan(Pemesanan pemesanan) {
    _orders.add(pemesanan);
    _adaPesananBaru = true; // Menandakan ada pesanan baru
    notifyListeners();
  }

  // Method untuk reset status pesanan baru
  void resetPesananBaru() {
    _adaPesananBaru = false;
    notifyListeners();
  }
}
