import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../auth/data/repositories/auth_repository.dart';
import 'seller_settings_layout.dart';

class SellerSettingsPage extends StatelessWidget {
  const SellerSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SellerSettingsLayout(
      title: 'Pengaturan Akun',
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildSection([
              _buildMenuItem(
                context,
                'Akun & Keamanan',
                onTap: () => context.push('/seller/settings/account-security'),
              ),
              const Divider(height: 1, color: Color(0xFFF5793B)),
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
              const Divider(height: 1, color: Color(0xFFF5793B)),
              _buildMenuItem(
                context,
                'Pengaturan Notifikasi',
                onTap: () => context.push('/seller/settings/notifications'),
              ),
            ]),
            const SizedBox(height: 16),
            _buildSection([
              _buildMenuItem(
                context,
                'Ganti Akun / Keluar',
                isLogOut: true,
                onTap: () {
                  AuthRepository().signOut();
                  context.go('/login');
                },
              ),
            ]),
            const SizedBox(height: 120), // padding for bottom nav
          ],
        ),
      ),
    );
  }

  Widget _buildSection(List<Widget> children) {
    return Container(
      color: Colors.white,
      child: Column(children: children),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title, {
    VoidCallback? onTap,
    String? trailingText,
    bool isLogOut = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: isLogOut ? const Color(0xFFEAEAEA) : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: Colors.black87,
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
                    color: Colors.black54,
                  ),
                ),
              ),
            if (isLogOut)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.logout, size: 16, color: Colors.white),
              )
            else
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: Color(0xFF54B7C2),
              ),
          ],
        ),
      ),
    );
  }
}
