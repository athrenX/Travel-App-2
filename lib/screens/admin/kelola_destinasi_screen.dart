import 'package:flutter/material.dart';
import 'package:travelapp/models/destinasi.dart';
import 'package:travelapp/services/destinasi_service.dart';
import 'package:travelapp/screens/admin/aksi/tambah_destinasi_screen.dart';
import 'package:travelapp/screens/admin/aksi/edit_destinasi_screen.dart';

class KelolaDestinasiScreen extends StatefulWidget {
  const KelolaDestinasiScreen({Key? key}) : super(key: key);

  @override
  _AdminKelolaDestinasiState createState() => _AdminKelolaDestinasiState();
}

class _AdminKelolaDestinasiState extends State<KelolaDestinasiScreen> {
  late Future<List<Destinasi>> _destinasiList;
  bool _isLoading = false;
  final _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _fetchDestinasi();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchDestinasi() async {
    setState(() {
      _destinasiList = DestinasiService.getAllDestinasi();
    });
  }

  void _refreshDestinasi() {
    _fetchDestinasi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Kelola Destinasi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,

        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                      onRefresh: _fetchDestinasi,
                      child: FutureBuilder<List<Destinasi>>(
                        future: _destinasiList,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (snapshot.hasError) {
                            return _buildErrorView(snapshot.error.toString());
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return _buildEmptyView();
                          } else {
                            final filteredData =
                                _searchQuery.isEmpty
                                    ? snapshot.data!
                                    : snapshot.data!
                                        .where(
                                          (destinasi) =>
                                              destinasi.nama
                                                  .toLowerCase()
                                                  .contains(
                                                    _searchQuery.toLowerCase(),
                                                  ) ||
                                              destinasi.lokasi
                                                  .toLowerCase()
                                                  .contains(
                                                    _searchQuery.toLowerCase(),
                                                  ) ||
                                              destinasi.kategori
                                                  .toLowerCase()
                                                  .contains(
                                                    _searchQuery.toLowerCase(),
                                                  ),
                                        )
                                        .toList();

                            if (filteredData.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.search_off,
                                      size: 64,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Tidak ada hasil untuk "$_searchQuery"',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _searchController.clear();
                                          _searchQuery = "";
                                        });
                                      },
                                      child: const Text('Hapus Pencarian'),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return _buildDestinationList(filteredData);
                          }
                        },
                      ),
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TambahDestinasiScreen(),
            ),
          ).then((_) => _refreshDestinasi());
        },
        icon: const Icon(Icons.add),
        label: const Text('Destinasi Baru'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextFormField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Cari destinasi...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon:
              _searchQuery.isNotEmpty
                  ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _searchQuery = "";
                      });
                    },
                  )
                  : null,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildErrorView(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'Terjadi kesalahan',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _refreshDestinasi,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 24),
          const Text(
            'Belum Ada Destinasi',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            'Tambahkan destinasi baru untuk mulai mengelola',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Tambah Destinasi Baru'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TambahDestinasiScreen(),
                ),
              ).then((_) => _refreshDestinasi());
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDestinationList(List<Destinasi> destinations) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80), // Space for FAB
      itemCount: destinations.length,
      itemBuilder: (context, index) {
        final destinasi = destinations[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => EditDestinasiScreen(destinasi: destinasi),
                  ),
                ).then((_) => _refreshDestinasi());
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image section
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: SizedBox(
                      height: 160,
                      width: double.infinity,
                      child: _buildImage(destinasi.gambar),
                    ),
                  ),
                  // Content section
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                destinasi.nama,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                destinasi.kategori,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                destinasi.lokasi,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Edit button
                            OutlinedButton.icon(
                              icon: const Icon(Icons.edit, size: 18),
                              label: const Text('Edit'),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => EditDestinasiScreen(
                                          destinasi: destinasi,
                                        ),
                                  ),
                                ).then((_) => _refreshDestinasi());
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.blue,
                                side: const BorderSide(color: Colors.blue),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Delete button
                            OutlinedButton.icon(
                              icon: const Icon(Icons.delete, size: 18),
                              label: const Text('Hapus'),
                              onPressed: () {
                                _showDeleteConfirmation(context, destinasi.id);
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
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
            ),
          ),
        );
      },
    );
  }

  Widget _buildImage(String imagePath) {
    try {
      if (imagePath.startsWith('http')) {
        // Handle network images
        return Image.network(
          imagePath,
          fit: BoxFit.cover,
          width: double.infinity,
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
              color: Colors.grey[200],
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_not_supported,
                    color: Colors.grey[400],
                    size: 40,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Gambar tidak tersedia',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            );
          },
        );
      } else {
        // Handle asset images
        return Image.asset(
          imagePath,
          fit: BoxFit.cover,
          width: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[200],
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_not_supported,
                    color: Colors.grey[400],
                    size: 40,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Gambar tidak tersedia',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            );
          },
        );
      }
    } catch (e) {
      return Container(
        color: Colors.grey[200],
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, color: Colors.grey[400], size: 40),
            const SizedBox(height: 8),
            Text(
              'Error: ${e.toString()}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
  }

  void _showDeleteConfirmation(BuildContext context, String id) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Hapus Destinasi',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Text(
              'Apakah Anda yakin ingin menghapus destinasi ini? Tindakan ini tidak dapat dibatalkan.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
                style: TextButton.styleFrom(foregroundColor: Colors.grey[800]),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleDeleteDestinasi(id);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                child: const Text('Hapus'),
              ),
            ],
          ),
    );
  }

  void _handleDeleteDestinasi(String id) async {
    setState(() => _isLoading = true);

    try {
      // Implement actual delete functionality using the service
      await DestinasiService.deleteDestinasi(id);
      _refreshDestinasi();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 16),
              Text('Destinasi berhasil dihapus'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 16),
              Expanded(
                child: Text('Gagal menghapus destinasi: ${e.toString()}'),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'COBA LAGI',
            textColor: Colors.white,
            onPressed: () => _handleDeleteDestinasi(id),
          ),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
