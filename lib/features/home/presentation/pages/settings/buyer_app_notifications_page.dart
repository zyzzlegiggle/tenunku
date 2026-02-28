import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/repositories/user_settings_repository.dart';

class BuyerAppNotificationsPage extends StatefulWidget {
  const BuyerAppNotificationsPage({super.key});

  @override
  State<BuyerAppNotificationsPage> createState() =>
      _BuyerAppNotificationsPageState();
}

class _BuyerAppNotificationsPageState extends State<BuyerAppNotificationsPage> {
  final UserSettingsRepository _settingsRepo = UserSettingsRepository();
  bool _isLoading = true;

  Map<String, dynamic> _settings = {
    'app': true,
    'app_sound': true,
    'orders': true,
    'chat': true,
  };

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      final settings = await _settingsRepo.getNotificationSettings(userId);
      if (mounted) {
        setState(() {
          _settings.addAll(settings);
          _isLoading = false;
        });
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateSetting(String key, bool value) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    setState(() {
      _settings[key] = value;
    });

    try {
      await _settingsRepo.saveNotificationSettings(userId, _settings);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menyimpan pengaturan')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const cyanBlue = Color(0xFF54B7C2);
    const yellow = Color(0xFFFFE14F);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: cyanBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: yellow),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Notifikasi di Aplikasi',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          color: const Color(0xFFF4F4F4),
                          child: Column(
                            children: [
                              _buildSwitchItem(
                                'Notifikasi di Aplikasi',
                                _settings['app'] ?? true,
                                (val) => _updateSetting('app', val),
                              ),
                              _buildDivider(),
                              Opacity(
                                opacity: (_settings['app'] ?? true) ? 1.0 : 0.5,
                                child: IgnorePointer(
                                  ignoring: !(_settings['app'] ?? true),
                                  child: Column(
                                    children: [
                                      _buildSwitchItem(
                                        'Bunyi Notifikasi',
                                        _settings['app_sound'] ?? true,
                                        (val) =>
                                            _updateSetting('app_sound', val),
                                      ),
                                      _buildDivider(),
                                      _buildSwitchItem(
                                        'Pesanan',
                                        _settings['orders'] ?? true,
                                        (val) => _updateSetting('orders', val),
                                      ),
                                      _buildDivider(),
                                      _buildSwitchItem(
                                        'Chat',
                                        _settings['chat'] ?? true,
                                        (val) => _updateSetting('chat', val),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: Container(
        color: cyanBlue,
        padding: const EdgeInsets.only(bottom: 16, top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(context, 'Beranda', 0, Icons.home),
            _buildNavItem(context, 'Telusuri', 1, Icons.search),
            _buildNavItem(context, 'Keranjang', 2, Icons.shopping_cart),
            _buildNavItem(context, 'Akun Saya', 3, Icons.person),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, thickness: 1, color: Color(0xFFF5793B));
  }

  Widget _buildSwitchItem(
    String label,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6B6B6B),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: const Color(0xFFF5793B), // orange track
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey[300],
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    String label,
    int index,
    IconData icon,
  ) {
    const yellow = Color(0xFFFFE14F);
    const navyBlue = Color(0xFF31476C);
    final bool isActiveStatus = index == 3;

    return GestureDetector(
      onTap: () {
        if (isActiveStatus) {
          context.pop();
        } else {
          context.go('/buyer', extra: index);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isActiveStatus ? yellow : navyBlue,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isActiveStatus ? navyBlue : Colors.grey[400],
              size: 26,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: Colors.white,
              fontWeight: isActiveStatus ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
