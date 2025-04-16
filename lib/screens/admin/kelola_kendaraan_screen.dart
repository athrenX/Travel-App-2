import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class KelolaKendaraanScreen extends StatefulWidget {
  @override
  _KelolaKendaraanScreenState createState() => _KelolaKendaraanScreenState();
}

class _KelolaKendaraanScreenState extends State<KelolaKendaraanScreen> {
  // Data kendaraan
  List<Map<String, dynamic>> _kendaraanList = [
    {
      'id': 'K001',
      'jenis': 'Toyota Hiace',
      'tipe': 'Minibus',
      'kapasitas': 12,
      'harga': 1500000,
      'status': 'Tersedia',
      'gambar': 'assets/minibus.png',
    },
    {
      'id': 'K002',
      'jenis': 'Bus Pariwisata',
      'tipe': 'Bus',
      'kapasitas': 30,
      'harga': 3500000,
      'status': 'Tersedia',
      'gambar': 'assets/bus.png',
    },
    {
      'id': 'K003',
      'jenis': 'Avanza',
      'tipe': 'MPV',
      'kapasitas': 6,
      'harga': 800000,
      'status': 'Dalam Perbaikan',
      'gambar': 'assets/avanza.png',
    },
  ];

  // Controller untuk form
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _jenisController = TextEditingController();
  final TextEditingController _tipeController = TextEditingController();
  final TextEditingController _kapasitasController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
  String _selectedStatus = 'Tersedia';
  String? _editingId;
  String _searchQuery = '';

  // Warna tema
  final Color _primaryColor = Colors.blue.shade700;
  final Color _accentColor = Colors.blue.shade400;
  final Color _dangerColor = Colors.red.shade600;
  final Color _successColor = Colors.green.shade600;

  @override
  void dispose() {
    _searchController.dispose();
    _jenisController.dispose();
    _tipeController.dispose();
    _kapasitasController.dispose();
    _hargaController.dispose();
    super.dispose();
  }

  // Format Rupiah
  String _formatRupiah(int number) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(number);
  }

  // Validasi form
  bool _validateForm() {
    if (_jenisController.text.isEmpty ||
        _tipeController.text.isEmpty ||
        _kapasitasController.text.isEmpty ||
        _hargaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Harap isi semua field!'),
          backgroundColor: _dangerColor,
        ),
      );
      return false;
    }

    if (int.tryParse(_kapasitasController.text) == null ||
        int.tryParse(_hargaController.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kapasitas dan Harga harus berupa angka!'),
          backgroundColor: _dangerColor,
        ),
      );
      return false;
    }

    return true;
  }

  // Buka form tambah/edit
  void _openKendaraanForm([Map<String, dynamic>? kendaraan]) {
    // Reset form
    _jenisController.clear();
    _tipeController.clear();
    _kapasitasController.clear();
    _hargaController.clear();
    _selectedStatus = 'Tersedia';
    _editingId = null;

    // Jika edit, isi form dengan data yang ada
    if (kendaraan != null) {
      _editingId = kendaraan['id'];
      _jenisController.text = kendaraan['jenis'];
      _tipeController.text = kendaraan['tipe'];
      _kapasitasController.text = kendaraan['kapasitas'].toString();
      _hargaController.text = kendaraan['harga'].toString();
      _selectedStatus = kendaraan['status'];
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _editingId == null ? 'Tambah Kendaraan' : 'Edit Kendaraan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _primaryColor,
                ),
              ),
              SizedBox(height: 20),
              _buildTextField(_jenisController, 'Jenis Kendaraan', Icons.directions_car),
              SizedBox(height: 15),
              _buildTextField(_tipeController, 'Tipe Kendaraan', Icons.category),
              SizedBox(height: 15),
              _buildTextField(_kapasitasController, 'Kapasitas', Icons.people, isNumber: true),
              SizedBox(height: 15),
              _buildTextField(_hargaController, 'Harga Sewa', Icons.attach_money, isNumber: true),
              SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                items: ['Tersedia', 'Dalam Perbaikan', 'Tidak Tersedia']
                    .map((String value) {
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
                decoration: InputDecoration(
                  labelText: 'Status',
                  prefixIcon: Icon(Icons.info),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 25),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        side: BorderSide(color: _primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Batal',
                        style: TextStyle(color: _primaryColor),
                      ),
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_validateForm()) {
                          _editingId == null
                              ? _addKendaraan()
                              : _updateKendaraan();
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        _editingId == null ? 'Tambah' : 'Simpan',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Widget text field
  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isNumber = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: _primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: _primaryColor),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // Tambah kendaraan baru
  void _addKendaraan() {
    // Generate ID baru (K001, K002, dst)
    int nextId = _kendaraanList.isEmpty
        ? 1
        : int.parse(_kendaraanList.last['id'].substring(1)) + 1;
    String newId = 'K${nextId.toString().padLeft(3, '0')}';

    setState(() {
      _kendaraanList.add({
        'id': newId,
        'jenis': _jenisController.text,
        'tipe': _tipeController.text,
        'kapasitas': int.parse(_kapasitasController.text),
        'harga': int.parse(_hargaController.text),
        'status': _selectedStatus,
        'gambar': 'assets/car_placeholder.png',
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Kendaraan berhasil ditambahkan'),
        backgroundColor: _successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // Update kendaraan
  void _updateKendaraan() {
    setState(() {
      final index = _kendaraanList.indexWhere((k) => k['id'] == _editingId);
      if (index != -1) {
        _kendaraanList[index] = {
          'id': _editingId!,
          'jenis': _jenisController.text,
          'tipe': _tipeController.text,
          'kapasitas': int.parse(_kapasitasController.text),
          'harga': int.parse(_hargaController.text),
          'status': _selectedStatus,
          'gambar': _kendaraanList[index]['gambar'],
        };
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Kendaraan berhasil diperbarui'),
        backgroundColor: _successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // Hapus kendaraan
  void _deleteKendaraan(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konfirmasi Hapus'),
        content: Text('Yakin ingin menghapus kendaraan ini?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: TextStyle(color: Colors.grey.shade700)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _dangerColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              setState(() {
                _kendaraanList.removeWhere((k) => k['id'] == id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Kendaraan berhasil dihapus'),
                  backgroundColor: _successColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            child: Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Filter kendaraan berdasarkan pencarian
  List<Map<String, dynamic>> get _filteredKendaraanList {
    if (_searchQuery.isEmpty) return _kendaraanList;
    return _kendaraanList.where((k) {
      return k['jenis'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          k['tipe'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          k['id'].toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  // Warna berdasarkan status
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Tersedia':
        return Colors.green.shade100;
      case 'Dalam Perbaikan':
        return Colors.orange.shade100;
      case 'Tidak Tersedia':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  // Text color berdasarkan status
  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'Tersedia':
        return Colors.green.shade800;
      case 'Dalam Perbaikan':
        return Colors.orange.shade800;
      case 'Tidak Tersedia':
        return Colors.red.shade800;
      default:
        return Colors.grey.shade800;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _filteredKendaraanList;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Kelola Kendaraan',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: _primaryColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Cari Kendaraan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 15),
                        TextField(
                          controller: _searchController,
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: 'Cari berdasarkan jenis/tipe/ID',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                        ),
                        SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _searchQuery = '';
                                });
                                Navigator.pop(context);
                              },
                              child: Text('Reset'),
                            ),
                            SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text('Tutup'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search info
          if (_searchQuery.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Hasil pencarian: "${_searchQuery}"',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _searchQuery = '';
                      });
                    },
                    child: Text(
                      'Clear',
                      style: TextStyle(color: _primaryColor),
                    ),
                  ),
                ],
              ),
            ),
          // List kendaraan
          Expanded(
            child: filteredList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.directions_car,
                          size: 60,
                          color: Colors.grey.shade400,
                        ),
                        SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'Belum ada data kendaraan'
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
                    padding: EdgeInsets.symmetric(vertical: 8),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final kendaraan = filteredList[index];
                      return Card(
                        margin: EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {},
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Gambar kendaraan
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(8),
                                        image: DecorationImage(
                                          image: AssetImage(
                                              kendaraan['gambar'] ?? 'assets/car_placeholder.png'),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                kendaraan['jenis'],
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                kendaraan['id'],
                                                style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.category,
                                                size: 16,
                                                color: Colors.grey.shade600,
                                              ),
                                              SizedBox(width: 4),
                                              Text(kendaraan['tipe']),
                                              SizedBox(width: 16),
                                              Icon(
                                                Icons.people,
                                                size: 16,
                                                color: Colors.grey.shade600,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                  '${kendaraan['kapasitas']} orang'),
                                            ],
                                          ),
                                          SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.attach_money,
                                                size: 16,
                                                color: Colors.green,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                _formatRupiah(
                                                    kendaraan['harga']),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Spacer(),
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 12, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: _getStatusColor(
                                                      kendaraan['status']),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Text(
                                                  kendaraan['status'],
                                                  style: TextStyle(
                                                    color: _getStatusTextColor(
                                                        kendaraan['status']),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    OutlinedButton.icon(
                                      onPressed: () =>
                                          _openKendaraanForm(kendaraan),
                                      icon: Icon(Icons.edit,
                                          size: 18, color: _primaryColor),
                                      label: Text(
                                        'Edit',
                                        style: TextStyle(color: _primaryColor),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(color: _primaryColor),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    ElevatedButton.icon(
                                      onPressed: () =>
                                          _deleteKendaraan(kendaraan['id']),
                                      icon: Icon(Icons.delete,
                                          size: 18, color: Colors.white),
                                      label: Text('Hapus'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _dangerColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openKendaraanForm(),
        child: Icon(Icons.add, size: 28),
        backgroundColor: _primaryColor,
        elevation: 2,
      ),
    );
  }
}