import 'package:flutter/material.dart';
import 'package:travelapp/models/destinasi.dart';

class DestinasiCard extends StatelessWidget {
  final Destinasi destinasi;
  final VoidCallback? onTap;
  final bool isInWishlist;
  final VoidCallback? onWishlistPressed;

  const DestinasiCard({
    super.key,
    required this.destinasi,
    this.onTap,
    this.isInWishlist = false,
    this.onWishlistPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                  Expanded(
                    child: Text(
                      destinasi.nama,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    children: [
                      Chip(
                        label: Text(destinasi.kategori),
                        backgroundColor:
                            destinasi.kategori == 'Gunung'
                                ? Colors.green[100]
                                : Colors.blue[100],
                      ),
                      SizedBox(width: 8),
                      if (onWishlistPressed != null)
                        IconButton(
                          icon: Icon(
                            isInWishlist
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: isInWishlist ? Colors.red : Colors.grey,
                          ),
                          onPressed: onWishlistPressed,
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          iconSize: 24,
                        ),
                    ],
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
              // Harga dan rating
              Row(
                children: [
                  Icon(Icons.star, size: 16, color: Colors.amber),
                  SizedBox(width: 4),
                  Text(destinasi.rating.toStringAsFixed(1) ?? '0.0'),
                  Spacer(),
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
            ],
          ),
        ),
      ),
    );
  }
}
