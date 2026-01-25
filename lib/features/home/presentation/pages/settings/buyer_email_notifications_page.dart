import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class BuyerEmailNotificationsPage extends StatefulWidget {
  const BuyerEmailNotificationsPage({super.key});

  @override
  State<BuyerEmailNotificationsPage> createState() =>
      _BuyerEmailNotificationsPageState();
}

class _BuyerEmailNotificationsPageState
    extends State<BuyerEmailNotificationsPage> {
  bool _emailNotifications = false;
  bool _statusPesanan = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Notifikasi Email',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          children: [
            // Main toggle section
            _buildSection(
              children: [
                _buildSwitchItem(
                  'Notifikasi Email',
                  _emailNotifications,
                  (val) => setState(() => _emailNotifications = val),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Sub notification toggles
            _buildSection(
              children: [
                _buildSwitchItem(
                  'Status Pesanan',
                  _statusPesanan,
                  (val) => setState(() => _statusPesanan = val),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildSwitchItem(
    String label,
    bool value,
    ValueChanged<bool> onChanged, {
    bool showDivider = false,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.grey[700],
              activeTrackColor: Colors.grey[300],
            ),
          ],
        ),
        if (showDivider)
          const Divider(height: 24, thickness: 1, color: Color(0xFFE0E0E0)),
      ],
    );
  }
}
