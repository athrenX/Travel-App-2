import 'package:flutter/material.dart';
import 'package:travelapp/models/destinasi.dart';
import 'package:travelapp/services/destinasi_service.dart';
import 'dart:convert'; // penting untuk json.decode
import 'package:http/http.dart' as http;


final String baseUrl = 'http://192.168.1.4:8000';

class DestinasiProvider with ChangeNotifier {
  // =================== Carousel =====================
  List<Destinasi> _carouselDestinasi = [];

  List<Destinasi> get carouselDestinasi => _carouselDestinasi;

  Future<void> fetchCarouselDestinasi(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/destinasis'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List<dynamic> data = jsonData['data'];
        final destinasiList =
            data.map((json) => Destinasi.fromJson(json)).toList();

        print('✅ Fetched carousel destinasi: ${destinasiList.length}');
        _carouselDestinasi = destinasiList.take(6).toList();
        notifyListeners();
      } else {
        print('❌ Failed to load carousel destinasi: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching carousel destinasi: $e');
    }
  }

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
