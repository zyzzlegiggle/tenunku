import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../auth/data/repositories/auth_repository.dart';
import 'seller_settings_layout.dart';

class SellerSettingsPage extends StatefulWidget {
  const SellerSettingsPage({super.key});

  @override
  State<SellerSettingsPage> createState() => _SellerSettingsPageState();
}

class _SellerSettingsPageState extends State<SellerSettingsPage> {
  @override
  Widget build(BuildContext context) {
    const yellow = Color(0xFFFFE14F);
    const darkOrange = Color(0xFFF5793B);
    const navyBlue = Color(0xFF31476C);

    return SellerSettingsLayout(
      title: 'Pengaturan Akun',
      body: Column(
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
                      onTap: () =>
                          context.push('/seller/settings/account-security'),
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      context,
                      'Alamat Saya',
                      trailingText: 'Atur Sekarang',
                      onTap: () => context.push('/seller/settings/address'),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  _buildSection([
                    _buildMenuItem(
                      context,
                      'Pusat Bantuan',
                      onTap: () => context.push('/seller/settings/help-center'),
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      context,
                      'Pengaturan Notifikasi',
                      onTap: () =>
                          context.push('/seller/settings/notifications'),
                    ),
                  ]),
                  const SizedBox(height: 48),
                  // Logout section
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
}
