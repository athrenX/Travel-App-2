import 'package:flutter/material.dart';
import 'package:travelapp/models/kendaraan.dart';

class KendaraanCard extends StatelessWidget {
  final Kendaraan kendaraan;
  final bool isSelected;
  final VoidCallback onTap;

  const KendaraanCard({
    super.key,
    required this.kendaraan,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: isSelected ? 8 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                kendaraan.jenis,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.blue : Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text('Kapasitas: ${kendaraan.kapasitas} orang'),
              Text('Harga: Rp ${kendaraan.harga.toStringAsFixed(0)}'),
            ],
          ),
        ),
      ),
    );
  }
}
