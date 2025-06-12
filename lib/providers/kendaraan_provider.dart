import 'package:flutter/material.dart';
import 'package:travelapp/models/kendaraan.dart';
import 'package:travelapp/services/kendaraan_service.dart';

class KendaraanProvider with ChangeNotifier {
  List<Kendaraan> _kendaraanList = [];
  bool _isLoading = false;

  List<Kendaraan> get kendaraanList => _kendaraanList;
  bool get isLoading => _isLoading;

  Future<void> fetchKendaraanByDestinasi(String destinasiId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _kendaraanList = await KendaraanService.getKendaraanByDestinasi(destinasiId);
    } catch (e) {
      print('Gagal mengambil data kendaraan untuk destinasi $destinasiId: $e');
      _kendaraanList = [];
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Tambahkan method ini jika belum ada
  void updateKendaraanInList(Kendaraan updatedKendaraan) {
    final index = _kendaraanList.indexWhere((k) => k.id == updatedKendaraan.id);
    if (index != -1) {
      _kendaraanList[index] = updatedKendaraan;
      notifyListeners();
    }
  }

  Kendaraan? getKendaraanById(String id) {
    try {
      return _kendaraanList.firstWhere((kendaraan) => kendaraan.id == id);
    } catch (_) {
      return null;
    }
  }
}