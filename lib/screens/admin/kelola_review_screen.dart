import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:travelapp/models/review.dart';
import 'package:travelapp/providers/review_provider.dart';

class KelolaReviewScreen extends StatelessWidget {
  const KelolaReviewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final reviewProvider = Provider.of<ReviewProvider>(context);
    final List<Review> reviews = reviewProvider.allReviews;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Review'),
        backgroundColor: Colors.blue.shade700,
      ),
      body:
          reviewProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : reviews.isEmpty
              ? Center(
                child: Text(
                  'Belum ada review dari pengguna.',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              )
              : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: reviews.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, i) {
                  final r = reviews[i];
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Foto profil user
                        CircleAvatar(
                          radius: 28,
                          backgroundImage:
                              r.userProfilePictureUrl != null &&
                                      r.userProfilePictureUrl!.isNotEmpty
                                  ? NetworkImage(r.userProfilePictureUrl!)
                                  : const AssetImage(
                                        'assets/images/default_profile.png',
                                      )
                                      as ImageProvider,
                        ),
                        const SizedBox(width: 14),
                        // Detail Review
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Nama User dan tanggal
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    r.userName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    DateFormat(
                                      'd MMM yyyy, HH:mm',
                                      'id_ID',
                                    ).format(r.createdAt),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              // Nama destinasi
                              Text(
                                r.destinasiName ?? '-',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue.shade800,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Bintang
                              Row(
                                children: List.generate(5, (index) {
                                  return Icon(
                                    index < r.rating
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.amber,
                                    size: 18,
                                  );
                                }),
                              ),
                              const SizedBox(height: 6),
                              // Comment
                              Text(
                                r.comment,
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
    );
  }
}
