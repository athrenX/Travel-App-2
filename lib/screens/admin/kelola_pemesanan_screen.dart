import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class KelolaPemesananScreen extends StatefulWidget {
  const KelolaPemesananScreen({super.key});

  @override
  _KelolaPemesananScreenState createState() => _KelolaPemesananScreenState();
}

class _KelolaPemesananScreenState extends State<KelolaPemesananScreen> {
  final List<Map<String, dynamic>> _pemesananList = [
    {
      'id': 'P001',
      'nama': 'Asep Kurniawan',
      'destinasi': 'Bali',
      'kendaraan': 'Toyota Hiace',
      'tanggal': '2025-06-15',
      'jumlah': 4,
      'total': 2500000,
      'status': 'Dikonfirmasi',
    },
    {
      'id': 'P002',
      'nama': 'Lina Susanti',
      'destinasi': 'Yogyakarta',
      'kendaraan': 'Bus Pariwisata',
      'tanggal': '2025-06-18',
      'jumlah': 12,
      'total': 4800000,
      'status': 'Menunggu Pembayaran',
    },
    {
      'id': 'P003',
      'nama': 'atal Sukma',
      'destinasi': 'Lombok',
      'kendaraan': 'Avanza',
      'tanggal': '2025-06-20',
      'jumlah': 2,
      'total': 1800000,
      'status': 'Selesai',
    },
    {
      'id': 'P004',
      'nama': 'Yos',
      'destinasi': 'Raja Ampat',
      'kendaraan': 'Jet Pribadi',
      'tanggal': '2025-06-22',
      'jumlah': 6,
      'total': 7500000,
      'status': 'Dibatalkan',
    },
  ];

  // Form controllers
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _destinasiController = TextEditingController();
  final TextEditingController _kendaraanController = TextEditingController();
  final TextEditingController _tanggalController = TextEditingController();
  final TextEditingController _jumlahController = TextEditingController();
  final TextEditingController _totalController = TextEditingController();
  String _selectedStatus = 'Menunggu Pembayaran';
  String? _editingId;

  // Search and filter
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  String _filterStatus = 'Semua Status';

  @override
  void dispose() {
    _namaController.dispose();
    _destinasiController.dispose();
    _kendaraanController.dispose();
    _tanggalController.dispose();
    _jumlahController.dispose();
    _totalController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String _formatRupiah(int number) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(number);
  }

  void _hapusPemesanan(String id) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Hapus Pemesanan'),
            content: Text('Yakin ingin menghapus pemesanan $id?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Batal'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  setState(() {
                    _pemesananList.removeWhere((p) => p['id'] == id);
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Pemesanan berhasil dihapus'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: Text('Hapus', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );
  }

  void _bukaFormPemesanan([Map<String, dynamic>? pemesanan]) {
    // Reset form
    _namaController.clear();
    _destinasiController.clear();
    _kendaraanController.clear();
    _tanggalController.clear();
    _jumlahController.clear();
    _totalController.clear();
    _selectedStatus = 'Menunggu Pembayaran';
    _editingId = null;

    // Jika edit, isi form dengan data yang ada
    if (pemesanan != null) {
      _editingId = pemesanan['id'];
      _namaController.text = pemesanan['nama'];
      _destinasiController.text = pemesanan['destinasi'];
      _kendaraanController.text = pemesanan['kendaraan'];
      _tanggalController.text = pemesanan['tanggal'];
      _jumlahController.text = pemesanan['jumlah'].toString();
      _totalController.text = pemesanan['total'].toString();
      _selectedStatus = pemesanan['status'];
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _editingId == null ? 'Tambah Pemesanan' : 'Edit Pemesanan',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _namaController,
                  decoration: InputDecoration(labelText: 'Nama Pemesan'),
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: _destinasiController,
                  decoration: InputDecoration(labelText: 'Destinasi'),
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: _kendaraanController,
                  decoration: InputDecoration(labelText: 'Kendaraan'),
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: _tanggalController,
                  decoration: InputDecoration(
                    labelText: 'Tanggal (YYYY-MM-DD)',
                  ),
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: _jumlahController,
                  decoration: InputDecoration(labelText: 'Jumlah'),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: _totalController,
                  decoration: InputDecoration(labelText: 'Total'),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  items:
                      [
                        'Menunggu Pembayaran',
                        'Dikonfirmasi',
                        'Selesai',
                        'Dibatalkan',
                      ].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value!;
                    });
                  },
                  decoration: InputDecoration(labelText: 'Status'),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Batal'),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _simpanPemesanan,
                        child: Text(_editingId == null ? 'Tambah' : 'Simpan'),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
    );
  }

  void _simpanPemesanan() {
    if (_namaController.text.isEmpty ||
        _destinasiController.text.isEmpty ||
        _kendaraanController.text.isEmpty ||
        _tanggalController.text.isEmpty ||
        _jumlahController.text.isEmpty ||
        _totalController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Harap isi semua field!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final pemesanan = {
      'id':
          _editingId ??
          'P${(_pemesananList.length + 1).toString().padLeft(3, '0')}',
      'nama': _namaController.text,
      'destinasi': _destinasiController.text,
      'kendaraan': _kendaraanController.text,
      'tanggal': _tanggalController.text,
      'jumlah': int.parse(_jumlahController.text),
      'total': int.parse(_totalController.text),
      'status': _selectedStatus,
    };

    setState(() {
      if (_editingId != null) {
        // Update existing
        final index = _pemesananList.indexWhere((p) => p['id'] == _editingId);
        if (index != -1) {
          _pemesananList[index] = pemesanan;
        }
      } else {
        // Add new
        _pemesananList.add(pemesanan);
      }
    });

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pemesanan berhasil disimpan'),
        backgroundColor: Colors.green,
      ),
    );
  }

  List<Map<String, dynamic>> get _filteredPemesananList {
    return _pemesananList.where((pemesanan) {
      final matchesStatus =
          _filterStatus == 'Semua Status' ||
          pemesanan['status'] == _filterStatus;

      final matchesSearch =
          _searchQuery.isEmpty ||
          pemesanan['nama'].toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          pemesanan['id'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          pemesanan['destinasi'].toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );

      return matchesStatus && matchesSearch;
    }).toList();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Dikonfirmasi':
        return Colors.green;
      case 'Menunggu Pembayaran':
        return Colors.orange;
      case 'Selesai':
        return Colors.blue;
      case 'Dibatalkan':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _filteredPemesananList;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Kelola Pemesanan',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: Text('Cari Pemesanan'),
                      content: TextField(
                        controller: _searchController,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: 'Cari berdasarkan nama/ID/destinasi',
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                          child: Text('Reset'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Tutup'),
                        ),
                      ],
                    ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _filterStatus,
                  items:
                      [
                        'Semua Status',
                        'Menunggu Pembayaran',
                        'Dikonfirmasi',
                        'Selesai',
                        'Dibatalkan',
                      ].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _filterStatus = value!;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Filter Status',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari berdasarkan nama/ID/destinasi',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    suffixIcon:
                        _searchController.text.isNotEmpty
                            ? IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _searchQuery = '';
                                });
                              },
                            )
                            : null,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: ${filteredList.length} pemesanan',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
                if (_filterStatus != 'Semua Status' || _searchQuery.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _filterStatus = 'Semua Status';
                        _searchController.clear();
                        _searchQuery = '';
                      });
                    },
                    child: Text('Reset Filter'),
                  ),
              ],
            ),
          ),
          SizedBox(height: 8),
          Expanded(
            child:
                filteredList.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 60,
                            color: Colors.grey.shade400,
                          ),
                          SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty
                                ? 'Belum ada data pemesanan'
                                : 'Tidak ada hasil pencarian',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: EdgeInsets.only(bottom: 16),
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final pemesanan = filteredList[index];
                        return Card(
                          margin: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'ID: ${pemesanan['id']}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(
                                          pemesanan['status'],
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        pemesanan['status'],
                                        style: TextStyle(
                                          color:
                                              Theme.of(
                                                context,
                                              ).scaffoldBackgroundColor,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                _buildInfoRow(
                                  Icons.person,
                                  'Nama: ${pemesanan['nama']}',
                                ),
                                _buildInfoRow(
                                  Icons.place,
                                  'Destinasi: ${pemesanan['destinasi']}',
                                ),
                                _buildInfoRow(
                                  Icons.directions_car,
                                  'Kendaraan: ${pemesanan['kendaraan']}',
                                ),
                                _buildInfoRow(
                                  Icons.calendar_today,
                                  'Tanggal: ${pemesanan['tanggal']}',
                                ),
                                _buildInfoRow(
                                  Icons.people,
                                  'Jumlah: ${pemesanan['jumlah']} orang',
                                ),
                                _buildInfoRow(
                                  Icons.attach_money,
                                  'Total: ${_formatRupiah(pemesanan['total'])}',
                                ),
                                SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.edit,
                                        color: Colors.blue.shade700,
                                      ),
                                      onPressed:
                                          () => _bukaFormPemesanan(pemesanan),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed:
                                          () =>
                                              _hapusPemesanan(pemesanan['id']),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _bukaFormPemesanan(),
        backgroundColor: Colors.blue.shade700,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
