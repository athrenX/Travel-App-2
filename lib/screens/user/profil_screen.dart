import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../providers/auth_provider.dart';
import '../../models/user.dart';
import 'package:travelapp/providers/wishlist_provider.dart';
import 'package:travelapp/providers/theme_provider.dart';
import 'package:http/http.dart' as http;

String _currentPaymentMethod = 'Bank Transfer';

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

    bool _isOldPasswordVisible = false;
    bool _isNewPasswordVisible = false;
    bool _isConfirmPasswordVisible = false;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: Row(
                    children: [
                      Icon(Icons.lock, color: Colors.blue[800], size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Ubah Password',
                        style: TextStyle(
                          color: Colors.blue[800],
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildPasswordTextField(
                          controller: _oldPasswordController,
                          label: 'Password Lama',
                          icon: Icons.lock,
                          isVisible: _isOldPasswordVisible,
                          onToggleVisibility: () {
                            setState(() {
                              _isOldPasswordVisible = !_isOldPasswordVisible;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildPasswordTextField(
                          controller: _newPasswordController,
                          label: 'Password Baru',
                          icon: Icons.lock_outline,
                          isVisible: _isNewPasswordVisible,
                          onToggleVisibility: () {
                            setState(() {
                              _isNewPasswordVisible = !_isNewPasswordVisible;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildPasswordTextField(
                          controller: _confirmPasswordController,
                          label: 'Konfirmasi Password Baru',
                          icon: Icons.lock_reset,
                          isVisible: _isConfirmPasswordVisible,
                          onToggleVisibility: () {
                            setState(() {
                              _isConfirmPasswordVisible =
                                  !_isConfirmPasswordVisible;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                      child: Text(
                        'BATAL',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (_newPasswordController.text !=
                            _confirmPasswordController.text) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Row(
                                children: [
                                  Icon(Icons.error, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text('Password baru tidak cocok'),
                                ],
                              ),
                              backgroundColor: Colors.red[600],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
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
                            SnackBar(
                              content: const Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text('Password berhasil diubah'),
                                ],
                              ),
                              backgroundColor: Colors.green[600],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Row(
                                children: [
                                  Icon(Icons.error, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text('Gagal mengubah password'),
                                ],
                              ),
                              backgroundColor: Colors.red[600],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[800],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'UBAH',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
          ),
    );
  }

  Widget _buildPasswordTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
  }) {
    return TextField(
      obscureText: !isVisible,
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue[600]),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.blue[600],
          ),
          onPressed: onToggleVisibility,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue[200]!),
        ),
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Ubah Foto Profil',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildImageSourceOption(
                    icon: Icons.camera_alt,
                    title: 'Ambil Foto',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                  _buildImageSourceOption(
                    icon: Icons.photo_library,
                    title: 'Pilih dari Galeri',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                  const Divider(height: 20),
                  _buildImageSourceOption(
                    icon: Icons.close,
                    title: 'Batal',
                    onTap: () => Navigator.pop(context),
                    isCancel: true,
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isCancel = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isCancel ? Colors.grey[600] : Colors.blue[600],
        size: 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isCancel ? Colors.grey[600] : Colors.blue[800],
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }

  Widget _buildProfileImage() {
    print('[LOG] FOTO PROFIL URL: ${user?.fotoProfil}');

    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.blue[300]!, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Colors.blue[300]!, Colors.blue[500]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(child: Icon(Icons.person, size: 60, color: Colors.white)),
    );
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.payment, color: Colors.blue[800], size: 24),
                const SizedBox(width: 8),
                Text(
                  'Pilih Metode Pembayaran',
                  style: TextStyle(
                    color: Colors.blue[800],
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
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
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
                child: Text(
                  'TUTUP',
                  style: TextStyle(
                    color: Colors.blue[800],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildPaymentMethodOption(String method, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              _selectedPaymentMethod == method
                  ? Colors.blue[600]!
                  : Colors.grey[300]!,
          width: 2,
        ),
        color:
            _selectedPaymentMethod == method
                ? Colors.blue[50]
                : Colors.transparent,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color:
              _selectedPaymentMethod == method
                  ? Colors.blue[600]
                  : Colors.grey[600],
        ),
        title: Text(
          method,
          style: TextStyle(
            color:
                _selectedPaymentMethod == method
                    ? Colors.blue[800]
                    : Colors.grey[800],
            fontWeight:
                _selectedPaymentMethod == method
                    ? FontWeight.w600
                    : FontWeight.normal,
          ),
        ),
        trailing:
            _selectedPaymentMethod == method
                ? Icon(Icons.check_circle, color: Colors.blue[600])
                : null,
        onTap: () {
          setState(() {
            _selectedPaymentMethod = method;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.edit, color: Colors.blue[800], size: 24),
                const SizedBox(width: 8),
                Text(
                  'Edit Profil',
                  style: TextStyle(
                    color: Colors.blue[800],
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
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
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue[200]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.blue[600]!,
                          width: 2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue[200]!),
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
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue[200]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.blue[600]!,
                          width: 2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue[200]!),
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
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
                child: Text(
                  'BATAL',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
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
                      SnackBar(
                        content: const Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.white),
                            SizedBox(width: 8),
                            Text('Profil berhasil diperbarui'),
                          ],
                        ),
                        backgroundColor: Colors.green[600],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'SIMPAN',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profil Saya',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[800],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body:
          _isLoading
              ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[800]!),
                ),
              )
              : Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.blue[50]!, Colors.white],
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Profile Image Section
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 2,
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
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
                                padding: const EdgeInsets.only(top: 16),
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
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: const Row(
                                            children: [
                                              Icon(
                                                Icons.check_circle,
                                                color: Colors.white,
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                'Foto profil berhasil diperbarui',
                                              ),
                                            ],
                                          ),
                                          backgroundColor: Colors.green[600],
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Row(
                                            children: [
                                              const Icon(
                                                Icons.error,
                                                color: Colors.white,
                                              ),
                                              const SizedBox(width: 8),
                                              Text('Gagal mengunggah foto: $e'),
                                            ],
                                          ),
                                          backgroundColor: Colors.red[600],
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.save),
                                  label: const Text("Simpan Foto"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue[800],
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 10,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 2,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 16),
                            if (user != null) ...[
                              Text(
                                user!.nama,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[900],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user!.email,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Menu Options
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 2,
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildMenuTile(
                              icon: Icons.payment,
                              title: 'Metode Pembayaran',
                              subtitle: _selectedPaymentMethod,
                              onTap: _showPaymentMethodDialog,
                            ),
                            _buildDivider(),
                            _buildMenuTile(
                              icon: Icons.edit,
                              title: 'Edit Profil',
                              subtitle: 'Ubah informasi profil Anda',
                              onTap: _showEditProfileDialog,
                            ),
                            _buildDivider(),
                            _buildMenuTile(
                              icon: Icons.lock,
                              title: 'Ubah Password',
                              subtitle: 'Ganti password akun Anda',
                              onTap: _showChangePasswordDialog,
                            ),
                            _buildDivider(),
                            _buildThemeToggle(),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Save Payment Method Button
                      if (_selectedPaymentMethod != _currentPaymentMethod)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 16),
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final authProvider = Provider.of<AuthProvider>(
                                context,
                                listen: false,
                              );
                              await authProvider.updateUserProfile(
                                nama: user?.nama ?? '',
                                email: user?.email ?? '',
                                paymentMethod: _selectedPaymentMethod,
                              );
                              setState(() {
                                _currentPaymentMethod = _selectedPaymentMethod;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Metode pembayaran berhasil diperbarui',
                                      ),
                                    ],
                                  ),
                                  backgroundColor: Colors.green[600],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.save),
                            label: const Text('Simpan Metode Pembayaran'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[800],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                          ),
                        ),

                      // Logout Button
                      Container(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final authProvider = Provider.of<AuthProvider>(
                              context,
                              listen: false,
                            );
                            final wishlistProvider =
                                Provider.of<WishlistProvider>(
                                  context,
                                  listen: false,
                                );

                            await authProvider.logout();
                            wishlistProvider.updateToken(
                              null,
                            ); // reset wishlist token dan data

                            Navigator.pushReplacementNamed(context, '/login');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          icon: const Icon(Icons.logout),
                          label: const Text(
                            'Logout',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.blue[700], size: 24),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: Colors.grey[800],
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.grey[600], fontSize: 14),
      ),
      trailing: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blue[600]),
      ),
      onTap: onTap,
    );
  }

  Widget _buildThemeToggle() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 8,
          ),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              themeProvider.themeMode == ThemeMode.dark
                  ? Icons.dark_mode
                  : Icons.light_mode,
              color: Colors.blue[700],
              size: 24,
            ),
          ),
          title: Text(
            'Mode Gelap',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.grey[800],
            ),
          ),
          subtitle: Text(
            themeProvider.themeMode == ThemeMode.dark ? 'Aktif' : 'Nonaktif',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          trailing: Switch(
            activeColor: Colors.blue[600],
            activeTrackColor: Colors.blue[200],
            inactiveThumbColor: Colors.grey[400],
            inactiveTrackColor: Colors.grey[200],
            value: themeProvider.themeMode == ThemeMode.dark,
            onChanged: (bool value) {
              themeProvider.toggleTheme(value);
            },
          ),
        );
      },
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey[200],
      indent: 20,
      endIndent: 20,
    );
  }
}
