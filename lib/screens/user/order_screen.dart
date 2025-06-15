import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelapp/models/pemesanan.dart';
import 'package:travelapp/providers/order_provider.dart';
import 'package:intl/intl.dart';
import 'package:travelapp/screens/user/review_screen.dart';
import 'package:travelapp/screens/user/pembayaran_screen.dart';
import 'package:travelapp/services/pemesanan_service.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  String _selectedFilterStatus = 'all';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchOrders();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchOrders() async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    await orderProvider.fetchOrders();
  }

  List<Pemesanan> _filterOrders(List<Pemesanan> allOrders) {
    List<Pemesanan> filtered = allOrders;

    if (_selectedFilterStatus != 'all') {
      filtered =
          filtered
              .where(
                (order) =>
                    order.status.toLowerCase() ==
                    _selectedFilterStatus.toLowerCase(),
              )
              .toList();
    }

    final searchText = _searchController.text.toLowerCase();
    if (searchText.isNotEmpty) {
      filtered =
          filtered.where((order) {
            final destinasiName = order.destinasi.nama.toLowerCase();
            final userName = order.user?.nama?.toLowerCase() ?? '';

            return destinasiName.contains(searchText) ||
                userName.contains(searchText);
          }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    print("Building OrderScreen");
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, child) {
        final List<Pemesanan> daftarPesanan = _filterOrders(
          orderProvider.orders,
        );

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Pesanan Saya',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.blue.shade600,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list, color: Colors.white),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder:
                        (context) => FilterBottomSheet(
                          initialStatus: _selectedFilterStatus,
                          onFilterApplied: (status) {
                            setState(() {
                              _selectedFilterStatus = status;
                            });
                            Navigator.pop(context);
                          },
                        ),
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Cari pesanan...',
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.blue.shade600,
                        ),
                        suffixIcon:
                            _searchController.text.isNotEmpty
                                ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {});
                                  },
                                )
                                : null,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 40,
                      alignment: Alignment.centerLeft,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children:
                            [
                                  _buildStatusChip(
                                    'menunggu pembayaran',
                                    'Menunggu Pembayaran',
                                  ),
                                  _buildStatusChip('dibayar', 'Dibayar'),
                                  _buildStatusChip('selesai', 'Selesai'),
                                  _buildStatusChip('dibatalkan', 'Dibatalkan'),
                                ]
                                .map(
                                  (chip) => Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: chip,
                                  ),
                                )
                                .toList(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              orderProvider.isLoading
                  ? const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    ),
                  )
                  : orderProvider.errorMessage != null
                  ? Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 80,
                            color: Colors.red.shade200,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error: ${orderProvider.errorMessage}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _fetchOrders,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade600,
                            ),
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  )
                  : daftarPesanan.isEmpty
                  ? _buildEmptyState(context)
                  : Expanded(
                    child: RefreshIndicator(
                      onRefresh: _fetchOrders,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount: daftarPesanan.length,
                        itemBuilder: (context, index) {
                          final pesanan = daftarPesanan[index];
                          return _buildOrderCard(pesanan, context);
                        },
                      ),
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String value, String label) {
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color:
              _selectedFilterStatus == value
                  ? Colors.white
                  : Colors.blue.shade600,
          fontSize: 12,
        ),
      ),
      selected: _selectedFilterStatus == value,
      onSelected: (bool selected) {
        setState(() {
          _selectedFilterStatus = selected ? value : 'all';
        });
      },
      selectedColor: Colors.blue.shade600,
      backgroundColor: Colors.white,
      side: BorderSide(color: Colors.blue.shade200),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.article_outlined, size: 80, color: Colors.blue.shade200),
          const SizedBox(height: 16),
          Text(
            'Belum ada pesanan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Jelajahi destinasi impianmu sekarang!',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/home');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text('Jelajahi Destinasi'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Pemesanan pesanan, BuildContext context) {
    Color statusColor;
    switch (pesanan.status.toLowerCase()) {
      case 'selesai':
        statusColor = Colors.green;
        break;
      case 'dibatalkan':
        statusColor = Colors.red;
        break;
      case 'dibayar':
        statusColor = Colors.green.shade700;
        break;
      case 'menunggu pembayaran':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.blue.shade50),
      ),
      child: InkWell(
        onTap: () {
          // Navigasi ke detail pemesanan
          if (pesanan.status == 'menunggu pembayaran') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PembayaranScreen(pemesanan: pesanan),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    pesanan.status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _formatDate(pesanan.tanggal),
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      pesanan.destinasi.gambar,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        print(
                          '[LOG] Memuat gambar dari: ${pesanan.destinasi.gambar}',
                        );
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value:
                                loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        print(
                          '[ERROR] Gagal memuat gambar: ${pesanan.destinasi.gambar}',
                        );
                        print('[DETAIL ERROR] $error');
                        return Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pesanan.destinasi.nama,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                pesanan.destinasi.lokasi,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.people,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${pesanan.jumlahPeserta} orang',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.directions_bus,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${pesanan.kendaraan.jenis} (${pesanan.kendaraan.tipe})',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.chair,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Kursi: ${_formatSeatNumbersOrderCard(pesanan.selectedSeats)}',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Pembayaran',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'Rp ${_formatRupiahOrderCard(pesanan.totalHarga)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  _buildActionButtons(pesanan.status, context, pesanan),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    String status,
    BuildContext context,
    Pemesanan pesanan,
  ) {
    Widget reviewButton = OutlinedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => ReviewScreen(
                  pemesanan: pesanan,
                  destinasi: pesanan.destinasi,
                ),
          ),
        );
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.blue.shade600,
        side: BorderSide(color: Colors.blue.shade200),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      child: const Text('Beri Ulasan'),
    );

    switch (status.toLowerCase()) {
      case 'menunggu pembayaran':
        return Row(
          children: [
            OutlinedButton(
              onPressed: () async {
                final confirmCancel =
                    await showDialog<bool>(
                      context: context,
                      builder:
                          (ctx) => AlertDialog(
                            title: const Text('Batalkan Pemesanan?'),
                            content: const Text(
                              'Apakah Anda yakin ingin membatalkan pemesanan ini? Kursi akan dikembalikan ke tersedia.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                child: const Text('Tidak'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(true),
                                child: const Text('Ya'),
                              ),
                            ],
                          ),
                    ) ??
                    false;

                if (confirmCancel) {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder:
                        (ctx) => const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.red,
                            ),
                          ),
                        ),
                  );
                  try {
                    await PemesananService.cancelPemesanan(pesanan.id);
                    if (mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Pemesanan berhasil dibatalkan.'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      _fetchOrders(); // Refresh daftar pesanan
                    }
                  } catch (e) {
                    if (mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Gagal membatalkan pemesanan: ${e.toString()}',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: BorderSide(color: Colors.red.shade200),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: const Text(
                'Batalkan',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PembayaranScreen(pemesanan: pesanan),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: const Text(
                'Bayar Sekarang',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      case 'selesai':
        return reviewButton;
      case 'dibayar':
      case 'diproses':
        return const Text(
          'Sedang diproses',
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        );
      case 'dibatalkan':
        return const Text(
          'Dibatalkan',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        );
      case 'pending':
        return const Text(
          'Pending',
          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  String _formatRupiahOrderCard(double number) {
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 0,
    );
    return formatCurrency.format(number);
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMMM HH:mm', 'id_ID').format(date);
  }

  String _formatSeatNumbersOrderCard(List<int> seats) {
    seats.sort();
    if (seats.isEmpty) return '-';
    if (seats.length > 5) {
      return '${seats.take(5).join(', ')}, ...';
    }
    return seats.join(', ');
  }
}

class FilterBottomSheet extends StatefulWidget {
  final String initialStatus;
  final Function(String status) onFilterApplied;

  const FilterBottomSheet({
    super.key,
    required this.initialStatus,
    required this.onFilterApplied,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late String _selectedStatus;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.initialStatus;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter Pesanan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Status Pesanan',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _filterChip('menunggu pembayaran', 'Menunggu Pembayaran'),
              _filterChip('dibayar', 'Dibayar'),
              _filterChip('selesai', 'Selesai'),
              _filterChip('dibatalkan', 'Dibatalkan'),
            ],
          ),
          const SizedBox(height: 16),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _selectedStatus = 'all';
                    });
                    widget.onFilterApplied(_selectedStatus);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue.shade600,
                    side: BorderSide(color: Colors.blue.shade200),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Reset'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onFilterApplied(_selectedStatus);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Terapkan'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String value, String label) {
    return FilterChip(
      label: Text(label),
      selected: _selectedStatus == value,
      onSelected: (bool selected) {
        setState(() {
          _selectedStatus = value;
        });
      },
      selectedColor: Colors.blue.shade100,
      checkmarkColor: Colors.blue.shade600,
      backgroundColor: Colors.white,
      side: BorderSide(color: Colors.blue.shade200),
      labelStyle: TextStyle(
        color:
            _selectedStatus == value
                ? Colors.blue.shade800
                : Colors.grey.shade700,
      ),
    );
  }
}
