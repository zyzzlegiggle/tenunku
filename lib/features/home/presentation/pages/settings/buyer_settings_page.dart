import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../auth/data/repositories/auth_repository.dart';
import '../../../data/repositories/buyer_repository.dart';
import '../../../data/repositories/user_settings_repository.dart';

class BuyerSettingsPage extends StatefulWidget {
  const BuyerSettingsPage({super.key});

  @override
  State<BuyerSettingsPage> createState() => _BuyerSettingsPageState();
}

class _BuyerSettingsPageState extends State<BuyerSettingsPage> {
  final BuyerRepository _buyerRepo = BuyerRepository();
  final UserSettingsRepository _settingsRepo = UserSettingsRepository();

  bool _isLoading = true;
  String? _language;
  int _addressCount = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final addresses = await _buyerRepo.getAddresses(user.id);
      final language = await _settingsRepo.getLanguage(user.id);
      if (mounted) {
        setState(() {
          _addressCount = addresses.length;
          _language = language;
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
    const darkOrange = Color(0xFFF5793B);
    const navyBlue = Color(0xFF31476C);

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
          'Pengaturan Akun',
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
                        _buildSection([
                          _buildMenuItem(
                            context,
                            'Akun & Keamanan',
                            onTap: () => context.push(
                              '/buyer/settings/account-security',
                            ),
                          ),
                          _buildDivider(),
                          _buildMenuItem(
                            context,
                            'Alamat Saya',
                            trailingText: _addressCount > 0
                                ? '$_addressCount Alamat'
                                : 'Atur Sekarang',
                            onTap: () async {
                              await context.push('/buyer/settings/address');
                              _loadData(); // Reload after back
                            },
                          ),
                        ]),
                        const SizedBox(height: 16),
                        _buildSection([
                          _buildMenuItem(
                            context,
                            'Bahasa / Language',
                            trailingText: _language == 'id'
                                ? 'Indonesia'
                                : 'English',
                            onTap: () async {
                              await context.push('/buyer/settings/language');
                              _loadData(); // Reload after back
                            },
                          ),
                          _buildDivider(),
                          _buildMenuItem(
                            context,
                            'Pusat Bantuan',
                            onTap: () =>
                                context.push('/buyer/settings/help-center'),
                          ),
                          _buildDivider(),
                          _buildMenuItem(
                            context,
                            'Pengaturan Notifikasi',
                            onTap: () =>
                                context.push('/buyer/settings/notifications'),
                          ),
                        ]),
                        const SizedBox(height: 48), // push layout up logically
                        // Bottom part
                        Container(
                          width: double.infinity,
                          color: darkOrange,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 20,
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              AuthRepository().signOut();
                              context.go('/login');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: yellow,
                              foregroundColor: const Color(0xFF6B6B6B),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text(
                              'Ganti Akun / Keluar',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Image.asset(
                          'assets/logo.png',
                          width: 40,
                          height: 40,
                          color: navyBlue,
                        ),
                        const SizedBox(height: 30),
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

  Widget _buildSection(List<Widget> children) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF4F4F4),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, thickness: 1, color: Color(0xFFF5793B));
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title, {
    VoidCallback? onTap,
    String? trailingText,
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
            if (trailingText != null)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(
                  trailingText,
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
    final bool isActive = index == 3;

    return GestureDetector(
      onTap: () {
        if (isActive) {
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
              color: isActive ? yellow : navyBlue,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isActive ? navyBlue : Colors.grey[400],
              size: 26,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: Colors.white,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
