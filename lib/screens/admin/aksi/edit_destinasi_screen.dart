import 'package:flutter/material.dart';
import 'dart:io';
import 'package:travelapp/models/destinasi.dart';
import 'package:travelapp/services/destinasi_service.dart';

class EditDestinasiScreen extends StatefulWidget {
  final Destinasi destinasi;

  const EditDestinasiScreen({Key? key, required this.destinasi})
    : super(key: key);

  @override
  _EditDestinasiScreenState createState() => _EditDestinasiScreenState();
}

class _EditDestinasiScreenState extends State<EditDestinasiScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _deskripsiController;
  late TextEditingController _lokasiController;
  late TextEditingController _hargaController;
  late TextEditingController _latController;
  late TextEditingController _lngController;
  late String _selectedKategori;
  late String _currentImageUrl;
  bool _isLoading = false;
  final List<String> _kategoriList = [
    'Pantai',
    'Gunung',
    'Danau',
    'Taman',
    'Budaya',
    'Lainnya',
  ];
  late List<String> _galeriImages;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing data
    _namaController = TextEditingController(text: widget.destinasi.nama);
    _deskripsiController = TextEditingController(
      text: widget.destinasi.deskripsi,
    );
    _lokasiController = TextEditingController(text: widget.destinasi.lokasi);
    _hargaController = TextEditingController(
      text: widget.destinasi.harga.toString(),
    );
    _latController = TextEditingController(
      text: widget.destinasi.lat.toString(),
    );
    _lngController = TextEditingController(
      text: widget.destinasi.lng.toString(),
    );
    _selectedKategori = widget.destinasi.kategori;
    _currentImageUrl = widget.destinasi.gambar;
    _galeriImages = List<String>.from(widget.destinasi.galeri);
  }

  void _changeMainImage() {
    // Implement your image selection logic here, currently using a placeholder
    setState(() {
      _currentImageUrl = 'assets/images/destinations/updated_image.jpg';
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Gambar utama diubah')));
  }

  void _addGalleryImage() {
    setState(() {
      _galeriImages.add(
        'assets/images/gallery/new_image_${_galeriImages.length + 1}.jpg',
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gambar ditambahkan ke galeri')),
    );
  }

  void _removeGalleryImage(int index) {
    setState(() {
      _galeriImages.removeAt(index);
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Gambar dihapus dari galeri')));
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Parse latitude and longitude
        double lat, lng;
        try {
          lat = double.parse(_latController.text.trim());
          lng = double.parse(_lngController.text.trim());
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Koordinat tidak valid'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }

        // Update the destinasi object with new data
        final Destinasi updatedDestinasi = Destinasi(
          id: widget.destinasi.id,
          nama: _namaController.text.trim(),
          deskripsi: _deskripsiController.text.trim(),
          lokasi: _lokasiController.text.trim(),
          kategori: _selectedKategori,
          gambar: _currentImageUrl,
          harga: double.parse(_hargaController.text.trim()),
          rating: widget.destinasi.rating,
          lat: lat,
          lng: lng,
          galeri: List<String>.from(_galeriImages),
        );

        // Save the updated destinasi
        await DestinasiService.updateDestinasi(updatedDestinasi);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Destinasi berhasil diperbarui'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal memperbarui destinasi: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _deskripsiController.dispose();
    _lokasiController.dispose();
    _hargaController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  Widget _buildImagePreview() {
    try {
      if (_currentImageUrl.startsWith('http')) {
        return Image.network(
          _currentImageUrl,
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
          errorBuilder:
              (context, error, stackTrace) =>
                  const Icon(Icons.broken_image, size: 50, color: Colors.grey),
        );
      } else {
        return Image.asset(
          _currentImageUrl,
          fit: BoxFit.cover,
          errorBuilder:
              (context, error, stackTrace) =>
                  const Icon(Icons.broken_image, size: 50, color: Colors.grey),
        );
      }
    } catch (e) {
      return const Icon(Icons.error, size: 50, color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Destinasi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            color: Colors.red,
            onPressed: () {
              _showDeleteConfirmation(context);
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GestureDetector(
                        onTap: _changeMainImage,
                        child: Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: _buildImagePreview(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _namaController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Destinasi',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.place),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nama destinasi tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedKategori,
                        decoration: const InputDecoration(
                          labelText: 'Kategori',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.category),
                        ),
                        items:
                            _kategoriList.map((String kategori) {
                              return DropdownMenuItem<String>(
                                value: kategori,
                                child: Text(kategori),
                              );
                            }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedKategori = newValue!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _lokasiController,
                        decoration: const InputDecoration(
                          labelText: 'Lokasi',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lokasi tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _latController,
                              decoration: const InputDecoration(
                                labelText: 'Latitude',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.my_location),
                              ),
                              keyboardType: TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Latitude tidak boleh kosong';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Format tidak valid';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _lngController,
                              decoration: const InputDecoration(
                                labelText: 'Longitude',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.my_location),
                              ),
                              keyboardType: TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Longitude tidak boleh kosong';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Format tidak valid';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _hargaController,
                        decoration: const InputDecoration(
                          labelText: 'Harga (Rp)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.monetization_on),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Harga tidak boleh kosong';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Harga harus berupa angka';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _deskripsiController,
                        decoration: const InputDecoration(
                          labelText: 'Deskripsi',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 5,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Deskripsi tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Galeri Foto',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: _addGalleryImage,
                                    icon: const Icon(Icons.add),
                                    label: const Text('Tambah'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 120,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _galeriImages.length,
                                  itemBuilder: (context, index) {
                                    return Stack(
                                      children: [
                                        Container(
                                          width: 120,
                                          margin: const EdgeInsets.only(
                                            right: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            image: DecorationImage(
                                              image: AssetImage(
                                                _galeriImages[index],
                                              ),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                            onPressed:
                                                () =>
                                                    _removeGalleryImage(index),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _submitForm,
                        child: const Text('Simpan Perubahan'),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hapus Destinasi'),
          content: const Text(
            'Apakah Anda yakin ingin menghapus destinasi ini?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                // Call delete function here
                Navigator.pop(context);
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }
}
