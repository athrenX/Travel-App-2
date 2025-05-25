import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelapp/providers/auth_provider.dart';
import 'package:travelapp/screens/admin/kelola_destinasi_screen.dart';
import 'package:travelapp/screens/admin/kelola_kendaraan_screen.dart';
import 'package:travelapp/screens/admin/kelola_pembayaran_screen.dart';
import 'package:travelapp/screens/admin/kelola_pemesanan_screen.dart';
import 'package:travelapp/screens/admin/kelola_review_screen.dart';
import 'package:travelapp/screens/auth/login_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Blue color scheme variants
    const Color primaryBlue = Color(0xFF1A73E8);
    const Color darkBlue = Color(0xFF0D47A1);
    const Color lightBlue = Color(0xFFE8F0FE);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: primaryBlue,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [lightBlue, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            // Menggunakan GridView.builder untuk layout yang lebih fleksibel
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Menentukan jumlah kolom berdasarkan lebar layar
                final crossAxisCount =
                    MediaQuery.of(context).size.width > 600 ? 3 : 2;

                // Menghitung ukuran item yang lebih dinamis
                final width = constraints.maxWidth / crossAxisCount;
                // Pastikan itemHeight tidak terlalu besar yang bisa menyebabkan overflow
                final itemHeight = width * 0.9;

                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: width / itemHeight,
                  ),
                  itemCount: 5, // Total 5 menu
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    // Konfigurasi menu berdasarkan index
                    switch (index) {
                      case 0:
                        return _buildDashboardCard(
                          context,
                          icon: Icons.place_outlined,
                          title: 'Kelola Destinasi',
                          iconColor: Colors.green,
                          onTap:
                              () =>
                                  _navigateTo(context, KelolaDestinasiScreen()),
                        );
                      case 1:
                        return _buildDashboardCard(
                          context,
                          icon: Icons.directions_bus_outlined,
                          title: 'Kelola Kendaraan',
                          iconColor: Colors.orange,
                          onTap:
                              () =>
                                  _navigateTo(context, KelolaKendaraanScreen()),
                        );
                      case 2:
                        return _buildDashboardCard(
                          context,
                          icon: Icons.payment_outlined,
                          title: 'Kelola Pembayaran',
                          iconColor: Colors.purple,
                          onTap:
                              () => _navigateTo(
                                context,
                                KelolaPembayaranScreen(),
                              ),
                        );
                      case 3:
                        return _buildDashboardCard(
                          context,
                          icon: Icons.book_online_outlined,
                          title: 'Kelola Pemesanan',
                          iconColor: Colors.red,
                          onTap:
                              () =>
                                  _navigateTo(context, KelolaPemesananScreen()),
                        );
                      case 4:
                        return _buildDashboardCard(
                          context,
                          icon: Icons.reviews_outlined,
                          title: 'Kelola Review',
                          iconColor: Colors.teal,
                          onTap:
                              () => _navigateTo(context, KelolaReviewScreen()),
                        );
                      default:
                        return const SizedBox();
                    }
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.5),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(
              'Konfirmasi Logout',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Text('Apakah Anda yakin ingin keluar?'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A73E8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  await Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  ).logout();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
                child: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 8.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 28, color: iconColor),
                ),
                const SizedBox(height: 12),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D47A1),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
