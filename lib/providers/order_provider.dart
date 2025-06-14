// lib/providers/order_provider.dart

import 'package:flutter/material.dart';
import 'package:travelapp/models/pemesanan.dart';
import 'package:travelapp/services/pemesanan_service.dart';

class OrderProvider with ChangeNotifier {
  List<Pemesanan> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Pemesanan> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Mengambil daftar pesanan.
  /// Jika [isAdmin] true, akan mengambil semua pesanan (untuk admin) dari /api/pemesanans.
  /// Jika [isAdmin] false (default), akan mengambil pesanan user yang sedang login dari /api/my-pemesanans.
  Future<void> fetchOrders({bool isAdmin = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (isAdmin) {
        _orders =
            await PemesananService.getAllPemesananForAdmin(); // Panggil metode untuk admin
      } else {
        _orders =
            await PemesananService.getMyPemesananan(); // Panggil metode untuk user biasa
      }
      // Urutkan daftar agar pesanan terbaru berada di atas
      _orders.sort((a, b) => b.tanggal.compareTo(a.tanggal));
    } catch (e) {
      _errorMessage = e.toString();
      _orders = []; // Kosongkan daftar jika terjadi error
      print('Error fetching orders in provider: $e'); // Untuk debugging
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Menambahkan pesanan baru.
  Future<Pemesanan> addOrder(Pemesanan newOrder) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final createdOrder = await PemesananService.createPemesanan(newOrder);
      // Tambahkan pesanan yang baru dibuat ke daftar lokal
      // dan urutkan kembali. Asumsi ini dipanggil oleh user biasa.
      _orders.add(createdOrder);
      _orders.sort((a, b) => b.tanggal.compareTo(a.tanggal));
      notifyListeners();
      return createdOrder;
    } catch (e) {
      _errorMessage = e.toString();
      print('Error adding order in provider: $e');
      rethrow; // Lemparkan kembali error agar bisa ditangkap di UI
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void resetPesananBaru() {
    print('resetPesananBaru called in OrderProvider.');
    // Tambahkan logika untuk mereset status atau data terkait pesanan baru jika diperlukan
  }

  /// Memperbarui status pemesanan.
  /// [pemesananId] adalah ID unik dari pesanan yang akan diubah.
  /// [newStatus] adalah status baru yang akan diterapkan (misal: 'dibayar', 'selesai', 'dibatalkan').
  /// [isAdminUpdate] harus true jika pembaruan ini dilakukan oleh admin, untuk memastikan refresh data yang benar.
  Future<void> updateOrderStatus(
    String pemesananId,
    String newStatus, {
    bool isAdminUpdate = false,
  }) async {
    _isLoading = true; // Set status loading untuk UI
    _errorMessage = null;
    notifyListeners(); // Beri tahu listener bahwa status loading berubah

    try {
      // Panggil service untuk memperbarui status di backend
      final updatedOrder = await PemesananService.updatePemesananStatus(
        pemesananId,
        newStatus,
      );

      // Perbarui objek pesanan di daftar lokal (_orders)
      final index = _orders.indexWhere((order) => order.id == pemesananId);
      if (index != -1) {
        _orders[index] =
            updatedOrder; // Ganti objek lama dengan objek yang sudah diperbarui
      }

      // Refresh daftar pesanan setelah update berhasil untuk memastikan konsistensi
      // Penting: Panggil `fetchOrders` dengan parameter `isAdmin` yang sesuai
      // agar provider mengambil data yang relevan (semua pesanan untuk admin, atau hanya milik user).
      await fetchOrders(isAdmin: isAdminUpdate);
    } catch (e) {
      _errorMessage = e.toString();
      print('Error updating order status in provider: $e');
      rethrow; // Lemparkan kembali error agar UI bisa menangkap dan menampilkan SnackBar
    } finally {
      _isLoading = false;
      notifyListeners(); // Beri tahu listener bahwa status loading telah selesai
    }
  }
}
