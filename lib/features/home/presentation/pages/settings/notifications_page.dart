import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'seller_settings_layout.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _appNotifications = true;
  bool _pesananMaster = true;
  bool _orderIncoming = false;
  bool _orderReceived = false;

  bool _obrolanMaster = true;
  bool _chatNewBuyer = false;
  bool _chatIncoming = false;

  bool _emailMaster = true;
  bool _emailOrderStatus = false;
  bool _emailOrderReceived = false;

  @override
  Widget build(BuildContext context) {
    return SellerSettingsLayout(
      title: 'Notifikasi di Aplikasi',
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  _buildMasterSwitch(
                    'Notifikasi di Aplikasi',
                    _appNotifications,
                    (v) => setState(() => _appNotifications = v),
                    isFirst: true,
                  ),
                  const SizedBox(height: 16),

                  // Pesanan Group
                  _buildMasterSwitch(
                    'Pesanan',
                    _pesananMaster,
                    (v) => setState(() {
                      _pesananMaster = v;
                      if (!v) {
                        _orderIncoming = false;
                        _orderReceived = false;
                      }
                    }),
                  ),
                  _buildChildSwitches([
                    _buildChildSwitch(
                      'Pesanan Masuk',
                      _orderIncoming,
                      (v) => setState(() => _orderIncoming = v),
                    ),
                    const SizedBox(height: 8),
                    _buildChildSwitch(
                      'Pesanan Diterima',
                      _orderReceived,
                      (v) => setState(() => _orderReceived = v),
                    ),
                  ]),
                  const SizedBox(height: 16),

                  // Obrolan Group
                  _buildMasterSwitch(
                    'Obrolan',
                    _obrolanMaster,
                    (v) => setState(() {
                      _obrolanMaster = v;
                      if (!v) {
                        _chatNewBuyer = false;
                        _chatIncoming = false;
                      }
                    }),
                  ),
                  _buildChildSwitches([
                    _buildChildSwitch(
                      'Obrolan Pembeli Baru',
                      _chatNewBuyer,
                      (v) => setState(() => _chatNewBuyer = v),
                    ),
                    const SizedBox(height: 8),
                    _buildChildSwitch(
                      'Pesan Masuk',
                      _chatIncoming,
                      (v) => setState(() => _chatIncoming = v),
                    ),
                  ]),
                  const SizedBox(height: 16),

                  // Email Group
                  _buildMasterSwitch(
                    'Email',
                    _emailMaster,
                    (v) => setState(() {
                      _emailMaster = v;
                      if (!v) {
                        _emailOrderStatus = false;
                        _emailOrderReceived = false;
                      }
                    }),
                  ),
                  _buildChildSwitches([
                    _buildChildSwitch(
                      'Status Pesanan',
                      _emailOrderStatus,
                      (v) => setState(() => _emailOrderStatus = v),
                    ),
                    const SizedBox(height: 8),
                    _buildChildSwitch(
                      'Pesanan Diterima',
                      _emailOrderReceived,
                      (v) => setState(() => _emailOrderReceived = v),
                    ),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 120), // Bottom nav padding
          ],
        ),
      ),
    );
  }

  Widget _buildMasterSwitch(
    String title,
    bool value,
    ValueChanged<bool> onChanged, {
    bool isFirst = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: const Color(0xFFF5793B),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey[300],
          ),
        ],
      ),
    );
  }

  Widget _buildChildSwitches(List<Widget> children) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFF0F0F0),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(children: children),
    );
  }

  Widget _buildChildSwitch(
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87),
          ),
          SizedBox(
            height: 32,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.white,
              activeTrackColor: const Color(0xFFF5793B),
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: const Color(
                0xFFDCDCDC,
              ), // Slightly darker grey for child switch
            ),
          ),
        ],
      ),
    );
  }
}
