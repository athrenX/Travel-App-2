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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF1A73E8), // primaryBlue
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1A73E8), // primaryBlue
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
            dialogBackgroundColor: Colors.white,
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
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF1A73E8), // primaryBlue
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1A73E8), // primaryBlue
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
            dialogBackgroundColor: Colors.white,
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
    return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
  }

  String _formatTime(TimeOfDay time) {
    return time.format(context);
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF1A73E8);
    const Color darkBlue = Color(0xFF0D47A1);
    const Color whiteColor = Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pilih Waktu Keberangkatan',
          style: TextStyle(
            color: whiteColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: primaryBlue,
        elevation: 0,
        iconTheme: const IconThemeData(color: whiteColor),
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.destinasi.nama,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: darkBlue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.destinasi.lokasi,
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                    const Divider(height: 24),
                    Text(
                      'Harga: ${NumberFormat.currency(
                        locale: 'id_ID',
                        symbol: 'Rp ',
                        decimalDigits: 0,
                      ).format(widget.destinasi.harga)} / orang',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
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
            ),
            const SizedBox(height: 16),
            _buildSelectionCard(
              icon: Icons.access_time,
              title: 'Pilih Waktu',
              value: _selectedTime == null
                  ? 'Belum dipilih'
                  : _formatTime(_selectedTime!),
              onTap: () => _selectTime(context),
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
                backgroundColor: primaryBlue,
                foregroundColor: whiteColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              child: const Text(
                'Lanjutkan ke Pemilihan Kendaraan',
                style: TextStyle(
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
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF1A73E8), size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D47A1),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  size: 20, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}