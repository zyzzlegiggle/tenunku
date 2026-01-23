import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class BuyerAccountSecurityPage extends StatelessWidget {
  const BuyerAccountSecurityPage({super.key});

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
          'Akun & Keamanan',
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
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildMenuItem(
                context,
                'Profil Saya',
                onTap: () {
                  // TODO: Navigate to profile editing
                },
              ),
              const Divider(height: 1),
              _buildMenuItem(
                context,
                'Username',
                trailingText: 'Atur Sekarang',
                onTap: () {
                  // TODO: Implement username editing
                },
              ),
              const Divider(height: 1),
              _buildMenuItem(
                context,
                'No. Handphone',
                trailingText: 'Atur Sekarang',
                onTap: () {
                  // TODO: Implement phone number editing
                },
              ),
              const Divider(height: 1),
              _buildMenuItem(
                context,
                'Email',
                trailingText: '**/**/****',
                onTap: () {
                  // TODO: Implement email editing
                },
              ),
              const Divider(height: 1),
              _buildMenuItem(
                context,
                'Ganti Password',
                onTap: () => context.push('/buyer/settings/change-password'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title, {
    VoidCallback? onTap,
    String? trailingText,
    Widget? trailing,
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
            if (trailing != null) trailing,
            if (trailing == null)
              const Icon(Icons.chevron_right, size: 20, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}
