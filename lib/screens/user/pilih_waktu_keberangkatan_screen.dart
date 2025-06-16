import 'package:flutter/material.dart';
import 'package:travelapp/models/destinasi.dart';
import 'package:travelapp/screens/user/pemilihan_kendaraan_screen.dart';
import 'package:intl/intl.dart';

class PilihWaktuKeberangkatanScreen extends StatefulWidget {
  final Destinasi destinasi;

  const PilihWaktuKeberangkatanScreen({super.key, required this.destinasi});

  @override
  State<PilihWaktuKeberangkatanScreen> createState() =>
      _PilihWaktuKeberangkatanScreenState();
}

class _PilihWaktuKeberangkatanScreenState
    extends State<PilihWaktuKeberangkatanScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    // Inisialisasi dengan tanggal dan waktu saat ini jika belum ada
    _selectedDate = DateTime.now();
    _selectedTime = TimeOfDay.now();
  }

  Future<void> _selectDate(BuildContext context) async {
    final theme = Theme.of(context); // Akses tema
    final colorScheme = theme.colorScheme;

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          // Gunakan tema aplikasi Anda untuk DatePicker
          data: theme.copyWith(
            colorScheme: colorScheme.copyWith(
              primary: colorScheme.primary, // Warna utama DatePicker
              onPrimary: colorScheme.onPrimary, // Warna teks/ikon di primary
              surface: colorScheme.surface, // Background DatePicker
              onSurface: colorScheme.onSurface, // Warna teks di background
            ),
            dialogBackgroundColor: colorScheme.surface, // Background dialog
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final theme = Theme.of(context); // Akses tema
    final colorScheme = theme.colorScheme;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          // Gunakan tema aplikasi Anda untuk TimePicker
          data: theme.copyWith(
            colorScheme: colorScheme.copyWith(
              primary: colorScheme.primary,
              onPrimary: colorScheme.onPrimary,
              surface: colorScheme.surface,
              onSurface: colorScheme.onSurface,
            ),
            dialogBackgroundColor: colorScheme.surface, // Background dialog
          ),
          child: child!,
        );
      },
    );
    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  String _formatDate(DateTime date) {
    // Perbaiki karakter unicode yang salah, pastikan hanya karakter ASCII atau karakter yang valid dalam string.
    return DateFormat('dd MMMM, yyyy', 'id_ID').format(date); // Changed ' silam' to 'yyyy' for year
  }

  String _formatTime(TimeOfDay time) {
    return time.format(context);
  }

  @override
  Widget build(BuildContext context) {
    // Akses tema di sini
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.background, // Background dari tema
      appBar: AppBar(
        title: Text(
          'Pilih Waktu Keberangkatan',
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colorScheme.primary, // Warna AppBar
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onPrimary), // Warna ikon AppBar
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              color: colorScheme.surface, // Warna card
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.destinasi.nama,
                      style: textTheme.headlineSmall?.copyWith( // Sesuaikan gaya teks
                        fontWeight: FontWeight.bold,
                        color: textTheme.bodyLarge?.color, // Warna teks
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.destinasi.lokasi,
                      style: textTheme.bodyMedium?.copyWith(color: textTheme.bodyMedium?.color?.withOpacity(0.7)), // Warna teks
                    ),
                    Divider(height: 24, color: theme.dividerColor), // Divider
                    Text(
                      'Harga: ${NumberFormat.currency(
                            locale: 'id_ID',
                            symbol: 'Rp ',
                            decimalDigits: 0,
                          ).format(widget.destinasi.harga)} / orang',
                      style: textTheme.titleMedium?.copyWith( // Sesuaikan gaya teks
                        fontWeight: FontWeight.bold,
                        color: colorScheme.secondary, // Warna harga
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildSelectionCard(
              icon: Icons.date_range,
              title: 'Pilih Tanggal',
              value: _selectedDate == null
                  ? 'Belum dipilih'
                  : _formatDate(_selectedDate!),
              onTap: () => _selectDate(context),
              theme: theme, // Teruskan tema
            ),
            const SizedBox(height: 16),
            _buildSelectionCard(
              icon: Icons.access_time,
              title: 'Pilih Waktu',
              value: _selectedTime == null
                  ? 'Belum dipilih'
                  : _formatTime(_selectedTime!),
              onTap: () => _selectTime(context),
              theme: theme, // Teruskan tema
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _selectedDate != null && _selectedTime != null
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (ctx) => PemilihanKendaraanScreen(
                            destinasi: widget.destinasi,
                            selectedDate: _selectedDate!,
                            selectedTime: _selectedTime!,
                          ),
                        ),
                      );
                    }
                  : null, // Disable button if date or time not selected
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary, // Warna tombol
                foregroundColor: colorScheme.onPrimary, // Warna teks tombol
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                disabledBackgroundColor: colorScheme.surfaceVariant, // Warna disabled
                disabledForegroundColor: textTheme.bodyMedium?.color?.withOpacity(0.4), // Warna teks disabled
              ),
              child: Text(
                'Lanjutkan ke Pemilihan Kendaraan',
                style: textTheme.titleMedium?.copyWith( // Gaya teks tombol
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16), // Padding for the bottom button
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionCard({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
    required ThemeData theme, // Tambahkan parameter tema
  }) {
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Card(
      elevation: 2,
      color: colorScheme.surface, // Warna card
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, color: colorScheme.primary, size: 28), // Ikon
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleSmall?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: textTheme.bodyLarge?.color?.withOpacity(0.7), // Teks judul
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: textTheme.titleMedium?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textTheme.bodyLarge?.color, // Teks nilai
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 20, color: textTheme.bodyMedium?.color?.withOpacity(0.6)), // Ikon panah
            ],
          ),
        ),
      ),
    );
  }
}