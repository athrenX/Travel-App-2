import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class KelolaPembayaranScreen extends StatefulWidget {
  const KelolaPembayaranScreen({super.key});

  @override
  _KelolaPembayaranScreenState createState() => _KelolaPembayaranScreenState();
}

class _KelolaPembayaranScreenState extends State<KelolaPembayaranScreen> {
  // Data pembayaran yang sudah diverifikasi
  final List<Map<String, dynamic>> _verifiedPayments = [
    {
      'id': 'PYM001',
      'user': 'John Doe',
      'orderId': 'ORD12345',
      'amount': 750000,
      'date': DateTime.now().subtract(Duration(days: 2)),
      'status': 'Verified',
      'method': 'Bank Transfer',
      'bank': 'BCA',
      'accountNumber': '1234567890',
      'verifiedBy': 'Admin 1',
      'verifiedDate': DateTime.now().subtract(Duration(days: 1)),
    },
    {
      'id': 'PYM002',
      'user': 'Jane Smith',
      'orderId': 'ORD12346',
      'amount': 1200000,
      'date': DateTime.now().subtract(Duration(days: 3)),
      'status': 'Verified',
      'method': 'Credit Card',
      'cardLast4': '4242',
      'verifiedBy': 'Admin 2',
      'verifiedDate': DateTime.now().subtract(Duration(days: 2)),
    },
  ];

  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat Pembayaran'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [_buildStatsHeader(), _buildSearchBar(), _buildPaymentList()],
      ),
    );
  }

  Widget _buildStatsHeader() {
    final totalAmount = _verifiedPayments.fold(
      0.0,
      (sum, p) => sum + p['amount'],
    );

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Total Pembayaran',
                'Rp${NumberFormat('#,###').format(totalAmount)}',
                Colors.blue.shade800,
              ),
              _buildStatItem(
                'Jumlah Transaksi',
                _verifiedPayments.length.toString(),
                Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Cari pembayaran...',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
        onChanged: (value) => setState(() {}),
      ),
    );
  }

  Widget _buildPaymentList() {
    final searchTerm = _searchController.text.toLowerCase();
    final filteredPayments =
        _verifiedPayments.where((payment) {
          return payment['id'].toLowerCase().contains(searchTerm) ||
              payment['user'].toLowerCase().contains(searchTerm) ||
              payment['orderId'].toLowerCase().contains(searchTerm);
        }).toList();

    if (filteredPayments.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.payment, size: 60, color: Colors.grey.shade400),
              SizedBox(height: 16),
              Text(
                _searchController.text.isEmpty
                    ? 'Belum ada riwayat pembayaran'
                    : 'Pembayaran tidak ditemukan',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        itemCount: filteredPayments.length,
        itemBuilder: (context, index) {
          final payment = filteredPayments[index];
          return _buildPaymentItem(payment);
        },
      ),
    );
  }

  Widget _buildPaymentItem(Map<String, dynamic> payment) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showPaymentDetail(payment),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ID: ${payment['id']}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Chip(
                    label: Text('Terverifikasi'),
                    backgroundColor: Colors.green.withOpacity(0.1),
                    labelStyle: TextStyle(color: Colors.green),
                    avatar: Icon(Icons.verified, size: 18, color: Colors.green),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey),
                  SizedBox(width: 8),
                  Text(payment['user']),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.receipt, size: 16, color: Colors.grey),
                  SizedBox(width: 8),
                  Text('Pesanan: ${payment['orderId']}'),
                ],
              ),
              SizedBox(height: 12),
              Divider(height: 1),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jumlah',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'Rp${NumberFormat('#,###').format(payment['amount'])}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Diverifikasi oleh',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        payment['verifiedBy'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPaymentDetail(Map<String, dynamic> payment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Detail Pembayaran',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                _buildDetailRow('ID Pembayaran', payment['id']),
                _buildDetailRow('ID Pesanan', payment['orderId']),
                _buildDetailRow('Pelanggan', payment['user']),
                _buildDetailRow(
                  'Tanggal',
                  DateFormat('dd MMM yyyy HH:mm').format(payment['date']),
                ),
                _buildDetailRow(
                  'Jumlah',
                  'Rp${NumberFormat('#,###').format(payment['amount'])}',
                ),
                _buildDetailRow('Metode Pembayaran', payment['method']),
                if (payment['method'] == 'Bank Transfer') ...[
                  _buildDetailRow('Bank', payment['bank']),
                  _buildDetailRow('Nomor Rekening', payment['accountNumber']),
                ],
                if (payment['method'] == 'Credit Card')
                  _buildDetailRow(
                    'Kartu',
                    '•••• •••• •••• ${payment['cardLast4']}',
                  ),
                SizedBox(height: 16),
                Divider(),
                SizedBox(height: 8),
                _buildDetailRow('Diverifikasi oleh', payment['verifiedBy']),
                _buildDetailRow(
                  'Tanggal Verifikasi',
                  DateFormat(
                    'dd MMM yyyy HH:mm',
                  ).format(payment['verifiedDate']),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: TextStyle(color: Colors.grey.shade600)),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(value, style: TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
