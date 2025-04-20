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
  bool _isImageSelected = false;

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
      _isImageSelected = true;
    });

    // Show a confirmation to the user
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text('Gambar utama telah dipilih'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
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
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text('Gambar ditambahkan ke galeri'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (!_isImageSelected) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 12),
                Text('Silakan pilih gambar destinasi'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
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
              content: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Koordinat tidak valid'),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
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
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Destinasi berhasil ditambahkan'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('Gagal menambahkan destinasi: ${e.toString()}'),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 5),
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
      appBar: AppBar(
        title: const Text(
          'Tambah Destinasi Baru',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Confirm before leaving if form has data
            if (_namaController.text.isNotEmpty ||
                _deskripsiController.text.isNotEmpty) {
              _showDiscardChangesDialog();
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Image Preview and Upload Section
                      _buildImageSection(),

                      // Form Fields
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Informasi Utama Section
                            _buildSectionHeader('Informasi Utama'),
                            const SizedBox(height: 16),

                            // Nama Destinasi
                            _buildTextField(
                              controller: _namaController,
                              label: 'Nama Destinasi',
                              icon: Icons.place,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Nama destinasi tidak boleh kosong';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Kategori Dropdown
                            _buildDropdownField(),
                            const SizedBox(height: 16),

                            // Lokasi
                            _buildTextField(
                              controller: _lokasiController,
                              label: 'Lokasi',
                              icon: Icons.location_on,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Lokasi tidak boleh kosong';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),

                            // Koordinat Section
                            _buildSectionHeader('Koordinat Lokasi'),
                            const SizedBox(height: 8),
                            Text(
                              'Masukkan koordinat untuk peta lokasi destinasi',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Row untuk Latitude dan Longitude
                            Row(
                              children: [
                                // Latitude
                                Expanded(
                                  child: _buildTextField(
                                    controller: _latController,
                                    label: 'Latitude',
                                    icon: Icons.my_location,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
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
                                  child: _buildTextField(
                                    controller: _lngController,
                                    label: 'Longitude',
                                    icon: Icons.my_location,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
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
                            const SizedBox(height: 24),

                            // Informasi Tambahan Section
                            _buildSectionHeader('Informasi Tambahan'),
                            const SizedBox(height: 16),

                            // Harga
                            _buildTextField(
                              controller: _hargaController,
                              label: 'Harga Tiket (Rp)',
                              icon: Icons.monetization_on,
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
                              suffix: const Text('IDR'),
                            ),
                            const SizedBox(height: 16),

                            // Deskripsi
                            _buildTextField(
                              controller: _deskripsiController,
                              label: 'Deskripsi Destinasi',
                              icon: Icons.description,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Deskripsi tidak boleh kosong';
                                }
                                return null;
                              },
                              maxLines: 5,
                              hint:
                                  'Berikan deskripsi lengkap tentang destinasi ini...',
                            ),
                            const SizedBox(height: 24),

                            // Galeri Foto Section
                            _buildGallerySection(),
                            const SizedBox(height: 40),

                            // Submit Button
                            _buildSubmitButton(),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildImageSection() {
    return Stack(
      children: [
        Container(
          height: 220,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(24),
            ),
          ),
          child:
              _isImageSelected
                  ? ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(24),
                    ),
                    child: Image.asset(
                      _imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image,
                                size: 50,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Gambar tidak tersedia',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  )
                  : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate,
                          size: 60,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Tambahkan Foto Utama',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Foto ini akan menjadi tampilan utama destinasi',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: ElevatedButton.icon(
            onPressed: _selectImage,
            icon: Icon(
              _isImageSelected ? Icons.edit : Icons.add_a_photo,
              size: 20,
            ),
            label: Text(_isImageSelected ? 'Ubah Foto' : 'Pilih Foto'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              elevation: 3,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        Expanded(child: Divider(color: Colors.grey[300], thickness: 1.5)),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? hint,
    Widget? suffix,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Icon(icon),
        suffixIcon:
            suffix != null
                ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: suffix,
                )
                : null,
        contentPadding: EdgeInsets.symmetric(
          vertical: maxLines > 1 ? 16 : 0,
          horizontal: maxLines > 1 ? 16 : 12,
        ),
        alignLabelWithHint: maxLines > 1,
        filled: true,
        fillColor: Colors.grey[50],
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      textInputAction:
          maxLines > 1 ? TextInputAction.newline : TextInputAction.next,
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      value: _selectedKategori,
      decoration: InputDecoration(
        labelText: 'Kategori',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: const Icon(Icons.category),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
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
      icon: const Icon(Icons.arrow_drop_down_circle_outlined),
      isExpanded: true,
    );
  }

  Widget _buildGallerySection() {
    return Card(
      elevation: 0,
      color: Colors.grey[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.photo_library, color: Colors.deepOrange),
                const SizedBox(width: 8),
                const Text(
                  'Galeri Foto',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_galeriImages.length} foto',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Tambahkan beberapa foto untuk galeri destinasi',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 16),

            // Gallery preview
            if (_galeriImages.isNotEmpty)
              Container(
                height: 100,
                margin: const EdgeInsets.only(bottom: 16),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _galeriImages.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              _galeriImages[index],
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (ctx, error, __) => Center(
                                    child: Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _galeriImages.removeAt(index);
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

            // Add button
            Center(
              child: ElevatedButton.icon(
                onPressed: _addGalleryImage,
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text('Tambah Foto'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  backgroundColor: Colors.deepOrange,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _submitForm,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.save),
          SizedBox(width: 8),
          Text(
            'SIMPAN DESTINASI',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  void _showDiscardChangesDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Batalkan Perubahan?'),
            content: const Text(
              'Data yang Anda masukkan akan hilang. Yakin ingin membatalkan?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('LANJUTKAN EDIT'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('BATALKAN'),
              ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
    );
  }
}
