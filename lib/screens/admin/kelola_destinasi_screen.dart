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

  @override
  void initState() {
    super.initState();
    _fetchDestinasi();
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
        title: const Text('Kelola Destinasi'),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TambahDestinasiScreen()),
              ).then((_) => _refreshDestinasi());
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchDestinasi,
              child: FutureBuilder<List<Destinasi>>(
                future: _destinasiList,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Error: ${snapshot.error}'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _refreshDestinasi,
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.location_off, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text(
                            'Tidak ada data destinasi',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text('Tambah Destinasi'),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const TambahDestinasiScreen()),
                              ).then((_) => _refreshDestinasi());
                            },
                          ),
                        ],
                      ),
                    );
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final destinasi = snapshot.data![index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          elevation: 2,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(8),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: _buildImage(destinasi.gambar),
                            ),
                            title: Text(
                              destinasi.nama,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(destinasi.kategori),
                                Text(
                                  destinasi.lokasi,
                                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditDestinasiScreen(destinasi: destinasi),
                                      ),
                                    ).then((_) => _refreshDestinasi());
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    _showDeleteConfirmation(context, destinasi.id);
                                  },
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditDestinasiScreen(destinasi: destinasi),
                                ),
                              ).then((_) => _refreshDestinasi());
                            },
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
    );
  }

  Widget _buildImage(String imagePath) {
    try {
      if (imagePath.startsWith('http')) {
        // Handle network images
        return Image.network(
          imagePath,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 80,
              height: 80,
              color: Colors.grey[300],
              child: const Icon(Icons.image_not_supported, color: Colors.grey),
            );
          },
        );
      } else {
        // Handle asset images
        return Image.asset(
          imagePath,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 80,
              height: 80,
              color: Colors.grey[300],
              child: const Icon(Icons.image_not_supported, color: Colors.grey),
            );
          },
        );
      }
    } catch (e) {
      return Container(
        width: 80,
        height: 80,
        color: Colors.grey[300],
        child: const Icon(Icons.error, color: Colors.grey),
      );
    }
  }

  void _showDeleteConfirmation(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Destinasi'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus destinasi ini?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _handleDeleteDestinasi(id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
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
          content: Text('Destinasi berhasil dihapus'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus destinasi: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}

