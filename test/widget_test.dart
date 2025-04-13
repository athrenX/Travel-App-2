import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travelapp/main.dart'; // Import aplikasi utama atau halaman yang ingin diuji.
import 'package:travelapp/screens/auth/login_screen.dart'; // Pastikan path benar ke file login_screen.dart
import 'package:travelapp/screens/auth/register_screen.dart'; // Pastikan path benar ke file register_screen.dart

void main() {
  // Menguji apakah halaman login muncul saat aplikasi dijalankan
  testWidgets('Halaman Login dimuat dengan benar', (WidgetTester tester) async {
    // Memompa widget aplikasi
    await tester.pumpWidget(MyApp()); // Ganti dengan widget utama aplikasi jika berbeda

    // Memeriksa apakah widget LoginScreen muncul
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  // Menguji interaksi pada form login (misalnya pengisian email dan password)
  testWidgets('Menguji input email dan password di form login', (WidgetTester tester) async {
    // Memompa widget aplikasi
    await tester.pumpWidget(MyApp());

    // Memasukkan email ke dalam field email
    await tester.enterText(find.byType(TextField).first, 'test@example.com');
    // Memasukkan password ke dalam field password
    await tester.enterText(find.byType(TextField).last, 'password123');

    // Menekan tombol login
    await tester.tap(find.text('Login'));

    // Menunggu beberapa waktu untuk perubahan UI
    await tester.pumpAndSettle();

    // Memastikan tidak ada error setelah login
    expect(find.text('Invalid email or password'), findsNothing);
  });

  // Menguji navigasi saat tombol "Don't have an account? Register here" ditekan
  testWidgets('Mengganti layar ketika register ditekan', (WidgetTester tester) async {
    // Memompa widget aplikasi
    await tester.pumpWidget(MyApp());

    // Memastikan tombol register muncul
    expect(find.text("Don't have an account? Register here"), findsOneWidget);

    // Menekan tombol register
    await tester.tap(find.text("Don't have an account? Register here"));

    // Menunggu transisi layar
    await tester.pumpAndSettle();

    // Memastikan kita berada di halaman register
    expect(find.byType(RegisterScreen), findsOneWidget);
  });
}
