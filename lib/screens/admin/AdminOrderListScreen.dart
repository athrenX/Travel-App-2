import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:travelapp/models/pemesanan.dart';
import 'package:travelapp/providers/order_provider.dart';

class AdminOrderListScreen extends StatefulWidget {
  const AdminOrderListScreen({super.key});

  @override
  State<AdminOrderListScreen> createState() => _AdminOrderListScreenState();
}

class _AdminOrderListScreenState extends State<AdminOrderListScreen> {
  String _selectedFilterStatus = 'all'; // Default filter status
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Memuat pesanan saat halaman pertama kali dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchOrdersForAdmin();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Mengambil data pesanan khusus untuk admin
  Future<void> _fetchOrdersForAdmin() async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    await orderProvider.fetchOrders(
      isAdmin: true,
    ); // Memanggil fetchOrders dengan isAdmin: true
  }

  // Logika filter pesanan berdasarkan status dan pencarian
  List<Pemesanan> _filterOrders(List<Pemesanan> allOrders) {
    List<Pemesanan> filtered = allOrders;

    // Filter berdasarkan status
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

    // Filter berdasarkan teks pencarian
    final searchText = _searchController.text.toLowerCase();
    if (searchText.isNotEmpty) {
      filtered =
          filtered.where((order) {
            final destinasiName = order.destinasi.nama.toLowerCase();
            final userName = order.user?.nama?.toLowerCase() ?? '';
            final orderId = order.id.toLowerCase();
            return destinasiName.contains(searchText) ||
                userName.contains(searchText) ||
                orderId.contains(searchText);
          }).toList();
    }

    // Urutkan berdasarkan tanggal pemesanan, terbaru di atas
    filtered.sort((a, b) => b.tanggal.compareTo(a.tanggal));

    return filtered;
  }

  // Fungsi untuk mengubah status pesanan melalui provider
  Future<void> _updateOrderStatus(Pemesanan pemesanan, String newStatus) async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    // Tampilkan dialog loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),
    );

    try {
      // Panggil provider untuk update status
      await orderProvider.updateOrderStatus(
        pemesanan.id,
        newStatus,
        isAdminUpdate: true, // Beri tahu provider bahwa ini update dari admin
      );
      if (mounted) {
        Navigator.of(context).pop(); // Tutup dialog loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Status pemesanan berhasil diubah menjadi "$newStatus".',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Tutup dialog loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengubah status pemesanan: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, child) {
        // Daftar pesanan yang sudah difilter
        final List<Pemesanan> daftarPesanan = _filterOrders(
          orderProvider.orders,
        );

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Kelola Pemesanan',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.blue.shade800, // Warna AppBar khusus admin
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: _fetchOrdersForAdmin, // Refresh data
              ),
              IconButton(
                icon: const Icon(Icons.filter_list, color: Colors.white),
                onPressed: () {
                  // Tampilkan bottom sheet untuk filter status
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
              // Bagian pencarian dan filter status
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
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
                        hintText: 'Cari pemesanan (ID, destinasi, user)...',
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.blue.shade800,
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
                        setState(
                          () {},
                        ); // Memperbarui UI saat teks pencarian berubah
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
                                  _buildStatusChip('all', 'Semua'),
                                  _buildStatusChip(
                                    'menunggu pembayaran',
                                    'Menunggu Pembayaran',
                                  ),
                                  _buildStatusChip('dibayar', 'Dibayar'),
                                  _buildStatusChip('diproses', 'Diproses'),
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

              // Tampilan kondisi (loading, error, empty, atau list pesanan)
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
                            onPressed: _fetchOrdersForAdmin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade600,
                              foregroundColor: Colors.white,
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
                      onRefresh: _fetchOrdersForAdmin,
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

  // Widget untuk chip filter status
  Widget _buildStatusChip(String value, String label) {
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color:
              _selectedFilterStatus == value
                  ? Colors.white
                  : Colors.blue.shade800,
          fontSize: 12,
        ),
      ),
      selected: _selectedFilterStatus == value,
      onSelected: (bool selected) {
        setState(() {
          _selectedFilterStatus = selected ? value : 'all';
        });
      },
      selectedColor: Colors.blue.shade800,
      backgroundColor: Colors.white,
      side: BorderSide(color: Colors.blue.shade200),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      visualDensity: VisualDensity.compact,
    );
  }

  // Tampilan ketika tidak ada pesanan
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.article_outlined, size: 80, color: Colors.blue.shade200),
          const SizedBox(height: 16),
          Text(
            'Tidak ada pemesanan yang ditemukan.',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coba ubah filter atau cari dengan kata kunci lain.',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  // Widget untuk menampilkan setiap detail pesanan dalam bentuk kartu
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
      case 'diproses':
        statusColor = Colors.blue.shade700;
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
          // Admin bisa menambahkan navigasi ke detail pesanan yang lebih rinci di sini
          // Misalnya: Navigator.push(context, MaterialPageRoute(builder: (context) => AdminOrderDetailScreen(pemesanan: pesanan)));
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header kartu dengan status dan tanggal
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
            // Detail utama pesanan
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
                          'ID Pesanan: ${pesanan.id}', // Tampilkan ID Pemesanan
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          pesanan.destinasi.nama,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Pemesan: ${pesanan.user?.nama ?? 'N/A'}', // Tampilkan nama user
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
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
                        const SizedBox(height: 4),
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
            // Bagian total pembayaran dan tombol aksi
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
                  _buildAdminActionButtons(pesanan, context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk tombol aksi admin berdasarkan status pesanan
  Widget _buildAdminActionButtons(Pemesanan pesanan, BuildContext context) {
    if (pesanan.status == 'dibayar') {
      return ElevatedButton.icon(
        onPressed: () {
          _showChangeStatusDialog(context, pesanan, 'selesai');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
        icon: const Icon(Icons.check_circle_outline, size: 18),
        label: const Text('Tandai Selesai'),
      );
    } else if (pesanan.status == 'menunggu pembayaran') {
      return Row(
        children: [
          OutlinedButton(
            onPressed:
                () => _showChangeStatusDialog(context, pesanan, 'dibatalkan'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: BorderSide(color: Colors.red.shade200),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: const Text('Batalkan'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              _showChangeStatusDialog(
                context,
                pesanan,
                'dibayar',
              ); // Admin bisa langsung tandai dibayar
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: const Text('Tandai Dibayar'),
          ),
        ],
      );
    } else if (pesanan.status == 'dibatalkan') {
      return const Text(
        'Dibatalkan',
        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      );
    } else if (pesanan.status == 'selesai') {
      return const Text(
        'Selesai',
        style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
      );
    } else if (pesanan.status == 'diproses') {
      return const Text(
        'Sedang diproses',
        style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
      );
    } else {
      return const SizedBox.shrink(); // Widget kosong jika status tidak dikenali
    }
  }

  // Dialog konfirmasi perubahan status
  void _showChangeStatusDialog(
    BuildContext context,
    Pemesanan pesanan,
    String newStatus,
  ) {
    String actionText;
    if (newStatus == 'selesai') {
      actionText = 'mengubah status pemesanan ${pesanan.id} menjadi "Selesai"?';
    } else if (newStatus == 'dibayar') {
      actionText = 'mengubah status pemesanan ${pesanan.id} menjadi "Dibayar"?';
    } else if (newStatus == 'dibatalkan') {
      actionText =
          'membatalkan pemesanan ${pesanan.id} dan mengembalikan kursinya?';
    } else {
      actionText =
          'mengubah status pemesanan ${pesanan.id} menjadi "$newStatus"?';
    }

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Konfirmasi Perubahan Status'),
            content: Text('Apakah Anda yakin ingin $actionText'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Tidak'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop(); // Tutup dialog konfirmasi
                  _updateOrderStatus(
                    pesanan,
                    newStatus,
                  ); // Lanjutkan perubahan status
                },
                child: const Text('Ya'),
              ),
            ],
          ),
    );
  }

  // Fungsi format rupiah
  String _formatRupiahOrderCard(double number) {
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 0,
    );
    return formatCurrency.format(number);
  }

  // Fungsi format tanggal
  String _formatDate(DateTime date) {
    return DateFormat('dd MMMM HH:mm', 'id_ID').format(date);
  }

  // Fungsi format nomor kursi
  String _formatSeatNumbersOrderCard(List<int> seats) {
    seats.sort();
    if (seats.isEmpty) return '-';
    if (seats.length > 5) {
      return '${seats.take(5).join(', ')}, ...';
    }
    return seats.join(', ');
  }
}

// FilterBottomSheet (tetap sama)
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
              _filterChip('all', 'Semua'),
              _filterChip('menunggu pembayaran', 'Menunggu Pembayaran'),
              _filterChip('dibayar', 'Dibayar'),
              _filterChip('diproses', 'Diproses'),
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
