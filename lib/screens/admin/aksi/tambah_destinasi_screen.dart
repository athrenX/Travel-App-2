import 'package:flutter/material.dart';
import 'dart:io';
import 'package:travelapp/models/destinasi.dart';
import 'package:travelapp/services/destinasi_service.dart';
// Remove image_picker import and use your own image selection method

class TambahDestinasiScreen extends StatefulWidget {
  const TambahDestinasiScreen({Key? key}) : super(key: key);

  @override
  _TambahDestinasiScreenState createState() => _TambahDestinasiScreenState();
}

class _TambahDestinasiScreenState extends State<TambahDestinasiScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _lokasiController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lngController = TextEditingController();
  String _selectedKategori = 'Pantai';
  String _imagePath = 'assets/images/placeholder.jpg'; // Default placeholder
  bool _isLoading = false;
  final List<String> _kategoriList = [
    'Pantai',
    'Gunung',
    'Danau',
    'Taman',
    'Budaya',
    'Lainnya',
  ];
  final List<String> _galeriImages = []; // List to store gallery images

  // This is a simplified version without image_picker
  void _selectImage() {
    // Here you would implement your own image selection logic
    // For now, let's just set a dummy path as an example
    setState(() {
      _imagePath = 'assets/images/destinations/new_destination.jpg';
    });

    // Show a confirmation to the user
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Gambar utama telah dipilih')));
  }

  void _addGalleryImage() {
    // Simplified gallery image addition
    setState(() {
      _galeriImages.add(
        'assets/images/gallery/image_${_galeriImages.length + 1}.jpg',
      );
    });

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gambar ditambahkan ke galeri')),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_imagePath.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Silakan pilih gambar destinasi'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        // Instead of uploading, we're just using the path directly for this example
        final String imageUrl = _imagePath;

        // Parse lat and lng from text controllers
        double lat = 0.0;
        double lng = 0.0;

        try {
          lat = double.parse(_latController.text.trim());
          lng = double.parse(_lngController.text.trim());
        } catch (e) {
          // Handle parsing errors
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

        // Buat objek destinasi baru dengan semua field yang diperlukan
        final Destinasi newDestinasi = Destinasi(
          id:
              DateTime.now().millisecondsSinceEpoch
                  .toString(), // Buat ID sementara
          nama: _namaController.text.trim(),
          deskripsi: _deskripsiController.text.trim(),
          lokasi: _lokasiController.text.trim(),
          kategori: _selectedKategori,
          gambar: imageUrl,
          harga: double.parse(_hargaController.text.trim()),
          rating: 0.0, // Rating awal
          lat: lat,
          lng: lng,
          galeri: List<String>.from(
            _galeriImages,
          ), // Gunakan galeri yang sudah ditambahkan
        );

        // Simpan destinasi baru
        await DestinasiService.addDestinasi(newDestinasi);

        // Tampilkan pesan sukses dan kembali ke layar sebelumnya
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Destinasi berhasil ditambahkan'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menambahkan destinasi: ${e.toString()}'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Destinasi Baru')),
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
                      // Image Preview and Upload Button
                      GestureDetector(
                        onTap: _selectImage,
                        child: Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.add_photo_alternate,
                                size: 50,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Tap untuk memilih gambar',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Nama Destinasi
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

                      // Kategori Dropdown
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

                      // Lokasi
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

                      // Row untuk Latitude dan Longitude
                      Row(
                        children: [
                          // Latitude
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
                          // Longitude
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

                      // Harga
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

                      // Deskripsi
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

                      // Galeri Foto Section
                      Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Galeri Foto',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Jumlah foto: ${_galeriImages.length}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: _addGalleryImage,
                                icon: const Icon(Icons.add_photo_alternate),
                                label: const Text('Tambah Foto ke Galeri'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Submit Button
                      ElevatedButton.icon(
                        onPressed: _submitForm,
                        icon: const Icon(Icons.save),
                        label: const Text('SIMPAN DESTINASI'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
