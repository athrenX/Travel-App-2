import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelapp/providers/auth_provider.dart';
import 'package:travelapp/screens/admin/kelola_destinasi_screen.dart';
import 'package:travelapp/screens/admin/kelola_kendaraan_screen.dart';
import 'package:travelapp/screens/admin/kelola_pembayaran_screen.dart';
import 'package:travelapp/screens/admin/kelola_pemesanan_screen.dart';
import 'package:travelapp/screens/admin/kelola_review_screen.dart';
import 'package:travelapp/screens/auth/login_screen.dart'; // Assuming you have a login screen

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Admin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMenuTile(
            context,
            icon: Icons.place,
            title: 'Kelola Destinasi',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => KelolaDestinasiScreen()),
              );
            },
          ),
          _buildMenuTile(
            context,
            icon: Icons.directions_car,
            title: 'Kelola Kendaraan',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => KelolaKendaraanScreen()),
              );
            },
          ),
          _buildMenuTile(
            context,
            icon: Icons.payment,
            title: 'Kelola Pembayaran',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => KelolaPembayaranScreen()),
              );
            },
          ),
          _buildMenuTile(
            context,
            icon: Icons.book_online,
            title: 'Kelola Pemesanan',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => KelolaPemesananScreen()),
              );
            },
          ),
          _buildMenuTile(
            context,
            icon: Icons.reviews,
            title: 'Kelola Review',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => KelolaReviewScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Konfirmasi Logout'),
            content: const Text('Apakah anda yakin ingin keluar?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () async {
                  // Get the AuthProvider and call logout
                  await Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  ).logout();

                  // Navigate to login screen and clear navigation stack
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => LoginScreen()),
                    (route) => false,
                  );
                },
                child: const Text('Logout'),
              ),
            ],
          ),
    );
  }

  Widget _buildMenuTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
