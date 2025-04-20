import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Pastikan mengimpor intl
import 'package:intl/date_symbol_data_local.dart'; // Tambahkan ini untuk initializeDateFormatting

import 'package:travelapp/providers/auth_provider.dart';
import 'package:travelapp/providers/destinasi_provider.dart';
import 'package:travelapp/providers/kendaraan_provider.dart';
import 'package:travelapp/providers/order_provider.dart';
import 'package:travelapp/providers/wishlist_provider.dart';
import 'package:travelapp/providers/review_provider.dart';

import 'package:travelapp/screens/auth/login_screen.dart';
import 'package:travelapp/screens/auth/register_screen.dart';
import 'package:travelapp/screens/user/home_screen.dart';
import 'package:travelapp/screens/admin/dashboard_screen.dart';
import 'package:travelapp/config/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inisialisasi data locale untuk intl
  await initializeDateFormatting('id_ID', null); // Inisialisasi untuk Indonesia

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DestinasiProvider()),
        ChangeNotifierProvider(create: (_) => KendaraanProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
      ],
      child: MaterialApp(
        title: 'Travel App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home:
            HomeScreen(), // Ganti dengan LoginScreen jika belum ada auto-login
        routes: {
          AppRoutes.login: (context) => LoginScreen(),
          AppRoutes.register: (context) => RegisterScreen(),
          AppRoutes.home: (context) => HomeScreen(),
          AppRoutes.dashboard: (context) => DashboardScreen(),
        },
      ),
    );
  }
}
