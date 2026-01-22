import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _appNotifications = true;
  bool _orderIncoming = true;
  bool _orderReceived = true;
  bool _chatNewBuyer = true;
  bool _chatIncoming = true;
  bool _emailOrderStatus = true;
  bool _emailOrderReceived = true;

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
          'Notifikasi di Aplikasi',
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
            _buildSection(
              children: [
                _buildSwitchItem(
                  'Notifikasi di Aplikasi',
                  _appNotifications,
                  (val) => setState(() => _appNotifications = val),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: 'Pesanan',
              children: [
                _buildSwitchItem(
                  'Pesanan Masuk',
                  _orderIncoming,
                  (val) => setState(() => _orderIncoming = val),
                  showDivider: true,
                ),
                _buildSwitchItem(
                  'Pesanan Diterima',
                  _orderReceived,
                  (val) => setState(() => _orderReceived = val),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: 'Obrolan',
              children: [
                _buildSwitchItem(
                  'Obrolan Pembeli Baru',
                  _chatNewBuyer,
                  (val) => setState(() => _chatNewBuyer = val),
                  showDivider: true,
                ),
                _buildSwitchItem(
                  'Pesan Masuk',
                  _chatIncoming,
                  (val) => setState(() => _chatIncoming = val),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: 'Email',
              children: [
                _buildSwitchItem(
                  'Status Pesanan',
                  _emailOrderStatus,
                  (val) => setState(() => _emailOrderStatus = val),
                  showDivider: true,
                ),
                _buildSwitchItem(
                  'Pesanan Diterima',
                  _emailOrderReceived,
                  (val) => setState(() => _emailOrderReceived = val),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({String? title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5), // Light grey background
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
          ],
          ...children,
        ],
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
