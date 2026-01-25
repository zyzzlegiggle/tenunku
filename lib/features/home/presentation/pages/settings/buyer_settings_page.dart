import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../auth/data/repositories/auth_repository.dart';

class BuyerSettingsPage extends StatelessWidget {
  const BuyerSettingsPage({super.key});

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
          'Pengaturan',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                'Pengaturan Akun',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
            ),
            _buildSection([
              _buildMenuItem(
                context,
                'Akun & Keamanan',
                onTap: () => context.push('/buyer/settings/account-security'),
              ),
              const Divider(height: 1),
              _buildMenuItem(
                context,
                'Alamat Saya',
                onTap: () => context.push('/buyer/settings/address'),
              ),
              const Divider(height: 1),
              _buildMenuItem(
                context,
                'Bahasa',
                trailingText: 'Indonesia',
                onTap: () => context.push('/buyer/settings/language'),
              ),
            ]),
            const SizedBox(height: 24),
            _buildSection([
              _buildMenuItem(
                context,
                'Pusat Bantuan',
                onTap: () => context.push('/buyer/settings/help-center'),
              ),
              const Divider(height: 1),
              _buildMenuItem(
                context,
                'Pengaturan Notifikasi',
                onTap: () => context.push('/buyer/settings/notifications'),
              ),
            ]),
            const SizedBox(height: 24),
            _buildSection([
              _buildMenuItem(
                context,
                'Ganti Akun / Keluar',
                isLogOut: true,
                onTap: () {
                  AuthRepository().signOut();
                  context.go('/login');
                },
                icon: Icons.logout,
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title, {
    VoidCallback? onTap,
    String? trailingText,
    bool isLogOut = false,
    IconData? icon,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
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
              Icon(icon ?? Icons.logout, size: 20, color: Colors.black54)
            else
              const Icon(Icons.chevron_right, size: 20, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}
