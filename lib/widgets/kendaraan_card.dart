import 'package:flutter/material.dart';
import 'package:travelapp/models/kendaraan.dart';

class KendaraanCardCustom extends StatelessWidget {
  final Kendaraan kendaraan;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onImageTap;

  static const Color primaryBlue = Color(0xFF1A73E8);
  static const Color lightBlue = Color(0xFFE8F0FE);
  static const Color whiteColor = Colors.white;

  const KendaraanCardCustom({
    super.key,
    required this.kendaraan,
    required this.isSelected,
    required this.onTap,
    required this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side:
            isSelected
                ? const BorderSide(color: primaryBlue, width: 2)
                : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              GestureDetector(
                onTap: onImageTap,
                child: Container(
                  width: 100,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: lightBlue,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: kendaraan.gambar.isNotEmpty
                        ? FadeInImage.assetNetwork(
                            placeholder:
                                'assets/images/minibus.jpg', // Placeholder
                            image: kendaraan.gambar,
                            fit: BoxFit.cover,
                            imageErrorBuilder:
                                (context, error, stackTrace) => const Icon(
                              Icons.directions_bus,
                              size: 40,
                              color: primaryBlue,
                            ),
                          )
                        : const Icon(
                            Icons.directions_bus,
                            size: 40,
                            color: primaryBlue,
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      kendaraan.jenis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.category, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(kendaraan.tipe),
                        const SizedBox(width: 16),
                        Icon(Icons.people, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text('${kendaraan.kapasitas} orang'),
                      ],
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Icon(Icons.check_circle, color: primaryBlue),
                ),
            ],
          ),
        ),
      ),
    );
  }
}