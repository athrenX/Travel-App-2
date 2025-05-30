import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:travelapp/models/destinasi.dart';
import 'package:travelapp/models/kendaraan.dart';
import 'package:travelapp/screens/user/pemesanan_screen.dart';

class PilihKursiScreen extends StatefulWidget {
  final Destinasi destinasi;
  final Kendaraan kendaraan;

  const PilihKursiScreen({
    super.key,
    required this.destinasi,
    required this.kendaraan,
  });

  @override
  State<PilihKursiScreen> createState() => _PilihKursiScreenState();
}

class _PilihKursiScreenState extends State<PilihKursiScreen> {
  List<int> selectedSeats = [];
  double totalPrice = 0.0;

  // Enhanced color scheme
  static const Color primaryColor = Color(0xFF3498DB);
  static const Color secondaryColor = Color(0xFFFF9800);
  static const Color darkColor = Color(0xFF2C3E50);
  static const Color lightColor = Color(0xFFF5F7FA);
  static const Color unavailableColor = Color(0xFFE74C3C);
  static const Color accentColor = Color(0xFF1ABC9C);

  @override
  void initState() {
    super.initState();
    totalPrice = widget.destinasi.harga.toDouble();
  }

  String formatRupiah(dynamic price) {
    try {
      double numericPrice = price is int ? price.toDouble() : price is double ? price : 0.0;
      final formatter = NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp',
        decimalDigits: 0,
      );
      return formatter.format(numericPrice);
    } catch (e) {
      return 'Rp 0';
    }
  }

  void _toggleSeat(int seatNumber) {
  setState(() {
    if (selectedSeats.contains(seatNumber)) {
      selectedSeats.remove(seatNumber);
      totalPrice -= widget.destinasi.harga; // Kurangi harga saat kursi di-unselect
    } else {
      selectedSeats.add(seatNumber);
      totalPrice += widget.destinasi.harga; // Tambahkan harga saat kursi dipilih
    }
  });
}

  Widget _buildSeat(int seatNumber, {bool isDriver = false, bool isAvailable = true}) {
    bool isSelected = selectedSeats.contains(seatNumber);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: 52,
      height: 52,
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isDriver
            ? Colors.grey[200]
            : isSelected
                ? primaryColor
                : isAvailable
                    ? lightColor
                    : unavailableColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDriver
              ? Colors.grey
              : isSelected
                  ? primaryColor
                  : isAvailable
                      ? Colors.grey[300]!
                      : unavailableColor,
          width: 2,
        ),
        boxShadow: [
          if (isSelected)
            BoxShadow(
              color: primaryColor.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isAvailable && !isDriver ? () => _toggleSeat(seatNumber) : null,
          borderRadius: BorderRadius.circular(10),
          splashColor: primaryColor.withOpacity(0.1),
          highlightColor: primaryColor.withOpacity(0.05),
          child: Center(
            child: isDriver
                ? const Icon(Icons.airline_seat_recline_extra, size: 28, color: darkColor)
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        seatNumber.toString(),
                        style: TextStyle(
                          color: isSelected ? Colors.white : darkColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Icon(
                        Icons.event_seat,
                        size: 20,
                        color: isSelected ? Colors.white : darkColor.withOpacity(0.7),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey[200]!,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: color == lightColor ? Colors.grey[300]! : color),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: darkColor.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightColor,
      appBar: AppBar(
        title: const Text(
          'Pilih Kursi',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: Column(
        children: [
          // Vehicle Info Card
          Container(
            margin: const EdgeInsets.fromLTRB(16, 20, 16, 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.directions_bus_rounded,
                          color: primaryColor,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.kendaraan.jenis,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: darkColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${widget.kendaraan.kapasitas} kursi · ${widget.kendaraan.tipe}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Harga per kursi',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatRupiah(widget.destinasi.harga),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: secondaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.chair_alt_outlined,
                              size: 18,
                              color: secondaryColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Kursi terpilih: ${selectedSeats.length}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: secondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Legend
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildLegendItem(primaryColor, 'Terpilih'),
                const SizedBox(width: 10),
                _buildLegendItem(lightColor, 'Tersedia'),
                const SizedBox(width: 10),
                _buildLegendItem(unavailableColor, 'Tidak tersedia'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Seat Selection Area
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Driver Area
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Area Pengemudi',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: darkColor.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Center(child: _buildSeat(0, isDriver: true)),
                        Container(
                          margin: const EdgeInsets.only(top: 16),
                          height: 1,
                          color: Colors.grey[300],
                        ),
                      ],
                    ),
                  ),
                  
                  // Passenger Seats
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                        ),
                        itemCount: widget.kendaraan.kapasitas,
                        itemBuilder: (context, index) {
                          int seatNumber = index + 1;
                          // Assume some seats are unavailable for demo purpose
                          bool isAvailable = seatNumber % 5 != 0;
                          return Center(child: _buildSeat(seatNumber, isAvailable: isAvailable));
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, -3),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Harga:',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatRupiah(totalPrice),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: darkColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: selectedSeats.isNotEmpty
                        ? () {
                            Navigator.push(
  context,
  MaterialPageRoute(
    builder: (ctx) => PemesananScreen(
      destinasi: widget.destinasi,
      kendaraan: widget.kendaraan,
      selectedSeats: selectedSeats, // Hanya kursi terpilih
      totalPrice: totalPrice.toInt(), // Total hanya dari kursi terpilih
    ),
  ),
);
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey[300],
                      elevation: selectedSeats.isNotEmpty ? 2 : 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'LANJUTKAN',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 20,
                          color: selectedSeats.isNotEmpty ? Colors.white : Colors.grey[400],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}