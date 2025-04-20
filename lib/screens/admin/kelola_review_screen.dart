import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class KelolaReviewScreen extends StatelessWidget {
  // Dummy review data
  final List<Map<String, dynamic>> reviews = [
    {
      'id': 'REV001',
      'user': 'Sarah Johnson',
      'destinasi': 'Gunung Bromo',
      'rating': 5,
      'comment': 'Pengalaman yang sangat menyenangkan! Pemandangan luar biasa.',
      'date': DateTime.now().subtract(Duration(days: 5)),
      'status': 'Published',
    },
    {
      'id': 'REV002',
      'user': 'Michael Brown',
      'destinasi': 'Pantai Pangandaran',
      'rating': 4,
      'comment': 'Pantainya bersih dan indah, tapi cukup ramai di akhir pekan.',
      'date': DateTime.now().subtract(Duration(days: 3)),
      'status': 'Pending',
    },
    {
      'id': 'REV003',
      'user': 'Lisa Wong',
      'destinasi': 'Kawah Ijen',
      'rating': 3,
      'comment': 'Sulit dijangkau tapi pemandangan biru apinya spektakuler.',
      'date': DateTime.now().subtract(Duration(days: 1)),
      'status': 'Rejected',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kelola Review'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari review...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                final review = reviews[index];
                return _buildReviewCard(review, context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review, BuildContext context) {
    Color statusColor;
    switch (review['status']) {
      case 'Published':
        statusColor = Colors.green;
        break;
      case 'Pending':
        statusColor = Colors.orange;
        break;
      case 'Rejected':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  review['destinasi'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.blue.shade800,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    review['status'],
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Oleh: ${review['user']}',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                ...List.generate(
                  5,
                  (index) => Icon(
                    index < review['rating'] ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 20,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  DateFormat('dd MMM yyyy').format(review['date']),
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(review['comment'], style: TextStyle(fontSize: 15)),
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (review['status'] == 'Pending') ...[
                  TextButton(
                    onPressed: () {
                      _approveReview(context, review['id']);
                    },
                    child: Text(
                      'Setujui',
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                  SizedBox(width: 8),
                ],
                TextButton(
                  onPressed: () {
                    _deleteReview(context, review['id']);
                  },
                  child: Text(
                    review['status'] == 'Rejected' ? 'Hapus' : 'Tolak',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Filter Review'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text('Semua'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text('Published'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text('Pending'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text('Rejected'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _approveReview(BuildContext context, String reviewId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Setujui Review'),
            content: Text('Anda yakin ingin menyetujui review ini?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Batal'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Review $reviewId telah disetujui')),
                  );
                },
                child: Text('Setujui'),
              ),
            ],
          ),
    );
  }

  void _deleteReview(BuildContext context, String reviewId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              reviewId.startsWith('REV003') ? 'Hapus Review' : 'Tolak Review',
            ),
            content: Text(
              reviewId.startsWith('REV003')
                  ? 'Anda yakin ingin menghapus review ini?'
                  : 'Anda yakin ingin menolak review ini?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Batal'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        reviewId.startsWith('REV003')
                            ? 'Review $reviewId telah dihapus'
                            : 'Review $reviewId telah ditolak',
                      ),
                    ),
                  );
                },
                child: Text('Ya'),
              ),
            ],
          ),
    );
  }
}
