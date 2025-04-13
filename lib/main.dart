import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelapp/providers/auth_provider.dart';
import 'package:travelapp/providers/destinasi_provider.dart';
import 'package:travelapp/providers/kendaraan_provider.dart';
import 'package:travelapp/screens/auth/login_screen.dart';
import 'package:travelapp/screens/auth/register_screen.dart';
import 'package:travelapp/screens/user/home_screen.dart';
import 'package:travelapp/screens/admin/dashboard_screen.dart';
import 'package:travelapp/config/routes.dart';

void main() {
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
      ],
      child: MaterialApp(
        title: 'Travel App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: LoginScreen(),
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
