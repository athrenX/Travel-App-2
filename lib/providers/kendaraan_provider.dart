import 'package:flutter/material.dart';
import 'package:travelapp/models/kendaraan.dart';
import 'package:travelapp/services/kendaraan_service.dart';

class KendaraanProvider with ChangeNotifier {
  List<Kendaraan> _kendaraanList = [];
  bool _isLoading = false;

  List<Kendaraan> get kendaraanList => _kendaraanList;
  bool get isLoading => _isLoading;

  Future<void> fetchKendaraan() async {
    _isLoading = true;
    notifyListeners();

    try {
      _kendaraanList = await KendaraanService.getAllKendaraan();
    } catch (e) {
      print('Gagal mengambil data kendaraan: $e');
      _kendaraanList = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Kendaraan? getKendaraanById(String id) {
    try {
      return _kendaraanList.firstWhere((kendaraan) => kendaraan.id == id);
    } catch (_) {
      return null;
    }
  }
}
