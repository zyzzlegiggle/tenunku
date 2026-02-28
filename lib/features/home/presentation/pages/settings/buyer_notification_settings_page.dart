import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/repositories/user_settings_repository.dart';

class BuyerNotificationSettingsPage extends StatefulWidget {
  const BuyerNotificationSettingsPage({super.key});

  @override
  State<BuyerNotificationSettingsPage> createState() =>
      _BuyerNotificationSettingsPageState();
}

class _BuyerNotificationSettingsPageState
    extends State<BuyerNotificationSettingsPage> {
  final UserSettingsRepository _settingsRepo = UserSettingsRepository();
  bool _isLoading = true;
  Map<String, dynamic> _settings = {};

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
          _settings = settings;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
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
          'Pengaturan Notifikasi',
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
                              _buildMenuItem(
                                context,
                                'Notifikasi di Aplikasi',
                                isActive: _settings['app'] ?? true,
                                onTap: () async {
                                  await context.push(
                                    '/buyer/settings/notifications/app',
                                  );
                                  _loadSettings(); // Refresh status when backing out
                                },
                              ),
                              _buildDivider(),
                              _buildMenuItem(
                                context,
                                'Notifikasi Email',
                                isActive: _settings['email'] ?? true,
                                onTap: () async {
                                  await context.push(
                                    '/buyer/settings/notifications/email',
                                  );
                                  _loadSettings();
                                },
                              ),
                              _buildDivider(),
                              _buildMenuItem(
                                context,
                                'Notifikasi WhatsApp',
                                isActive: _settings['whatsapp'] ?? false,
                                onTap: () async {
                                  await context.push(
                                    '/buyer/settings/notifications/whatsapp',
                                  );
                                  _loadSettings();
                                },
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

  Widget _buildMenuItem(
    BuildContext context,
    String title, {
    required bool isActive,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6B6B6B),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(
                isActive ? 'Aktif' : 'Tidak Aktif',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, size: 24, color: Color(0xFF54B7C2)),
          ],
        ),
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
