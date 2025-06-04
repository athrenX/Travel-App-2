// import 'package:flutter/material.dart';
// import 'package:travelapp/models/destinasi.dart';
// import 'package:travelapp/services/destinasi_service.dart';

// class DestinasiProvider with ChangeNotifier {
//   List<Destinasi> _destinasiList = [];
//   bool _isLoading = false;

//   List<Destinasi> get destinasiList => _destinasiList;
//   bool get isLoading => _isLoading;

//   Future<void> fetchDestinasi() async {
//     _isLoading = true;
//     notifyListeners();

//     try {
//       _destinasiList = await DestinasiService.getAllDestinasi();
//     } catch (e) {
//       print('Error fetch destinasi: $e');
//     }

//     _isLoading = false;
//     notifyListeners();
//   }

//   List<Destinasi> getByKategori(String kategori) {
//     return _destinasiList.where((d) => d.kategori == kategori).toList();
//   }

//   Destinasi? getById(String id) {
//     try {
//       return _destinasiList.firstWhere((d) => d.id == id);
//     } catch (e) {
//       return null;
//     }
//   }

//   void addDestinasi(Destinasi destinasi) {
//     _destinasiList.add(destinasi);
//     notifyListeners();
//   }

//   void removeDestinasi(String id) {
//     _destinasiList.removeWhere((d) => d.id == id);
//     notifyListeners();
//   }
// }
import 'package:flutter/material.dart';
import 'package:travelapp/models/destinasi.dart';
import 'package:travelapp/services/destinasi_service.dart';

class DestinasiProvider with ChangeNotifier {
  List<Destinasi> _destinasiList = [];
  bool _isLoading = false;

  List<Destinasi> get destinasiList => _destinasiList;
  bool get isLoading => _isLoading;

  /// Fetch data dari API Laravel
  Future<void> fetchDestinasi() async {
    _isLoading = true;
    notifyListeners();

    try {
      _destinasiList = await DestinasiService.getAllDestinasi();
    } catch (e) {
      print('Error fetch destinasi: $e');
      _destinasiList = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Filter berdasarkan kategori
  List<Destinasi> getByKategori(String kategori) {
    return _destinasiList.where((d) => d.kategori == kategori).toList();
  }

  /// Cari berdasarkan ID
  Destinasi? getById(String id) {
    try {
      return _destinasiList.firstWhere((d) => d.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Tambah destinasi ke API
  Future<void> addDestinasi(Destinasi destinasi) async {
    try {
      final newDestinasi = await DestinasiService.addDestinasi(destinasi);
      _destinasiList.add(newDestinasi);
      notifyListeners();
    } catch (e) {
      print("Error add destinasi: $e");
    }
  }

  /// Hapus destinasi via API
  Future<void> removeDestinasi(String id) async {
    try {
      final success = await DestinasiService.deleteDestinasi(id);
      if (success) {
        _destinasiList.removeWhere((d) => d.id == id);
        notifyListeners();
      }
    } catch (e) {
      print("Error delete destinasi: $e");
    }
  }

  /// Update destinasi via API
  Future<void> updateDestinasi(Destinasi updated) async {
    try {
      final success = await DestinasiService.updateDestinasi(updated);
      if (success) {
        final index = _destinasiList.indexWhere((d) => d.id == updated.id);
        if (index != -1) {
          _destinasiList[index] = updated;
          notifyListeners();
        }
      }
    } catch (e) {
      print("Error update destinasi: $e");
    }
  }
}
