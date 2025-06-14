import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class KelolaReviewScreen extends StatelessWidget {
  // Dummy review data
  final List<Map<String, dynamic>> reviews;

  KelolaReviewScreen({super.key})
    : reviews = [
        {
          'id': 'REV001',
          'user': 'Sarah Johnson',
          'destinasi': 'Gunung Bromo',
          'rating': 5,
          'comment':
              'Pengalaman yang sangat menyenangkan! Pemandangan luar biasa.',
          "date": DateTime.now().subtract(Duration(days: 5)),
          'status': 'Published',
        },
        {
          'id': 'REV002',
          'user': 'Michael Brown',
          'destinasi': 'Pantai Pangandaran',
          'rating': 4,
          'comment':
              'Pantainya bersih dan indah, tapi cukup ramai di akhir pekan.',
          'date': DateTime.now().subtract(Duration(days: 3)),
          'status': 'Pending',
        },
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Kelola Review')),
      body: Center(child: Text('Review List Placeholder')),
    );
  }
}
