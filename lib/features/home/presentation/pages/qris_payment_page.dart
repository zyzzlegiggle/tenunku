import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class QrisPaymentPage extends StatefulWidget {
  final double totalAmount;
  final String? qrisUrl; // Placeholder if passing from central/seller

  const QrisPaymentPage({super.key, required this.totalAmount, this.qrisUrl});

  @override
  State<QrisPaymentPage> createState() => _QrisPaymentPageState();
}

class _QrisPaymentPageState extends State<QrisPaymentPage> {
  late DateTime _expiryTime;

  @override
  void initState() {
    super.initState();
    // Set expiry to 24 hours from now (or 23:59 if meant by end of day)
    // For demo, we are setting it +24 hours
    _expiryTime = DateTime.now().add(const Duration(hours: 24));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF54B7C2), // Cyan Blue header
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Optional: You could navigate home here or pop
            context.go('/buyer');
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lakukan Pembayaran',
              style: GoogleFonts.poppins(fontSize: 18, color: Colors.black),
            ),
            const SizedBox(height: 8),
            Text(
              'Produk Akan Segera di Proses Setelah Anda Melakukan Pembayaran',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: const Color(0xFF757575),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: Color(0xFFE0E0E0)),
            const SizedBox(height: 16),
            Text(
              'Scan Kode Q-RIS',
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.black),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9D9D9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: widget.qrisUrl != null && widget.qrisUrl!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              widget.qrisUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.image,
                                color: Color(0xFF757575),
                                size: 50,
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.qr_code,
                            color: Color(0xFF757575),
                            size: 80,
                          ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Total',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFF757575),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rp ${widget.totalAmount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF757575),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Batas Waktu:',
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.black),
                ),
                Text(
                  DateFormat('HH:mm').format(_expiryTime), // e.g 23:59
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.black),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
