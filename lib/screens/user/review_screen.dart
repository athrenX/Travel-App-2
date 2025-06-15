import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelapp/models/destinasi.dart';
import 'package:travelapp/models/pemesanan.dart';
import 'package:travelapp/providers/auth_provider.dart';
import 'package:travelapp/providers/review_provider.dart';
import 'package:travelapp/models/review.dart';

class ReviewScreen extends StatefulWidget {
  final Pemesanan pemesanan;
  final Destinasi destinasi;

  const ReviewScreen({
    super.key,
    required this.pemesanan,
    required this.destinasi,
  });

  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  int _rating = 5;
  final TextEditingController _commentController = TextEditingController();
  Review? _existingReview;

  @override
  void initState() {
    super.initState();
    _loadExistingReview();
  }

  void _loadExistingReview() async {
    final reviewProvider = Provider.of<ReviewProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final review = await reviewProvider.fetchReviewByOrder(
      widget.pemesanan.id,
      authProvider.token ?? '',
    );
    if (mounted && review != null) {
      setState(() {
        _existingReview = review;
        _rating = _existingReview!.rating;
        _commentController.text = _existingReview!.comment;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue.shade800, Colors.blue.shade600],
            ),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min, // Added to prevent overflow
          children: [
            Icon(
              _existingReview != null ? Icons.edit_note : Icons.rate_review,
              color: Colors.white,
            ),
            SizedBox(width: 8),
            Flexible(
              // Wrapped with Flexible to prevent overflow
              child: Text(
                _existingReview != null ? 'Edit Ulasan' : 'Beri Ulasan',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Destination info card
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        children: [
                          // Background image
                          Image.network(
                            widget.destinasi.gambar,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) => Container(
                                  height: 200,
                                  color: Colors.grey.shade200,
                                  child: Icon(
                                    Icons.broken_image,
                                    size: 60,
                                    color: Colors.grey,
                                  ),
                                ),
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return Container(
                                height: 200,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            },
                          ),
                          // Gradient overlay
                          Container(
                            height: 200,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.7),
                                ],
                              ),
                            ),
                          ),
                          // Content
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.destinasi.nama,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                      color:
                                          Theme.of(
                                            context,
                                          ).scaffoldBackgroundColor,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 4),
                                      Flexible(
                                        // Added Flexible to prevent overflow
                                        child: Text(
                                          widget.destinasi.lokasi,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 32),

                  // Rating section
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.star_rate_rounded,
                              color: Colors.amber,
                              size: 28,
                            ),
                            SizedBox(width: 8),
                            Flexible(
                              // Added Flexible to prevent overflow
                              child: Text(
                                'Bagaimana pengalaman Anda?',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        SingleChildScrollView(
                          // Added scroll for small devices
                          scrollDirection: Axis.horizontal,
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisSize:
                                    MainAxisSize.min, // Ini yang utama
                                children: List.generate(5, (index) {
                                  return IconButton(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ), // Padding disesuaikan
                                    icon: Icon(
                                      index < _rating
                                          ? Icons.star_rounded
                                          : Icons.star_outline_rounded,
                                      color:
                                          index < _rating
                                              ? Colors.amber
                                              : Colors.grey.shade400,
                                      size: 40, // Ukuran sedikit diperkecil
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _rating = index + 1;
                                      });
                                    },
                                  );
                                }),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Center(
                          child: Text(
                            _getRatingText(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: _getRatingColor(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),

                  // Comment form
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.comment_outlined,
                              color: Colors.blue.shade700,
                              size: 28,
                            ),
                            SizedBox(width: 8),
                            Flexible(
                              // Added Flexible to prevent overflow
                              child: Text(
                                'Tulis ulasan Anda',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _commentController,
                          maxLines: 5,
                          decoration: InputDecoration(
                            hintText:
                                'Bagikan pengalaman perjalanan Anda di destinasi ini...',
                            filled: true,
                            fillColor: Colors.blue.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.blue.shade300,
                                width: 2,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Silakan tulis ulasan Anda';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32),

                  // Submit button
                  SizedBox(
                    // Wrapped with SizedBox to constrain width
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: _submitReview,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.shade700,
                              Colors.blue.shade500,
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _existingReview != null
                                  ? Icons.update
                                  : Icons.send,
                              color: Colors.white,
                            ),
                            SizedBox(width: 10),
                            Text(
                              _existingReview != null
                                  ? 'Perbarui Ulasan'
                                  : 'Kirim Ulasan',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getRatingText() {
    switch (_rating) {
      case 1:
        return 'Sangat Mengecewakan';
      case 2:
        return 'Kurang Memuaskan';
      case 3:
        return 'Cukup Baik';
      case 4:
        return 'Memuaskan';
      case 5:
        return 'Luar Biasa!';
      default:
        return '';
    }
  }

  Color _getRatingColor() {
    switch (_rating) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.amber;
      case 4:
        return Colors.green;
      case 5:
        return Colors.green.shade700;
      default:
        return Colors.grey;
    }
  }

  void _submitReview() async {
    if (_formKey.currentState!.validate()) {
      final reviewProvider = Provider.of<ReviewProvider>(
        context,
        listen: false,
      );
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      String userName = 'Pengguna';
      if (authProvider.user != null) {
        userName =
            authProvider.user?.nama ??
            authProvider.user?.email.split('@').first ??
            'Pengguna';
      }

      final review = Review(
        id: _existingReview?.id ?? '', // ID dikosongkan saat post baru
        userId: authProvider.user?.id ?? '',
        destinasiId: int.parse(widget.destinasi.id.toString()),
        orderId: widget.pemesanan.id,
        userName: userName,
        rating: _rating,
        comment: _commentController.text,
        createdAt: DateTime.now(), // Tidak digunakan untuk post
      );

      try {
        final token = authProvider.token ?? '';

        if (_existingReview == null) {
          // Post review baru
          await reviewProvider.postReview(review, token);
        } else {
          // Jika sudah punya review dan ingin update, tambahkan method updateReview() di ReviewProvider
          await reviewProvider.updateReview(review, token);
        }

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Text(
                  _existingReview != null
                      ? 'Ulasan berhasil diperbarui!'
                      : 'Ulasan berhasil disimpan!',
                ),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: Duration(seconds: 3),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan ulasan. Silakan coba lagi.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}
