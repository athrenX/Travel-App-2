import 'package:flutter/material.dart';
import 'package:travelapp/models/destinasi.dart';
import 'package:travelapp/services/destinasi_service.dart';

class DestinasiProvider with ChangeNotifier {
  List<Destinasi> _destinasiList = [];
  bool _isLoading = false;

  List<Destinasi> get destinasiList => _destinasiList;
  bool get isLoading => _isLoading;

  Future<void> fetchDestinasi() async {
    _isLoading = true;
    notifyListeners();

    try {
      _destinasiList = await DestinasiService.getAllDestinasi();
    } catch (e) {
      print('Error fetch destinasi: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  List<Destinasi> getByKategori(String kategori) {
    return _destinasiList.where((d) => d.kategori == kategori).toList();
  }

  Destinasi? getById(String id) {
    try {
      return _destinasiList.firstWhere((d) => d.id == id);
    } catch (e) {
      return null;
    }
  }

  void addDestinasi(Destinasi destinasi) {
    _destinasiList.add(destinasi);
    notifyListeners();
  }

  void removeDestinasi(String id) {
    _destinasiList.removeWhere((d) => d.id == id);
    notifyListeners();
  }
}
