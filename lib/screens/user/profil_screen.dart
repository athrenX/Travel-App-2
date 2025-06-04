import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../providers/auth_provider.dart';
import '../../models/user.dart';
import 'package:travelapp/providers/theme_provider.dart';

String _currentPaymentMethod =
    'Bank Transfer'; // default awal, bisa nanti diganti saat load user

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? user;
  File? _imageFile;
  String _selectedPaymentMethod = 'Bank Transfer';
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUser();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();

    super.dispose();
  }

  Future<void> _loadUser() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _selectedPaymentMethod = user?.paymentMethod ?? 'Bank Transfer';
    _currentPaymentMethod = _selectedPaymentMethod;

    if (mounted) {
      setState(() {
        user = authProvider.user;
        _nameController.text = user?.nama ?? '';
        _emailController.text = user?.email ?? '';
        _isLoading = false;
      });
    }
  }

  void _showChangePasswordDialog() {
    final TextEditingController _nameController = TextEditingController();
    final TextEditingController _emailController = TextEditingController();
    final TextEditingController _oldPasswordController =
        TextEditingController();
    final TextEditingController _newPasswordController =
        TextEditingController();
    final TextEditingController _confirmPasswordController =
        TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Ubah Password',
              style: TextStyle(color: Colors.blue[800]),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    obscureText: true,
                    controller: _oldPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Password Lama',
                      prefixIcon: Icon(Icons.lock, color: Colors.blue[600]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    obscureText: true,
                    controller: _newPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Password Baru',
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: Colors.blue[600],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    obscureText: true,
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Konfirmasi Password Baru',
                      prefixIcon: Icon(
                        Icons.lock_reset,
                        color: Colors.blue[600],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('BATAL', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_newPasswordController.text !=
                      _confirmPasswordController.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Password baru tidak cocok'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  final authProvider = Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  );
                  final success = await authProvider.changePassword(
                    oldPassword: _oldPasswordController.text,
                    newPassword: _newPasswordController.text,
                  );

                  if (success) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Password berhasil diubah'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Gagal mengubah password'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('UBAH'),
              ),
            ],
          ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 75);

    if (pickedFile != null && mounted) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Ubah Foto Profil',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.camera_alt, color: Colors.blue[600]),
                  title: Text(
                    'Ambil Foto',
                    style: TextStyle(color: Colors.blue[800]),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.photo_library, color: Colors.blue[600]),
                  title: Text(
                    'Pilih dari Galeri',
                    style: TextStyle(color: Colors.blue[800]),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.close, color: Colors.grey),
                  title: Text('Batal', style: TextStyle(color: Colors.grey)),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildProfileImage() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.blue[200]!, width: 3),
        color: Colors.blue[100],
      ),
      child: ClipOval(
        child:
            _imageFile != null
                ? kIsWeb
                    ? Image.network(
                      _imageFile!.path,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    )
                    : Image.file(
                      _imageFile!,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    )
                : user?.fotoProfil != null && user!.fotoProfil!.isNotEmpty
                ? Image.network(
                  user!.fotoProfil!,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildDefaultAvatar();
                  },
                )
                : _buildDefaultAvatar(),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Center(child: Icon(Icons.person, size: 60, color: Colors.blue[800]));
  }

  Widget _buildCameraIcon() {
    return GestureDetector(
      onTap: _showImageSourceActionSheet,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue[800],
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
      ),
    );
  }

  void _showPaymentMethodDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Pilih Metode Pembayaran',
              style: TextStyle(color: Colors.blue[800]),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildPaymentMethodOption(
                  'Bank Transfer',
                  Icons.account_balance,
                ),
                _buildPaymentMethodOption('E-Wallet', Icons.wallet),
                _buildPaymentMethodOption('Kartu Kredit', Icons.credit_card),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('TUTUP', style: TextStyle(color: Colors.blue[800])),
              ),
            ],
          ),
    );
  }

  Widget _buildPaymentMethodOption(String method, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue[600]),
      title: Text(method),
      trailing:
          _selectedPaymentMethod == method
              ? Icon(Icons.check, color: Colors.blue)
              : null,
      onTap: () {
        setState(() {
          _selectedPaymentMethod = method;
        });
        Navigator.pop(context);
      },
    );
  }

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Edit Profil',
              style: TextStyle(color: Colors.blue[800]),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Nama',
                      prefixIcon: Icon(Icons.person, color: Colors.blue[600]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    controller: _nameController,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email, color: Colors.blue[600]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    controller: _emailController,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('BATAL', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_nameController.text.isNotEmpty) {
                    final authProvider = Provider.of<AuthProvider>(
                      context,
                      listen: false,
                    );
                    await authProvider.updateUserProfile(
                      nama: _nameController.text,
                      fotoProfil: _imageFile,
                      email: _emailController.text,
                    );

                    if (mounted) {
                      setState(() {
                        user = user?.copyWith(
                          nama: _nameController.text,
                          email: _emailController.text,
                        );
                      });
                    }

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profil berhasil diperbarui'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 9, 9, 9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('SIMPAN'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        centerTitle: true,
        backgroundColor: Colors.blue[800],
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              _buildProfileImage(),
                              Positioned(
                                bottom: -5,
                                right: -5,
                                child: _buildCameraIcon(),
                              ),
                            ],
                          ),
                          if (_imageFile != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  final authProvider =
                                      Provider.of<AuthProvider>(
                                        context,
                                        listen: false,
                                      );
                                  try {
                                    await authProvider.updateUserProfile(
                                      nama: user?.nama ?? '',
                                      email: user?.email ?? '',
                                      fotoProfil: _imageFile,
                                    );
                                    await _loadUser();
                                    setState(() {
                                      _imageFile = null;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Foto profil berhasil diperbarui',
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Gagal mengunggah foto: $e',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.save),
                                label: const Text("Simpan Foto"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[800],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    if (user != null) ...[
                      Text(
                        user!.nama,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900],
                        ),
                      ),
                      Text(
                        user!.email,
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                    ],
                    const SizedBox(height: 30),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            leading: Icon(
                              Icons.payment,
                              color: Colors.blue[600],
                            ),
                            title: const Text('Metode Pembayaran'),
                            subtitle: Text(_selectedPaymentMethod),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                            ),
                            onTap: _showPaymentMethodDialog,
                          ),
                          const Divider(height: 1, indent: 16),
                          ListTile(
                            leading: Icon(Icons.edit, color: Colors.blue[600]),
                            title: const Text('Edit Profil'),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                            ),
                            onTap: _showEditProfileDialog,
                          ),
                          const Divider(height: 1, indent: 16),
                          ListTile(
                            leading: Icon(Icons.lock, color: Colors.blue[600]),
                            title: const Text('Ubah Password'),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                            ),
                            onTap: _showChangePasswordDialog,
                          ),
                          if (_selectedPaymentMethod != _currentPaymentMethod)
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  final authProvider =
                                      Provider.of<AuthProvider>(
                                        context,
                                        listen: false,
                                      );
                                  await authProvider.updateUserProfile(
                                    nama: user?.nama ?? '',
                                    email: user?.email ?? '',
                                    paymentMethod: _selectedPaymentMethod,
                                  );
                                  setState(() {
                                    _currentPaymentMethod =
                                        _selectedPaymentMethod;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Metode pembayaran berhasil diperbarui',
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.save),
                                label: const Text('Simpan Metode Pembayaran'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[800],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.dark_mode, color: Colors.blue[600]),
                      title: const Text('Mode Gelap'),
                      trailing: Consumer<ThemeProvider>(
                        builder: (context, themeProvider, _) {
                          return Switch(
                            activeColor: Colors.blue,
                            value: themeProvider.themeMode == ThemeMode.dark,
                            onChanged: (bool value) {
                              themeProvider.toggleTheme(value);
                            },
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Provider.of<AuthProvider>(
                            context,
                            listen: false,
                          ).logout();
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[600],
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        icon: const Icon(Icons.logout),
                        label: const Text(
                          'Logout',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
