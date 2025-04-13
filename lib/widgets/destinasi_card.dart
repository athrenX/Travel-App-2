import 'package:flutter/material.dart';
import 'package:travelapp/models/destinasi.dart';

class DestinasiCard extends StatelessWidget {
  final Destinasi destinasi;
  final VoidCallback? onTap;

  const DestinasiCard({
    Key? key,
    required this.destinasi,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nama dan kategori
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    destinasi.nama,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Chip(
                    label: Text(destinasi.kategori),
                    backgroundColor: destinasi.kategori == 'Gunung'
                        ? Colors.green[100]
                        : Colors.blue[100],
                  ),
                ],
              ),
              SizedBox(height: 8),
              // Deskripsi singkat
              Text(
                destinasi.deskripsi,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[700]),
              ),
              SizedBox(height: 8),
              // Harga
              Text(
                'Rp ${destinasi.harga.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.orange[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
