import 'package:flutter/material.dart';
import 'package:travelapp/models/pemesanan.dart';
import 'package:travelapp/services/pemesanan_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderProvider with ChangeNotifier {
  List<Pemesanan> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Pemesanan> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _orders = await PemesananService.getMyPemesananan(); // TANPA token
    } catch (e) {
      _errorMessage = e.toString();
      _orders = [];
      print('Error fetching orders in provider: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Pemesanan> addOrder(Pemesanan newOrder) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final createdOrder = await PemesananService.createPemesanan(newOrder);
      // Tambahkan pemesanan yang baru dibuat ke daftar lokal
      _orders.add(createdOrder);
      // Sort the list so new orders appear at the top
      _orders.sort((a, b) => b.tanggal.compareTo(a.tanggal));
      notifyListeners();
      return createdOrder;
    } catch (e) {
      _errorMessage = e.toString();
      print('Error adding order in provider: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void resetPesananBaru() {
    print('resetPesananBaru called in OrderProvider.');
  }

  Future<void> updateOrderStatus(String pemesananId, String newStatus) async {
    // Ini adalah implementasi placeholder. Anda perlu membuat API di PemesananService
    // yang sesuai untuk mengupdate status pemesanan di backend.
    // Contoh:
    // try {
    //   final updatedOrder = await PemesananService.updatePemesananStatus(pemesananId, newStatus);
    //   final index = _orders.indexWhere((order) => order.id == pemesananId);
    //   if (index != -1) {
    //     _orders[index] = updatedOrder; // Update objek di list lokal
    //     notifyListeners();
    //   }
    // } catch (e) {
    //   _errorMessage = e.toString();
    //   print('Error updating order status: $e');
    //   rethrow;
    // }
    print(
      'Update order status for $pemesananId to $newStatus (API not fully implemented yet)',
    );
  }
}
