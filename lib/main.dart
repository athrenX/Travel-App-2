// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:travelapp/providers/auth_provider.dart';
import 'package:travelapp/providers/destinasi_provider.dart';
import 'package:travelapp/providers/kendaraan_provider.dart';
import 'package:travelapp/providers/order_provider.dart';
import 'package:travelapp/providers/wishlist_provider.dart';
import 'package:travelapp/providers/review_provider.dart';

import 'package:travelapp/screens/auth/login_screen.dart';
import 'package:travelapp/screens/auth/register_screen.dart';
import 'package:travelapp/screens/splash_screen.dart';
import 'package:travelapp/screens/user/home_screen.dart';
import 'package:travelapp/screens/admin/dashboard_screen.dart';
import 'package:travelapp/config/routes.dart';
import 'package:provider/provider.dart';


void main() {
  runApp(MyAppWrapper());
}

class MyAppWrapper extends StatefulWidget {
  @override
  State<MyAppWrapper> createState() => _MyAppWrapperState();
}

class _MyAppWrapperState extends State<MyAppWrapper> {
  final AuthProvider _authProvider = AuthProvider();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initAuth();
  }

  Future<void> _initAuth() async {
    WidgetsFlutterBinding.ensureInitialized();
    await initializeDateFormatting('id_ID', null);
    await _authProvider.tryAutoLogin();
    setState(() => _isInitialized = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: _authProvider),
        ChangeNotifierProvider(create: (_) => DestinasiProvider()),
        ChangeNotifierProvider(create: (_) => KendaraanProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travel App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/dashboard': (context) => const DashboardScreen(),
      },
    );
  }
}
